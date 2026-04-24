import SwiftUI

struct ChatDetailView: View {
    let conversationId: String
    let username: String
    @State private var messages: [ChatMessageItem] = ChatMessageItem.samples
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 0) {
            messageList
            inputBar
        }
        .background(Color.bgPrimary)
        .navigationTitle(username)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: .spaceMD) {
                    ForEach(messages) { msg in
                        ChatBubble(
                            message: msg.text,
                            isOwn: msg.isOwn,
                            time: msg.time,
                            showAvatar: !msg.isOwn,
                            senderName: username
                        )
                        .id(msg.id)
                    }
                }
                .padding(.vertical, .spaceSM)
            }
            .onChange(of: messages.count) { _, _ in
                if let lastId = messages.last?.id {
                    withAnimation(.appNormal) { proxy.scrollTo(lastId, anchor: .bottom) }
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: .spaceSM) {
            AppIconButton(iconName: "mic") {}
            TextField("输入消息...", text: $inputText)
                .font(.bodyMedium)
                .padding(.horizontal, .spaceMD)
                .frame(height: 40)
                .background(Color.bgTertiary)
                .clipShape(RoundedRectangle(cornerRadius: .radiusSM))
            if inputText.isEmpty {
                AppIconButton(iconName: "plus.circle") {}
            } else {
                AppIconButton(iconName: "arrow.up.circle.fill", tint: .brandPrimary) {
                    sendMessage()
                }
            }
        }
        .padding(.horizontal, .spaceLG)
        .padding(.vertical, .spaceSM)
        .background(Color.bgPrimary)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.dividerColor).frame(height: 0.5)
        }
    }

    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        messages.append(ChatMessageItem(
            id: UUID().uuidString,
            text: inputText,
            isOwn: true,
            time: "刚刚"
        ))
        inputText = ""
    }
}

struct ChatMessageItem: Identifiable {
    let id: String
    let text: String
    let isOwn: Bool
    let time: String

    static var samples: [ChatMessageItem] {
        [
            ChatMessageItem(id: "1", text: "你好，很高兴认识你！", isOwn: false, time: "10:00"),
            ChatMessageItem(id: "2", text: "你好！我也是", isOwn: true, time: "10:01"),
            ChatMessageItem(id: "3", text: "最近有什么有趣的动态吗？", isOwn: false, time: "10:02"),
            ChatMessageItem(id: "4", text: "有很多呢，你可以看看首页推荐", isOwn: true, time: "10:03"),
        ]
    }
}
