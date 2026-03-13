//
//  WeatherBackgroundProvider.swift
//  Weather
//

import UIKit

/// Градиент фона в зависимости от кода погоды (WeatherAPI.com)
struct WeatherBackgroundConfig {
    let topColor: UIColor
    let bottomColor: UIColor
}

/// Провайдер фоновых градиентов по типу погоды
enum WeatherBackgroundProvider {

    /// Прозрачность градиента (смягчает яркость)
    private static let gradientAlpha: CGFloat = 0.42

    /// Возвращает конфигурацию градиента по коду условия погоды
    static func background(for conditionCode: Int) -> WeatherBackgroundConfig {
        switch conditionCode {
        case 1000:
            return .init(
                topColor: UIColor(red: 0.98, green: 0.85, blue: 0.45, alpha: gradientAlpha),
                bottomColor: UIColor(red: 0.98, green: 0.65, blue: 0.35, alpha: gradientAlpha)
            )
        case 1003:
            return .init(
                topColor: UIColor(red: 0.6, green: 0.78, blue: 0.95, alpha: gradientAlpha),
                bottomColor: UIColor(red: 0.75, green: 0.88, blue: 0.98, alpha: gradientAlpha)
            )
        case 1006, 1009:
            return .init(
                topColor: UIColor(red: 0.55, green: 0.58, blue: 0.65, alpha: gradientAlpha),
                bottomColor: UIColor(red: 0.7, green: 0.72, blue: 0.78, alpha: gradientAlpha)
            )
        case 1030, 1135, 1147:
            return .init(
                topColor: UIColor(red: 0.72, green: 0.74, blue: 0.78, alpha: gradientAlpha),
                bottomColor: UIColor(red: 0.82, green: 0.84, blue: 0.88, alpha: gradientAlpha)
            )
        case 1063, 1150, 1153, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243:
            return .init(
                topColor: UIColor(red: 0.35, green: 0.55, blue: 0.78, alpha: gradientAlpha),
                bottomColor: UIColor(red: 0.5, green: 0.65, blue: 0.85, alpha: gradientAlpha)
            )
        case 1066, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258:
            return .init(
                topColor: UIColor(red: 0.85, green: 0.9, blue: 0.95, alpha: gradientAlpha),
                bottomColor: UIColor(red: 0.7, green: 0.82, blue: 0.92, alpha: gradientAlpha)
            )
        case 1087, 1273, 1276, 1279, 1282:
            return .init(
                topColor: UIColor(red: 0.35, green: 0.3, blue: 0.45, alpha: gradientAlpha),
                bottomColor: UIColor(red: 0.5, green: 0.45, blue: 0.6, alpha: gradientAlpha)
            )
        default:
            return .init(
                topColor: UIColor(red: 0.6, green: 0.72, blue: 0.88, alpha: gradientAlpha),
                bottomColor: UIColor(red: 0.75, green: 0.82, blue: 0.92, alpha: gradientAlpha)
            )
        }
    }

    /// Градиент по умолчанию (загрузка, ошибка)
    static var `default`: WeatherBackgroundConfig {
        .init(
            topColor: UIColor(red: 0.55, green: 0.62, blue: 0.73, alpha: gradientAlpha),
            bottomColor: UIColor(red: 0.7, green: 0.76, blue: 0.85, alpha: gradientAlpha)
        )
    }

}
