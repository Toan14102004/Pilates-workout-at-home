//
//  HeightStepView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct HeightStepView: View {
    @ObservedObject var viewModel: ProfileSetupView.ViewModel

    var body: some View {
        ProfileSetupNumberInputCard(text: $viewModel.heightText) {
            ProfileSetupUnitToggle(
                options: [(HeightUnit.centimeters, "cm"), (HeightUnit.feetInches, "ft & in")],
                selection: Binding(
                    get: { viewModel.answers.heightUnit },
                    set: { newValue in
                        guard newValue != viewModel.answers.heightUnit else { return }
                        viewModel.answers.heightUnit = newValue
                        viewModel.heightUnitChanged()
                    }
                )
            )
            .frame(width: 160)
        }
    }
}
