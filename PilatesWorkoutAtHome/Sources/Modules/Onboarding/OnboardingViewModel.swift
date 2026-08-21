//
//  OnboardingViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 20/8/26.
//

import Foundation

struct OnboardingPage: Identifiable {
    let id: Int
    let headline: String
}

struct OnboardingTestimonial: Identifiable {
    let id = UUID()
    let name: String
    let quote: String
    let image: ImageAsset
}

extension OnboardingView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator

        @Published var coordinator = Coordinator()
        @Published var currentPage: Int = 0

        let pages: [OnboardingPage] = [
            OnboardingPage(id: 0, headline: "Build strength, improve flexibility, and feel your best"),
            OnboardingPage(id: 1, headline: "Explore 3,000+ Pilates workouts for every goal."),
            OnboardingPage(id: 2, headline: "Join 100K+ Pilates Lovers on Their Wellness Journey"),
        ]

        let testimonials: [OnboardingTestimonial] = [
            OnboardingTestimonial(
                name: "Maria Jane",
                quote: "Perfect for beginners. The exercises are easy to understand and I already feel more flexible after a few weeks.",
                image: Asset.Image.testimonial1
            ),
            OnboardingTestimonial(
                name: "Jennie",
                quote: "So calming and easy to use. I love doing a quick Pilates session before starting my day.",
                image: Asset.Image.testimonial2
            ),
            OnboardingTestimonial(
                name: "Anna",
                quote: "Great app for working out at home. No equipment needed for most workouts, which makes it super convenient.",
                image: Asset.Image.testimonial3
            ),
        ]

        var isLastPage: Bool { currentPage == pages.count - 1 }

        func next() {
            if isLastPage {
                navigator.presentCover(
                    RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .onboarding),
                    withNavigation: true
                )
            } else {
                currentPage += 1
            }
        }
    }
}
