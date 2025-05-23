import SwiftUI

public struct ModelProvider: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let models: [String]
}

public struct ModeManageView: View {
    @State private var selectedProvider: ModelProvider = providers[0]
    @State private var apiKey: String = ""
    @State private var selectedModel: String = providers[0].models[0]
    @State private var contextSize: Int = 2048
    @State private var temperature: Double = 0.7
    
    static let providers: [ModelProvider] = [
        ModelProvider(name: "OpenAI", models: ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo"]),
        ModelProvider(name: "DeepSeek", models: ["deepseek-chat", "deepseek-coder"]),
        ModelProvider(name: "Azure", models: ["azure-gpt-4", "azure-gpt-35"]),
        ModelProvider(name: "Google", models: ["gemini-pro", "gemini-ultra"])
    ]
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("模型管理")
                    .font(.largeTitle).bold()
                    .padding(.top, 32)
                
                // 供应商选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("模型供应商").font(.headline)
                    Picker("选择模型供应商", selection: $selectedProvider) {
                        ForEach(Self.providers) { provider in
                            Text(provider.name).tag(provider)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // API Key
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key").font(.headline)
                    SecureField("请输入API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // 模型选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("模型").font(.headline)
                    Picker("选择模型", selection: $selectedModel) {
                        ForEach(selectedProvider.models, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 高级设置
                VStack(alignment: .leading, spacing: 8) {
                    Text("高级设置").font(.headline)
                    HStack {
                        Text("上下文数量: ")
                        Stepper(value: $contextSize, in: 512...32768, step: 512) {
                            Text("\(contextSize)")
                        }
                    }
                    HStack {
                        Text("Temperature: ")
                        Slider(value: $temperature, in: 0...2, step: 0.01)
                        Text(String(format: "%.2f", temperature))
                            .frame(width: 48, alignment: .trailing)
                    }
                }
                
                // 保存按钮
                Button(action: {
                    // 保存逻辑
                }) {
                    Text("保存设置")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}


import UIKit

// MARK: - UIKit 包装器
public class ModelManageViewController: UIViewController {
    
    // 可选的回调闭包
    var onSave: ((ModelProvider, String, String, Int, Double) -> Void)?
    var onDismiss: (() -> Void)?
    
    private var hostingController: UIHostingController<ModeManageView>!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
        setupNavigationBar()
    }
    
    private func setupSwiftUIView() {
        let swiftUIView = ModeManageView()
        hostingController = UIHostingController(rootView: swiftUIView)
        
        // 添加为子视图控制器
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // 设置约束
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "模型管理"
        
        // 如果是模态展示，添加关闭按钮
        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(dismissTapped)
            )
        }
    }
    
    @objc private func dismissTapped() {
        onDismiss?()
        dismiss(animated: true)
    }
}

// MARK: - 便利的工厂方法
public extension ModelManageViewController {
    
    /// 创建一个包装在导航控制器中的模型管理视图控制器
    static func wrappedInNavigationController() -> UINavigationController {
        let modelVC = ModelManageViewController()
        let navController = UINavigationController(rootViewController: modelVC)
        return navController
    }
    
    /// 创建一个带有回调的模型管理视图控制器
    static func create(
        onSave: ((ModelProvider, String, String, Int, Double) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> ModelManageViewController {
        let controller = ModelManageViewController()
        controller.onSave = onSave
        controller.onDismiss = onDismiss
        return controller
    }
}

// MARK: - 使用示例
/*
// 在UIKit视图控制器中使用示例：

class MainViewController: UIViewController {
    
    @IBAction func showModelManage(_ sender: UIButton) {
        // 方式1: 直接推送到导航栈
        let modelVC = ModelManageViewController()
        navigationController?.pushViewController(modelVC, animated: true)
        
        // 方式2: 模态展示
        let modelVC2 = ModelManageViewController.create(
            onSave: { provider, apiKey, model, contextSize, temperature in
                print("保存设置: \(provider.name), \(model)")
                // 处理保存逻辑
            },
            onDismiss: {
                print("用户取消了设置")
            }
        )
        let navController = UINavigationController(rootViewController: modelVC2)
        present(navController, animated: true)
        
        // 方式3: 使用便利方法
        let wrappedVC = ModelManageViewController.wrappedInNavigationController()
        present(wrappedVC, animated: true)
    }
}
*/
