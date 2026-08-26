//
//  ContentViewCoordinator.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/9/25.
//

import Foundation
import SwiftUI

extension ContentView {
  struct Coordinator: BaseCoordinator {
    enum Alert: BaseAlert {
      case error(title: String, message: String)
      case success(title: String, message: String)
    }

    enum Navigation: BaseNavigation {
      case settingView
      case languageView
      case workoutSchedule(programId: String)
      case workoutDay(workoutId: String)
      case exerciseDetail(workoutId: String, exerciseId: String)
      case workoutSession(workoutId: String)
      case discoverCategory(sectionId: Int, title: String)
      case discoverWeeklyTop
      case discoverWorkout(workoutId: String)
    }

    var alert: Alert?
  }
}
