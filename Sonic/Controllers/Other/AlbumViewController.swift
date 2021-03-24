//
//  AlbumViewController.swift
//  Sonic
//
//  Created by Tarek on 23/03/2021.
//

import UIKit

class AlbumViewController: UIViewController {

    private let album: Album
    
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name ?? "Album"
        view.backgroundColor = .systemBackground
        
        
        APICaller.shared.getAlbumDetails(for: album) { [weak self] result in
            switch result {
            case .success(let model):
                print(model)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    

}
