//
//  CategoryViewController.swift
//  Sonic
//
//  Created by Tarek on 27/03/2021.
//

import UIKit
import RxSwift
class CategoryViewController: UIViewController {

    
    
    
    let category: MusicCategory
    var playlists = [Playlist]()
    let disposeBag = DisposeBag()
    
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1))
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 5,
                bottom: 5,
                trailing: 5
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(250)),
                subitem: item,
                count: 2
            )
            
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 5,
                bottom: 5,
                trailing: 5
            )
            
            return NSCollectionLayoutSection(group: group)
        })
    )
    
    
    
    init(category: MusicCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.name
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            FeaturedPlaylistCollectionViewCell.self,
            forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        APICaller.shared
            .getCategoryPlaylists(category: category)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] playlists in
                    self?.playlists = playlists
                    self?.collectionView.reloadData()
                    
                },
                onFailure: { error in
                    debugPrint(error.localizedDescription)
                }).disposed(by: disposeBag)
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    

    

}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let playlist = playlists[indexPath.row]
    
        cell.configure(with: FeaturedPlaylistCellViewModel(
            name: playlist.name ?? "",
            artworkURL: URL(string: playlist.images?.first?.url ?? ""),
            creatorName: playlist.owner?.displayName ?? ""
        ))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = PlaylistViewController(playlist: playlists[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
