//
//  AppTabBarStyle.swift
//  3.0 home demo
//
//  Created by Codex on 2026/5/5.
//

import SwiftUI
import UIKit

enum AppTabBarStyle {
    static let selectedColor = Color(hex: "#ffffff")

    static let selectedUIColor = UIColor(selectedColor)
    static let unselectedUIColor = UIColor(
        red: 255.0 / 255.0,
        green: 0.0 / 255.0,
        blue: 0.0 / 255.0,
        alpha: 1
    )

    static func configure() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        let selectedTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: selectedUIColor
        ]
        let unselectedTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: unselectedUIColor
        ]

        [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance]
            .forEach { itemAppearance in
                itemAppearance.selected.iconColor = selectedUIColor
                itemAppearance.selected.titleTextAttributes = selectedTitleAttributes
                itemAppearance.normal.iconColor = unselectedUIColor
                itemAppearance.normal.titleTextAttributes = unselectedTitleAttributes
            }

        UITabBar.appearance().tintColor = selectedUIColor
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = unselectedUIColor

        UITabBarItem.appearance().setTitleTextAttributes(selectedTitleAttributes, for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes(unselectedTitleAttributes, for: .normal)
    }

    static func apply(to tabBar: UITabBar) {
        configure()

        tabBar.tintColor = selectedUIColor
        tabBar.unselectedItemTintColor = unselectedUIColor
        tabBar.standardAppearance = UITabBar.appearance().standardAppearance
        tabBar.scrollEdgeAppearance = UITabBar.appearance().scrollEdgeAppearance

        tabBar.items?.forEach { item in
            item.image = item.image?.withRenderingMode(.alwaysTemplate)
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysTemplate)
            item.setTitleTextAttributes([.foregroundColor: selectedUIColor], for: .selected)
            item.setTitleTextAttributes([.foregroundColor: unselectedUIColor], for: .normal)
        }
    }
}

struct TabBarStyleAccessor: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        TabBarStyleViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        (uiViewController as? TabBarStyleViewController)?.applyStyle()
    }
}

private final class TabBarStyleViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyStyle()
    }

    func applyStyle() {
        DispatchQueue.main.async { [weak self] in
            guard let tabBar = self?.tabBarController?.tabBar else {
                return
            }

            AppTabBarStyle.apply(to: tabBar)
        }
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
