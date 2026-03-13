//
//  LocationService.swift
//  Weather
//

import CoreLocation
import Foundation

/// Координаты Москвы по умолчанию при отказе в доступе к геолокации
enum LocationConstants {
    static let moscowLatitude: Double = 55.7558
    static let moscowLongitude: Double = 37.6176
}

/// Результат запроса геолокации
enum LocationResult {
    case success(CLLocation)
    case denied
}

/// Протокол сервиса геолокации
protocol LocationServiceProtocol: AnyObject {
    func requestLocation(completion: @escaping (LocationResult) -> Void)
}

/// Сервис для получения координат пользователя через CoreLocation
final class LocationService: NSObject, LocationServiceProtocol {

    private let locationManager = CLLocationManager()
    private var completion: ((LocationResult) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation(completion: @escaping (LocationResult) -> Void) {
        self.completion = completion

        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            deliver(result: .denied)
        @unknown default:
            deliver(result: .denied)
        }
    }

    private func deliver(result: LocationResult) {
        completion?(result)
        completion = nil
    }

}

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        deliver(result: .success(location))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        deliver(result: .denied)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            deliver(result: .denied)
        case .notDetermined:
            break
        @unknown default:
            deliver(result: .denied)
        }
    }

}
