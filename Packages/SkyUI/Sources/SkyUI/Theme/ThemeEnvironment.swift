import SwiftUI

extension EnvironmentValues {
    /// The look currently in use. Drives the sky and the globe together.
    @Entry public var theme: Theme = ThemeRegistry.standard.defaultTheme

    /// Every look the app offers, for the look picker.
    @Entry public var themeRegistry: ThemeRegistry = .standard
}

extension View {
    /// Applies a look to this view and everything below it.
    public func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }

    /// Replaces the set of looks offered below this view. Useful in previews and tests.
    public func themeRegistry(_ registry: ThemeRegistry) -> some View {
        environment(\.themeRegistry, registry)
    }
}
