//
//  ContentView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/9/25.
//

import SwiftUI

enum Tab: CaseIterable {
    case practice, discover, progress, profile

    var title: String {
        switch self {
        case .practice: "Pilates Workout"
        case .discover: "Discover"
        case .progress: "Progress"
        case .profile: "Profile"
        }
    }

    /// Short label for the tab bar item — `title` is the full header text ("Pilates Workout"),
    /// which is too long to sit under a tab bar icon next to "Discover"/"Progress"/"Profile".
    var tabLabel: String {
        switch self {
        case .practice: "Plan"
        case .discover: "Discover"
        case .progress: "Progress"
        case .profile: "Profile"
        }
    }

    var normalIcon: ImageAsset {
        switch self {
        case .practice: Asset.Icon.TabBar.Normal.planNormal
        case .discover: Asset.Icon.TabBar.Normal.discoverNormal
        case .progress: Asset.Icon.TabBar.Normal.progressNormal
        case .profile: Asset.Icon.TabBar.Normal.profileNormal
        }
    }

    var selectedIcon: ImageAsset {
        switch self {
        case .practice: Asset.Icon.TabBar.Selected.planSelected
        case .discover: Asset.Icon.TabBar.Selected.discoverSelected
        case .progress: Asset.Icon.TabBar.Selected.progressSelected
        case .profile: Asset.Icon.TabBar.Selected.profileSelected
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = ViewModel()
    @ObservedObject private var languageManager = LanguageManager.shared
    @State var currentTab: Tab = .practice

    var body: some View {
        VStack(spacing: 0) {
            header()

            TabView(selection: $currentTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Group {
                        if tab == .practice {
                            PracticeHomeView()
                        } else {
                            // TODO: replace with real screens as each flow lands (see 7-day sprint plan).
                            placeholderContent(for: tab)
                        }
                    }
                    .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .overlay(alignment: .bottom) {
            tabBar()
        }
        .navigationBarBackButtonHidden(true)
        .flowDestination(for: Coordinator.Navigation.self) { item in
            switch item {
            case .settingView:
                SettingView(viewModel: .init())
            case .languageView:
                LanguageView(viewModel: .init())
            case let .workoutSchedule(programId):
                WorkoutScheduleView(programId: programId)
            case let .workoutDay(workoutId):
                WorkoutDayView(workoutId: workoutId)
            case let .exerciseDetail(workoutId, exerciseId):
                ExerciseDetailView(workoutId: workoutId, initialExerciseId: exerciseId)
            case let .workoutSession(workoutId):
                WorkoutSessionView(workoutId: workoutId)
            }
        }
        .popup(item: $viewModel.coordinator.alert) { item in
            switch item {
            case .error(let title, let message):
                CustomAlertView(
                    title: LocalizedStringKey(title),
                    titleColor: .red,
                    description: LocalizedStringKey(message),
                    primaryActionTitle: "OK",
                    primaryAction: {
                        viewModel.coordinator.alert = nil
                    }
                )
            case .success(let title, let message):
                CustomAlertView(
                    title: LocalizedStringKey(title),
                    titleColor: .green,
                    description: LocalizedStringKey(message),
                    primaryActionTitle: "OK",
                    primaryAction: {
                        viewModel.coordinator.alert = nil
                    }
                )
            }
        } customize: { params in
            params.centerPopup()
        }
    }

    @ViewBuilder
    func header() -> some View {
        HStack(spacing: Layout.Spacing.s) {
            Text(currentTab.title)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .font(FontFamily.Inter.bold.font(size: Layout.Text.title1))
                .frame(maxWidth: .infinity, alignment: .leading)

            if !subscriptionManager.isSubscribed {
                Button {
                    viewModel.showPremiumFullScreen()
                } label: {
                    Asset.Icon.Commo.premium.image
                        .toIcon(28.iPad(32))
                }
            }
        }
        .frame(height: Layout.Button.largeHeight)
        .padding(.horizontal, Layout.Spacing.m)
        .frame(maxWidth: .infinity)
        .background(Asset.Color.bgPrimary.color)
    }

    @ViewBuilder
    func placeholderContent(for tab: Tab) -> some View {
        VStack(spacing: Layout.Spacing.s) {
            Spacer()
            tab.normalIcon.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundStyle(Asset.Color.textBrandPrimary.color)
            Text("\(tab.title) screen")
                .font(FontFamily.Inter.bold.font(size: Layout.Text.title3))
                .foregroundStyle(Asset.Color.textPrimary.color)
            Text("Build this screen based on the Figma design.")
                .font(FontFamily.Inter.regular.font(size: Layout.Text.callout))
                .foregroundStyle(Asset.Color.textTertiary.color)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, Layout.Spacing.xxl * 2)
    }

    @ViewBuilder
    func tabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    currentTab = tab
                } label: {
                    VStack(spacing: Layout.Spacing.xxs) {
                        (currentTab == tab ? tab.selectedIcon : tab.normalIcon).image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Layout.Icon.xs, height: Layout.Icon.xs)
                        Text(tab.tabLabel)
                            .font(FontFamily.Inter.medium.font(size: Layout.Text.caption2))
                    }
                    .foregroundStyle(
                        currentTab == tab
                            ? Asset.Color.textBrandPrimary.color
                            : Asset.Color.textTertiary.color
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, Layout.Spacing.xxs)
        .padding(.bottom, Layout.Spacing.xxs)
        .background(
            Asset.Color.bgPrimary.color
                .overlay(alignment: .top) {
                    Asset.Color.borderPrimary.color.frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    ContentView()
        .preview()
}
