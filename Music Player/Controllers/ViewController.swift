//
//  ViewController.swift
//  Music Player
//
//  Created by Damir Yackupov on 15.12.2021.
//

import UIKit
import AVKit

class ViewController: UIViewController, UITableViewDelegate {

    var musicTableView: UITableView!
    var playerSmallView: PlayerSmallView!
    static var songsModel = SongsModel()
    static var chosenSong: String?
    static var songIndex: Int?

    static var player = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Music"
        navigationController?.navigationBar.prefersLargeTitles = true
        loadSongs()
        setupTableView()

        let playerSmallViewTap = UITapGestureRecognizer(target: self, action: #selector(playerSmallViewClicked(_:)))
        playerSmallView.isUserInteractionEnabled = true
        playerSmallView.addGestureRecognizer(playerSmallViewTap)

        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlayerSmallView(_:)), name: NSNotification.Name(rawValue: "updatePlayerSmallView"), object: nil)

        //Add Songs Assets
        for item in ViewController.songsModel.songs {
            let path = Bundle.main.path(forResource: item, ofType: nil)!
            let url = URL(fileURLWithPath: path)
            let asset = AVAsset(url: url) as AVAsset
            for metaDataItems in asset.commonMetadata {

                if metaDataItems.commonKey?.rawValue == "artwork" {
                    let imageData = metaDataItems.value as! NSData
                    let image2: UIImage = UIImage(data: imageData as Data)!
                    ViewController.songsModel.albumImage.append(image2)
                }

                if metaDataItems.commonKey?.rawValue == "title" {
                    let titleData = metaDataItems.value
                    ViewController.songsModel.songName.append(titleData as! String)
                }

                if metaDataItems.commonKey?.rawValue == "artist" {
                    let artistData = metaDataItems.value
                    ViewController.songsModel.artist.append(artistData as! String)
                }
            }
        }
    }

    override func viewWillLayoutSubviews() {
        musicTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: playerSmallView.frame.size.height + 60, right: 0)
    }

    //Load songs from bundle
    func loadSongs () {
        DispatchQueue.global(qos: .userInitiated).async {
            let fm = FileManager.default
            let path = Bundle.main.resourcePath!
            let items = try! fm.contentsOfDirectory(atPath: path)

            for item in items {
                if item.hasSuffix("mp3") {
                    ViewController.songsModel.songs.append(item)
                }
            }
        }
    }

    static func setupPlayer() {
        let path = Bundle.main.path(forResource: ViewController.chosenSong, ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            ViewController.player = try AVAudioPlayer(contentsOf: url)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print(error)
        }
    }

    // presenting PlayerViewController
    @objc func playerSmallViewClicked(_ sender: Any) {
        let vc = PlayerViewController()
        vc.modalPresentationStyle = .popover
        self.present(vc, animated: true)
    }

    //Method for changing smallPlayerView image and label
    @objc func updatePlayerSmallView(_ notification: NSNotification) {
        playerSmallView.albumImageView.image = ViewController.songsModel.albumImage[ViewController.songIndex!]
        playerSmallView.musicNameLabel.text = ViewController.songsModel.songName[ViewController.songIndex!]
        ViewController.player.delegate = self
    }

}

// configuring musicTableView and playerSmallView
private extension ViewController {
    func setupTableView() {
        musicTableView = UITableView()
        playerSmallView = PlayerSmallView()
        musicTableView.delegate = self
        musicTableView.dataSource = self
        musicTableView.register(MusicTableCell.self, forCellReuseIdentifier: MusicTableCell.identifier)

        musicTableView.translatesAutoresizingMaskIntoConstraints = false
        playerSmallView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(musicTableView)
        musicTableView.addSubview(playerSmallView)

        NSLayoutConstraint.activate([
            musicTableView.topAnchor.constraint(equalTo: view.topAnchor),
            musicTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            musicTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            musicTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])

        NSLayoutConstraint.activate([
            playerSmallView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            playerSmallView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            playerSmallView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            playerSmallView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.09)
            ])
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.songsModel.songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = musicTableView.dequeueReusableCell(withIdentifier: MusicTableCell.identifier, for: indexPath) as! MusicTableCell
        cell.songNameTextLabel.text = ViewController.songsModel.songName[indexPath.row]
        cell.albumImageView.image = ViewController.songsModel.albumImage[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        ViewController.chosenSong = ViewController.songsModel.songs[indexPath.row]
        ViewController.songIndex = indexPath.row
        ViewController.setupPlayer()
        ViewController.player.delegate = self
        ViewController.player.play()

        //configuring items on PlayerViewController
        PlayerViewController.albumAtwork = ViewController.songsModel.albumImage[indexPath.row]
        PlayerViewController.songName = ViewController.songsModel.songName[indexPath.row]
        PlayerViewController.artistName = ViewController.songsModel.artist[indexPath.row]

        playerSmallView.albumImageView.image = ViewController.songsModel.albumImage[indexPath.row]
        playerSmallView.musicNameLabel.text = ViewController.songsModel.songName[indexPath.row]
    }
}

// switching the track when the song ends
extension ViewController: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "songFinishPlaying"), object: nil)
    }
}
