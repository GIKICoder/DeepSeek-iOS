//
//  File.swift
//  AppDomain
//
//  Created by 巩柯 on 2025/6/4.
//

import Foundation
import UIKit
import AppInfra
import AppFoundation
import IQListKit
import AppServices
import AIProxy
import AppComponents

extension ChatViewController {
    /// 创建笔记
    func createNote(with selects: [ChatMessage]) {
        Task {
            do {
                try await createNoteAsync(with: selects)
            } catch {
                AppHUD.dismiss()
                AppHUD.showToast("创建笔记失败: \(error.localizedDescription)")
            }
        }
    }
    
    func createNoteAsync(with selects: [ChatMessage]) async throws {
        guard let activeDeepseek = ModelStorageManager.shared.getActiveConfiguration(for: .deepseek) else {
            AppHUD.dismiss()
            AppHUD.showToast("创建笔记失败")
            return
        }
        let deepSeekService = AIProxy.deepSeekDirectService(
            unprotectedAPIKey: activeDeepseek.apiKey
        )
        
        // System Prompt - 包含角色定义、任务说明和输出格式
        let systemPrompt = """
        # 对话整理与文档生成助手
        
        ## 你的角色
        你是一个专业的对话整理助手，擅长将对话历史转换为结构化的文档。
        
        ## 输出要求
        
        ### 1. 文档标题
        基于对话内容生成一个准确、简洁的标题（10-20字）
        
        ### 2. 文档正文
        请按以下格式整理：
        
        #### 2.1 背景概述
        - 简要说明对话的主题和背景（50-100字）
        
        #### 2.2 核心内容
        - 按照逻辑顺序整理对话要点
        - 使用分级标题组织内容
        - 保留关键信息，去除冗余内容
        - 适当补充上下文使内容连贯
        
        #### 2.3 关键要点
        - 用bullet points列出3-5个核心要点
        
        ### 3. 对话总结
        - 概括对话的主要内容（100-200字）
        - 说明对话的目的和成果
        - 指出任何未解决的问题或后续行动项
        
        ### 4. 元信息
        - 参与方：[列出对话参与者]
        - 对话轮次：[统计总轮次]
        - 主要话题：[提取1-3个关键词]
        
        ## 格式要求
        - 使用Markdown格式
        - 层级清晰，逻辑连贯
        - 专业术语保持一致
        - 重要信息加粗标注
        """
        
        // User Prompt - 包含具体的对话内容
        var userPrompt = """
                请将以下对话历史整理成一份结构化的文档：
                
                <conversation>
                """
        
        for select in selects {
            userPrompt += """
            \(select.aiMessage ? "assistant" : "user"): \(select.content ?? "")
            """
        }
        
        userPrompt += """
        </conversation>
        """
        
        // 创建请求
        let requestBody = DeepSeekChatCompletionRequestBody(
            messages: [
                .system(content: systemPrompt),
                .user(content: userPrompt)
            ],
            model: "deepseek-chat"
        )
        // 发送请求
        do {
            let response = try await deepSeekService.chatCompletionRequest(body: requestBody)
            print("\(response.choices.first?.message.content ?? "")")
            AppHUD.dismiss()
            if let note = response.choices.first?.message.content {
                showNote(note)
            } else {
                AppHUD.showToast("创建笔记失败")
            }
            if let usage = response.usage {
                print(
                        """
                        Used:
                         \(usage.completionTokens ?? 0) completion tokens
                         \(usage.completionTokensDetails?.reasoningTokens ?? 0) reasoning tokens
                         \(usage.promptCacheHitTokens ?? 0) prompt cache hit tokens
                         \(usage.promptCacheMissTokens ?? 0) prompt cache miss tokens
                         \(usage.promptTokens ?? 0) prompt tokens
                         \(usage.totalTokens ?? 0) total tokens
                        """
                )
            }
        } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
            print("Received non-200 status code: \(statusCode) with response body: \(responseBody)")
            AppHUD.dismiss()
            AppHUD.showToast("创建笔记失败")
        } catch {
            print("Could not get DeepSeek buffered chat completion: \(error.localizedDescription)")
            AppHUD.dismiss()
            AppHUD.showToast("创建笔记失败")
        }
    }
    
    @MainActor
    func showNote(_ note: String) {
        let note = NoteMarkdownController(markdown: note)
        self.navigationController?.pushViewController(note, animated: true)
    }
        
}

