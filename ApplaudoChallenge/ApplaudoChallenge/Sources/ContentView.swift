import SwiftUI

private enum AppTab: Hashable {
    case breeds
    case myCats
    case addCat
}

public struct ContentView: View {
    @State private var selectedTab: AppTab = .breeds
    @State private var tabIDs: [AppTab: UUID] = [.breeds: UUID(), .addCat: UUID(), .myCats: UUID()]

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab 1: Cat List
            CatBreedView()
            .tabItem {
                Label(LocalizableKey.Tab.catBreeds, systemImage: "cat")
            }
            .id(tabIDs[.breeds])
            .tag(AppTab.breeds)

            // MARK: - Tab 2: Add Cat
            CatUploadView {
                selectedTab = .myCats
            }
            .tabItem {
                Label(LocalizableKey.Tab.addCat, systemImage: "plus.circle")
            }
            .id(tabIDs[.addCat])
            .tag(AppTab.addCat)
            
            // MARK: - Tab 3: My Cat
            MyCatsView {
                selectedTab = .addCat
            }
            .tabItem {
                Label(LocalizableKey.Tab.myCats, systemImage: "heart")
            }
            .id(tabIDs[.myCats])
            .tag(AppTab.myCats)
        }
        .tint(AppTheme.Colors.primary)
        .onChange(of: selectedTab) { _, newValue in
            tabIDs[newValue] = UUID()
        }
    }
}

#Preview {
    ContentView()
}
