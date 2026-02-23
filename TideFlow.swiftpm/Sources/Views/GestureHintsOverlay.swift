import SwiftUI

struct GestureHintsOverlay: View {
    @Binding var isVisible: Bool

    private let hints: [(icon: String, gesture: String, action: String)] = [
        ("hand.tap", "Tap", "Expand task details"),
        ("hand.tap.fill", "Double Tap", "Complete task"),
        ("arrow.left.and.right", "Drag", "Reschedule task on wave")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Quick Guide")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(.white)

            ForEach(Array(hints.enumerated()), id: \.offset) { _, hint in
                HStack(spacing: 14) {
                    Image(systemName: hint.icon)
                        .font(.system(.title3, weight: .medium))
                        .foregroundColor(Color(hex: "00D4AA"))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "00D4AA").opacity(0.15))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hint.gesture)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                        Text(hint.action)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
            }

            Button {
                withAnimation(.easeOut(duration: 0.25)) { isVisible = false }
            } label: {
                Text("Got it")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(Color(hex: "0A0E27"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [Color(hex: "00D4AA"), Color(hex: "7EB8D4")],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
        .padding(.horizontal, 40)
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}
