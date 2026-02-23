import Foundation

enum EnergyLevel: String, CaseIterable, Codable {
    case low = "Low", medium = "Medium", high = "High"
    var emoji: String {
        switch self { case .low: return "🔵"; case .medium: return "🟡"; case .high: return "🔴" }
    }
    var numericValue: Double {
        switch self { case .low: return 0.3; case .medium: return 0.6; case .high: return 1.0 }
    }
}

struct EnergyTask: Identifiable {
    let id: UUID
    var name: String
    var emoji: String
    var energyLevel: EnergyLevel
    var durationMinutes: Int
    var scheduledHour: Double
    var aiReason: String
    var isCompleted: Bool
    var isUrgent: Bool
    init(id: UUID = UUID(), name: String, emoji: String, energyLevel: EnergyLevel,
         durationMinutes: Int, scheduledHour: Double = 8.0, aiReason: String = "",
         isCompleted: Bool = false, isUrgent: Bool = false) {
        self.id = id; self.name = name; self.emoji = emoji; self.energyLevel = energyLevel
        self.durationMinutes = durationMinutes; self.scheduledHour = scheduledHour
        self.aiReason = aiReason; self.isCompleted = isCompleted; self.isUrgent = isUrgent
    }
    var formattedTime: String {
        let hour = Int(scheduledHour), minute = Int((scheduledHour - Double(hour)) * 60)
        let period = hour >= 12 ? "PM" : "AM"
        let dh = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return minute == 0 ? "\(dh) \(period)" : "\(dh):\(String(format: "%02d", minute)) \(period)"
    }
    var durationFormatted: String {
        if durationMinutes >= 60 {
            let hrs = durationMinutes / 60, mins = durationMinutes % 60
            return mins > 0 ? "\(hrs)h \(mins)m" : "\(hrs)h"
        }
        return "\(durationMinutes)m"
    }
    static let sampleTasks: [EnergyTask] = [
        EnergyTask(name: "Deep Work", emoji: "🧠", energyLevel: .high, durationMinutes: 90,
                   scheduledHour: 10.0, aiReason: "Deep Work at 10 AM — your energy peaks here for maximum focus."),
        EnergyTask(name: "Team Meeting", emoji: "👥", energyLevel: .medium, durationMinutes: 60,
                   scheduledHour: 11.5, aiReason: "Team Meeting at 11:30 AM — riding the morning wave for collaboration."),
        EnergyTask(name: "Lunch Break", emoji: "🍽️", energyLevel: .low, durationMinutes: 45,
                   scheduledHour: 13.0, aiReason: "Lunch Break at 1 PM — energy dips here, perfect time to recharge."),
        EnergyTask(name: "Email & Admin", emoji: "📧", energyLevel: .low, durationMinutes: 30,
                   scheduledHour: 14.5, aiReason: "Email & Admin at 2:30 PM — low-energy tasks fit the afternoon dip."),
        EnergyTask(name: "Creative Review", emoji: "🎨", energyLevel: .medium, durationMinutes: 45,
                   scheduledHour: 17.0, aiReason: "Creative Review at 5 PM — catch the secondary energy peak."),
        EnergyTask(name: "Planning Tomorrow", emoji: "📋", energyLevel: .low, durationMinutes: 20,
                   scheduledHour: 20.0, aiReason: "Planning Tomorrow at 8 PM — wind down as energy fades.")
    ]
}
