//
//  LoadingView.swift
//  Weather
//

import UIKit
import SnapKit

/// Переиспользуемый индикатор загрузки
final class LoadingView: UIView {

    private let activityIndicator = UIActivityIndicatorView(style: .large)

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

        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func show() {
        isHidden = false
        activityIndicator.startAnimating()
    }

    func hide() {
        isHidden = true
        activityIndicator.stopAnimating()
    }

}
