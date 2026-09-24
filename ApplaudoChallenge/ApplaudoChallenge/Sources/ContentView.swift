import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        TabView {
            // MARK: - Tab 1: Cat List
            CatBreedView()
            .tabItem {
                Label(LocalizableKey.Tab.catBreeds, systemImage: "cat")
            }
            
            // MARK: - Tab 2: My Cat
            MyCatsView()
            .tabItem {
                Label(LocalizableKey.Tab.myCats, systemImage: "heart")
            }

            // MARK: - Tab 2: Add Cat
            MyCatsView()
            .tabItem {
                Label(LocalizableKey.Tab.addCat, systemImage: "plus.circle")
            }
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview {
    ContentView()
}
