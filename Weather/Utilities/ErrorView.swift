//
//  ErrorView.swift
//  Weather
//

import UIKit
import SnapKit

/// Переиспользуемый экран ошибки с кнопкой повтора
final class ErrorView: UIView {

    var onRetry: (() -> Void)?

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Повторить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        isHidden = true

        addSubview(messageLabel)
        addSubview(retryButton)

        messageLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        retryButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    @objc private func retryTapped() {
        onRetry?()
    }

    func configure(message: String) {
        messageLabel.text = message
    }

    func show() {
        isHidden = false
    }

    func hide() {
        isHidden = true
    }

}
