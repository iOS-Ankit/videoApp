//
//  ViewController.swift
//  MusicApp
//
//  Created by MSS on 23/11/20.
//  Copyright © 2020 Ankit Bansal. All rights reserved.
//

import UIKit
import AVKit

struct TrackInfo {
    var trackName: String
    var trackImage: UIImage
    var trackUrl: String
    var isPlaying: Bool
}

class ViewController: UIViewController {
    
    // MARK: Interface Builder Outlets
    
    @IBOutlet weak var trackListTblVw: UITableView!
    
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var volSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var trackSlider: UISlider!
    
    @IBOutlet weak var seekMinlabel: UILabel!
    @IBOutlet weak var seekMaxlabel: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    
    @IBOutlet weak var listVwLeading: NSLayoutConstraint!
    
    // MARK: Interface Builder Properties
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var tracksArray = [TrackInfo]()
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIElements()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape {
            self.playerLayer?.videoGravity = .resizeAspectFill
        } else {
            self.playerLayer?.videoGravity = .resizeAspect
        }
        
        self.playerView.frame.size = size
        self.playerLayer?.frame.size = size
        
        self.listVwLeading.constant = size.width
    }
    
    // MARK: Helper Functions
    
    func setupUIElements() {
        
        trackListTblVw.tableFooterView = UIView()
        
        self.listVwLeading.constant = self.view.frame.width
        seekMinlabel.text = "00.00"
        seekMaxlabel.text = "00.00"
        
        let track1 = TrackInfo(trackName: "For Bigger Blazes", trackImage: #imageLiteral(resourceName: "cover"), trackUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", isPlaying: false)
        let track2 = TrackInfo(trackName: "For Bigger Meltdowns", trackImage: #imageLiteral(resourceName: "cover"), trackUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", isPlaying: false)
        let track3 = TrackInfo(trackName: "Sintel", trackImage: #imageLiteral(resourceName: "cover"), trackUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4", isPlaying: false)
        let track4 = TrackInfo(trackName: "Tears of Steel", trackImage: #imageLiteral(resourceName: "cover"), trackUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4", isPlaying: false)
        let track5 = TrackInfo(trackName: "We Are Going On Bullrun", trackImage: #imageLiteral(resourceName: "cover"), trackUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4", isPlaying: false)
        
        tracksArray.append(track1)
        tracksArray.append(track2)
        tracksArray.append(track3)
        tracksArray.append(track4)
        tracksArray.append(track5)
        trackListTblVw.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = tracksArray[0].trackName
    }
    
    func controlsSetup(shown: Bool) {
        volSlider.superview?.isHidden = shown
        trackSlider.isHidden = shown
        seekMinlabel.isHidden = shown
        seekMaxlabel.isHidden = shown
        playPauseBtn.isHidden = shown
        nextBtn.isHidden = shown
        previousBtn.isHidden = shown
    }
    
    /**
     Call this function to play track no from list of tracks.
     */
    
    func playMusic(_ atIndex: Int) {
        self.title = tracksArray[atIndex].trackName
        initializePlayer(tracksArray[atIndex].trackUrl)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playPauseBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.player?.play()
        }
    }
    
    /**
     This function to Initialize Player.
     */
    
    func initializePlayer(_ playableItem: String) {
        if player != nil {
            player?.pause()
            playerLayer?.removeFromSuperlayer()
            player = nil
            playerLayer = nil
            seekMinlabel.text = "00.00"
            seekMaxlabel.text = "00.00"
            trackSlider.value = 0
        }
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = playerView.bounds
        playerLayer?.videoGravity = .resizeAspect
        if let layer = playerLayer {
            playerView.layer.addSublayer(layer)
        }
        let videoURL = URL(string: playableItem)!
        let playerItem = AVPlayerItem(url: videoURL)
        player?.replaceCurrentItem(with: playerItem)
        self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { (time) in
            if self.player!.currentItem?.status == .readyToPlay {
                self.updateTime()
            }
        })
    }
    
    /**
     Call this function to update the value of the slider.
     */
    
    func updateTime() {
        // Access current item
        if let currentItem = self.player?.currentItem {
            // Get the current time in seconds
            let playhead = currentItem.currentTime().seconds
            let duration = currentItem.duration.seconds
            // Format seconds for readable text
            trackSlider.minimumValue = 0
            trackSlider.value = Float(playhead)
            trackSlider.maximumValue = Float(duration)
            self.seekMinlabel.text = formatTimeFor(seconds: playhead)
            self.seekMaxlabel.text = formatTimeFor(seconds: duration)
            
            if self.seekMinlabel.text == self.seekMaxlabel.text {
                nextBtnAction(nextBtn)
            }
        }
    }
    
    // MARK: Handel Animation
    
    /**
     Call this function to expand and collapse tracks list.
     */
    
    func animateViewFromLeading(_ leading: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.listVwLeading.constant = leading
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Handel Duration
    
    /**
     Call this function to get duration of track.
     */
    
    func getHoursMinutesSecondsFrom(_ seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    /**
     Call this function to get formated readable duration of track.
     */
    
    func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }
    
    // MARK: Interface Builder Actions
    
    @IBAction func expandListView(sender: UIBarButtonItem) {
        self.animateViewFromLeading(0)
    }
    
    @IBAction func collapseListView(sender: UIButton) {
        self.animateViewFromLeading(self.view.frame.width)
    }
    
    @IBAction func playPauseButton(sender: UIButton) {
        if player != nil {
            if player?.timeControlStatus == .playing {
                self.playPauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
                player?.pause()
            } else {
                self.playPauseBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                player?.play()
            }
        } else {
            self.playMusic(currentIndex)
        }
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        if currentIndex < tracksArray.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        self.playMusic(currentIndex)
    }
    
    @IBAction func previousBtnAction(_ sender: UIButton) {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = tracksArray.count - 1
        }
        self.playMusic(currentIndex)
    }
    
    @IBAction func hideControlsBtnAction(_ sender: UIButton) {
        if player != nil {
            sender.isSelected = !sender.isSelected
            self.controlsSetup(shown: sender.isSelected)
        }
    }
    
    @IBAction func trackSliderAction(_ sender: UISlider) {
        if player != nil {
            if let _ = self.player?.currentItem {
                let seconds = sender.value
                player?.seek(to: CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }
    
    @IBAction func volumeSliderAction(_ sender: UISlider) {
        player?.volume = Float(sender.value)/10
    }
    
    @IBAction func volumeMinAction(_ sender: UIButton) {
        player?.volume = 0
        volSlider.value = 0
    }
    
    @IBAction func volumeMaxAction(_ sender: UIButton) {
        player?.volume = 10
        volSlider.value = 10
    }
    
    @IBAction func brightnessSliderAction(_ sender: UISlider) {
        self.playerView.alpha = CGFloat(sender.value)
    }
    
    @IBAction func brightnessMinAction(_ sender: UIButton) {
        self.playerView.alpha = 0.5
        brightnessSlider.value = 0.5
    }
    
    @IBAction func brightnessMaxAction(_ sender: UIButton) {
         self.playerView.alpha = 1
        brightnessSlider.value = 1
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell", for: indexPath) as!  TrackTableViewCell
        cell.setCellData(trackDetail: tracksArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndex = indexPath.row
        self.playMusic(indexPath.row)
        self.animateViewFromLeading(self.view.frame.width)
    }
}

