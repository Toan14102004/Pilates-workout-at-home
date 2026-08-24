//
//  SelectOptionsStepView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

/// Renders a `ProfileSetupStep.options` list as selectable cells.
/// Works for both single-select steps (`isSelected` + `onSelect`) and multi-select steps
/// (`isSelected` checks membership, `onSelect` toggles) — the parent view model owns that distinction.
struct SelectOptionsStepView: View {
    let options: [String]
    let isSelected: (String) -> Bool
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: Layout.Spacing.s) {
            ForEach(options, id: \.self) { option in
                ProfileSetupOptionCell(title: option, isSelected: isSelected(option)) {
                    onSelect(option)
                }
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
    }
}
