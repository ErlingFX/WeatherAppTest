//
//  CurrentWeatherView.swift
//  Weather
//

import UIKit
import SnapKit

/// Блок отображения текущей погоды
final class CurrentWeatherView: UIView {

    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64, weight: .light)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(cityLabel)
        addSubview(temperatureLabel)
        addSubview(conditionLabel)
        addSubview(iconImageView)

        cityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(cityLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(64)
        }

        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        conditionLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    func configure(city: String, temperature: String, condition: String, iconURL: String) {
        cityLabel.text = city
        temperatureLabel.text = temperature
        conditionLabel.text = condition
        loadIcon(from: iconURL)
    }

    private func loadIcon(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.iconImageView.image = image
            }
        }.resume()
    }

}
