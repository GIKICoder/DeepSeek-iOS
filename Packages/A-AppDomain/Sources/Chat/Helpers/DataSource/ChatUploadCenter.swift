//
//  ChatUploadCenter.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/27.
//

import Foundation
import AppInfra
import AppFoundation
import ReerCodable
import AppServices
import UIKit
import CommonCrypto
import Combine
import Foundation


// MARK: - ChatUploadResult

public class ChatUploadResult {
    var uploadUrl: String?
    var md5: String?
    var fileName: String?
    var fileContentType: String?
    var uploadTime: Int?
    
    init(uploadUrl: String?, md5: String?, fileName: String?, fileContentType: String?, uploadTime: Int?) {
        self.uploadUrl = uploadUrl
        self.md5 = md5
        self.fileName = fileName
        self.fileContentType = fileContentType
        self.uploadTime = uploadTime
    }
}

// MARK: - UploadError

public enum UploadError: Error, LocalizedError {
    case imageCompressionFailed
    case imageResizingFailed
    case imageTooLarge
    case imageTooLargeAfterResizing
    case networkError(Error)
    case invalidResponse
    case unknown
    case uploadCancelled // 新增取消上传的错误
    
    public var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "Image compression failed."
        case .imageResizingFailed:
            return "Image resizing failed."
        case .imageTooLarge:
            return "The image size exceeds 20MB."
        case .imageTooLargeAfterResizing:
            return "The image still exceeds 20MB after resizing."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "The server returned an invalid response."
        case .unknown:
            return "An unknown error occurred."
        case .uploadCancelled:
            return "The upload was cancelled."
        }
    }
}

// MARK: - ChatUploadCenter

