//
//  LibraryViewController.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import UIKit

class LibraryViewController: UIViewController {

    private let playlistsVC = LibraryPlaylistViewController()
    private let albumsVC = LibraryAlbumViewController()
    private let toggleView = LibraryToggleView()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true

        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        scrollView.delegate = self
        toggleView.delegate = self
        view.addSubview(scrollView)
        view.addSubview(toggleView)
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        addChildren()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top+55,
            width: view.width,
            height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55
        )
        
        toggleView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: 55
        )
    }
    
    private func addChildren() {
        addChild(playlistsVC)
        playlistsVC.view.backgroundColor = .cyan
        scrollView.addSubview(playlistsVC.view)
        playlistsVC.view.frame = CGRect(
            x: 0,
            y: 0,
            width: scrollView.width,
            height: scrollView.height
        )
        playlistsVC.didMove(toParent: self)
        
        addChild(albumsVC)
        albumsVC.view.backgroundColor = .systemTeal
        scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(
            x: view.width,
            y: 0,
            width: scrollView.width,
            height: scrollView.height
        )
        albumsVC.didMove(toParent: self)
    }

   

}

extension LibraryViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= view.width-100 {
            self.toggleView.updateForState(.albums)
        } else {
            self.toggleView.updateForState(.playlists)
        }
    }
    
}


extension LibraryViewController: LibraryToggleViewDelegate {
    func didTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
    }
    
    func didTapPlaylists(_ toogleView: LibraryToggleView) {
        scrollView.setContentOffset(.zero, animated: true)
        
    }
}
