//
//  ViewController.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import UIKit
import RxSwift
enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel]) //1
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel]) //2
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel]) //3
    
    var title: String {
        switch self {
        case .newReleases:
            return "New Released Albums"
        case .featuredPlaylists:
            return "Featured Playlists"
        case .recommendedTracks:
            return "Recommended"
        }
    }
}
class HomeViewController: UIViewController {

    private var newAlbums: [Album] = []
    private var playlists: [Playlist] = []
    private var tracks: [AudioTrack] = []
    
   let disposeBag = DisposeBag()
    
    private var collectionView: UICollectionView?
    
    private var sections = [BrowseSectionType]()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            return self.createSectionLayout(section: sectionIndex)
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
   
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    private func fetchData() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var newReleases: NewReleasesResponse?
        var featuredPlaylist: FeaturedPlaylistsResponse?
        var recommendations: Recommendation?
        //NewReleases
        APICaller.shared.getNewReleases { [weak self] result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        //Featured Playlists
        APICaller.shared.getFeaturedPlaylist { [weak self] result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let model):
                featuredPlaylist = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        //Recommended Tracks
        APICaller.shared.getRecommendedGenres { [weak self] (result) in
            guard let self = self else {return}
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                APICaller.shared
                    .getRecommendations(genres: seeds)
                    .observe(on: MainScheduler.instance)
                    .subscribe(
                        onSuccess: { apiRecommendations in
                            defer {
                                dispatchGroup.leave()
                            }
                            recommendations = apiRecommendations
                        },
                        onFailure: { error in
                            debugPrint(error.localizedDescription)
                        }).disposed(by: self.disposeBag)
            case .failure(let error):
                debugPrint(error)
            }
        }
        dispatchGroup.notify(queue: .main) {
            guard let newAlbums = newReleases?.albumResponse?.albums,
                  let playlists = featuredPlaylist?.playlistsResponse?.playlists,
                  let tracks = recommendations?.tracks else {
                fatalError("Models are Nil")
                return
             }
            self.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
        }
        
       
    }
    
    private func configureModels(
        newAlbums   : [Album],
        playlists   : [Playlist],
        tracks      : [AudioTrack]
    ) {
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
    
        
        //Configure Models
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(
                name: $0.name ?? "",
                artworkURL: URL(string: $0.images.first?.url ?? ""),
                numberOfTracks: $0.totalTracks ?? 0,
                artistName: $0.artists.first?.name ?? ""
            )
        })))
        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(
                name: $0.name ?? "",
                artworkURL: URL(string: $0.images?.first?.url ?? ""),
                creatorName: $0.owner?.displayName ?? ""
            )
        })))
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTrackCellViewModel(
                name: $0.name ?? "",
                artistName: $0.artists.first?.name ?? "",
                artworkURL: URL(string: $0.album?.images.first?.url ?? "")
            )
        })))
        collectionView?.reloadData()
    }

}

//MARK: - CollectionView -

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases(let viewModels):
            return viewModels.count
        case .featuredPlaylists(viewModels: let viewModels):
            return viewModels.count
        case .recommendedTracks(viewModels: let viewModels):
            return viewModels.count
        
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        case .featuredPlaylists(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .recommendedTracks(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        
        switch section {
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            let track = tracks[indexPath.row]
            PlaybackPresenter.shared.startPlayback(from: self, track: track)
        }
    }
    
    
    private func configureCollectionView() {
        guard let collectionView = self.collectionView else {return}
        view.addSubview(collectionView)
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(
            TitleHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        let section = sections[indexPath.section]
        header.configure(with: section.title)
        return header
    }
    
    private func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        let supplementaryViews = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(50)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top)
        ]
        switch section {
        case 0:
            
            //Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(120)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            //Vertical group in horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)),
                subitem: item,
                count: 3
            )
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(390)),
                subitem: verticalGroup,
                count: 1
            )
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 1:
            
            //Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(200)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            //Vertical group in horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)),
                subitem: item,
                count: 2
            )
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)),
                subitem: verticalGroup,
                count: 1
            )
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 2:
            
            //Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            //Vertical group in horizontal group

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(80)),
                subitem: item,
                count: 1
            )
            //Section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        default:
            
            //Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(120)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            //Vertical group in horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)),
                subitem: item,
                count: 3
            )
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(390)),
                subitem: verticalGroup,
                count: 1
            )
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
    }
}
