import SwiftUI

public struct ModelProviderV2: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let models: [String]
}

public struct ModeManageView: View {
    @State private var selectedProvider: ModelProviderV2 = providers[0]
    @State private var apiKey: String = ""
    @State private var selectedModel: String = providers[0].models[0]
    @State private var temperature: Double = 0.7
    @State private var topP: Double = 1.0
    @State private var contextMessageLimit: Double = 20
    @State private var showAdvancedSettings: Bool = false
    @State private var showProviderPicker: Bool = false
    @State private var showModelPicker: Bool = false
    
    @Namespace private var providerPickerNamespace
    @Namespace private var modelPickerNamespace
    
    static let providers: [ModelProviderV2] = [
        ModelProviderV2(name: "DeepSeek", models: ["deepseek-chat", "deepseek-coder"]),
        ModelProviderV2(name: "OpenAI", models: ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo"]),
        ModelProviderV2(name: "Azure", models: ["azure-gpt-4", "azure-gpt-35"]),
        ModelProviderV2(name: "Google", models: ["gemini-pro", "gemini-ultra"])
    ]
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 供应商选择
                VStack(alignment: .leading, spacing: 12) {
                    Text("模型供应商")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showProviderPicker.toggle()
                                if showProviderPicker {
                                    showModelPicker = false
                                }
                            }
                        }) {
                            HStack {
                                Text(selectedProvider.name)
                                    .foregroundColor(.primary)
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .medium))
                                    .rotationEffect(.degrees(showProviderPicker ? 180 : 0))
                                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showProviderPicker)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .cornerRadius(showProviderPicker ? 12 : 12, corners: showProviderPicker ? [.topLeft, .topRight] : .allCorners)
                            .overlay(
                                RoundedRectangle(cornerRadius: showProviderPicker ? 12 : 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                                    .cornerRadius(showProviderPicker ? 12 : 12, corners: showProviderPicker ? [.topLeft, .topRight] : .allCorners)
                            )
                        }
                        .matchedGeometryEffect(id: "providerButton", in: providerPickerNamespace)
                        
                        if showProviderPicker {
                            VStack(spacing: 0) {
                                ForEach(Array(Self.providers.enumerated()), id: \.element.id) { index, provider in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                            selectedProvider = provider
                                            selectedModel = provider.models[0]
                                            showProviderPicker = false
                                        }
                                    }) {
                                        HStack {
                                            Text(provider.name)
                                                .foregroundColor(.primary)
                                                .font(.body)
                                            Spacer()
                                            if selectedProvider.id == provider.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 16))
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            Color(.systemBackground)
                                                .opacity(selectedProvider.id == provider.id ? 0.1 : 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if index < Self.providers.count - 1 {
                                        Divider()
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                                    .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 1.0, anchor: .top)),
                                removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.98, anchor: .top))
                            ))
                            .matchedGeometryEffect(id: "providerOptions", in: providerPickerNamespace)
                        }
                    }
                    .zIndex(showProviderPicker ? 1 : 0)
                }
                
                // 添加间距，当供应商选择器展开时
                if showProviderPicker {
                    Spacer()
                        .frame(height: 16)
                        .transition(.opacity)
                }
                
                // API Key
                VStack(alignment: .leading, spacing: 12) {
                    Text("API Key")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    SecureField("请输入API Key", text: $apiKey)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // 模型选择
                VStack(alignment: .leading, spacing: 12) {
                    Text("模型")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showModelPicker.toggle()
                                if showModelPicker {
                                    showProviderPicker = false
                                }
                            }
                        }) {
                            HStack {
                                Text(selectedModel)
                                    .foregroundColor(.primary)
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .medium))
                                    .rotationEffect(.degrees(showModelPicker ? 180 : 0))
                                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showModelPicker)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .cornerRadius(showModelPicker ? 12 : 12, corners: showModelPicker ? [.topLeft, .topRight] : .allCorners)
                            .overlay(
                                RoundedRectangle(cornerRadius: showModelPicker ? 12 : 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                                    .cornerRadius(showModelPicker ? 12 : 12, corners: showModelPicker ? [.topLeft, .topRight] : .allCorners)
                            )
                        }
                        .matchedGeometryEffect(id: "modelButton", in: modelPickerNamespace)
                        
                        if showModelPicker {
                            VStack(spacing: 0) {
                                ForEach(Array(selectedProvider.models.enumerated()), id: \.element) { index, model in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                            selectedModel = model
                                            showModelPicker = false
                                        }
                                    }) {
                                        HStack {
                                            Text(model)
                                                .foregroundColor(.primary)
                                                .font(.body)
                                            Spacer()
                                            if selectedModel == model {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 16))
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            Color(.systemBackground)
                                                .opacity(selectedModel == model ? 0.1 : 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if index < selectedProvider.models.count - 1 {
                                        Divider()
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                                    .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 1.0, anchor: .top)),
                                removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.98, anchor: .top))
                            ))
                            .matchedGeometryEffect(id: "modelOptions", in: modelPickerNamespace)
                        }
                    }
                    .zIndex(showModelPicker ? 1 : 0)
                }
                
                // 添加间距，当模型选择器展开时
                if showModelPicker {
                    Spacer()
                        .frame(height: 16)
                        .transition(.opacity)
                }
                
                // 高级设置
                VStack(alignment: .leading, spacing: 16) {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showAdvancedSettings.toggle()
                        }
                    }) {
                        HStack {
                            Text("高级设置")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .medium))
                                .rotationEffect(.degrees(showAdvancedSettings ? 180 : 0))
                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showAdvancedSettings)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    
                    if showAdvancedSettings {
                        VStack(spacing: 24) {
                            // Temperature
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Temperature")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(String(format: "%.2f", temperature))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(6)
                                }
                                Slider(value: $temperature, in: 0...2, step: 0.01)
                                    .accentColor(.orange)
                            }
                            
                            // Top P
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Top P")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(String(format: "%.2f", topP))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(6)
                                }
                                Slider(value: $topP, in: 0...1, step: 0.01)
                                    .accentColor(.blue)
                            }
                            
                            // 上下文消息数量上限
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("上下文的消息数量上限")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(contextMessageLimit > 500 ? "无限制" : "\(Int(contextMessageLimit))")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(6)
                                }
                                Slider(value: $contextMessageLimit, in: 0...510, step: 1)
                                    .accentColor(.green)
                            }
                        }                        .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.98, anchor: .top)),
                                removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.98, anchor: .top))
                            ))
                    }
                }
                
                // 保存按钮
                Button(action: {
                    // 保存逻辑
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("保存设置")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                    .foregroundColor(.white)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: false)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showProviderPicker = false
                showModelPicker = false
            }
        }
    }
}

// 自定义按钮样式，添加按压效果
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// 扩展View以支持特定角的圆角
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ModeManageView()
}


