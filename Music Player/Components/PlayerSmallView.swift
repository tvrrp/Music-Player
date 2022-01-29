//
//  PlayerSmallView.swift
//  Music Player
//
//  Created by Damir Yackupov on 21.01.2022.
//

import UIKit

class PlayerSmallView: UIView {

    static var songName: String?
    static var albumAtwork: UIImage?

    lazy var albumImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "music.note")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 5
        image.layer.masksToBounds = true
        return image
    }()

    lazy var musicNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.text = "Not Playing"
        label.textAlignment = .left
        return label
    }()

    private lazy var controlStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [albumImageView, musicNameLabel, spacer])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.setCustomSpacing(10, after: albumImageView)
        stackView.setCustomSpacing(10, after: musicNameLabel)
        return stackView
    }()

    private lazy var blurEffect: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        blurEffect.frame = CGRect(x: 0, y: 0, width: 1000, height: 100)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        self.setupView()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(blurEffect)
        addSubview(controlStackView)

        NSLayoutConstraint.activate([

            albumImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.75),
            albumImageView.widthAnchor.constraint(equalTo: albumImageView.heightAnchor),

            controlStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            controlStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            controlStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            controlStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),

            ])
    }
}
