import SwiftUI

struct WaveCanvasView: View {
    let phase: Double
    let peakHour: Double
    let completionRatio: Double
    var adjustment: ((Double) -> Double)? = nil

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let path = WaveMath.wavePath(in: rect, phase: phase, amplitude: 1.0, peakHour: peakHour, layerOffset: 0.0, adjustment: adjustment)
            let colors: [Color] = [
                Color(hex: "1A6B8A").opacity(0.5),
                Color(hex: "00D4AA").opacity(0.5),
                Color(hex: "7EB8D4").opacity(0.5)
            ]
            context.fill(path, with: .linearGradient(Gradient(colors: colors),
                startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
        }
    }
}

struct CurrentTimeIndicator: View {
    let currentHour: Double

    private var isVisible: Bool {
        currentHour >= 6.0 && currentHour <= 22.0
    }

    private var timeLabel: String {
        let h = Int(currentHour)
        let m = Int((currentHour - Double(h)) * 60)
        let period = h >= 12 ? "PM" : "AM"
        let display = h > 12 ? h - 12 : (h == 0 ? 12 : h)
        return m == 0 ? "\(display) \(period)" : "\(display):\(String(format: "%02d", m)) \(period)"
    }

    var body: some View {
        if isVisible {
            GeometryReader { geo in
                let x = CGFloat(currentHour - 6.0) / 17.0 * geo.size.width
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    .stroke(Color(hex: "00D4AA").opacity(0.6),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))

                    VStack(spacing: 2) {
                        Text("NOW")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundColor(Color(hex: "00D4AA"))
                        Text(timeLabel)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(Color(hex: "00D4AA").opacity(0.7))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(hex: "0A0E27").opacity(0.8), in: RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "00D4AA").opacity(0.3), lineWidth: 1))
                    .position(x: x, y: 16)
                }
            }
        }
    }
}

struct TimeAxisView: View {
    var body: some View {
        GeometryReader { geo in
            ForEach([6,8,10,12,14,16,18,20,22], id: \.self) { hour in
                let x = CGFloat(hour - 6) / 17.0 * geo.size.width
                VStack(spacing: 2) {
                    Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 8)
                    Text({ let h = hour > 12 ? hour - 12 : hour; return "\(h)\(hour >= 12 ? "PM" : "AM")" }())
                        .font(.system(.caption2, design: .rounded)).foregroundColor(.white.opacity(0.4))
                }.position(x: x, y: geo.size.height / 2)
            }
        }.frame(height: 24)
    }
}
