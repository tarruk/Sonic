//
//  AlbumViewController.swift
//  Sonic
//
//  Created by Tarek on 23/03/2021.
//

import UIKit

class AlbumViewController: UIViewController {

    
    
    private let album: Album
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _  -> NSCollectionLayoutSection? in
        //Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
        
        //Vertical group in horizontal group

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(60)),
            subitem: item,
            count: 1
        )
        //Section
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
        ]
        return section
    })
    )
    
    private var viewModels = [AlbumTrackCellViewModel]()
    private var tracks = [AudioTrack]()
    
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
        
        view.addSubview(collectionView)
        collectionView.register(AlbumTrackCollectionViewCell.self, forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier)
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
      
        APICaller.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    guard let tracks = model.tracks?.tracks else { return }
                    self?.tracks = model.tracks?.tracks ?? []
                    self?.viewModels = tracks.compactMap({
                        return AlbumTrackCellViewModel(
                            name: $0.name ?? "",
                            artistName: $0.artists.first?.name ?? ""
                        )
                    
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    
    

}

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let track = viewModels[indexPath.row]
        guard let albumCell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTrackCollectionViewCell.identifier, for: indexPath) as? AlbumTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        albumCell.configure(with: AlbumTrackCellViewModel(name: track.name, artistName: track.artistName))
        return albumCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
                for: indexPath) as? PlaylistHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        header.configure(with: PlaylistHeaderViewModel(
                            name: album.name,
                            ownerName: album.artists.first?.name,
                            description: "Release date: \(String.formatDate(string: album.releaseDate ?? ""))",
                            artworkURL: URL(string: album.images.first?.url ?? ""))
        )
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        var track = tracks[indexPath.row]
        track.album = album
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
    
    
}


extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        //Start play list play in queue
    
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap({
            var track = $0
            track.album = self.album
            return track
        })
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum)
    }
    
   
}
