import SwiftUI

struct CreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var selectedImages: [URL] = []
    @State private var location = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                textEditor
                mediaSection
                toolbar
                Spacer()
                publishButton
            }
            .background(Color.bgPrimary)
            .navigationTitle("发布动态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(.textSecondary)
                }
            }
        }
    }

    private var textEditor: some View {
        TextEditor(text: $text)
            .font(.bodyMedium)
            .foregroundStyle(.textPrimary)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 150)
            .padding(.horizontal, .spaceLG)
            .padding(.top, .spaceMD)
    }

    private var mediaSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: .spaceSM) {
                addMediaButton
                ForEach(selectedImages, id: \.self) { url in
                    AsyncImage(url: url)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: .radiusSM))
                }
            }
            .padding(.horizontal, .spaceLG)
        }
    }

    private var addMediaButton: some View {
        Button {} label: {
            RoundedRectangle(cornerRadius: .radiusSM)
                .fill(Color.bgTertiary)
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: "plus")
                        .font(.system(size: IconSize.lg.rawValue))
                        .foregroundStyle(.textTertiary)
                }
        }
    }

    private var toolbar: some View {
        HStack(spacing: .spaceXXXL) {
            toolbarButton(icon: "photo.on.rectangle", label: "相册")
            toolbarButton(icon: "camera", label: "拍照")
            toolbarButton(icon: "mic", label: "语音")
            toolbarButton(icon: "location", label: "位置")
        }
        .padding(.horizontal, .spaceLG)
        .padding(.vertical, .spaceMD)
    }

    private func toolbarButton(icon: String, label: String) -> some View {
        Button {} label: {
            VStack(spacing: .spaceXXS) {
                Image(systemName: icon)
                    .font(.system(size: IconSize.lg.rawValue))
                    .foregroundStyle(.textSecondary)
                Text(label)
                    .font(.captionSmall)
                    .foregroundStyle(.textTertiary)
            }
        }
    }

    private var publishButton: some View {
        AppButton(
            title: "发布",
            variant: .primary,
            size: .large,
            action: { dismiss() }
        )
        .padding(.horizontal, .spaceLG)
        .padding(.bottom, .spaceLG)
    }
}
