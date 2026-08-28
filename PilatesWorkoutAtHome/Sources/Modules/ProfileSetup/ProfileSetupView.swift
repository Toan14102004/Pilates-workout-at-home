//
//  ProfileSetupView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Group {
            if viewModel.currentStep == .generatingPlan {
                GeneratingPlanStepView()
            } else {
                VStack(spacing: 0) {
                    header
                        .padding(.top, Layout.Spacing.m)

                    ScrollView {
                        VStack(spacing: 0) {
                            stepContent
                                .padding(.vertical, Layout.Spacing.l)

                            footer
                                .padding(.top, Layout.Spacing.xl)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .colorScheme(.light)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentStep)
        .trackScreen("profileSetupVC")
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
            HStack(spacing: Layout.Spacing.s) {
                Button(action: viewModel.back) {
                    Asset.Icon.ProfileSetup.backChevron.image
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .opacity(viewModel.currentStep.showsBackButton ? 1 : 0)
                .disabled(!viewModel.currentStep.showsBackButton)

                progressBar

                Text(viewModel.progressLabel)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textSecondary.color)
                    .fixedSize()
            }
//            .frame(height: 54)
            .padding(.horizontal, Layout.Spacing.m)

            VStack(alignment: .leading, spacing: Layout.Spacing.xxs) {
                Text(viewModel.currentStep.title)
                    .font(.custom("Didot-Bold", size: 24))
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Layout.Spacing.m)

                if let subtitle = viewModel.currentStep.subtitle {
                    Text(subtitle)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, Layout.Spacing.m)
        }
        .padding(.top, Layout.Spacing.xs)
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Asset.Color.bgSecondary.color)
                Capsule()
                    .fill(Asset.Color.mainColor.color)
                    .frame(width: geometry.size.width * viewModel.progressFraction, height: 8)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .motivation:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.motivation) },
                onSelect: { viewModel.selectSingle($0, for: \.motivation) }
            )
        case .primaryGoal:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.primaryGoal) },
                onSelect: { viewModel.selectSingle($0, for: \.primaryGoal) }
            )
        case .height:
            HeightStepView(viewModel: viewModel)
        case .currentWeight:
            WeightStepView(viewModel: viewModel, text: $viewModel.currentWeightText, type: .current)
        case .targetWeight:
            WeightStepView(viewModel: viewModel, text: $viewModel.targetWeightText, type: .target)
        case .age:
            AgeStepView(viewModel: viewModel)
        case .workoutLocation:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.workoutLocation) },
                onSelect: { viewModel.selectSingle($0, for: \.workoutLocation) }
            )
        case .preferredActivities:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.preferredActivities) },
                onSelect: { viewModel.toggleMulti($0, for: \.preferredActivities) }
            )
        case .experienceLevel:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.experienceLevel) },
                onSelect: { viewModel.selectSingle($0, for: \.experienceLevel) }
            )
        case .workoutIntensity:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.workoutIntensity) },
                onSelect: { viewModel.selectSingle($0, for: \.workoutIntensity) }
            )
        case .injuredAreas:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.injuredAreas) },
                onSelect: {
                    viewModel.toggleMulti($0, exclusiveWith: viewModel.currentStep.exclusiveOption, for: \.injuredAreas)
                }
            )
        case .currentRole:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.currentRole) },
                onSelect: { viewModel.selectSingle($0, for: \.currentRole) }
            )
        case .dailyActivityLevel:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.dailyActivityLevel) },
                onSelect: { viewModel.selectSingle($0, for: \.dailyActivityLevel) }
            )
        case .fitnessLevel:
            SelectOptionsStepView(
                options: viewModel.currentStep.options,
                isSelected: { viewModel.isSelected($0, in: \.fitnessLevel) },
                onSelect: { viewModel.selectSingle($0, for: \.fitnessLevel) }
            )
        case .generatingPlan:
            EmptyView()
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: Layout.Spacing.s) {
            if let adKey = viewModel.currentStep.compactAdKey {
                PreloadedNativeAdsView(adKey: adKey, style: .banner, height: NativeAdViewStyle.banner.height)
                    .padding(.horizontal, Layout.Spacing.m)
            }
            if let adKey = viewModel.currentStep.mediumAdKey {
                PreloadedNativeAdsView(adKey: adKey, style: .medium, height: NativeAdViewStyle.medium.height)
                    .padding(.horizontal, Layout.Spacing.m)
            }

            Button(action: viewModel.next) {
                Text("Next")
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.white.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Layout.Spacing.m)
                    .background(viewModel.isNextEnabled ? Asset.Color.mainColor.color : Asset.Color.gray.color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.isNextEnabled)
            .padding(.horizontal, Layout.Spacing.xxl)
        }
        .padding(.top, Layout.Spacing.m)
        .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.s)
    }
}

#Preview {
    ProfileSetupView(viewModel: .init())
        .preview()
}
