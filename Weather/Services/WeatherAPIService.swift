//
//  WeatherAPIService.swift
//  Weather
//

import Foundation

/// DTO для декодирования ответа API прогноза (включает текущую погоду)
struct ForecastWeatherDTO: Codable {
    let location: LocationDTO
    let current: CurrentDTO
    let forecast: ForecastDTO

    struct LocationDTO: Codable {
        let name: String
        let localtime_epoch: TimeInterval?
    }

    struct CurrentDTO: Codable {
        let temp_c: Double
        let condition: ConditionDTO

        struct ConditionDTO: Codable {
            let text: String
            let icon: String
            let code: Int
        }
    }

    struct ForecastDTO: Codable {
        let forecastday: [ForecastDayDTO]
    }

    struct ForecastDayDTO: Codable {
        let date: String
        let date_epoch: TimeInterval
        let day: DayDTO
        let hour: [HourDTO]
    }

    struct DayDTO: Codable {
        let maxtemp_c: Double
        let mintemp_c: Double
        let condition: ConditionDTO

        struct ConditionDTO: Codable {
            let icon: String
        }
    }

    struct HourDTO: Codable {
        let time_epoch: TimeInterval
        let temp_c: Double
        let condition: ConditionDTO

        struct ConditionDTO: Codable {
            let icon: String
        }
    }
}

/// Протокол API погоды
protocol WeatherAPIServiceProtocol {
    func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastWeatherDTO
}

/// Сервис для запросов к WeatherAPI.com (forecast.json включает current)
final class WeatherAPIService: WeatherAPIServiceProtocol {

    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let session = URLSession.shared

    func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastWeatherDTO {
        let query = "\(latitude),\(longitude)"
        let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(query)&days=3")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(ForecastWeatherDTO.self, from: data)
    }

}
