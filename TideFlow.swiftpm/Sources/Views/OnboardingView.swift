import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @Binding var peakHour: Double
    @State private var currentPage = 0
    @State private var wavePhase: Double = 0

    var body: some View {
        ZStack {
            Color(hex: "0A0E27").ignoresSafeArea()
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                conceptPage.tag(1)
                personalizePage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) { wavePhase = .pi * 2 }
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("🌊").font(.system(size: 80))
            Text("TideFlow")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(LinearGradient(colors: [Color(hex: "00D4AA"), Color(hex: "7EB8D4")],
                                                startPoint: .leading, endPoint: .trailing))
            Text("Ride your energy. Plan your day.")
                .font(.system(.title3, design: .rounded)).foregroundColor(.white.opacity(0.7))
            Spacer()
            swipeHint
        }.padding()
    }

    private var conceptPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Your Energy Wave").font(.system(.title, design: .rounded, weight: .bold)).foregroundColor(.white)
            Text("Your energy rises and falls throughout the day like an ocean wave. TideFlow matches your tasks to your natural rhythm.")
                .font(.system(.body, design: .rounded)).foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center).padding(.horizontal, 32)
            Canvas { context, size in
                let path = WaveMath.wavePath(in: CGRect(origin: .zero, size: size), phase: wavePhase, amplitude: 0.8)
                context.fill(path, with: .linearGradient(
                    Gradient(colors: [Color(hex: "1A6B8A").opacity(0.6), Color(hex: "00D4AA").opacity(0.4), Color(hex: "7EB8D4").opacity(0.2)]),
                    startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
            }
            .frame(height: 120).padding(.horizontal, 24).clipShape(RoundedRectangle(cornerRadius: 12))
            HStack(spacing: 24) {
                ForEach([("🔴","High"),("🟡","Medium"),("🔵","Low")], id: \.0) { e, l in
                    VStack(spacing: 4) { Text(e).font(.title2); Text(l).font(.system(.caption, design: .rounded)).foregroundColor(.white.opacity(0.6)) }
                }
            }
            Spacer()
            swipeHint
        }.padding()
    }

    private var personalizePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Set Your Peak Hour").font(.system(.title, design: .rounded, weight: .bold)).foregroundColor(.white)
            Text("When do you feel most energized?").font(.system(.body, design: .rounded)).foregroundColor(.white.opacity(0.7))
            Text(peakHourFormatted).font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(Color(hex: "00D4AA")).padding(.top, 8)
            Slider(value: $peakHour, in: 6...18, step: 0.5).tint(Color(hex: "00D4AA")).padding(.horizontal, 40)
            HStack {
                Text("6 AM").font(.system(.caption, design: .rounded))
                Spacer()
                Text("6 PM").font(.system(.caption, design: .rounded))
            }.foregroundColor(.white.opacity(0.5)).padding(.horizontal, 40)
            Spacer()
            Button { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { isOnboardingComplete = true } } label: {
                Text("Start Planning").font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(Color(hex: "0A0E27")).frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: [Color(hex: "00D4AA"), Color(hex: "7EB8D4")],
                                               startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }.padding(.horizontal, 40).padding(.bottom, 40)
        }.padding()
    }

    private var swipeHint: some View {
        Text("Swipe to continue →").font(.system(.caption, design: .rounded))
            .foregroundColor(.white.opacity(0.4)).padding(.bottom, 40)
    }
    private var peakHourFormatted: String {
        let h = Int(peakHour), m = Int((peakHour - Double(h)) * 60)
        let p = h >= 12 ? "PM" : "AM", d = h > 12 ? h - 12 : h
        return m == 0 ? "\(d):00 \(p)" : "\(d):\(String(format: "%02d", m)) \(p)"
    }
}
