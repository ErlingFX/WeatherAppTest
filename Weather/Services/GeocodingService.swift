//
//  GeocodingService.swift
//  Weather
//

import CoreLocation
import Foundation

/// Протокол геокодирования
protocol GeocodingServiceProtocol: AnyObject {
    func cityName(for location: CLLocation) async -> String?
}

/// Сервис обратного геокодирования для получения названия города
final class GeocodingService: GeocodingServiceProtocol {

    private let geocoder = CLGeocoder()

    func cityName(for location: CLLocation) async -> String? {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality ?? placemarks.first?.administrativeArea
        } catch {
            return nil
        }
    }

}
