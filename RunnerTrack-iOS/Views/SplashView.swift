import SwiftUI

// MARK: - Streak shape

private struct Streak: Shape {
    enum Kind { case top, middle, bottom }
    let kind: Kind

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / 1024
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * s, y: rect.minY + y * s)
        }
        var path = Path()
        switch kind {
        case .top:
            path.move(to: p(328, 640))
            path.addCurve(to: p(735, 198), control1: p(420, 470), control2: p(580, 290))
            path.addCurve(to: p(788, 242), control1: p(770, 182), control2: p(800, 212))
            path.addCurve(to: p(745, 275), control1: p(778, 262), control2: p(760, 268))
            path.addCurve(to: p(350, 650), control1: p(590, 345), control2: p(450, 490))
            path.addCurve(to: p(328, 640), control1: p(340, 658), control2: p(322, 652))
        case .middle:
            path.move(to: p(368, 695))
            path.addCurve(to: p(735, 425), control1: p(450, 590), control2: p(580, 460))
            path.addCurve(to: p(765, 475), control1: p(765, 420), control2: p(780, 450))
            path.addCurve(to: p(722, 490), control1: p(750, 485), control2: p(735, 485))
            path.addCurve(to: p(380, 708), control1: p(600, 520), control2: p(480, 610))
            path.addCurve(to: p(368, 695), control1: p(370, 715), control2: p(360, 705))
        case .bottom:
            path.move(to: p(385, 760))
            path.addCurve(to: p(665, 618), control1: p(480, 700), control2: p(580, 640))
            path.addCurve(to: p(698, 662), control1: p(695, 612), control2: p(710, 640))
            path.addCurve(to: p(660, 672), control1: p(690, 668), control2: p(675, 668))
            path.addCurve(to: p(395, 775), control1: p(580, 685), control2: p(490, 735))
            path.addCurve(to: p(385, 760), control1: p(382, 778), control2: p(376, 768))
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - IconMark

struct IconMark: View {
    var size: CGFloat = 220
    var onFinished: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dotVisible = false
    @State private var streakVisible = [false, false, false]

    private let kinds: [Streak.Kind] = [.top, .middle, .bottom]
    private let dotAnchor = UnitPoint(x: 257.0 / 1024, y: 770.0 / 1024)

    var body: some View {
        ZStack {
            Circle()
                .fill(DS.Colors.accent)
                .frame(width: size * 140 / 1024, height: size * 140 / 1024)
                .scaleEffect(dotVisible ? 1 : 0)
                .opacity(dotVisible ? 1 : 0)
                .position(x: size * 257 / 1024, y: size * 770 / 1024)

            ForEach(0..<3, id: \.self) { i in
                Streak(kind: kinds[i])
                    .fill(DS.Colors.accent)
                    .scaleEffect(streakVisible[i] ? 1 : 0.7, anchor: dotAnchor)
                    .offset(x: streakVisible[i] ? 0 : -size * 0.07,
                            y: streakVisible[i] ? 0 :  size * 0.07)
                    .opacity(streakVisible[i] ? 1 : 0)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
        .task { await play() }
    }

    private func play() async {
        if reduceMotion {
            dotVisible = true
            streakVisible = [true, true, true]
            onFinished?()
            return
        }

        withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
            dotVisible = true
        }

        for (step, index) in [2, 1, 0].enumerated() {
            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.5)
                .delay(0.45 + 0.15 * Double(step))) {
                streakVisible[index] = true
            }
        }

        try? await Task.sleep(for: .seconds(1.7))
        onFinished?()
    }
}

// MARK: - SplashView

struct SplashView: View {
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()
            IconMark(size: 220, onFinished: onFinished)
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView(onFinished: {})
        .preferredColorScheme(.dark)
}
