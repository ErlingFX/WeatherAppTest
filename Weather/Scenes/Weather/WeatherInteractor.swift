//
//  WeatherInteractor.swift
//  Weather
//

import Foundation

protocol WeatherBusinessLogic {
    func loadWeather(request: Weather.Load.Request)
}

/// Interactor: запрашивает локацию, получает данные через Worker, формирует Response
final class WeatherInteractor: WeatherBusinessLogic {

    var presenter: WeatherPresentationLogic?
    private let worker: WeatherWorkerProtocol
    private let locationService: LocationServiceProtocol

    private static let moscowLatitude = 55.7558
    private static let moscowLongitude = 37.6176

    init(
        worker: WeatherWorkerProtocol = WeatherWorker(),
        locationService: LocationServiceProtocol = LocationService()
    ) {
        self.worker = worker
        self.locationService = locationService
    }

    func loadWeather(request: Weather.Load.Request) {
        presenter?.presentLoading()
        Task { @MainActor in
            let (lat, lon) = await getCoordinates()
            do {
                let dto = try await worker.fetchWeather(latitude: lat, longitude: lon)
                let response = buildResponse(from: dto)
                presenter?.presentWeather(response: response)
            } catch {
                presenter?.presentError(message: error.localizedDescription)
            }
        }
    }

    private func getCoordinates() async -> (Double, Double) {
        await withCheckedContinuation { continuation in
            locationService.requestLocation { result in
                switch result {
                case .success(let location):
                    continuation.resume(returning: (location.coordinate.latitude, location.coordinate.longitude))
                case .denied:
                    continuation.resume(returning: (Self.moscowLatitude, Self.moscowLongitude))
                }
            }
        }
    }

    private func buildResponse(from dto: ForecastWeatherDTO) -> Weather.Load.Response {
        let current = CurrentWeather(
            city: dto.location.name,
            temperature: dto.current.temp_c,
            condition: dto.current.condition.text,
            iconURL: makeAbsoluteURL(dto.current.condition.icon)
        )

        // Оставшиеся часы текущего дня + все часы следующего дня
        let currentHourStart = (dto.location.localtime_epoch ?? Date().timeIntervalSince1970) / 3600 * 3600

        var hourly: [HourlyWeather] = []

        if let today = dto.forecast.forecastday.first {
            for hourDTO in today.hour where hourDTO.time_epoch >= currentHourStart {
                hourly.append(HourlyWeather(
                    time: Date(timeIntervalSince1970: hourDTO.time_epoch),
                    temperature: hourDTO.temp_c,
                    iconURL: makeAbsoluteURL(hourDTO.condition.icon)
                ))
            }
        }

        if dto.forecast.forecastday.count > 1 {
            let tomorrow = dto.forecast.forecastday[1]
            for hourDTO in tomorrow.hour {
                hourly.append(HourlyWeather(
                    time: Date(timeIntervalSince1970: hourDTO.time_epoch),
                    temperature: hourDTO.temp_c,
                    iconURL: makeAbsoluteURL(hourDTO.condition.icon)
                ))
            }
        }

        let daily: [DailyWeather] = dto.forecast.forecastday.prefix(3).map { dayDTO in
            DailyWeather(
                date: Date(timeIntervalSince1970: dayDTO.date_epoch),
                minTemperature: dayDTO.day.mintemp_c,
                maxTemperature: dayDTO.day.maxtemp_c,
                iconURL: makeAbsoluteURL(dayDTO.day.condition.icon)
            )
        }

        return Weather.Load.Response(
            current: current,
            hourly: hourly,
            daily: Array(daily)
        )
    }

    private func makeAbsoluteURL(_ path: String) -> String {
        if path.hasPrefix("//") {
            return "https:" + path
        }
        return path
    }

}
