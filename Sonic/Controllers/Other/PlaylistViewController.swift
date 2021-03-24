//
//  PlaylistViewController.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import UIKit

class PlaylistViewController: UIViewController {

    
    private let playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name ?? "Playlist"
        view.backgroundColor = .systemBackground
        
        APICaller.shared.getPlaylistDetails(for: playlist) { [weak self] result in
            switch result {
            case .success(let model):
                break
            case .failure(let error):
                break
            }
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
