//
//  CatUploadView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

struct CatUploadView: View {
    @StateObject private var viewModel = CatUploadFormViewModel()
    private let onCreationConfirmed: () -> Void

    init(onCreationConfirmed: @escaping () -> Void = {}) {
        self.onCreationConfirmed = onCreationConfirmed
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.md) {
                StepperIndicator(
                    currentStep: viewModel.currentStep,
                    totalSteps: 3,
                    stepTitles: LocalizableKey.CatUpload.stepTitles
                )
                .padding(.top, AppTheme.Spacing.sm)

                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                        if let errorMessage = viewModel.errorMessage {
                            SectionHeader(
                                title: LocalizableKey.CatUpload.saveError,
                                subtitle: errorMessage,
                                systemImage: "exclamationmark.triangle"
                            )
                        }

                        currentForm
                    }
                    .padding(AppTheme.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDismissesKeyboard(.interactively)

                AppButton(title: viewModel.buttonTitle) {
                    viewModel.clearError()
                    viewModel.performPrimaryAction()
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizableKey.CatUpload.navigationTitle)
            .task {
                viewModel.fetchBreeds()
            }
            .alert(
                LocalizableKey.CatUpload.successTitle,
                isPresented: $viewModel.isConfirmationPresented
            ) {
                Button(LocalizableKey.CatUpload.done, role: .cancel) {
                    onCreationConfirmed()
                }
            } message: {
                Text(LocalizableKey.CatUpload.successMessage)
            }
        }
    }

    @ViewBuilder
    private var currentForm: some View {
        switch viewModel.currentStep {
        case 0:
            CatSimpleFormView(viewModel: viewModel)
        case 1:
            CatDetailsFormView(viewModel: viewModel)
        default:
            CatResumeFormView(viewModel: viewModel)
        }
    }
}

#Preview {
    CatUploadView()
}
