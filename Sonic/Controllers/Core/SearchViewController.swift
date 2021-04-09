//
//  SearchViewController.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//
import SafariServices
import UIKit
import RxSwift
class SearchViewController: UIViewController {


    var categories = [MusicCategory]()
    let disposeBag = DisposeBag()
    
    let searchController: UISearchController = {
        let results = SearchResultsViewController()
       let vc = UISearchController(searchResultsController: results)
        vc.searchBar.placeholder = "Songs, Artists, Album"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: { _, _ -> NSCollectionLayoutSection? in
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 2,
                    leading: 7,
                    bottom: 2,
                    trailing: 7
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(150)
                    ),
                    subitem: item,
                    count: 2
                )
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 2,
                    bottom: 10,
                    trailing: 2
                )
                return NSCollectionLayoutSection(group: group)
            })
    )
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
       
        navigationItem.searchController = searchController
        view.addSubview(collectionView)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        APICaller.shared
            .getCategories()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] categories in
                    
                    self?.categories = categories
                    self?.collectionView.reloadData()
                },
                onFailure: { error in
                    debugPrint(error)
                }).disposed(by: disposeBag)
        
        searchController.searchBar.rx
            .searchButtonClicked
            .subscribe(
                onNext: { [weak self] _ in
                    self?.updateSearchResults()
                }).disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func updateSearchResults() {
        guard let resultController = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        resultController.delegate = self
        
        //Perform search
        APICaller.shared
            .search(with: query)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { results in
                    resultController.update(with: results)
                },
                onError: { error in
                
                }).disposed(by: disposeBag)
    }
    
    

}


extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.row]
        cell.configure(with: CategoryCollectionCellViewModel(
            title: category.name ?? "",
            artworkURL: URL(string: category.icons.first?.url ?? "")
        ))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let vc = CategoryViewController(category: categories[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension SearchViewController: SearchResultsViewControllerDelegate {
    func didTapResult(_ result: SearchResult) {
        switch result {
        case .album(let album):
            let vc = AlbumViewController(album: album)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .artist(let artist):
            guard let url = URL(string: artist.externalUrls?.spotify ?? "") else {
                return
            }
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
            
        case .playlist(let playlist):
            let vc = PlaylistViewController(playlist: playlist)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .track(let track):
            PlaybackPresenter.shared.startPlayback(from: self, track: track)
        }
    }
}
