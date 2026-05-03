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
private let unicornBackgroundColor = "#FAF7F1"

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
    var body: some View {
        GeometryReader { geometry in
            let shaderWidth = geometry.size.width

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    UnicornShaderView(sceneFileName: unicornSceneFileName)
                        .frame(width: shaderWidth, height: unicornShaderHeight)
                        .clipped()
                        .ignoresSafeArea(edges: .top)

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
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(red: 250.0 / 255.0, green: 247.0 / 255.0, blue: 241.0 / 255.0))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
