//
//  MyCatsView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

struct MyCatsView: View {
    var body: some View {
        NavigationView {
            Text(LocalizableKey.MyCats.placeholder)
                .font(AppTheme.Fonts.title)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .navigationTitle(LocalizableKey.MyCats.navigationTitle)
        }
    }
}

#Preview {
    MyCatsView()
}
