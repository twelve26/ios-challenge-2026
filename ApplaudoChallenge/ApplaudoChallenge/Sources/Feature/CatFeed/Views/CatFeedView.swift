//
//  CatFeedView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

struct CatFeedView: View {
    var body: some View {
        NavigationStack {
            Text("Cat List")
                .font(AppTheme.Fonts.title)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .navigationTitle("Cats")
        }
    }
}

#Preview {
    CatFeedView()
}
