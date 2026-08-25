//
//  DurationStepper.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// The "Duration  −  01:00  +" row on the Exercise Detail edit screen.
struct DurationStepper: View {
    @Binding var seconds: Int
    var step: Int = 5
    var minimumSeconds: Int = 5

    private var label: String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var body: some View {
        HStack {
            Text("Duration")
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)

            Spacer()

            HStack(spacing: Layout.Spacing.m) {
                stepButton(symbol: "−") { seconds = max(minimumSeconds, seconds - step) }

                Text(label)
                    .font(.custom("Didot-Bold", size: 20))
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .frame(minWidth: 56)

                stepButton(symbol: "+") { seconds += step }
            }
        }
    }

    private func stepButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Asset.Color.textPrimary.color)
                .frame(width: 32, height: 32)
                .background(Asset.Color.bgSecondary.color)
                .clipShape(Circle())
        }
    }
}
