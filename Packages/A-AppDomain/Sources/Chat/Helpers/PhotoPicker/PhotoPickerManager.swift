//
//  PhotoPickerManager.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/27.
//
//

import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers
import AppInfra
import AppFoundation

@MainActor
class PhotoPickerManager: NSObject {
    
    // MARK: - 类型别名
    typealias PhotoPickerCompletion = (UIImage?) -> Void
    
    // MARK: - 属性
    private var completion: PhotoPickerCompletion?
    private var shouldAnimateDismiss: Bool = true
    
    // MARK: - 初始化
    override init() {
        super.init()
    }
    
    // MARK: - 公共方法
    
    /// 配置是否在回调后自动关闭相册
    /// - Parameter animate: 是否有动画
    func configureDismissAnimation(animate: Bool) {
        self.shouldAnimateDismiss = animate
    }
    
    /// 显示操作选择器，选择相机或相册
    /// - Parameters:
    ///   - viewController: 用于展示的视图控制器
    ///   - completion: 选择图片后的回调
    func presentSelection(in viewController: UIViewController, completion: @escaping PhotoPickerCompletion) {
        self.completion = completion
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 相机选项
        alert.addAction(UIAlertAction(title: "Camera".localized, style: .default, handler: { [weak self] _ in
            self?.cameraAction(in: viewController)
        }))
        
        // 相册选项
        alert.addAction(UIAlertAction(title: "Album".localized, style: .default, handler: { [weak self] _ in
            self?.photoPickerAction(in: viewController)
        }))
        
        // 取消选项
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        
        // 对于 iPad，配置弹出样式
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func presentCamera(in viewController: UIViewController, completion: @escaping PhotoPickerCompletion) {
        self.completion = completion
        cameraAction(in: viewController)
    }
    
    func presentPhotoPicker(in viewController: UIViewController, completion: @escaping PhotoPickerCompletion) {
        self.completion = completion
        photoPickerAction(in: viewController)
    }
    
    // MARK: - 私有方法
    
    /// 相机操作
    private func cameraAction(in viewController: UIViewController) {
        PermissionHelper.checkCameraResult { [weak self] granted in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.openSystemCamera(in: viewController)
                } else {
                    AlertHelper.showCameraPermissionAlert(in: viewController)
                }
            }
        }
    }
    
    /// 打开系统相机
    private func openSystemCamera(in viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            AppHUD.showToast("The current device does not support the camera.".localized)
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .camera
        imagePickerController.mediaTypes = [UTType.image.identifier]
        imagePickerController.modalPresentationStyle = .fullScreen
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
    
    /// 打开图片选择器
    private func photoPickerAction(in viewController: UIViewController) {
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images
            let pickerViewController = PHPickerViewController(configuration: config)
            pickerViewController.delegate = self
            viewController.present(pickerViewController, animated: true, completion: nil)
        } else {
            // 使用 UIImagePickerController 处理 iOS 14 以下版本
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.modalPresentationStyle = .fullScreen
            viewController.present(imagePickerController, animated: shouldAnimateDismiss, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension PhotoPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        completion?(nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: shouldAnimateDismiss) { [weak self] in
            guard let self = self else { return }
            if let image = info[.originalImage] as? UIImage {
                self.completion?(image)
            } else {
                self.completion?(nil)
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14, *)
extension PhotoPickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: shouldAnimateDismiss) { [weak self] in
            guard let self = self else { return }
            guard let result = results.first else {
                self.completion?(nil)
                return
            }
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    DispatchQueue.main.async {
                        if let image = object as? UIImage {
                            self?.completion?(image)
                        } else {
                            self?.completion?(nil)
                        }
                    }
                }
            } else {
                self.completion?(nil)
            }
        }
    }
}

// PermissionHelper 用于处理权限检查的辅助类
class PermissionHelper {
    static func checkCameraResult(completion: @escaping (Bool) -> Void) {
        // 实现相机权限检查逻辑
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }
}

@MainActor
public class AlertHelper {
    
    static public func showAlbumPermissionAlert(in viewController: UIViewController?) {
        guard let viewController = viewController else { return }

        let alertController = UIAlertController(
            title: "Save to Photos".localized,
            message: "Allow us to save images to your photo library? Your memories, always accessible.".localized,
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: "Go to settings".localized, style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static public func showCameraPermissionAlert(in viewController: UIViewController?) {
        guard let viewController = viewController else { return }

        let alertController = UIAlertController(
            title: "Save to Photos".localized,
            message: "Camera access not granted, would you like to go to settings to enable camera permissions?".localized,
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: "Go to settings".localized, style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        viewController.present(alertController, animated: true, completion: nil)
    }
}
