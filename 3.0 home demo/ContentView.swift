//
//  ContentView.swift
//  3.0 home demo
//
//  Created by 陈智健 on 2026/5/3.
//

// BlurUIKit 是通过 Swift Package Manager 引入的第三方库：
// Xcode project 里添加了 https://github.com/TimOliver/BlurUIKit.git，
// 当前页面用它来做系统 Material 难以实现的“顶部强、向下渐隐”的可变模糊。
import BlurUIKit // 提供 VariableBlur 所需的参数类型，比如 .down、.relative、.constant。
import BlurSwiftUI // 提供 SwiftUI 版本的 VariableBlur 视图，可以直接写在 SwiftUI body 里。
import SwiftUI
import UIKit
import WebKit

private let unicornSceneFileName = "unicorn-scene.json.txt"
private let unicornShaderHeight = 680.0
private let unicornShaderGradientHeight = 180.0
private let unicornBackgroundColor = "#FAF7F1"
private let appPageBackground = Color(hex: "#F8F9FA")
private let headerBackground = Color(hex: "#FAF7F1")
private let homeStack2TopOffset = 136.0
private let progressArcVerticalOffset = -24
private let progressLabelCharacterSpacing = 0.4
private let progressViewHeight = 72.0
private let progressDesignWidth = 347.0
private let progressDesignHeight = 58.0
private let homeStackLoadingDuration = 1.0
private let homeStackSwipeThreshold = 50.0
private let homeToolbarProgressiveBlurHeight = 24
private enum AppTab: Hashable {
    case home
    case device
    case community
    case me
}

private enum HomeStackDirection {
    case previous
    case next
}

struct UnicornShaderView: UIViewRepresentable {
    let sceneFileName: String

    func makeUIView(context: Context) -> WKWebView {
        // 背景动画实现思路：
        // SwiftUI 本身不直接跑 Unicorn Studio 的 WebGL 动画，所以这里用 UIViewRepresentable
        // 把 UIKit 的 WKWebView 包进 SwiftUI，再让 WebView 加载一段本地 HTML。
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.websiteDataStore = .nonPersistent()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        // WebView 只负责显示动画，不参与页面滚动和点击，避免影响上层 SwiftUI 交互。
        webView.isOpaque = true
        webView.backgroundColor = UIColor(
            red: 250.0 / 255.0,
            green: 247.0 / 255.0,
            blue: 241.0 / 255.0,
            alpha: 1
        )
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isUserInteractionEnabled = false

        clearWebsiteData {
            // HTML 里引用本地的 unicorn-scene.json.txt，同时加载 UnicornStudio 的运行脚本；
            // 页面加载完成后调用 UnicornStudio.init()，WebGL 动画就在这个 WebView 内部运行。
            webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func clearWebsiteData(completion: @escaping () -> Void) {
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: .distantPast,
            completionHandler: completion
        )
    }

    private var html: String {
        let cacheBuster = UUID().uuidString

        // 这段 HTML 是 WebView 里的“动画舞台”：#scene 占满 WebView，
        // data-us-project-src 指向本地 shader 配置文件，脚本负责把配置渲染成 WebGL 动画。
        return """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
          <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
          <meta http-equiv="Pragma" content="no-cache">
          <meta http-equiv="Expires" content="0">
          <style>
            html, body {
              width: 100%;
              height: 100%;
              margin: 0;
              padding: 0;
              overflow: hidden;
              background: \(unicornBackgroundColor);
            }

            #scene {
              width: 100%;
              height: 100%;
            }
          </style>
          <!-- 这里开始加载 Unicorn Studio 的官方远程 SDK，不是本地文件；本地只提供 scene 配置。 -->
          <script src="https://cdn.jsdelivr.net/gh/hiunicornstudio/unicornstudio.js@v2.1.11/dist/unicornStudio.umd.js?v=\(cacheBuster)"></script>
        </head>
        <body>
          <div
            id="scene"
            data-us-project-src="\(sceneFileName)"
            data-us-scale="1"
            data-us-dpi="1"
            data-us-fps="30"
            data-us-production="false"
            data-us-disablemobile="true"
            data-us-alttext="Animated WebGL shader"
            data-us-arialabel="Decorative animated shader"
          ></div>

          <script>
            window.addEventListener("load", function () {
              if (window.UnicornStudio && window.UnicornStudio.init) {
                window.UnicornStudio.init();
              }
            });
          </script>
        </body>
        </html>
        """
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        // 底部导航：保留系统 TabView/TabBar 结构，保证页面切换和安全区处理稳定；
        // 视觉样式再通过 tab label 和 AppTabBarStyle 单独定制。
        TabView(selection: $selectedTab) {
            Tab(value: AppTab.home) {
                NavigationStack {
                    HomeView()
                }
            } label: {
                tabLabel("Home", image: "TabHome", tab: .home)
            }

            Tab(value: AppTab.device) {
                NavigationStack {
                    PlaceholderTabView()
                        .navigationTitle("Device")
                }
            } label: {
                tabLabel("Device", image: "TabDevice", tab: .device)
            }

            Tab(value: AppTab.community) {
                NavigationStack {
                    PlaceholderTabView()
                        .navigationTitle("Community")
                }
            } label: {
                tabLabel("Community", image: "TabCommunity", tab: .community)
            }

            Tab(value: AppTab.me) {
                NavigationStack {
                    PlaceholderTabView()
                        .navigationTitle("Me")
                }
            } label: {
                tabLabel("Me", image: "TabMe", tab: .me)
            }
        }
        .tint(AppTabBarStyle.selectedColor)
    }

    private func tabLabel(_ title: LocalizedStringKey, image: String, tab: AppTab) -> some View {
        Label {
            Text(title)
        } icon: {
            Image(uiImage: AppTabBarStyle.icon(named: image, isSelected: selectedTab == tab))
        }
    }
}

private struct HomeView: View {
    @State private var isHomeStackLoading = false

