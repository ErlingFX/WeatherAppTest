//
//  WeatherInteractor.swift
//  Weather
//

import CoreLocation
import Foundation

protocol WeatherBusinessLogic {
    func loadWeather(request: Weather.Load.Request)
}

/// Interactor: запрашивает локацию, получает данные через Worker, формирует Response
final class WeatherInteractor: WeatherBusinessLogic {

    var presenter: WeatherPresentationLogic?
    private let worker: WeatherWorkerProtocol
    private let locationService: LocationServiceProtocol
    private let geocodingService: GeocodingServiceProtocol

    init(
        worker: WeatherWorkerProtocol = WeatherWorker(),
        locationService: LocationServiceProtocol = LocationService(),
        geocodingService: GeocodingServiceProtocol = GeocodingService()
    ) {
        self.worker = worker
        self.locationService = locationService
        self.geocodingService = geocodingService
    }

    func loadWeather(request: Weather.Load.Request) {
        presenter?.presentLoading()
        Task { @MainActor in
            let (lat, lon) = await getCoordinates()
            do {
                let dto = try await worker.fetchWeather(latitude: lat, longitude: lon)
                let cityName = await resolveCityName(latitude: lat, longitude: lon, apiFallback: dto.location.name)
                let response = buildResponse(from: dto, cityName: cityName)
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
                    continuation.resume(returning: (LocationConstants.moscowLatitude, LocationConstants.moscowLongitude))
                }
            }
        }
    }

    private func resolveCityName(latitude: Double, longitude: Double, apiFallback: String) async -> String {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return await geocodingService.cityName(for: location) ?? apiFallback
    }

    private func buildResponse(from dto: ForecastWeatherDTO, cityName: String) -> Weather.Load.Response {
        let current = CurrentWeather(
            city: cityName,
            temperature: dto.current.temp_c,
            condition: dto.current.condition.text,
            iconURL: makeAbsoluteURL(dto.current.condition.icon),
            conditionCode: dto.current.condition.code
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
