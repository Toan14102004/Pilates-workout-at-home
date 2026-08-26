//
//  Typography.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 20/8/26.
//
//  Mirrors the named type scale from the Figma "Typography" frame
//  (Inter family; weight/size/line-height per style).
//

import SwiftUI

public enum Typography {
    // MARK: - Display (Didot)

    /// The serif the design uses for screen titles, section headers and plan names. Sizes are
    /// read straight off the Figma frames -- see docs/README.md.
    public static func display(_ size: CGFloat) -> Font { .custom("Didot-Bold", size: size) }

    /// 32pt -- the day number on Workout Day.
    public static var displayLarge: Font { display(32) }
    /// 24pt -- plan card and workout detail titles.
    public static var displayMedium: Font { display(24) }
    /// 22pt -- the tab header.
    public static var displaySmall: Font { display(22) }
    /// 20pt -- the Recent card and weekly-top rank numbers.
    public static var displayXSmall: Font { display(20) }
    /// 16pt -- every "Your Plan" / "Challenge" / "Weekly Top" section header.
    public static var displaySection: Font { display(16) }

    // MARK: - Inter

    public static var headlineLarge: Font { FontFamily.Inter.bold.font(size: 34) }
    public static var headlineMedium: Font { FontFamily.Inter.bold.font(size: 24) }
    public static var headlineSmall: Font { FontFamily.Inter.bold.font(size: 22) }

    public static var subtitleLarge: Font { FontFamily.Inter.bold.font(size: 20) }
    public static var subtitleMedium: Font { FontFamily.Inter.medium.font(size: 20) }
    public static var subtitleSmall: Font { FontFamily.Inter.bold.font(size: 16) }

    public static var bodyLarge: Font { FontFamily.Inter.medium.font(size: 16) }
    public static var bodyMedium: Font { FontFamily.Inter.regular.font(size: 16) }
    public static var bodySmall: Font { FontFamily.Inter.regular.font(size: 14) }

    public static var labelLarge: Font { FontFamily.Inter.bold.font(size: 14) }
    public static var labelMedium: Font { FontFamily.Inter.medium.font(size: 14) }
    public static var labelSmall: Font { FontFamily.Inter.regular.font(size: 12) }

    public static var captionLarge: Font { FontFamily.Inter.bold.font(size: 12) }
    public static var captionMedium: Font { FontFamily.Inter.medium.font(size: 12) }
    public static var captionSmall: Font { FontFamily.Inter.medium.font(size: 10) }
}