    var body: some View {
        GeometryReader { geometry in
            let shaderWidth = geometry.size.width

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        UnicornShaderContainer(width: shaderWidth)

                        HomeStack2View(
                            isLoading: isHomeStackLoading,
                            onPrevious: { switchHomeStack(direction: .previous) },
                            onNext: { switchHomeStack(direction: .next) }
                        )
                            .padding(.top, homeStack2TopOffset)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("3.0 Home Demo")
                            .font(.largeTitle.bold())

                        Text("Unicorn Studio WebGL shader is embedded at the top of this SwiftUI page.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 360, alignment: .topLeading)
                    .padding(24)
                }
                .frame(width: geometry.size.width, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(appPageBackground)
            .ignoresSafeArea(.container, edges: .top)
            .background(appPageBackground.ignoresSafeArea())
            .overlay(alignment: .top) {
                HomeToolbarBlurBackground()
                    // 实际模糊层高度 = 顶部安全区高度 + 自定义延伸高度。
                    // 安全区负责覆盖状态栏/刘海区域；homeToolbarProgressiveBlurHeight 负责控制往内容区延伸多远。
                    .frame(height: geometry.safeAreaInsets.top + CGFloat(homeToolbarProgressiveBlurHeight))
                    .ignoresSafeArea(.container, edges: .top)
                    .allowsHitTesting(false)
            }
            // 顶部导航：系统 toolbar 只负责承载内容和处理安全区位置；
            // 背后的滚动模糊改为自定义浅色 blur，避免系统 Scroll Edge 自动变深。
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HomeTopNavigationBar()
                        .frame(width: geometry.size.width)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func switchHomeStack(direction _: HomeStackDirection) {
        guard !isHomeStackLoading else {
            return
        }

        withAnimation(.easeInOut(duration: 0.18)) {
            isHomeStackLoading = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + homeStackLoadingDuration) {
            withAnimation(.easeInOut(duration: 0.22)) {
                isHomeStackLoading = false
            }
        }
    }
}

private struct HomeStack2View: View {
    let isLoading: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HomeStackDateView(
                isLoading: isLoading,
                onPrevious: onPrevious,
                onNext: onNext
            )

            Image("fruit")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .opacity(isLoading ? 0.28 : 1)
                .animation(.easeInOut(duration: 0.24), value: isLoading)

            VStack(spacing: 8) {
                if isLoading {
                    HomeSkeletonBar(width: 220, height: 32, cornerRadius: 8)
                } else {
                    Text("7 Weeks, 48 Days")
                        .font(.custom("Denton-Regular", size: 32))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                VStack(spacing: 8) {
                    if isLoading {
                        HomeSkeletonBar(width: 260, height: 16, cornerRadius: 6)
                    } else {
                        Text("Bonnie is as big as a Blueberry now")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }

                    if isLoading {
                        HomeSkeletonBar(width: 116, height: 12, cornerRadius: 5)
                    } else {
                        HStack(spacing: 10) {
                            Text("0.35 in")

                            Rectangle()
                                .frame(width: 1, height: 10)

                            Text("0.003 oz")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "#4E4E4E"))
                        .blendMode(.plusLighter)
                    }
                }
            }

            HomePregnancyProgressView(isLoading: isLoading)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 18)
                .onEnded { value in
                    handleSwipe(value.translation)
                }
        )
    }

