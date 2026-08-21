//
//  LanguageView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 15/10/25.
//

import SwiftUI

struct LanguageView: View {
    
    @Injected var localStorageService: LocalStorageService
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        BaseView {
            VStack(spacing: Layout.Spacing.m) {
                header

                ScrollView {
                    VStack(spacing: Layout.Spacing.s) {
                        ForEach(viewModel.languages) { language in
                            LanguageRowView(
                                language: language,
                                isSelected: viewModel.selectedLanguage?.id == language.id,
                                onTap: viewModel.selectLanguage(_:)
                            )
                        }
                    }
                    .padding(.horizontal, Layout.Spacing.m)
                }

                ZStack {
                    if viewModel.showClickAd {
                        PreloadedNativeAdsView(
                            adKey: .languageClick,
                            style: .large(),
                            height: 250
                        )
                    } else {
                        PreloadedNativeAdsView(
                            adKey: .language,
                            style: .large(),
                            height: 250
                        )
                    }
                }
                .padding(.horizontal, Layout.Spacing.xs)
            }
        }
        .colorScheme(.light)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .trackScreen("languageVC")
    }

    private var header: some View {
        HStack {
            if !viewModel.isOnboardingContext {
                Button(action: viewModel.goBack) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Asset.Color.textPrimary.color)
                }
            }

            Text("Language")
                .font(FontFamily.Inter.bold.font(size: 20))
                .foregroundStyle(Asset.Color.textPrimary.color)

            Spacer()

            Button(action: viewModel.confirmLanguageChange) {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(viewModel.hasLanguageChanged ? Asset.Color.mainColor.color : Asset.Color.textDisable.color)
            }
            .disabled(!viewModel.hasLanguageChanged)
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.top, Layout.Spacing.s)
    }
}

struct LanguageRowView: View {
    let language: Language
    let isSelected: Bool
    let onTap: (Language) -> Void

    var body: some View {
        Button {
            onTap(language)
        } label: {
            HStack(spacing: Layout.Spacing.m) {
                language.flagAsset.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Text(language.name)
                    .font(FontFamily.Inter.regular.font(size: 14))
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.vertical, Layout.Spacing.m)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Asset.Color.secondaryColor.color : Asset.Color.borderPrimary.color, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LanguageView(viewModel: .init())
        .preview()
}
