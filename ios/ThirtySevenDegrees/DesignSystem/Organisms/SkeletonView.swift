import SwiftUI

struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        Rectangle()
            .fill(Color.bgTertiary)
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.2), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: isAnimating ? geo.size.width : -geo.size.width)
                }
            }
            .clipped()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

struct FeedSkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: .spaceSM) {
                    SkeletonView()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: .spaceXS) {
                        SkeletonView().frame(height: 14).frame(maxWidth: 120)
                        SkeletonView().frame(height: 10).frame(maxWidth: 80)
                    }
                    Spacer()
                }
                .padding(.horizontal, .spaceLG)
                .padding(.vertical, .spaceSM)

                VStack(alignment: .leading, spacing: .spaceXS) {
                    SkeletonView().frame(height: 14)
                    GeometryReader { geo in
                        SkeletonView().frame(height: 14).frame(maxWidth: geo.size.width * 0.7)
                    }.frame(height: 14)
                }
                .padding(.horizontal, .spaceLG)
                .padding(.bottom, .spaceSM)

                SkeletonView()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: .radiusMD))
                    .padding(.horizontal, .spaceLG)
                    .padding(.bottom, .spaceSM)

                Divider()
            }
        }
    }
}
