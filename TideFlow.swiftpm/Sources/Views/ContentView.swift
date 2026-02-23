import SwiftUI

struct ContentView: View {
    @State private var isOnboardingComplete = false
    @State private var peakHour: Double = 10.0
    @State private var tasks: [EnergyTask] = EnergyTask.sampleTasks
    @State private var wavePhase: Double = 0
    @State private var expandedTaskID: UUID? = nil
    @State private var showAddTask = false
    @State private var showSchedulerPanel = false
    @State private var isShowingTips = false
    @State private var completionParticles: [(id: UUID, position: CGPoint, emoji: String)] = []
    @State private var draggedTaskID: UUID? = nil
    @State private var dragOffset: CGSize = .zero
    @AppStorage("hasSeenGestureHints") private var hasSeenGestureHints = false
    @State private var showGestureHints = false
    @State private var dragTargetHour: Double? = nil
    @State private var showCompletedTasks = false
    @State private var energyStore = EnergyStore()
    @State private var pendingCompletionTask: EnergyTask? = nil

    private var completionRatio: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter(\.isCompleted).count) / Double(tasks.count)
    }

    var body: some View {
        ZStack {
            Color(hex: "0A0E27").ignoresSafeArea()
            if isOnboardingComplete { mainView }
            else { OnboardingView(isOnboardingComplete: $isOnboardingComplete, peakHour: $peakHour) }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) { wavePhase = .pi * 2 }
        }
    }

    private var mainView: some View {
        GeometryReader { geo in
            let waveRect = CGRect(x: 0, y: 0, width: geo.size.width, height: geo.size.height * 0.65)
            ZStack {
                LinearGradient(colors: [Color(hex: "0A0E27"), Color(hex: "0D1B3E"), Color(hex: "0A0E27")],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                VStack(spacing: 0) {
                    headerView
                    TimelineView(.periodic(from: .now, by: 60)) { context in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: context.date)
                        let nowHour = Double(comps.hour ?? 12) + Double(comps.minute ?? 0) / 60.0
                        waveContent(nowHour: nowHour, waveRect: waveRect)
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    if showSchedulerPanel {
                        AISchedulerPanel(tasks: $tasks, peakHour: peakHour, isShowingTips: $isShowingTips)
                            .padding(.horizontal, 16).transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    bottomBar
                }
                if showGestureHints {
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { showGestureHints = false; hasSeenGestureHints = true }
                        }
                    GestureHintsOverlay(isVisible: $showGestureHints)
                        .onChange(of: showGestureHints) { newValue in
                            if !newValue { hasSeenGestureHints = true }
                        }
                }
            }
        }
        .onAppear {
            if !hasSeenGestureHints {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation { showGestureHints = true }
                }
            }
        }
    }

    @ViewBuilder
    private func waveContent(nowHour: Double, waveRect: CGRect) -> some View {
        ZStack {
            WaveCanvasView(phase: wavePhase, peakHour: peakHour, completionRatio: completionRatio, adjustment: energyStore.adjustment)
                .frame(height: waveRect.height)
            CurrentTimeIndicator(currentHour: nowHour)
                .frame(height: waveRect.height)
            TimeAxisView().padding(.horizontal, 16).offset(y: waveRect.height * 0.38)
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                if !task.isCompleted {
                    let x = WaveMath.waveX(hour: task.scheduledHour, in: waveRect)
                    let y = WaveMath.waveY(hour: task.scheduledHour, in: waveRect, phase: wavePhase, peakHour: peakHour, adjustment: energyStore.adjustment) + cardYOffset(for: task)
                    TaskCardView(task: task, isExpanded: expandedTaskID == task.id,
                        waveY: y, waveX: x + (draggedTaskID == task.id ? dragOffset.width : 0),
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                expandedTaskID = expandedTaskID == task.id ? nil : task.id
                            }
                        },
                        onDoubleTap: { pendingCompletionTask = task },
                        onDrag: { v in
                            draggedTaskID = task.id; dragOffset = v.translation
                            let newX = WaveMath.waveX(hour: task.scheduledHour, in: waveRect) + v.translation.width
                            let newHour = max(6.0, min(22.0, 6.0 + ((newX - waveRect.minX) / waveRect.width) * 17.0))
                            dragTargetHour = Double((newHour * 2).rounded() / 2)
                        },
                        onDragEnd: { v in dragTargetHour = nil; handleDragEnd(task: task, translation: v.translation, in: waveRect) },
                        dragTimeLabel: draggedTaskID == task.id ? dragTimeLabelText(in: waveRect) : nil,
                    )
                        
                }
            }
            ForEach(completionParticles, id: \.id) { p in
                CompletionParticlesView(position: p.position, emoji: p.emoji)
            }
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("TideFlow").font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: [Color(hex: "00D4AA"), Color(hex: "7EB8D4")],
                                                    startPoint: .leading, endPoint: .trailing))
                Text("\(tasks.filter(\.isCompleted).count)/\(tasks.count) tasks completed")
                    .font(.system(.caption, design: .rounded)).foregroundColor(.white.opacity(0.5))
            }
            Spacer()
            Button { showCompletedTasks = true } label: {
                Image(systemName: "checkmark.circle")
                    .font(.system(.body, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { showGestureHints = true }
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.system(.body, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            ZStack {
                Circle().stroke(Color.white.opacity(0.1), lineWidth: 3)
                Circle().trim(from: 0, to: completionRatio)
                    .stroke(Color(hex: "00D4AA"), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(completionRatio * 100))%").font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundColor(Color(hex: "00D4AA"))
            }.frame(width: 40, height: 40)
        }.padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 4)
    }

    private var bottomBar: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showSchedulerPanel.toggle()
                    if !showSchedulerPanel { isShowingTips = false }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(""); Text("AI Schedule").font(.system(.subheadline, design: .rounded, weight: .semibold))
                }
                .foregroundColor(showSchedulerPanel ? Color(hex: "0A0E27") : .white)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(showSchedulerPanel
                    ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "00D4AA"), Color(hex: "7EB8D4")],
                                                    startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color.white.opacity(0.1)))
                .clipShape(Capsule())
            }
            Spacer()
            Button { showAddTask = true } label: {
                Image(systemName: "plus").font(.system(.title3, weight: .bold)).foregroundColor(Color(hex: "0A0E27"))
                    .frame(width: 44, height: 44)
                    .background(LinearGradient(colors: [Color(hex: "00D4AA"), Color(hex: "7EB8D4")],
                                               startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Circle()).shadow(color: Color(hex: "00D4AA").opacity(0.4), radius: 8, y: 4)
            }
        }
        .padding(.horizontal, 20).padding(.bottom, 16)
        .sheet(isPresented: $showAddTask) {
            AddTaskView(isPresented: $showAddTask, peakHour: peakHour, existingTasks: tasks,
                        onAdd: { t in withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { tasks.append(t) } })
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showCompletedTasks) {
            CompletedTasksView(tasks: $tasks).presentationDetents([.medium, .large])
        }
        .sheet(item: $pendingCompletionTask) { task in
            EnergyRatingSheet(task: task) { rating in
                completeTask(task, rating: rating)
                pendingCompletionTask = nil
            }
            .presentationDetents([.height(280)])
        }
    }

    private func completeTask(_ task: EnergyTask, rating: Double) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let currentHour = Double(comps.hour ?? 12) + Double(comps.minute ?? 0) / 60.0
        energyStore.addReading(hour: currentHour, value: rating)

        guard let i = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        let x = WaveMath.waveX(hour: task.scheduledHour, in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.65))
        let y = WaveMath.waveY(hour: task.scheduledHour, in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.65), phase: wavePhase, peakHour: peakHour)
        let particle = (id: UUID(), position: CGPoint(x: x, y: y), emoji: task.emoji)
        completionParticles.append(particle)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            tasks[i].isCompleted = true
            expandedTaskID = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { completionParticles.removeAll { $0.id == particle.id } }
    }

    private func dragTimeLabelText(in rect: CGRect) -> String? {
        guard let hour = dragTargetHour else { return nil }
        let h = Int(hour), m = Int((hour - Double(h)) * 60)
        let p = h >= 12 ? "PM" : "AM"
        let d = h > 12 ? h - 12 : (h == 0 ? 12 : h)
        return m == 0 ? "\(d) \(p)" : "\(d):\(String(format: "%02d", m)) \(p)"
    }

    private func cardYOffset(for task: EnergyTask) -> CGFloat {
        let active = tasks.filter { !$0.isCompleted }.sorted { $0.scheduledHour < $1.scheduledHour }
        var cluster: [EnergyTask] = []
        for t in active {
            if abs(t.scheduledHour - task.scheduledHour) < 1.5 { cluster.append(t) }
        }
        guard cluster.count > 1, let idx = cluster.firstIndex(where: { $0.id == task.id }) else { return 0 }
        return CGFloat(idx) * -45.0
    }

    private func handleDragEnd(task: EnergyTask, translation: CGSize, in rect: CGRect) {
        guard let i = tasks.firstIndex(where: { $0.id == task.id }) else {
            draggedTaskID = nil; dragOffset = .zero; return
        }
        let newX = WaveMath.waveX(hour: task.scheduledHour, in: rect) + translation.width
        let newHour = max(6.0, min(22.0, 6.0 + ((newX - rect.minX) / rect.width) * 17.0))
        let snapped = (newHour * 2).rounded() / 2
        if EnergyScheduler.wouldOverlap(task, at: snapped, with: tasks) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                draggedTaskID = nil; dragOffset = .zero
            }
            return
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            tasks[i].scheduledHour = snapped
            tasks[i].aiReason = "Manually scheduled at \(tasks[i].formattedTime)."
            draggedTaskID = nil; dragOffset = .zero
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255,
                  blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
