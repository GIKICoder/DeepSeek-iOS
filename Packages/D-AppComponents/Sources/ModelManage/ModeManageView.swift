import SwiftUI

struct ModelProvider: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let models: [String]
}

struct ModeManageView: View {
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
    
    var body: some View {
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
