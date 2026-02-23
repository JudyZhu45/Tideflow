import Foundation

struct EnergyScheduler {
    static func optimalHour(for task: EnergyTask, peakHour: Double,
                             existingTasks: [EnergyTask]) -> (hour: Double, reason: String) {
        let occupied = existingTasks.filter { $0.id != task.id && !$0.isCompleted }
            .map { (start: $0.scheduledHour, end: $0.scheduledHour + Double($0.durationMinutes) / 60.0) }
        let taskDuration = Double(task.durationMinutes) / 60.0
        var bestHour = 8.0, bestScore = -1.0
        for quarter in 0..<65 {
            let hour = 6.0 + Double(quarter) * 0.25
            let candidateEnd = hour + taskDuration
            guard candidateEnd <= 23.0 else { break }
            if occupied.contains(where: { candidateEnd > $0.start && hour < $0.end }) { continue }
            var score = 1.0 - abs(WaveMath.circadianEnergy(at: hour, peakHour: peakHour) - task.energyLevel.numericValue)
            if task.isUrgent { score += (22.0 - hour) / 16.0 * 0.3 }
            if score > bestScore { bestScore = score; bestHour = hour }
        }
        return (bestHour, generateReason(task: task, hour: bestHour, peakHour: peakHour))
    }

    static func wouldOverlap(_ task: EnergyTask, at hour: Double, with others: [EnergyTask]) -> Bool {
        let candidateEnd = hour + Double(task.durationMinutes) / 60.0
        return others.contains { other in
            guard other.id != task.id, !other.isCompleted else { return false }
            let otherEnd = other.scheduledHour + Double(other.durationMinutes) / 60.0
            return candidateEnd > other.scheduledHour && hour < otherEnd
        }
    }

    static func optimizeSchedule(tasks: [EnergyTask], peakHour: Double) -> [EnergyTask] {
        var sorted = tasks.sorted {
            if $0.isUrgent != $1.isUrgent { return $0.isUrgent }
            return $0.energyLevel.numericValue > $1.energyLevel.numericValue
        }
        var scheduled: [EnergyTask] = []
        for i in 0..<sorted.count {
            let r = optimalHour(for: sorted[i], peakHour: peakHour, existingTasks: scheduled)
            sorted[i].scheduledHour = r.hour; sorted[i].aiReason = r.reason
            scheduled.append(sorted[i])
        }
        return tasks.map { orig in scheduled.first { $0.id == orig.id } ?? orig }
    }

    private static func generateReason(task: EnergyTask, hour: Double, peakHour: Double) -> String {
        let energy = WaveMath.circadianEnergy(at: hour, peakHour: peakHour)
        let t = formatHour(hour)
        let urgentPrefix = task.isUrgent ? "🔥 Priority: " : ""
        switch task.energyLevel {
        case .high:
            return energy > 0.8 ? "\(urgentPrefix)\(task.name) at \(t) — your energy peaks here for maximum focus."
                                : "\(urgentPrefix)\(task.name) at \(t) — best available high-energy window."
        case .medium:
            return hour < 12 ? "\(urgentPrefix)\(task.name) at \(t) — riding the morning energy wave."
                             : "\(urgentPrefix)\(task.name) at \(t) — balanced energy for moderate tasks."
        case .low:
            return energy < 0.4 ? "\(urgentPrefix)\(task.name) at \(t) — energy dips here, perfect for lighter tasks."
                                : "\(urgentPrefix)\(task.name) at \(t) — saving peak energy for demanding work."
        }
    }

    private static func formatHour(_ hour: Double) -> String {
        let h = Int(hour), m = Int((hour - Double(h)) * 60)
        let p = h >= 12 ? "PM" : "AM", d = h > 12 ? h - 12 : (h == 0 ? 12 : h)
        return m == 0 ? "\(d) \(p)" : "\(d):\(String(format: "%02d", m)) \(p)"
    }
}
