//
//  AppTabBarStyle.swift
//  3.0 home demo
//
//  Created by Codex on 2026/5/5.
//

import SwiftUI
import UIKit

enum AppTabBarStyle {
    static let selectedColor = Color(hex: "#1B1821")
    static let unselectedUIColor = UIColor(Color(hex: "#7B7881"))

    static func icon(named name: String, isSelected: Bool) -> UIImage {
        guard let image = UIImage(named: name) else {
            return UIImage()
        }

        if isSelected {
            return image.withRenderingMode(.alwaysTemplate)
        }

        return image.withTintColor(unselectedUIColor, renderingMode: .alwaysOriginal)
    }

    static func configure() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        let unselectedTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: unselectedUIColor
        ]

        [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance]
            .forEach { itemAppearance in
                itemAppearance.normal.titleTextAttributes = unselectedTitleAttributes
            }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension Color {
    init(hex: String, opacity: Double = 1) {
        let hexValue = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)

        self.init(
            red: Double((rgbValue >> 16) & 0xFF) / 255.0,
            green: Double((rgbValue >> 8) & 0xFF) / 255.0,
            blue: Double(rgbValue & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
