//
//  AppGradient.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 29/9/25.
//

import Foundation
import SwiftUI
import UIKit

enum AppGradient {
    /// Shared brand gradient (Figma: node 2256:5565, Native Ad CTA button).
    /// #CEBAE8 -> #5A3093, horizontal (leading to trailing).
    static let startColor = Color(hex: "#CEBAE8")
    static let endColor = Color(hex: "#5A3093")

    static var mainGradient: LinearGradient {
        LinearGradient(
            colors: [startColor, endColor],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// UIKit equivalent for views that aren't SwiftUI (e.g. native ad templates).
    static func makeCAGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#CEBAE8").cgColor,
            UIColor(hex: "#5A3093").cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }
}
