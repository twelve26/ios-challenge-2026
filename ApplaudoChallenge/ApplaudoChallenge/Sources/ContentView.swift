import SwiftUI

private enum AppTab: Hashable {
    case breeds
    case myCats
    case addCat
}

public struct ContentView: View {
    @State private var selectedTab: AppTab = .breeds

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab 1: Cat List
            CatBreedView()
            .tabItem {
                Label(LocalizableKey.Tab.catBreeds, systemImage: "cat")
            }
            .tag(AppTab.breeds)
            
            // MARK: - Tab 2: My Cat
            MyCatsView {
                selectedTab = .addCat
            }
            .tabItem {
                Label(LocalizableKey.Tab.myCats, systemImage: "heart")
            }
            .tag(AppTab.myCats)

            // MARK: - Tab 3: Add Cat
            CatUploadView()
            .tabItem {
                Label(LocalizableKey.Tab.addCat, systemImage: "plus.circle")
            }
            .tag(AppTab.addCat)
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview {
    ContentView()
}
