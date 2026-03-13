//
//  WeatherViewController.swift
//  Weather
//

import UIKit
import SnapKit

protocol WeatherDisplayLogic: AnyObject {
    func displayLoading()
    func displayWeather(viewModel: Weather.Load.ViewModel)
    func displayError(message: String)
}

final class WeatherViewController: UIViewController {

    var interactor: WeatherBusinessLogic?
    var router: WeatherRouter?

    private var hourlyItems: [HourlyItem] = []
    private var dailyItems: [DailyItem] = []

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        return stack
    }()

    private let currentWeatherView = CurrentWeatherView()
    private let loadingView = LoadingView()
    private let errorView = ErrorView()

    private let gradientLayer = CAGradientLayer()

    private lazy var hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 60, height: 100)
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.reuseId)
        return cv
    }()

    private lazy var dailyTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.isScrollEnabled = false
        table.delegate = self
        table.dataSource = self
        table.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.reuseId)
        table.rowHeight = 56
        table.separatorInset = .zero
        table.backgroundColor = .clear
        table.layer.cornerRadius = 12
        table.clipsToBounds = true
        return table
    }()

    private var dailyTableHeightConstraint: Constraint?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupErrorRetry()
        loadWeather()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Погода"

        view.backgroundColor = UIColor(white: 0.96, alpha: 1)

        gradientLayer.colors = [
            WeatherBackgroundProvider.default.topColor.cgColor,
            WeatherBackgroundProvider.default.bottomColor.cgColor
        ]
        gradientLayer.locations = [0, 1]
        view.layer.insertSublayer(gradientLayer, at: 0)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        view.addSubview(loadingView)
        view.addSubview(errorView)

        contentStackView.addArrangedSubview(currentWeatherView)
        contentStackView.addArrangedSubview(hourlySectionView())
        contentStackView.addArrangedSubview(dailySectionView())
        contentStackView.setCustomSpacing(32, after: currentWeatherView)
        contentStackView.setCustomSpacing(32, after: contentStackView.arrangedSubviews[1])

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        errorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func hourlySectionView() -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "Почасовой прогноз"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label

        container.addSubview(titleLabel)
        container.addSubview(hourlyCollectionView)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(24)
        }

        hourlyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(110)
            make.bottom.equalToSuperview()
        }

        return container
    }

    private func dailySectionView() -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "Прогноз на 3 дня"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label

        container.addSubview(titleLabel)
        container.addSubview(dailyTableView)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(24)
        }

        dailyTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            dailyTableHeightConstraint = make.height.equalTo(0).constraint
        }

        return container
    }

    private func setupErrorRetry() {
        errorView.onRetry = { [weak self] in
            self?.loadWeather()
        }
    }

    private func loadWeather() {
        interactor?.loadWeather(request: Weather.Load.Request())
    }

    private func updateDailyTableHeight() {
        dailyTableView.layoutIfNeeded()
        let height = dailyTableView.contentSize.height
        dailyTableHeightConstraint?.update(offset: max(height, 1))
    }

}

// MARK: - WeatherDisplayLogic

extension WeatherViewController: WeatherDisplayLogic {

    func displayLoading() {
        loadingView.show()
        errorView.hide()
        contentStackView.isHidden = true
    }

    func displayWeather(viewModel: Weather.Load.ViewModel) {
        loadingView.hide()
        errorView.hide()
        contentStackView.isHidden = false

        let config = WeatherBackgroundProvider.background(for: viewModel.conditionCode)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.gradientLayer.colors = [config.topColor.cgColor, config.bottomColor.cgColor]
        }

        currentWeatherView.configure(
            city: viewModel.city,
            temperature: viewModel.temperature,
            condition: viewModel.condition,
            iconURL: viewModel.iconURL
        )

        hourlyItems = viewModel.hourly
        dailyItems = viewModel.daily
        hourlyCollectionView.reloadData()
        dailyTableView.reloadData()

        DispatchQueue.main.async { [weak self] in
            self?.updateDailyTableHeight()
        }
    }

    func displayError(message: String) {
        loadingView.hide()
        contentStackView.isHidden = true
        errorView.configure(message: message)
        errorView.show()
    }

}

// MARK: - UICollectionView

extension WeatherViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hourlyItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCell.reuseId, for: indexPath) as! HourlyForecastCell
        let item = hourlyItems[indexPath.item]
        cell.configure(hour: item.hour, temperature: item.temperature, iconURL: item.iconURL)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 60, height: 100)
    }

}

// MARK: - UITableView

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dailyItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastCell.reuseId, for: indexPath) as! DailyForecastCell
        let item = dailyItems[indexPath.row]
        cell.configure(dayName: item.dayName, minTemp: item.minTemperature, maxTemp: item.maxTemperature, iconURL: item.iconURL)
        return cell
    }

}
