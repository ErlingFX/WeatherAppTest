//
//  WeatherModels.swift
//  Weather
//

import Foundation

enum Weather {

    enum Load {

        struct Request {}

        struct Response {
            let current: CurrentWeather
            let hourly: [HourlyWeather]
            let daily: [DailyWeather]
        }

        struct ViewModel {
            let city: String
            let temperature: String
            let condition: String
            let iconURL: String
            let conditionCode: Int
            let hourly: [HourlyItem]
            let daily: [DailyItem]
        }

    }

}

// MARK: - Доменные модели для Response

struct CurrentWeather {
    let city: String
    let temperature: Double
    let condition: String
    let iconURL: String
    let conditionCode: Int
}

struct HourlyWeather {
    let time: Date
    let temperature: Double
    let iconURL: String
}

struct DailyWeather {
    let date: Date
    let minTemperature: Double
    let maxTemperature: Double
    let iconURL: String
}

// MARK: - Элементы для ViewModel (отформатированные Presenter'ом)

struct HourlyItem {
    let hour: String
    let temperature: String
    let iconURL: String
}

struct DailyItem {
    let dayName: String
    let minTemperature: String
    let maxTemperature: String
    let iconURL: String
}