    private func handleSwipe(_ translation: CGSize) {
        guard !isLoading else {
            return
        }

        let isHorizontalSwipe = abs(translation.width) > abs(translation.height) * 1.2
        guard isHorizontalSwipe, abs(translation.width) > homeStackSwipeThreshold else {
            return
        }

        if translation.width > 0 {
            onPrevious()
        } else {
            onNext()
        }
    }
}

private struct HomeStackDateView: View {
    let isLoading: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onPrevious) {
                Image("IconLeftChevren")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel("Previous date range")

            if isLoading {
                HomeSkeletonBar(width: 116, height: 16, cornerRadius: 6)
            } else {
                Text("Jan 10 - Jan 17")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            Button(action: onNext) {
                Image("IconRightChevren")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel("Next date range")
        }
        .frame(height: 20)
    }
}

private struct HomePregnancyProgressView: View {
    let isLoading: Bool

    var body: some View {
        ZStack(alignment: .top) {
            if isLoading {
                HomeProgressSkeletonView(verticalOffset: CGFloat(progressArcVerticalOffset))
            } else {
                HomeProgressCurvedLabelsView(verticalOffset: CGFloat(progressArcVerticalOffset))

                HomeProgressArcsView(verticalOffset: CGFloat(progressArcVerticalOffset))
            }
        }
        .frame(width: progressDesignWidth, height: progressViewHeight)
    }
}

private struct HomeProgressSkeletonView: View {
    let verticalOffset: CGFloat

    var body: some View {
        HomeProgressSkeletonArcs()
        .frame(width: progressDesignWidth, height: progressViewHeight)
        .offset(y: verticalOffset)
    }
}

private struct HomeProgressSkeletonArcs: View {
    var body: some View {
        ZStack(alignment: .top) {
            HomeProgressSegmentShape(
                start: CGPoint(x: 0, y: 8),
                control: CGPoint(x: 48, y: 25),
                end: CGPoint(x: 108, y: 34)
            )
                .stroke(Color.white.opacity(0.22), style: StrokeStyle(lineWidth: 7, lineCap: .round))

            HomeProgressSegmentShape(
                start: CGPoint(x: 118, y: 35),
                control: CGPoint(x: 172, y: 42),
                end: CGPoint(x: 232, y: 35)
            )
                .stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 7, lineCap: .round))

            HomeProgressSegmentShape(
                start: CGPoint(x: 242, y: 34),
                control: CGPoint(x: 300, y: 25),
                end: CGPoint(x: 347, y: 8)
            )
                .stroke(Color.white.opacity(0.16), style: StrokeStyle(lineWidth: 7, lineCap: .round))
        }
        .frame(width: progressDesignWidth, height: progressDesignHeight)
        .homeSkeletonShimmer()
    }
}

