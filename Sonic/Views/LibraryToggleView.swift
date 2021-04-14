//
//  LibraryToggleView.swift
//  Sonic
//
//  Created by Tarek on 09/04/2021.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func didTapPlaylists(_ toogleView: LibraryToggleView)
    func didTapAlbums(_ toggleView: LibraryToggleView)
}


class LibraryToggleView: UIView {

    enum State {
        case playlists
        case albums
    }
    
    var currentState: State = .playlists
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let playlistButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(.label, for: [])
        button.setTitle("Playlists", for: [])
        return button
    }()
    
    private let albumButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(.label, for: [])
        button.setTitle("Album", for: [])
        return button
    }()
    
    weak var delegate: LibraryToggleViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(playlistButton)
        addSubview(albumButton)
        addSubview(indicatorView)
        
        playlistButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        
        albumButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(
            x: 0,
            y: 0,
            width: frame.width/3,
            height: 50
        )
        albumButton.frame = CGRect(
            x: playlistButton.right,
            y: 0,
            width: frame.width/3,
            height: 50
        )
        layoutIndicator()
        
    }
    
    private func layoutIndicator() {
        switch currentState {
        case .playlists:
            indicatorView.frame = CGRect(
                x: 0,
                y: playlistButton.bottom,
                width: frame.width/3,
                height: 3
            )
        case .albums:
            indicatorView.frame = CGRect(
                x: albumButton.left,
                y: albumButton.bottom,
                width: frame.width/3,
                height: 3
            )
        }
    }
    
    @objc func didTapPlaylists() {
        currentState = .playlists
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIndicator()
        })
        delegate?.didTapPlaylists(self)
    }
    @objc func didTapAlbums() {
        currentState = .albums
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIndicator()
        })
        delegate?.didTapAlbums(self)
    }
    
    func updateForState(_ state: State) {
        currentState = state
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIndicator()
        })
    }
}
