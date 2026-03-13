//
//  WeatherWorker.swift
//  Weather
//

import Foundation

/// Протокол Worker для тестирования
protocol WeatherWorkerProtocol {
    func fetchWeather(latitude: Double, longitude: Double) async throws -> ForecastWeatherDTO
}

/// Worker выполняет сетевые запросы к WeatherAPI
final class WeatherWorker: WeatherWorkerProtocol {

    private let apiService: WeatherAPIServiceProtocol

    init(apiService: WeatherAPIServiceProtocol = WeatherAPIService()) {
        self.apiService = apiService
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> ForecastWeatherDTO {
        try await apiService.fetchForecast(latitude: latitude, longitude: longitude)
    }

}