private struct HomeSkeletonBar: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white.opacity(0.2))
            .frame(width: width, height: height)
            .homeSkeletonShimmer()
    }
}

private struct HomeSkeletonShimmerModifier: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.5),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.7)
                    .offset(x: isAnimating ? geometry.size.width * 1.25 : -geometry.size.width * 0.8)
                }
                .blendMode(.plusLighter)
            }
            .mask(content)
            .onAppear {
                isAnimating = false

                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

private extension View {
    func homeSkeletonShimmer() -> some View {
        modifier(HomeSkeletonShimmerModifier())
    }
}

private struct HomeProgressCurvedLabelsView: View {
    private static let labelUIFont = UIFont.systemFont(ofSize: 12, weight: .medium)

    let verticalOffset: CGFloat

    var body: some View {
        Canvas { context, size in
            drawLabel(
                "Early State",
                centerT: 0.5,
                normalOffset: 16,
                start: CGPoint(x: 0, y: 8),
                control: CGPoint(x: 48, y: 25),
                end: CGPoint(x: 108, y: 34),
                in: size,
                context: &context
            )
            drawLabel(
                "Mid State",
                centerT: 0.50,
                normalOffset: 16,
                start: CGPoint(x: 118, y: 35),
                control: CGPoint(x: 172, y: 42),
                end: CGPoint(x: 232, y: 35),
                in: size,
                context: &context
            )
            drawLabel(
                "Late State",
                centerT: 0.5,
                normalOffset: 16,
                start: CGPoint(x: 242, y: 34),
                control: CGPoint(x: 300, y: 25),
                end: CGPoint(x: 347, y: 8),
                in: size,
                context: &context
            )
        }
        .frame(width: progressDesignWidth, height: progressViewHeight)
        .offset(y: verticalOffset)
    }

    private func drawLabel(
        _ label: String,
        centerT: CGFloat,
        normalOffset: CGFloat,
        start: CGPoint,
        control: CGPoint,
        end: CGPoint,
        in size: CGSize,
        context: inout GraphicsContext
    ) {
        let characters = Array(label)
        let advances = characters.map(characterAdvance)
        let totalAdvance = advances.reduce(0, +)
        let curveLength = approximateCurveLength(start: start, control: control, end: end, in: size)
        var currentAdvance: CGFloat = 0

        for index in characters.indices {
            let character = characters[index]
            let advance = advances[index]
            let centeredAdvance = currentAdvance + advance / 2 - totalAdvance / 2
            let targetLength = min(max(curveLength * centerT + centeredAdvance, 0), curveLength)
            let t = tForLength(targetLength, start: start, control: control, end: end, in: size)
            let curvePosition = pointOnQuadraticCurve(start: start, control: control, end: end, t: t, in: size)
            let tangent = tangentOnQuadraticCurve(start: start, control: control, end: end, t: t, in: size)
            let position = offsetPoint(curvePosition, tangent: tangent, distance: normalOffset)
            let angle = Angle(radians: atan2(tangent.y, tangent.x))

            var characterContext = context
            characterContext.translateBy(x: position.x, y: position.y)
            characterContext.rotate(by: angle)
            characterContext.draw(
                Text(String(character))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.68)),
                at: .zero,
                anchor: .center
            )
            currentAdvance += advance
        }
    }

    private func characterAdvance(_ character: Character) -> CGFloat {
        let width = String(character).size(withAttributes: [.font: Self.labelUIFont]).width

        return width + progressLabelCharacterSpacing
    }

    private func pointOnQuadraticCurve(
        start: CGPoint,
        control: CGPoint,
        end: CGPoint,
        t: CGFloat,
        in size: CGSize
    ) -> CGPoint {
        let scaleX = size.width / progressDesignWidth
        let scaleY = scaleX
        let oneMinusT = 1 - t

        return CGPoint(
            x: (oneMinusT * oneMinusT * start.x + 2 * oneMinusT * t * control.x + t * t * end.x) * scaleX,
            y: (oneMinusT * oneMinusT * start.y + 2 * oneMinusT * t * control.y + t * t * end.y) * scaleY
        )
    }

    private func tangentOnQuadraticCurve(
        start: CGPoint,
        control: CGPoint,
        end: CGPoint,
        t: CGFloat,
        in size: CGSize
    ) -> CGPoint {
        let scaleX = size.width / progressDesignWidth
        let scaleY = scaleX

        return CGPoint(
            x: (2 * (1 - t) * (control.x - start.x) + 2 * t * (end.x - control.x)) * scaleX,
            y: (2 * (1 - t) * (control.y - start.y) + 2 * t * (end.y - control.y)) * scaleY
        )
    }

    private func offsetPoint(_ point: CGPoint, tangent: CGPoint, distance: CGFloat) -> CGPoint {
        let length = max(sqrt(tangent.x * tangent.x + tangent.y * tangent.y), 0.001)
        let normal = CGPoint(x: -tangent.y / length, y: tangent.x / length)

        return CGPoint(
            x: point.x + normal.x * distance,
            y: point.y + normal.y * distance
        )
    }

    private func approximateCurveLength(
        start: CGPoint,
        control: CGPoint,
        end: CGPoint,
        in size: CGSize
    ) -> CGFloat {
        var length: CGFloat = 0
        var previousPoint = pointOnQuadraticCurve(start: start, control: control, end: end, t: 0, in: size)

        for step in 1...40 {
            let t = CGFloat(step) / 40
            let nextPoint = pointOnQuadraticCurve(start: start, control: control, end: end, t: t, in: size)
            length += distance(from: previousPoint, to: nextPoint)
            previousPoint = nextPoint
        }

        return length
    }

    private func tForLength(
        _ targetLength: CGFloat,
        start: CGPoint,
        control: CGPoint,
        end: CGPoint,
        in size: CGSize
    ) -> CGFloat {
        var walkedLength: CGFloat = 0
        var previousPoint = pointOnQuadraticCurve(start: start, control: control, end: end, t: 0, in: size)

        for step in 1...80 {
            let t = CGFloat(step) / 80
            let nextPoint = pointOnQuadraticCurve(start: start, control: control, end: end, t: t, in: size)
            let segmentLength = distance(from: previousPoint, to: nextPoint)

            if walkedLength + segmentLength >= targetLength {
                let segmentProgress = (targetLength - walkedLength) / max(segmentLength, 0.001)
                return (CGFloat(step - 1) + segmentProgress) / 80
            }

            walkedLength += segmentLength
            previousPoint = nextPoint
        }

        return 1
    }

    private func distance(from start: CGPoint, to end: CGPoint) -> CGFloat {
        let x = end.x - start.x
        let y = end.y - start.y

        return sqrt(x * x + y * y)
    }
}

