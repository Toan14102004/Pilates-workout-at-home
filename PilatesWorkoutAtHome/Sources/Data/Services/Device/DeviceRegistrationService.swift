//
//  DeviceRegistrationService.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//
//  Registers this install's deviceId with the server. Every endpoint that is scoped to a
//  device -- /activities/*, /workouts/{id}/progress, /workouts/suggestions -- 404s or answers
//  empty until this has run once. Shared by ProgressService and WorkoutProgressStore rather than
//  each rolling its own registration call.
//

import Combine
import Foundation

final class DeviceRegistrationService {
    @Injected var networkService: NetworkService
    @Injected var localStorageService: LocalStorageService

    var deviceId: String { localStorageService.deviceId }

    /// `POST /users` "creates or updates" server-side, so calling it twice is harmless, but the
    /// local flag avoids paying for the round trip on every screen that needs a device identity.
    func registerIfNeeded() -> AnyPublisher<Void, NetworkError> {
        guard !localStorageService.isDeviceRegistered else {
            return Just(()).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
        }

        return networkService
            .post(endpoint: "/users",
                 body: DeviceRegisterRequest(deviceId: deviceId),
                 responseType: DeviceRegisterDTO.self)
            .map { [weak self] _ in self?.localStorageService.isDeviceRegistered = true }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

private struct DeviceRegisterRequest: Codable {
    let deviceId: String
}

/// Unlike every other endpoint, `POST /users` replies with the raw user document, not the
/// `{success, data}` envelope -- decode just the field this call needs.
private struct DeviceRegisterDTO: Codable {
    let deviceId: String
}
