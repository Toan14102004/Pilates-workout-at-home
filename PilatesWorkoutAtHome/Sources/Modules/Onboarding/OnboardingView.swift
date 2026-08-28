//
//  OnboardingView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 20/8/26.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $viewModel.currentPage) {
                Color.clear
                    .tag(0)
                galleryImages
                    .tag(1)
                testimonialsPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentPage)
            .background {
                // TabView(.page) clips its page content to the safe area regardless of
                // `.ignoresSafeArea`, so the hero can't bleed under the status bar from inside
                // a page. Rendering it as a background behind the TabView instead, sized to
                // just the TabView (not the footer below it).
                Group {
                    if viewModel.currentPage == 0 {
                        heroImage
                    } else {
                        Asset.Color.bgPrimary.color
                    }
                }
                .animation(.easeInOut, value: viewModel.currentPage)
                .ignoresSafeArea(edges: .top)
            }

            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .colorScheme(.light)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .trackScreen("onboardingVC")
    }

    private var heroImage: some View {
        Asset.Image.onboardingHero.image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .overlay(alignment: .bottom) { bottomFade.frame(height: 214) }
    }

    private var bottomFade: some View {
        LinearGradient(
            colors: [Asset.Color.bgPrimary.color.opacity(0), Asset.Color.bgPrimary.color],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private static let galleryColumns: [[ImageAsset]] = [
        [Asset.Image.gallery1, Asset.Image.gallery4, Asset.Image.gallery7],
        [Asset.Image.gallery2, Asset.Image.gallery5, Asset.Image.gallery8],
        [Asset.Image.gallery3, Asset.Image.gallery6, Asset.Image.gallery9],
    ]

    private var galleryImages: some View {
        HStack(spacing: Layout.Spacing.xs) {
            ForEach(Array(Self.galleryColumns.enumerated()), id: \.offset) { _, column in
                VStack(spacing: Layout.Spacing.xs) {
                    ForEach(Array(column.enumerated()), id: \.offset) { _, asset in
                        asset.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 189)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.top, UIApplication.shared.safeAreaTop + Layout.Spacing.m)
        .overlay(alignment: .bottom) { bottomFade.frame(height: 260) }
    }

    private var testimonialsPage: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Layout.Spacing.m) {
                ForEach(viewModel.testimonials) { testimonial in
                    testimonialCard(testimonial)
                }
            }
            .padding(.horizontal, Layout.Spacing.m)
        }
        .padding(.top, UIApplication.shared.safeAreaTop + Layout.Spacing.xxl)
    }

    private func testimonialCard(_ testimonial: OnboardingTestimonial) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            testimonial.image.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 279, height: 217)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: Layout.Spacing.xxs) {
                HStack(spacing: 2) {
                    Text(testimonial.name)
                        .font(FontFamily.Inter.medium.font(size: 14))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(red: 0.98, green: 0.75, blue: 0.0))
                        }
                    }
                }
                Text(testimonial.quote)
                    .font(FontFamily.Inter.regular.font(size: 12))
                    .foregroundStyle(Asset.Color.textSecondary.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Layout.Spacing.s)
        }
        .padding(.bottom, Layout.Spacing.m)
        .frame(width: 279)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.l) {
            Text(viewModel.pages[viewModel.currentPage].headline)
                .font(.custom("Didot-Bold", size: 24))
                .foregroundStyle(Asset.Color.textPrimary.color)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                HStack(spacing: 6) {
                    ForEach(viewModel.pages) { page in
                        Capsule()
                            .fill(page.id == viewModel.currentPage ? Asset.Color.mainColor.color : Asset.Color.borderPrimary.color)
                            .frame(width: page.id == viewModel.currentPage ? 29 : 8, height: 8)
                    }
                }

                Spacer()

                Button(action: viewModel.next) {
                    Text(viewModel.isLastPage ? "Get Started" : "Next")
                        .font(FontFamily.Inter.medium.font(size: 16))
                        .foregroundStyle(Asset.Color.mainColor.color)
                }
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.m)
        .padding(.top, Layout.Spacing.m)
    }
}

#Preview {
    OnboardingView(viewModel: .init())
        .preview()
}