private struct HomeProgressArcsView: View {
    let verticalOffset: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            HomeProgressSegmentShape(
                start: CGPoint(x: 0, y: 8),
                control: CGPoint(x: 48, y: 25),
                end: CGPoint(x: 108, y: 34)
            )
                .stroke(Color.white, style: StrokeStyle(lineWidth: 7, lineCap: .round))

            HomeProgressSegmentShape(
                start: CGPoint(x: 118, y: 35),
                control: CGPoint(x: 172, y: 42),
                end: CGPoint(x: 232, y: 35)
            )
                .stroke(Color(hex: "#1E1E1E"), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .blendMode(.plusLighter)

            HomeProgressSegmentShape(
                start: CGPoint(x: 242, y: 34),
                control: CGPoint(x: 300, y: 25),
                end: CGPoint(x: 347, y: 8)
            )
                .stroke(Color(hex: "#1E1E1E"), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .blendMode(.plusLighter)
        }
        .frame(width: progressDesignWidth, height: progressDesignHeight)
        .offset(y: verticalOffset)
    }
}

private struct HomeProgressSegmentShape: Shape {
    let start: CGPoint
    let control: CGPoint
    let end: CGPoint

    func path(in rect: CGRect) -> Path {
        let scaleX = rect.width / progressDesignWidth
        let scaleY = rect.height / progressDesignHeight

        var path = Path()
        path.move(to: CGPoint(x: start.x * scaleX, y: start.y * scaleY))
        path.addQuadCurve(
            to: CGPoint(x: end.x * scaleX, y: end.y * scaleY),
            control: CGPoint(x: control.x * scaleX, y: control.y * scaleY)
        )
        return path
    }
}

