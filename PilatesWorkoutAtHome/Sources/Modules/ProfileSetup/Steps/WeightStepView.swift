//
//  WeightStepView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

/// Shared body for the "Current Weight" and "Target Weight" steps — same input shape,
/// different backing text binding, same `weightUnit` preference.
struct WeightStepView: View {
    @ObservedObject var viewModel: ProfileSetupView.ViewModel
    let text: Binding<String>

    var body: some View {
        ProfileSetupNumberInputCard(text: text) {
            ProfileSetupUnitToggle(
                options: [(WeightUnit.kilograms, "kg"), (WeightUnit.pounds, "lb")],
                selection: Binding(
                    get: { viewModel.answers.weightUnit },
                    set: { newValue in
                        guard newValue != viewModel.answers.weightUnit else { return }
                        viewModel.answers.weightUnit = newValue
                        var mutableText = text.wrappedValue
                        viewModel.weightUnitChanged(text: &mutableText)
                        text.wrappedValue = mutableText
                    }
                )
            )
            .frame(width: 160)
        }
    }
}
