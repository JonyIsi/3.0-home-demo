# 3.0 home demo

这是一个 SwiftUI iOS 首页原型项目，包含自定义 TabBar 视觉样式、Unicorn Studio 动态 shader 背景、孕期进度卡片，以及随项目打包的图片、SVG 和字体资源。

## 项目概览

项目主界面使用系统 `TabView` 做底部导航，并在此基础上定制 TabBar 的颜色和图标状态。Home 页目前包含：

- 通过 `WKWebView` 渲染的本地 Unicorn Studio 场景
- 带渐进模糊效果的顶部工具栏
- 支持日期切换、拖拽手势、加载骨架屏和进度弧线的状态卡片
- 随包资源，包括图片、SVG 图标和自定义字体

`Device`、`Community` 和 `Me` 三个 Tab 目前仍是占位页面。

## 运行要求

- 支持 iOS 26.4 SDK 的 Xcode
- iPhone 或 iPad 模拟器/真机
- 首次解析 Swift Package 依赖，以及加载远程 Unicorn Studio 运行脚本时需要网络访问

## 依赖

项目通过 Swift Package Manager 管理依赖：

- `BlurUIKit` 1.5.0，来源：`https://github.com/TimOliver/BlurUIKit.git`

代码中同时使用了同一包提供的 `BlurSwiftUI`，用于实现可变模糊效果。

## 项目结构

```text
3.0 home demo/
├── 3.0 home demo.xcodeproj
├── 3.0 home demo/
│   ├── __0_home_demoApp.swift
│   ├── ContentView.swift
│   ├── AppTabBarStyle.swift
│   ├── Assets.xcassets/
│   ├── Denton-Regular.otf
│   └── unicorn-scene.json.txt
└── README.md
```

## 运行方式

1. 用 Xcode 打开 `3.0 home demo.xcodeproj`。
2. 等待 Xcode 完成 Swift Package Manager 依赖解析。
3. 选择一个 iOS 模拟器或已连接的真机。
4. 构建并运行 `3.0 home demo` scheme。

## 注意事项

- App 启动时会注册 `Denton-Regular.otf` 字体。
- shader 场景配置文件以 `unicorn-scene.json.txt` 的形式随包打包。
- Unicorn Studio 运行时脚本会在 `WKWebView` 内从 jsDelivr 加载；如果没有网络，动态 shader 可能无法显示。
- 当前 bundle identifier 是 `Jony.--0-home-demo`。
