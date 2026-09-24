//
//  CatUploadView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

struct CatUploadView: View {
    
    var body: some View {
        NavigationStack {
            Text("Add New Cat")
                .font(AppTheme.Fonts.title)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .navigationTitle("Add Cat")
        }
    }
}

#Preview {
    CatUploadView()
}

