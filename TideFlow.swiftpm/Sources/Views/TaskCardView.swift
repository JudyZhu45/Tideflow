import SwiftUI

struct TaskCardView: View {
    let task: EnergyTask
    let isExpanded: Bool
    let waveY: CGFloat
    let waveX: CGFloat
    let onTap: () -> Void
    let onDoubleTap: () -> Void
    let onDrag: (DragGesture.Value) -> Void
    let onDragEnd: (DragGesture.Value) -> Void
    var dragTimeLabel: String? = nil
    @State private var bobOffset: CGFloat = 0

    private var energyColor: Color {
        switch task.energyLevel { case .high: return .red; case .medium: return .yellow; case .low: return .blue }
    }

    var body: some View {
        VStack(spacing: isExpanded ? 8 : 4) {
            HStack(spacing: 6) {
                Text(task.emoji).font(.system(size: isExpanded ? 24 : 18))
                if isExpanded {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.name).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundColor(.white)
                        Text(task.formattedTime).font(.system(.caption2, design: .rounded)).foregroundColor(.white.opacity(0.6))
                    }
                }
                Spacer(minLength: 0)
                if task.isUrgent { Text("🔥").font(.system(size: 12)) }
                Text(task.energyLevel.emoji).font(.system(size: 12))
            }
            if !isExpanded {
                Text(task.name).font(.system(.caption, design: .rounded, weight: .medium)).foregroundColor(.white).lineLimit(1)
            }
            if isExpanded {
                Divider().background(Color.white.opacity(0.2))
                HStack {
                    Label(task.durationFormatted, systemImage: "clock"); Spacer()
                    Text(task.energyLevel.rawValue).padding(.horizontal, 8).padding(.vertical, 2)
                        .background(energyColor.opacity(0.3)).clipShape(Capsule())
                }.font(.system(.caption, design: .rounded)).foregroundColor(.white.opacity(0.7))
                Text(task.aiReason).font(.system(.caption2, design: .rounded))
                    .foregroundColor(Color(hex: "00D4AA").opacity(0.8)).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(isExpanded ? 12 : 8)
        .frame(width: isExpanded ? 200 : 90)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(energyColor.opacity(0.3), lineWidth: 1))
        .overlay(alignment: .top) {
            if let label = dragTimeLabel {
                Text(label)
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundColor(Color(hex: "00D4AA"))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color(hex: "0A0E27").opacity(0.9), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "00D4AA").opacity(0.4), lineWidth: 1))
                    .offset(y: -28)
            }
        }
        .shadow(color: energyColor.opacity(0.2), radius: 8, y: 4)
        .opacity(task.isCompleted ? 0 : 1).scaleEffect(task.isCompleted ? 0.3 : 1)
        .position(x: waveX, y: waveY + bobOffset - (isExpanded ? 40 : 20))
        .onAppear {
            withAnimation(.easeInOut(duration: Double.random(in: 1.8...2.5)).repeatForever(autoreverses: true)) {
                bobOffset = CGFloat.random(in: -6...(-3))
            }
        }
        .onTapGesture(count: 2, perform: onDoubleTap)
        .onTapGesture(count: 1, perform: onTap)
        .gesture(DragGesture().onChanged(onDrag).onEnded(onDragEnd))
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: task.scheduledHour)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
    }
}

struct CompletionParticlesView: View {
    let position: CGPoint
    let emoji: String
    @State private var scattered = false
    private let angles: [Double] = (0..<12).map { _ in Double.random(in: 0...(2 * .pi)) }
    private let distances: [CGFloat] = (0..<12).map { _ in CGFloat.random(in: 30...80) }

    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Circle().fill(Color(hex: "00D4AA")).frame(width: 6, height: 6)
                    .scaleEffect(scattered ? 0.1 : 1).opacity(scattered ? 0 : 1)
                    .position(x: position.x + (scattered ? cos(angles[i]) * distances[i] : 0),
                              y: position.y + (scattered ? sin(angles[i]) * distances[i] : 0))
            }
            Text(emoji).font(.system(size: 24)).position(position)
                .scaleEffect(scattered ? 1.5 : 1).opacity(scattered ? 0 : 1)
        }
        .onAppear { withAnimation(.easeOut(duration: 1.0)) { scattered = true } }
    }
}
