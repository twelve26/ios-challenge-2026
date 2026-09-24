import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        TabView {
            // MARK: - Tab 1: Cat List
            CatFeedView()
            .tabItem {
                Label("Cats", systemImage: "cat")
            }

            // MARK: - Tab 2: Add Cat
            CatFeedView()
            .tabItem {
                Label("Add Cat", systemImage: "plus.circle")
            }
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview {
    ContentView()
}
