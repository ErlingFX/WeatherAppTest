//
//  DailyForecastCell.swift
//  Weather
//

import UIKit
import SnapKit

/// Ячейка дневного прогноза
final class DailyForecastCell: UITableViewCell {

    static let reuseId = "DailyForecastCell"

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
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
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(tempLabel)

        dayLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(32)
        }

        tempLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(dayName: String, minTemp: String, maxTemp: String, iconURL: String) {
        dayLabel.text = dayName.capitalized
        tempLabel.text = "\(minTemp) / \(maxTemp)"
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
