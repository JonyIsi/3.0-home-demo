//
//  ContentView.swift
//  3.0 home demo
//
//  Created by 陈智健 on 2026/5/3.
//

import SwiftUI
import WebKit

private let unicornSceneFileName = "unicorn-scene.json.txt"
private let unicornShaderHeight = 680.0
private let unicornShaderGradientHeight = 180.0
private let unicornBackgroundColor = "#FAF7F1"
private let appPageBackground = Color(hex: "#F8F9FA")
private let homeStack2TopOffset = 136.0
private let progressArcVerticalOffset = -24

private enum AppTab: Hashable {
    case home
    case device
    case community
    case me
}

struct UnicornShaderView: UIViewRepresentable {
    let sceneFileName: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.websiteDataStore = .nonPersistent()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: configuration)
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
    var body: some View {
        GeometryReader { geometry in
            let shaderWidth = geometry.size.width

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        UnicornShaderContainer(width: shaderWidth)

                        HomeStack2View()
                            .padding(.top, homeStack2TopOffset)
                            .allowsHitTesting(false)
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
            .scrollEdgeEffectStyle(.soft, for: .top)
            .background(appPageBackground)
            .ignoresSafeArea(.container, edges: .top)
            .background(appPageBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HomeTopNavigationBar()
                        .frame(width: geometry.size.width)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HomeStack2View: View {
    var body: some View {
        VStack(spacing: 0) {
            HomeStackDateView()

            Image("fruit")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)

            VStack(spacing: 8) {
                Text("7 Weeks, 48 Days")
                    .font(.custom("Denton-Regular", size: 32))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                VStack(spacing: 8) {
                    Text("Bonnie is as big as a Blueberry now")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)

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

            HomePregnancyProgressView()
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HomeStackDateView: View {
    var body: some View {
        HStack(spacing: 10) {
            Image("IconLeftChevren")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            Text("Jan 10 - Jan 17")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(1)

            Image("IconRightChevren")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
        .frame(height: 20)
    }
}

private struct HomePregnancyProgressView: View {
    var body: some View {
        ZStack(alignment: .top) {
            HomeProgressCurvedLabelsView(verticalOffset: CGFloat(progressArcVerticalOffset))

            HomeProgressArcsView(verticalOffset: CGFloat(progressArcVerticalOffset))
        }
        .frame(width: 347, height: 58)
    }
}

private struct HomeProgressCurvedLabelsView: View {
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
        .frame(width: 347, height: 58)
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
        character == " " ? 6 : 6
    }

    private func pointOnQuadraticCurve(
        start: CGPoint,
        control: CGPoint,
        end: CGPoint,
        t: CGFloat,
        in size: CGSize
    ) -> CGPoint {
        let scaleX = size.width / 347
        let scaleY = size.height / 58
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
        let scaleX = size.width / 347
        let scaleY = size.height / 58

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
        .offset(y: verticalOffset)
    }
}

private struct HomeProgressSegmentShape: Shape {
    let start: CGPoint
    let control: CGPoint
    let end: CGPoint

    func path(in rect: CGRect) -> Path {
        let scaleX = rect.width / 347
        let scaleY = rect.height / 58

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
