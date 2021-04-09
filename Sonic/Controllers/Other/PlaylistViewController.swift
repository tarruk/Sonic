//
//  PlaylistViewController.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import UIKit

class PlaylistViewController: UIViewController {

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
    
    private let playlist: Playlist
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()
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
        view.addSubview(collectionView)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        APICaller.shared.getPlaylistDetails(for: playlist) { [weak self] result in

            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    guard let tracks = model.tracks else {
                        return
                    }
                    self?.tracks = model.tracks?.items.compactMap({$0.track}) ?? []
                    self?.viewModels =
                        tracks.items.compactMap({
                            return RecommendedTrackCellViewModel(
                                name: $0.track?.name ?? "",
                                artistName: $0.track?.artists.first?.name ?? "",
                                artworkURL: URL(string: $0.track?.album?.images.first?.url ?? "")
                            )
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
            }
            
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
    }

    @objc func didTapShare() {
        guard let url = URL(string: playlist.externalUrls?.spotify ?? "") else {
            return
        }
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: []
        )
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}


extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
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
                            name: playlist.name,
                            ownerName: playlist.owner?.displayName,
                            description: playlist.description,
                            artworkURL: URL(string: playlist.images?.first?.url ?? ""))
        )
        header.delegate = self
        return header
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        var track = tracks[indexPath.row]
        track.album?.images = playlist.images ?? []
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
        
    }
    
    
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        //Start play list play in queue
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
    
   
}
