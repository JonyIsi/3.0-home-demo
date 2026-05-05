//
//  __0_home_demoApp.swift
//  3.0 home demo
//
//  Created by 陈智健 on 2026/5/3.
//

import CoreText
import SwiftUI

@main
struct __0_home_demoApp: App {
    init() {
        FontRegistration.registerBundledFont(named: "Denton-Regular", withExtension: "otf")
        AppTabBarStyle.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private enum FontRegistration {
    static func registerBundledFont(named name: String, withExtension fileExtension: String) {
        guard let fontURL = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            return
        }

        _ = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
    }
}
