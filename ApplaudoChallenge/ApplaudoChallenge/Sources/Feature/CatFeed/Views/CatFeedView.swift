//
//  CatFeedView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI
import Combine

struct CatFeedView: View {
    let viewModel = CatFeedViewModel()
    
    var body: some View {
        NavigationStack {
            CatFeedListView(viewModel: viewModel)
                .font(AppTheme.Fonts.title)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .navigationTitle("Cats")
        }
    }
}

struct  CatFeedListView: View {
    let viewModel: CatFeedViewModel
    
    var body: some View {
        Text("Cat List")
    }
}

#Preview {
    CatFeedView()
}
