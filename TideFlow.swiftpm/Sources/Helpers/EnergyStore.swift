import Foundation

struct EnergyReading: Codable {
    let hour: Double
    let value: Double
}

struct EnergyStore {
    private static let storageKey = "energyReadings"

    var readings: [EnergyReading] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
                  let decoded = try? JSONDecoder().decode([EnergyReading].self, from: data) else { return [] }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: Self.storageKey)
            }
        }
    }

    mutating func addReading(hour: Double, value: Double) {
        var current = readings
        current.append(EnergyReading(hour: hour, value: value))
        // Keep last 50 readings
        if current.count > 50 { current = Array(current.suffix(50)) }
        readings = current
    }

    func adjustment(at hour: Double) -> Double {
        let nearby = readings.filter { abs($0.hour - hour) < 1.5 }
        guard nearby.count >= 3 else { return 0 }
        var weightedSum = 0.0, weightTotal = 0.0
        for r in nearby {
            let dist = abs(r.hour - hour)
            let weight = 1.0 - dist / 1.5
            weightedSum += r.value * weight
            weightTotal += weight
        }
        let avgValue = weightedSum / weightTotal
        let baseEnergy = WaveMath.circadianEnergy(at: hour)
        let delta = (avgValue - baseEnergy) * 0.5
        return max(-0.3, min(0.3, delta))
    }
}
