//
//  ProfileSetupViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 21/8/26.
//

import Foundation

extension ProfileSetupView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var currentStep: ProfileSetupStep = .motivation
        @Published var answers = ProfileSetupAnswers()

        @Published var heightText: String = ""
        @Published var currentWeightText: String = ""
        @Published var targetWeightText: String = ""
        @Published var ageText: String = ""
        @Published var showAgeError: Bool = false
        @Published var heightErrorText: String?
        @Published var currentWeightErrorText: String?
        @Published var targetWeightErrorText: String?

        var isNextEnabled: Bool {
            switch currentStep {
            case .motivation: answers.motivation != nil
            case .primaryGoal: answers.primaryGoal != nil
            case .height: !heightText.isEmpty && heightErrorText == nil
            case .currentWeight: !currentWeightText.isEmpty && currentWeightErrorText == nil
            case .targetWeight: !targetWeightText.isEmpty && targetWeightErrorText == nil
            case .age: !ageText.isEmpty && !showAgeError
            case .workoutLocation: answers.workoutLocation != nil
            case .preferredActivities: !answers.preferredActivities.isEmpty
            case .experienceLevel: answers.experienceLevel != nil
            case .workoutIntensity: answers.workoutIntensity != nil
            case .injuredAreas: !answers.injuredAreas.isEmpty
            case .currentRole: answers.currentRole != nil
            case .dailyActivityLevel: answers.dailyActivityLevel != nil
            case .fitnessLevel: answers.fitnessLevel != nil
            case .generatingPlan: true
            }
        }

        // MARK: - Progress

        /// 1-based tick out of `ProfileSetupStep.totalProgressSteps`. Every step is one tick except
        /// "Height", which is two (empty vs. a value entered) to match the Figma "n/15" labels — so
        /// every step after Height is shifted by one to keep the numbering in sync.
        var progressNumerator: Int {
            let base = currentStep.rawValue + 1
            if currentStep == .height {
                return heightText.isEmpty ? base : base + 1
            }
            return currentStep.rawValue > ProfileSetupStep.height.rawValue ? base + 1 : base
        }

        var progressLabel: String { "\(progressNumerator)/\(ProfileSetupStep.totalProgressSteps)" }

        var progressFraction: Double {
            Double(progressNumerator) / Double(ProfileSetupStep.totalProgressSteps)
        }

        // MARK: - Selection helpers

        func isSelected(_ value: String, in keyPath: KeyPath<ProfileSetupAnswers, String?>) -> Bool {
            answers[keyPath: keyPath] == value
        }

        func selectSingle(_ value: String, for keyPath: WritableKeyPath<ProfileSetupAnswers, String?>) {
            answers[keyPath: keyPath] = value
        }

        func isSelected(_ value: String, in keyPath: KeyPath<ProfileSetupAnswers, [String]>) -> Bool {
            answers[keyPath: keyPath].contains(value)
        }

        func toggleMulti(_ value: String, exclusiveWith exclusiveValue: String? = nil, for keyPath: WritableKeyPath<ProfileSetupAnswers, [String]>) {
            var selection = answers[keyPath: keyPath]
            if selection.contains(value) {
                selection.removeAll { $0 == value }
            } else if value == exclusiveValue {
                selection = [value]
            } else {
                selection.removeAll { $0 == exclusiveValue }
                selection.append(value)
            }
            answers[keyPath: keyPath] = selection
        }

        // MARK: - Unit conversion

        func heightUnitChanged() {
            guard let cm = parsedHeightCm(from: heightText, unit: answers.heightUnit == .centimeters ? .feetInches : .centimeters) else { return }
            heightText = answers.heightUnit == .centimeters ? "\(cm)" : "\(Int((Double(cm) / 2.54).rounded()))"
            validateHeight()
        }

        func validateHeight() {
            guard !heightText.isEmpty, let cm = parsedHeightCm(from: heightText, unit: answers.heightUnit) else {
                heightErrorText = nil
                return
            }
            heightErrorText = (100...250).contains(cm) ? nil : "Height must be 100-250 cm"
        }

        func weightUnitChanged(text: inout String) {
            guard let kg = parsedWeightKg(from: text, unit: answers.weightUnit == .kilograms ? .pounds : .kilograms) else { return }
            text = answers.weightUnit == .kilograms ? "\(Int(kg.rounded()))" : "\(Int((kg * 2.20462).rounded()))"
        }

        func validateWeight(_ text: String, errorBinding: inout String?) {
            guard !text.isEmpty, let kg = parsedWeightKg(from: text, unit: answers.weightUnit) else {
                errorBinding = nil
                return
            }
            errorBinding = (30...300).contains(kg) ? nil : "Weight must be 30-300 kg"
        }

        private func parsedHeightCm(from text: String, unit: HeightUnit) -> Int? {
            guard let raw = Int(text) else { return nil }
            switch unit {
            case .centimeters: return raw
            case .feetInches: return Int((Double(raw) * 2.54).rounded())
            }
        }

        private func parsedWeightKg(from text: String, unit: WeightUnit) -> Double? {
            guard let raw = Double(text) else { return nil }
            switch unit {
            case .kilograms: return raw
            case .pounds: return raw * 0.453592
            }
        }

        // MARK: - Navigation

        func back() {
            guard let previous = ProfileSetupStep(rawValue: currentStep.rawValue - 1) else {
                navigator.goBack()
                return
            }
            currentStep = previous
        }

        func next() {
            switch currentStep {
            case .height:
                validateHeight()
                guard heightErrorText == nil else { return }
                answers.heightCm = parsedHeightCm(from: heightText, unit: answers.heightUnit)
            case .currentWeight:
                validateWeight(currentWeightText, errorBinding: &currentWeightErrorText)
                guard currentWeightErrorText == nil else { return }
                answers.currentWeightKg = parsedWeightKg(from: currentWeightText, unit: answers.weightUnit)
            case .targetWeight:
                validateWeight(targetWeightText, errorBinding: &targetWeightErrorText)
                guard targetWeightErrorText == nil else { return }
                answers.targetWeightKg = parsedWeightKg(from: targetWeightText, unit: answers.weightUnit)
            case .age:
                guard let age = Int(ageText), (10...100).contains(age) else {
                    showAgeError = true
                    return
                }
                showAgeError = false
                answers.age = age
            default:
                break
            }

            guard let nextStep = ProfileSetupStep(rawValue: currentStep.rawValue + 1) else {
                return
            }
            currentStep = nextStep

            if nextStep == .generatingPlan {
                localStorageService.profileSetupAnswers = answers
                completeAfterDelay()
            }
        }

        private func completeAfterDelay() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
                self?.navigator.presentCover(
                    RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .onboarding),
                    withNavigation: true
                )
            }
        }
    }
}
