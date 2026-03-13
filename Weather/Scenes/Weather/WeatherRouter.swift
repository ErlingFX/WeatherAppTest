//
//  WeatherRouter.swift
//  Weather
//

import UIKit

/// Роутинг для Weather сцены
final class WeatherRouter {

    static func createModule() -> WeatherViewController {
        let viewController = WeatherViewController()
        let interactor = WeatherInteractor()
        let presenter = WeatherPresenter()
        let router = WeatherRouter()

        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController

        return viewController
    }

}
