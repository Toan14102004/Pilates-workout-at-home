//
//  WelcomeView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 20/8/26.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Group {
            VStack(spacing: 0) {
                Spacer()
                
                HStack(spacing: 0) {
                    Asset.Icon.Commo.leafLeft.image
                        .toIcon(Layout.Icon.xxl)
                    
                    VStack(spacing: 2) {
                        Text("1,000,000+")
                            .font(FontFamily.Inter.bold.font(size: 16))
                        Text("Download the App")
                            .font(FontFamily.Inter.regular.font(size: 14))
                            .foregroundStyle(.white.opacity(0.8))
                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(red: 0.98, green: 0.75, blue: 0.0))
                            }
                        }
                    }
                    
                    Asset.Icon.Commo.leafRight.image
                        .toIcon(Layout.Icon.xxl)
                }
                .padding(.bottom, Layout.Spacing.l)

                VStack(spacing: Layout.Spacing.xs) {
                    Text("Find Your Perfect Flow")
                        .font(.custom("Didot-Bold", size: 28))
                        .multilineTextAlignment(.center)

                    Text("Choose workouts that fit your goals, fitness level, and schedule — from gentle stretches to full body Pilates.")
                        .font(FontFamily.Inter.regular.font(size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, Layout.Spacing.l)
                .padding(.bottom, Layout.Spacing.l)

                PrimaryButton(title: "Get Started", systemIcon: nil, action: viewModel.getStarted)
                    .padding(.horizontal, Layout.Spacing.xxxl + Layout.Spacing.xxl)
            }
            .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.l)
        }
        .foregroundStyle(.white)
        .colorScheme(.dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Asset.Image.welcomeBg.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color.black.opacity(0.2))
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .trackScreen("welcomeVC")
    }
}

#Preview {
    WelcomeView(viewModel: .init())
        .preview()
}
