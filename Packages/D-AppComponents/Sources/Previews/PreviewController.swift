//
//  PreviewController.swift
//  AppComponents
//
//  Created by GIKI on 2025/1/20.
//

import UIKit
import QuickLook
import UIKit
import SDWebImage
import SDWebImageWebPCoder

// MARK: - PreviewFileType
public enum PreviewFileType {
    case image(ImageFormat)
    case pdf
    case text
    case audio
    case video
    case word
    case excel
    case powerPoint
    case other(String)
    
    // 图片格式枚举
    public enum ImageFormat {
        case jpeg
        case png
        case gif
        case webp
        case unknown
        
        var fileExtension: String {
            switch self {
            case .jpeg: return "jpg"
            case .png: return "png"
            case .gif: return "gif"
            case .webp: return "webp"
            case .unknown: return "jpg"
            }
        }
    }
    
    var fileExtension: String {
        switch self {
        case .image(let format): return format.fileExtension
        case .pdf: return "pdf"
        case .text: return "txt"
        case .audio: return "mp3"
        case .video: return "mp4"
        case .word: return "doc"
        case .excel: return "xls"
        case .powerPoint: return "ppt"
        case .other(let ext): return ext
        }
    }
}

// MARK: - PreviewController
public class PreviewController: QLPreviewController {
    
    private var previewItems: [PreviewItem] = []
    
    // MARK: - Initialization
    public convenience init(urls: [String], selectedIndex: Int = 0) {
        self.init()
        self.delegate = self
        self.dataSource = self
        self.currentPreviewItemIndex = selectedIndex
        self.previewItems = urls.map { PreviewItem(url: $0) }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        self.currentPreviewItem = currentPreviewItemIndex
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        // 自定义导航栏按钮
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissPreview)
        )
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func dismissPreview() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - QLPreviewControllerDataSource
extension PreviewController: QLPreviewControllerDataSource {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewItems.count
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItems[index]
    }
}

// MARK: - QLPreviewControllerDelegate
extension PreviewController: QLPreviewControllerDelegate {
    public func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
        return true
    }
    
    public func previewControllerDidDismiss(_ controller: QLPreviewController) {
        // 预览控制器关闭时的回调
    }
}

// MARK: - PreviewItem
public class PreviewItem: NSObject, QLPreviewItem {
    
    private var localURL: URL?
    private var remoteURL: URL?
    private var fileType: PreviewFileType
    private var downloadCompletion: ((Bool) -> Void)?
    
    public var previewItemURL: URL? {
        return localURL ?? remoteURL
    }
    
    public var previewItemTitle: String? {
        return remoteURL?.lastPathComponent
    }
    
    public init(url: String, fileType: PreviewFileType = .image(.unknown), completion: ((Bool) -> Void)? = nil) {
        self.fileType = fileType
        self.downloadCompletion = completion
        super.init()
        if let url = URL(string: url) {
            self.remoteURL = url
            if case .image = fileType {
                downloadImage(from: url)
            } else {
                downloadFile(from: url)
            }
        }
    }
    
    private func downloadImage(from url: URL) {
        let options: SDWebImageOptions = [
            .retryFailed,
            .refreshCached,
            .transformAnimatedImage
        ]
        
        SDWebImageManager.shared.loadImage(
            with: url,
            options: options,
            progress: nil
        ) { [weak self] (image, data, error, _, _, _) in
            guard let self = self,
                  error == nil,
                  let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                self?.downloadCompletion?(false)
                return
            }
            
            if let webpImage = image {
                let format = self.detectImageFormat(from: data)
                let fileName = self.generateImageFileName(format: format)
                let localURL = documentsPath.appendingPathComponent(fileName)
                
                do {
                    if FileManager.default.fileExists(atPath: localURL.path) {
                        try FileManager.default.removeItem(at: localURL)
                    }
                    
                    if case .webp = format {
                        if let pngData = webpImage.pngData() {
                            try pngData.write(to: localURL)
                        }
                    } else if let imageData = data {
                        try imageData.write(to: localURL)
                    }
                    
                    DispatchQueue.main.async {
                        self.localURL = localURL
                        self.downloadCompletion?(true)
                    }
                } catch {
                    print("Error saving image: \(error)")
                    self.downloadCompletion?(false)
                }
            }
        }
    }
    
    private func downloadFile(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                self?.downloadCompletion?(false)
                return
            }
            
            let fileName = "\(UUID().uuidString).\(self.fileType.fileExtension)"
            let localURL = documentsPath.appendingPathComponent(fileName)
            
            do {
                if FileManager.default.fileExists(atPath: localURL.path) {
                    try FileManager.default.removeItem(at: localURL)
                }
                
                try data.write(to: localURL)
                
                DispatchQueue.main.async {
                    self.localURL = localURL
                    self.downloadCompletion?(true)
                }
            } catch {
                print("Error saving file: \(error)")
                self.downloadCompletion?(false)
            }
        }.resume()
    }
    
    private func detectImageFormat(from data: Data?) -> PreviewFileType.ImageFormat {
        guard let data = data else { return .unknown }
        
        let firstBytes = data.prefix(4).map({ String(format: "%02hhx", $0) }).joined()
        switch firstBytes {
        case "ffd8ff": return .jpeg
        case "89504e47": return .png
        case "47494638": return .gif
        case "52494646": return .webp
        default: return .unknown
        }
    }

    
    private func generateImageFileName(format: PreviewFileType.ImageFormat) -> String {
        return "\(UUID().uuidString).\(format.fileExtension)"
    }
}

// MARK: - Convenience Initializers
public extension PreviewController {
    
    /// 创建图片预览控制器
    static func imagePreview(urls: [String], selectedIndex: Int = 0) -> PreviewController {
        // 确保 WebP 支持已启用
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        return PreviewController(urls: urls, selectedIndex: selectedIndex)
    }
    
    /// 创建PDF预览控制器
    static func pdfPreview(urls: [String], selectedIndex: Int = 0) -> PreviewController {
        let items = urls.map { PreviewItem(url: $0, fileType: .pdf) }
        let controller = PreviewController()
        controller.dataSource = controller
        controller.delegate = controller
        controller.previewItems = items
        controller.currentPreviewItemIndex = selectedIndex
        return controller
    }
    
    /// 创建文档预览控制器
    static func documentPreview(urls: [String], fileType: PreviewFileType, selectedIndex: Int = 0) -> PreviewController {
        let items = urls.map { PreviewItem(url: $0, fileType: fileType) }
        let controller = PreviewController()
        controller.dataSource = controller
        controller.delegate = controller
        controller.previewItems = items
        controller.currentPreviewItemIndex = selectedIndex
        return controller
    }
}

// MARK: - Cache Management
public extension PreviewController {
    
    /// 清除缓存
    static func clearCache() {
        guard let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: cachePath,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
}