private struct UnicornShaderContainer: View {
    let width: CGFloat

    var body: some View {
        // 这个容器只负责 SwiftUI 层的摆放：固定 WebView 的尺寸，并在动画上叠加上下渐变，
        // 让 WebGL 背景和页面内容之间过渡更自然，不改 WebView 内部动画本身。
        UnicornShaderView(sceneFileName: unicornSceneFileName)
            .frame(width: width, height: unicornShaderHeight)
            .clipped()
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [
                        Color(hex: "#F8F4EE"),
                        Color(hex: "#F8F4EE", opacity: 0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: unicornShaderGradientHeight)
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        Color(hex: "#F8F9FA"),
                        Color(hex: "#F8F9FA", opacity: 0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: unicornShaderGradientHeight)
            }
    }
}

private struct HomeToolbarBlurBackground: View {
    var body: some View {
        ZStack {
            // 这一层是真正的“可变模糊”：BlurUIKit 会读取下方实时画面，
            // 按 direction 和渐变参数让模糊半径从一端逐渐变化到另一端。
            // 这里不用系统 topEdgeEffect，因为系统只给 automatic / soft / hard 三种预设，
            // 不能细调模糊半径、渐变起点、遮罩透明度。
            VariableBlur(direction: .down)
                // 最大模糊半径。数值越大，顶部最糊的地方越强。
                .maximumBlurRadius(8)
                // 模糊渐变起点。0.18 表示从高度的 18% 附近开始明显过渡。
                .blurStartingInset(.relative(fraction: 0.18))
                // BlurUIKit 自带的浅色遮罩颜色，用页面背景色避免顶部发黑。
                .dimmingTintColor(appPageBackground)
                // 自带浅色遮罩透明度。数值越大越白，越小越透明。
                .dimmingAlpha(.constant(alpha: 0.28))
                // 浅色遮罩的渐变起点，和 blurStartingInset 分开调。
                .dimmingStartingInset(.relative(fraction: 0.08))
                // 允许遮罩渐变稍微延伸到视图范围之外，减少底部硬边。
                .dimmingOvershoot(.relative(fraction: 1))
                // 这层只是视觉效果，不应该挡住下面的滚动和按钮点击。
                .passesTouchesThrough(true)

            // VariableBlur 会实时采样下面的内容；下面是紫色 shader 时，blur 会被染成紫灰色。
            // 这层固定浅色渐变负责把顶部遮罩稳定在页面默认浅色，不随滚动内容变暗。
            LinearGradient(
                stops: [
                    .init(color: headerBackground.opacity(1), location: 0),
                    .init(color: headerBackground.opacity(0.8), location: 0.36),
                    .init(color: headerBackground.opacity(0.24), location: 0.68),
                    .init(color: headerBackground.opacity(0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

private struct HomeTopNavigationBar: View {
    var body: some View {
        ZStack {
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image("NavAvatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())

                    HStack(spacing: 3) {
                        Text("Clare and Bonnie")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color(hex: "#1B1821"))

                        Image("IconTria")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                    }
                }
                .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Clare and Bonnie")

            HStack {
                Image("IconCalander")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 24, height: 24, alignment: .leading)
                    .accessibilityLabel("Calendar")

                Spacer()

                Image("IconBell")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 24, height: 24, alignment: .trailing)
                    .accessibilityLabel("Notifications")
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
    }
}

private struct PlaceholderTabView: View {
    var body: some View {
        appPageBackground
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