public actor ChatUploadCenter {
    
    public static let shared = ChatUploadCenter()
    
    private let uploadAPI = NetworkProvider<UploadApi>()
    private var cancellables = Set<AnyCancellable>()
    
    // Combine publishers for upload progress and completion
    public let uploadProgressPublisher = PassthroughSubject<(UUID, Double), Never>()
    // 输出 ChatUploadResult
    public let uploadCompletionPublisher = PassthroughSubject<(UUID, Result<ChatUploadResult, UploadError>), Never>()
    
    // 跟踪上传任务
    private var uploadTasks: [UUID: Task<Void, Never>] = [:]
    
    // 存储上传任务的详细信息
    private var uploadDetails: [UUID: (md5: String, fileName: String, fileContentType: String?)] = [:]
    
    private init() {}
    
    // MARK: - Publishers
    
    public var uploadProgressStream: AnyPublisher<(UUID, Double), Never> {
        return uploadProgressPublisher.eraseToAnyPublisher()
    }
    
    public var uploadCompletionStream: AnyPublisher<(UUID, Result<ChatUploadResult, UploadError>), Never> {
        return uploadCompletionPublisher.eraseToAnyPublisher()
    }
    
    // MARK: - Upload Methods
    
    /// 异步上传图片，并通过 Combine 发布进度和结果
    /// - Returns: 上传任务的唯一标识符
    public func uploadImage(with image: UIImage) -> UUID {
        let uploadID = UUID()
        let task = Task {
            await performUpload(id: uploadID, image: image)
        }
        uploadTasks[uploadID] = task
        return uploadID
    }
    
    /// 异步上传文件，并通过 Combine 发布进度和结果
    /// - Returns: 上传任务的唯一标识符
    public func uploadFile(with fileURL: URL) -> UUID {
        let uploadID = UUID()
        let task = Task {
            await performUpload(id: uploadID, fileURL: fileURL)
        }
        uploadTasks[uploadID] = task
        return uploadID
    }
    
    /// 异步上传图片，并返回 ChatUploadResult
    /// - Returns: 上传成功的 ChatUploadResult
    public func uploadImageWithResult(image: UIImage) async throws -> ChatUploadResult {
        let uploadID = uploadImage(with: image)
        let result = try await waitForUploadCompletion(id: uploadID)
        
        // 清理上传详情
        uploadDetails.removeValue(forKey: uploadID)
        
        switch result {
        case .success(let chatResult):
            return chatResult
        case .failure(let error):
            throw error
        }
    }
    
    /// 异步上传文件，并返回 ChatUploadResult
    /// - Returns: 上传成功的 ChatUploadResult
    public func uploadFileWithResult(fileURL: URL) async throws -> ChatUploadResult {
        let uploadID = uploadFile(with: fileURL)
        let result = try await waitForUploadCompletion(id: uploadID)
        
        // 清理上传详情
        uploadDetails.removeValue(forKey: uploadID)
        
        switch result {
        case .success(let chatResult):
            return chatResult
        case .failure(let error):
            throw error
        }
    }
    
    /// 取消指定的上传任务
    /// - Parameter id: 上传任务的唯一标识符
    public func cancelUpload(with id: UUID) {
        if let task = uploadTasks[id] {
            task.cancel()
            uploadTasks.removeValue(forKey: id)
            uploadCompletionPublisher.send((id, .failure(.uploadCancelled))) // 或者定义一个专门的取消错误
            logDebug("Upload with ID \(id) has been cancelled.")
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// 发送上传进度
    private func sendProgress(id: UUID, progress: Double) {
        uploadProgressPublisher.send((id, progress))
    }
    
    /// 发送上传完成状态
    private func sendCompletion(id: UUID, result: Result<ChatUploadResult, UploadError>) {
        uploadCompletionPublisher.send((id, result))
    }
    
    /// 等待上传完成并返回 ChatUploadResult
    private func waitForUploadCompletion(id: UUID) async throws -> Result<ChatUploadResult, UploadError> {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = uploadCompletionPublisher
                .filter { $0.0 == id }
                .sink { result in
                    continuation.resume(returning: result.1)
                    cancellable?.cancel()
                }
        }
    }
    
    /// 压缩图片到指定的最大文件大小
    private func compressImage(_ image: UIImage, toMaxFileSize maxFileSize: Int) throws -> Data {
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.4

        guard var imageData = image.jpegData(compressionQuality: compression) else {
            throw UploadError.imageCompressionFailed
        }

        // 首先尝试压缩质量
        while imageData.count > maxFileSize && compression > maxCompression {
            compression -= 0.1
            if let newData = image.jpegData(compressionQuality: compression) {
                imageData = newData
            } else {
                throw UploadError.imageCompressionFailed
            }
        }

        // 检查压缩后的大小
        if imageData.count > maxFileSize {
            throw UploadError.imageTooLarge
        }

        var count = 0
        // 修正：在这里添加 `guard` 关键字
        guard var compressedImage = UIImage(data: imageData) else {
            throw UploadError.imageCompressionFailed
        }

        // 如果仍然过大，尝试降低分辨率
        while count < 3 && imageData.count > maxFileSize &&
              compressedImage.size.width > 100 && compressedImage.size.height > 100 {
            count += 1
            let newSize = CGSize(width: compressedImage.size.width / 2,
                                 height: compressedImage.size.height / 2)
            
            guard let newImage = resizeImage(compressedImage, to: newSize) else {
                throw UploadError.imageResizingFailed
            }
            
            compressedImage = newImage
            if let newData = compressedImage.jpegData(compressionQuality: compression) {
                imageData = newData
            } else {
                throw UploadError.imageCompressionFailed
            }
        }

        if imageData.count > maxFileSize {
            throw UploadError.imageTooLargeAfterResizing
        }

        return imageData
    }
    
    /// 调整图片大小
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 生成数据的 MD5 哈希
    private func md5ForData(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        data.withUnsafeBytes { dataBytes in
            CC_MD5(dataBytes.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Upload File

extension ChatUploadCenter {
    
    /// 执行具体的上传逻辑（文件）
    private func performUpload(id: UUID, fileURL: URL) async {
        do {
            // 1. 读取data
            let data = try Data(contentsOf: fileURL)
            // 2. 生成文件签名
            let md5 = md5ForData(data)
            let bucket = AppEnvironment.isProduction ? "popai" : "popai-boe"
            let param = PresignedParams(bucket: bucket, md5: md5, contentType: nil)
            let signed: UploadSinged  = try await uploadAPI.requestAsync(.getPresignedPost(param))
            let uploadUrl = signed.url + signed.key
            
            // 获取文件名
            let fileName = fileURL.lastPathComponent
            
            // 存储上传详细信息
            uploadDetails[id] = (md5: md5, fileName: fileName, fileContentType: nil) // 根据需要设置 contentType
            
            // 3. 上传文件
            _ = try await uploadAPI.requestRawAsync(.uploadFileURL(fileURL: fileURL, signed: signed)) { [weak self] progress in
                guard let self = self else { return }
                logDebug("Upload Progress: \(progress.progress)")
                // 使用 Task 在异步上下文中调用 sendProgress
                Task {
                    await self.sendProgress(id: id, progress: progress.progress)
                }
            }
            logDebug("Upload succeeded for ID \(id)")
            // 创建 ChatUploadResult
            let chatResult = ChatUploadResult(
                uploadUrl: uploadUrl,
                md5: md5,
                fileName: fileName,
                fileContentType: nil, // 根据需要设置
                uploadTime: Int(Date().timeIntervalSince1970)
            )
            // 上传完成，发布成功结果
            sendCompletion(id: id, result: .success(chatResult))
        } catch let error as UploadError {
            // 已知的上传错误，发布失败结果
            let chatResult = ChatUploadResult(
                uploadUrl: nil,
                md5: uploadDetails[id]?.md5,
                fileName: uploadDetails[id]?.fileName,
                fileContentType: uploadDetails[id]?.fileContentType,
                uploadTime: Int(Date().timeIntervalSince1970)
            )
            sendCompletion(id: id, result: .success(chatResult)) // 即使失败也返回 ChatUploadResult
            uploadCompletionPublisher.send((id, .failure(error)))
            logError("Upload failed for ID \(id) with error: \(error.localizedDescription)")
        } catch {
            // 未知错误，发布失败结果
            let chatResult = ChatUploadResult(
                uploadUrl: nil,
                md5: uploadDetails[id]?.md5,
                fileName: uploadDetails[id]?.fileName,
                fileContentType: uploadDetails[id]?.fileContentType,
                uploadTime: Int(Date().timeIntervalSince1970)
            )
            sendCompletion(id: id, result: .failure(.unknown))
            logError("Upload failed for ID \(id) with unexpected error: \(error.localizedDescription)")
        }
        
        // 移除任务
        uploadTasks.removeValue(forKey: id)
    }
}

// MARK: - Upload Image

extension ChatUploadCenter {
    
    /// 执行具体的上传逻辑（图片）
    private func performUpload(id: UUID, image: UIImage) async {
        do {
            // 1. 压缩图片
            let compressedData = try compressImage(image, toMaxFileSize: 20 * 1024 * 1024)
            let sizeInMB = Double(compressedData.count) / (1024 * 1024)
            logDebug("Data size: \(String(format: "%.2f", sizeInMB)) MB")
            
            // 2. 生成图片签名
            let md5 = md5ForData(compressedData)
            let bucket = AppEnvironment.isProduction ? "popai-file" : "popai-file-boe"
            let param = PresignedParams(bucket: bucket, md5: md5, contentType: "image/jpeg")
            let signed: UploadSinged = try await uploadAPI.requestAsync(.getPresignedPost(param))
            let uploadUrl = signed.url + signed.key
            
            // 存储上传详细信息
            uploadDetails[id] = (md5: md5, fileName: signed.key, fileContentType: "image/jpeg")
            
            // 3. 上传图片数据
            _ = try await uploadAPI.requestRawAsync(.uploadData(data: compressedData, signed: signed)) { [weak self] progress in
                guard let self = self else { return }
                logDebug("Upload Progress: \(progress.progress)")
                // 使用 Task 在异步上下文中调用 sendProgress
                Task {
                    await self.sendProgress(id: id, progress: progress.progress)
                }
            }
            logDebug("Upload succeeded for ID \(id)")
            
            // 创建 ChatUploadResult
            let chatResult = ChatUploadResult(
                uploadUrl: uploadUrl,
                md5: md5,
                fileName: signed.key,
                fileContentType: "image/jpeg",
                uploadTime: Int(Date().timeIntervalSince1970)
            )
            
            // 上传完成，发布成功结果
            sendCompletion(id: id, result: .success(chatResult))
        } catch let error as UploadError {
            // 已知的上传错误，发布失败结果
            let chatResult = ChatUploadResult(
                uploadUrl: nil,
                md5: uploadDetails[id]?.md5,
                fileName: uploadDetails[id]?.fileName,
                fileContentType: uploadDetails[id]?.fileContentType,
                uploadTime: Int(Date().timeIntervalSince1970)
            )
            sendCompletion(id: id, result: .failure(error))
            logError("Upload failed for ID \(id) with error: \(error.localizedDescription)")
        } catch {
            // 未知错误，发布失败结果
            let chatResult = ChatUploadResult(
                uploadUrl: nil,
                md5: uploadDetails[id]?.md5,
                fileName: uploadDetails[id]?.fileName,
                fileContentType: uploadDetails[id]?.fileContentType,
                uploadTime: Int(Date().timeIntervalSince1970)
            )
            sendCompletion(id: id, result: .failure(.unknown))
            logError("Upload failed for ID \(id) with unexpected error: \(error.localizedDescription)")
        }
        
        // 移除任务
        uploadTasks.removeValue(forKey: id)
    }
}

// MARK: - Helper Functions

func logDebug(_ message: String) {
    print("DEBUG: \(message)")
}

func logError(_ message: String) {
    print("ERROR: \(message)")
}

// MARK: - Usage Example

/*
Task {
    do {
        let image = UIImage(named: "example.png")!
        let uploadResult = try await ChatUploadCenter.shared.uploadImageWithResult(image: image)
        print("Upload Success: \(uploadResult.uploadUrl ?? "")")
        // 处理 ChatUploadResult 的其他字段
        print("MD5: \(uploadResult.md5 ?? "")")
        print("File Name: \(uploadResult.fileName ?? "")")
        print("Content Type: \(uploadResult.fileContentType ?? "")")
        print("Upload Time: \(uploadResult.uploadTime ?? 0)")
    } catch {
        print("Upload Failed: \(error.localizedDescription)")
    }
}

*/
