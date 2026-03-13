//
//  HourlyForecastCell.swift
//  Weather
//

import UIKit
import SnapKit

/// Ячейка почасового прогноза
final class HourlyForecastCell: UICollectionViewCell {

    static let reuseId = "HourlyForecastCell"

    private let hourLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
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

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(hourLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(tempLabel)

        hourLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(hourLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.size.equalTo(32)
        }

        tempLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    func configure(hour: String, temperature: String, iconURL: String) {
        hourLabel.text = hour
        tempLabel.text = temperature
        loadIcon(from: iconURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
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
