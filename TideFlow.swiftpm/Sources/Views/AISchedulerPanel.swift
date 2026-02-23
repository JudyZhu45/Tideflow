import SwiftUI

struct AISchedulerPanel: View {
    @Binding var tasks: [EnergyTask]
    let peakHour: Double
    @Binding var isShowingTips: Bool
    @State private var currentTipIndex = 0
    @State private var isOptimizing = false

    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(Color.white.opacity(0.3)).frame(width: 40, height: 4).padding(.top, 8)
            Text("AI Scheduler").font(.system(.headline, design: .rounded, weight: .bold)).foregroundColor(.white)
            if isShowingTips { tipsView } else { optimizeButton }
        }
        .padding(.horizontal, 20).padding(.bottom, 20).frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1)))
    }

    private var optimizeButton: some View {
        Button(action: {
            isOptimizing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    tasks = EnergyScheduler.optimizeSchedule(tasks: tasks, peakHour: peakHour)
                    isOptimizing = false; isShowingTips = true; currentTipIndex = 0
                }
            }
        }) {
            HStack(spacing: 8) {
                if isOptimizing { ProgressView().tint(Color(hex: "0A0E27")) } else { Text("🌊") }
                Text(isOptimizing ? "Optimizing..." : "AI Optimize Schedule")
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundColor(Color(hex: "0A0E27")).frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(LinearGradient(colors: [Color(hex: "00D4AA"), Color(hex: "7EB8D4")],
                                        startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }.disabled(isOptimizing)
    }

    private var tipsView: some View {
        VStack(spacing: 12) {
            let active = tasks.filter { !$0.isCompleted }
            if currentTipIndex < active.count {
                let task = active[currentTipIndex]
                HStack(spacing: 10) {
                    Text(task.emoji).font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.name).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundColor(.white)
                        Text(task.aiReason).font(.system(.caption, design: .rounded))
                            .foregroundColor(Color(hex: "00D4AA")).fixedSize(horizontal: false, vertical: true)
                    }
                }.padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                         removal: .move(edge: .leading).combined(with: .opacity))).id(task.id)
            }
            Button(currentTipIndex < tasks.filter({ !$0.isCompleted }).count - 1 ? "Next Tip →" : "Done") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if currentTipIndex < tasks.filter({ !$0.isCompleted }).count - 1 { currentTipIndex += 1 }
                    else { isShowingTips = false; currentTipIndex = 0 }
                }
            }.font(.system(.caption, design: .rounded, weight: .medium)).foregroundColor(Color(hex: "00D4AA"))
        }
    }
}
