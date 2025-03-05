//
//  DocumentPickerManager.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/1.
//
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

public class DocumentPickerManager: NSObject, UIDocumentPickerDelegate {
    
    // 单例模式
    static public let shared = DocumentPickerManager()
    
    
    // 防止外部创建实例
    private override init() {
        super.init()
    }
    
    // 用于存储回调的闭包
    private var completion: ((URL?) -> Void)?
    
    // 对外的主要调用方法
    public func openUploadFile(from viewController: UIViewController, completion: @escaping (URL?) -> Void) {
        self.completion = completion
        
        // 兼容性的文件类型定义
        let types: [String]
        if #available(iOS 14, *) {
            types = [
                UTType.pdf.identifier,
                "com.microsoft.word.doc",
                "com.microsoft.word.docx"
            ]
        } else {
            types = [
                kUTTypePDF as String,
                "com.microsoft.word.doc",
                "com.microsoft.word.docx"
            ]
        }
        
        // 创建文档选择器
        let documentPicker: UIDocumentPickerViewController
        if #available(iOS 14, *) {
            let contentTypes = types.compactMap { identifier -> UTType? in
                if identifier == UTType.pdf.identifier {
                    return .pdf
                } else if identifier == "com.microsoft.word.doc" {
                    return UTType(importedAs: "com.microsoft.word.doc")
                } else if identifier == "com.microsoft.word.docx" {
                    return UTType(importedAs: "com.microsoft.word.docx")
                }
                return nil
            }
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        } else {
            documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        }
        
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        viewController.present(documentPicker, animated: true)
        
        // 事件上报
        reportEvent("Newchatfile")
        reportEvent("NewchatEvent")
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            completion?(nil)
            return
        }
        completion?(fileURL)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion?(nil)
    }
    
    // MARK: - Private Methods
    
    private func reportEvent(_ eventName: String) {
        // 实现事件上报逻辑
        // Event_Report(eventName)
    }
    
}
