//
//  PlayerViewController.swift
//  Music Player
//
//  Created by Damir Yackupov on 07.01.2022.
//

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController {

    static var albumAtwork: UIImage?
    static var songName: String?
    static var artistName: String?
    var playingSong: String?
    
    //configurations for buttons
    let largeConfig = UIImage.SymbolConfiguration(pointSize: 20)
    let largeControlConfig = UIImage.SymbolConfiguration(pointSize: 25)
    let largePlayConfig = UIImage.SymbolConfiguration(pointSize: 45)
    let sliderConfig = UIImage.SymbolConfiguration(pointSize: 10)

    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "chevron.compact.down", withConfiguration: largeConfig)?.withTintColor(.systemGray)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        return button
    }()

    lazy var albumImageView: UIImageView = {
        let image = UIImageView()
        image.image = PlayerViewController.albumAtwork ?? UIImage(systemName: "music.note")
        image.contentMode = .scaleAspectFit
        return image
    }()

    private lazy var musicNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.text = PlayerViewController.songName ?? "Not Playing"
        return label
    }()

    private lazy var artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.text = PlayerViewController.artistName ?? " "
        return label
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "ellipsis.circle.fill", withConfiguration: largeConfig)?.withTintColor(.white)
        button.setImage(image, for: .normal)
        return button
    }()

    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [musicNameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var nameStackView: UIStackView = {
        let spacer = UIView()
        spacer.layer.borderWidth = 1
        spacer.layer.borderColor = UIColor.red.cgColor
        let stackView = UIStackView(arrangedSubviews: [descriptionStackView, moreButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.setCustomSpacing(80, after: descriptionStackView)
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var musicProgressSlider: UISlider = {
        let slider = UISlider()
        slider.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10))?.withTintColor(.systemGray), for: .normal)
        Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        slider.addTarget(self, action: #selector(slide), for: .touchUpInside)
        return slider
    }()

    private lazy var backwardButton: UIButton = {
        var button = UIButton()
        let image = UIImage(systemName: "backward.fill", withConfiguration: largeControlConfig)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(previousSong), for: .touchUpInside)
        return button
    }()

    private lazy var playPauseButton: UIButton = {
        var button = UIButton()
        return button
    }()

    private lazy var forwardButton: UIButton = {
        var button = UIButton()
        let image = UIImage(systemName: "forward.fill", withConfiguration: largeControlConfig)?.withTintColor(.white)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(PlayerViewController.nextSong), for: .touchUpInside)
        return button
    }()

    private lazy var controlStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [backwardButton, playPauseButton, forwardButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var volumeSlider: MPVolumeView = {
        let volumeView = MPVolumeView()
        volumeView.showsRouteButton = false

        var a = UIView()
        for view in volumeView.subviews {
            if type(of: view).description() == "MPVolumeSlider" {
                a = view
                (a as? UISlider)?.minimumValueImage = UIImage(systemName: "speaker.fill", withConfiguration: sliderConfig)
                (a as? UISlider)?.maximumValueImage = UIImage(systemName: "speaker.wave.3.fill", withConfiguration: sliderConfig)
                (a as? UISlider)?.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
            }
        }
        return volumeView
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        return blurEffectView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PlayerViewController.songName == nil {
            let playImage = UIImage(systemName: "play.fill", withConfiguration: largePlayConfig)
            playPauseButton.setImage(playImage, for: .normal)
        } else {
            if ViewController.player.isPlaying == true {
                let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: largePlayConfig)
                playPauseButton.setImage(pauseImage, for: .normal)
                playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
            } else {
                let playImage = UIImage(systemName: "play.fill", withConfiguration: largePlayConfig)
                playPauseButton.setImage(playImage, for: .normal)
                playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
            }
        }

        musicProgressSlider.maximumValue = Float(ViewController.player.duration)
        musicProgressSlider.value = Float(ViewController.player.currentTime)
        playingSong = ViewController.chosenSong ?? nil

        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(nextSong), name: NSNotification.Name(rawValue: "songFinishPlaying"), object: nil)
    }

    private func setupConstraints() {
        
        [blurEffectView, dismissButton, albumImageView, nameStackView, musicProgressSlider, controlStackView, volumeSlider].forEach { view.addSubview($0) }
        [dismissButton, albumImageView, nameStackView, musicProgressSlider, controlStackView, volumeSlider].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 15),
            dismissButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            dismissButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),

            albumImageView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 15),
            albumImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            albumImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            albumImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.48),

            nameStackView.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 25),
            nameStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            nameStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            nameStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08),

            musicProgressSlider.topAnchor.constraint(equalTo: nameStackView.bottomAnchor, constant: 5),
            musicProgressSlider.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            musicProgressSlider.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),

            controlStackView.topAnchor.constraint(equalTo: musicProgressSlider.bottomAnchor, constant: 30),
            controlStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            controlStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40),
            controlStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.09),

            volumeSlider.topAnchor.constraint(equalTo: controlStackView.bottomAnchor, constant: 30),
            volumeSlider.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            volumeSlider.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            volumeSlider.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06),

            ])
    }

    @objc private func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //updating musicProgress value from player current time
    @objc private func updateTime(_ timer: Timer) {
        musicProgressSlider.value = Float(ViewController.player.currentTime)
    }
    
    // changing player current time from slider value
    @objc private func slide(_ slider: UISlider) {
        ViewController.player.currentTime = TimeInterval(slider.value)
        ViewController.player.play()
    }

    @objc private func didTapPlayPauseButton() {

        if ViewController.player.isPlaying == true {
            // pause
            ViewController.player.pause()
            // show play button
            let playImage = UIImage(systemName: "play.fill", withConfiguration: largePlayConfig)
            playPauseButton.setImage(playImage, for: .normal)

        }
        else {
            // play
            ViewController.player.play()
            let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: largePlayConfig)
            playPauseButton.setImage(pauseImage, for: .normal)
        }
    }

    @objc private func nextSong() {
        if ViewController.songIndex != nil {
            if ViewController.songsModel.songs.count > ViewController.songIndex! + 1 {

                ViewController.player.stop()
                ViewController.songIndex! += 1
                ViewController.chosenSong = ViewController.songsModel.songs[ViewController.songIndex!]
                ViewController.setupPlayer()

                PlayerViewController.albumAtwork = ViewController.songsModel.albumImage[ViewController.songIndex!]
                PlayerViewController.songName = ViewController.songsModel.songName[ViewController.songIndex!]
                PlayerViewController.artistName = ViewController.songsModel.artist[ViewController.songIndex!]

                albumImageView.image = ViewController.songsModel.albumImage[ViewController.songIndex!]
                musicNameLabel.text = ViewController.songsModel.songName[ViewController.songIndex!]
                artistNameLabel.text = ViewController.songsModel.artist[ViewController.songIndex!]
                ViewController.player.play()
                musicProgressSlider.maximumValue = Float(ViewController.player.duration)
                
                let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: largePlayConfig)
                playPauseButton.setImage(pauseImage, for: .normal)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePlayerSmallView"), object: nil)
            }
            else {
                ViewController.player.stop()
                let pauseImage = UIImage(systemName: "play.fill", withConfiguration: largePlayConfig)
                playPauseButton.setImage(pauseImage, for: .normal)
            }
        }
    }

    @objc private func previousSong() {
        if ViewController.songIndex != nil {
            if ViewController.songIndex! != 0 {

                ViewController.player.stop()
                ViewController.songIndex! -= 1
                ViewController.chosenSong = ViewController.songsModel.songs[ViewController.songIndex!]
                ViewController.setupPlayer()

                PlayerViewController.albumAtwork = ViewController.songsModel.albumImage[ViewController.songIndex!]
                PlayerViewController.songName = ViewController.songsModel.songName[ViewController.songIndex!]
                PlayerViewController.artistName = ViewController.songsModel.artist[ViewController.songIndex!]

                albumImageView.image = ViewController.songsModel.albumImage[ViewController.songIndex!]
                musicNameLabel.text = ViewController.songsModel.songName[ViewController.songIndex!]
                artistNameLabel.text = ViewController.songsModel.artist[ViewController.songIndex!]
                musicProgressSlider.maximumValue = Float(ViewController.player.duration)
                
                let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: largePlayConfig)
                playPauseButton.setImage(pauseImage, for: .normal)

                ViewController.player.play()

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePlayerSmallView"), object: nil)
            }
        }
    }
}
