import Foundation
import SwiftUI

struct WaveMath {
    static func circadianEnergy(at hour: Double, peakHour: Double = 10.0,
                                 adjustment: ((Double) -> Double)? = nil) -> Double {
        let shift = peakHour - 10.0
        let morning = exp(-pow(hour - (10.0 + shift), 2) / 8.0)
        let dip = -0.3 * exp(-pow(hour - (14.0 + shift * 0.3), 2) / 4.0)
        let evening = 0.6 * exp(-pow(hour - (17.0 + shift * 0.2), 2) / 6.0)
        let decline = -0.4 * max(0, (hour - 19.0) / 4.0)
        let ramp = -0.3 * max(0, (8.0 - hour) / 3.0)
        let base = morning + dip + evening + decline + ramp
        let adj = adjustment?(hour) ?? 0
        return max(0.1, min(1.0, base + adj))
    }

    static func wavePath(in rect: CGRect, phase: Double, amplitude: Double = 1.0,
                          peakHour: Double = 10.0, layerOffset: Double = 0.0,
                          adjustment: ((Double) -> Double)? = nil) -> Path {
        var path = Path()
        let steps = 200
        for i in 0...steps {
            let frac = Double(i) / Double(steps)
            let hour = 6.0 + frac * 17.0
            let x = rect.minX + frac * rect.width
            let energy = circadianEnergy(at: hour, peakHour: peakHour, adjustment: adjustment)
            let ripple = sin(hour * 3.0 + phase * 2.0 + layerOffset) * 0.04
                       + sin(hour * 5.0 + phase * 1.5 + layerOffset * 2.0) * 0.02
            let y = rect.minY + (1.0 - (energy + ripple) * amplitude) * rect.height * 0.6 + rect.height * 0.15
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }

    static func waveY(hour: Double, in rect: CGRect, phase: Double,
                       amplitude: Double = 1.0, peakHour: Double = 10.0,
                       adjustment: ((Double) -> Double)? = nil) -> CGFloat {
        let energy = circadianEnergy(at: hour, peakHour: peakHour, adjustment: adjustment)
        let ripple = sin(hour * 3.0 + phase * 2.0) * 0.04 + sin(hour * 5.0 + phase * 1.5) * 0.02
        return rect.minY + (1.0 - (energy + ripple) * amplitude) * rect.height * 0.6 + rect.height * 0.15
    }

    static func waveX(hour: Double, in rect: CGRect) -> CGFloat {
        rect.minX + ((hour - 6.0) / 17.0) * rect.width
    }
}
