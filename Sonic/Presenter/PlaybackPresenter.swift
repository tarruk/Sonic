//
//  PlaybackPresenter.swift
//  Sonic
//
//  Created by Tarek on 04/04/2021.
//

import AVFoundation
import Foundation
import UIKit

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}

final class PlaybackPresenter {
    
    static let shared = PlaybackPresenter()
    
    var index = 0
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?
    var playerVc: PlayerViewController?
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        } else if let player = playerQueue, !tracks.isEmpty {
            return tracks[index]
                  
        } else {
            return nil
        }
    }
    
    func startPlayback(
        from viewController: UIViewController,
        track: AudioTrack
    ) {
        guard let url = URL(string: track.previewUrl ?? "") else {
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        self.tracks = []
        self.track = track
        
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        viewController.present(nav, animated: true, completion: { [weak self] in
            self?.player?.play()
        })
        
        playerVc = vc
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]) {
        
        self.tracks = tracks
        self.track = nil
        
        let items: [AVPlayerItem] = tracks.compactMap({
            guard let url = URL(string: $0.previewUrl ?? "") else {
                return nil
            }
            return AVPlayerItem(url: url)
        })
        
        self.playerQueue = AVQueuePlayer(items: items)
        self.playerQueue?.volume = 0.5
        let vc = PlayerViewController()
        
        vc.title = currentTrack?.name
        vc.dataSource = self
        vc.delegate = self
        
        let nav = UINavigationController(rootViewController: vc)
        viewController.present(nav, animated: true, completion: { [weak self] in
            self?.playerQueue?.play()
        })
        
        playerVc = vc
    }
    
    
}

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        } else if let player = playerQueue {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            //Not playlist or album
          
        } else if let player = playerQueue {
            player.advanceToNextItem()
            index += 1
            playerVc?.refreshUI()
        }
        
        
    }
    
    func didTapBackward() {
        if tracks.isEmpty {
            //Not playlist or album
           
        } else if let player = playerQueue, let firstItem = player.items().first {
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.play()
            playerQueue?.volume = 0.5
            
        }
        
    }
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
    
    
    
    
}
