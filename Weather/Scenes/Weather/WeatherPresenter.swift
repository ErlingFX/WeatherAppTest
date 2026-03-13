//
//  WeatherPresenter.swift
//  Weather
//

import Foundation

protocol WeatherPresentationLogic {
    func presentWeather(response: Weather.Load.Response)
    func presentError(message: String)
    func presentLoading()
}

/// Presenter: форматирует данные, конвертирует Response → ViewModel
final class WeatherPresenter: WeatherPresentationLogic {

    weak var viewController: WeatherDisplayLogic?

    private let dateFormatter = DateFormatter()
    private let dayFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "HH:mm"
        dayFormatter.dateFormat = "EEEE"
        dayFormatter.locale = Locale(identifier: "ru_RU")
    }

    func presentLoading() {
        viewController?.displayLoading()
    }

    func presentWeather(response: Weather.Load.Response) {
        let hourly = response.hourly.map { item in
            HourlyItem(
                hour: formatHour(item.time),
                temperature: formatTemperature(item.temperature),
                iconURL: item.iconURL
            )
        }

        let daily = response.daily.map { item in
            DailyItem(
                dayName: formatDayName(item.date),
                minTemperature: formatTemperature(item.minTemperature),
                maxTemperature: formatTemperature(item.maxTemperature),
                iconURL: item.iconURL
            )
        }

        let viewModel = Weather.Load.ViewModel(
            city: response.current.city,
            temperature: formatTemperature(response.current.temperature),
            condition: response.current.condition,
            iconURL: response.current.iconURL,
            hourly: hourly,
            daily: daily
        )

        viewController?.displayWeather(viewModel: viewModel)
    }

    func presentError(message: String) {
        viewController?.displayError(message: message)
    }

    // MARK: - Форматирование

    private func formatTemperature(_ value: Double) -> String {
        let rounded = Int(round(value))
        return "\(rounded)°"
    }

    private func formatHour(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    private func formatDayName(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Сегодня"
        }
        if calendar.isDateInTomorrow(date) {
            return "Завтра"
        }
        return dayFormatter.string(from: date)
    }

}
