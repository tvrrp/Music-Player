//
//  MusicTableCell.swift
//  Music Player
//
//  Created by Damir Yackupov on 15.12.2021.
//

import UIKit

class MusicTableCell: UITableViewCell {

    static let identifier = "MusicTableCell"
    var albumAtwork: String?

    lazy var albumImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()

    lazy var songNameTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel

    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView () {
        [albumImageView, songNameTextLabel].forEach { addSubview($0) }
        setupUI()
    }

    private func setupUI () {

        NSLayoutConstraint.activate([

            albumImageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 1),
            albumImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 1),
            albumImageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -1),
            albumImageView.widthAnchor.constraint(equalTo: layoutMarginsGuide.widthAnchor, multiplier: 0.15),
            albumImageView.heightAnchor.constraint(equalTo: albumImageView.widthAnchor, multiplier: 1.0 / 1.0),

            songNameTextLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 5),
            songNameTextLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -5),
            songNameTextLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 20),
            songNameTextLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 5),

            ])
    }
}
