//
//  SearchResultsViewController.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: class {
    func didTapResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController  {

    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var searchSections: [SearchSection] = []
    
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemBackground
        tableView.register(
            SearchResultDefaultTableViewCell.self,
            forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        
        tableView.register(
            SearchResultSubtitleTableViewCell.self,
            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier
        )
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with results: [SearchResult]) {
        DispatchQueue.main.async {
            let artists = results.filter({
                switch $0 {
                case .artist:
                    return true
                default:
                    return false
                }
            })
            
            let albums = results.filter({
                switch $0 {
                case .album:
                    return true
                default:
                    return false
                }
            })
            
            let playlists = results.filter({
                switch $0 {
                case .playlist:
                    return true
                default:
                    return false
                }
            })
            
            let tracks = results.filter({
                switch $0 {
                case .track:
                    return true
                default:
                    return false
                }
            })
            
            self.searchSections = [
                SearchSection(title: "Songs", results: tracks),
                SearchSection(title: "Artists", results: artists),
                SearchSection(title: "Playlists", results: playlists),
                SearchSection(title: "Albums", results: albums)
                ,
                
            ]
            self.tableView.reloadData()
            self.tableView.isHidden = results.isEmpty
        }
        
    }
    

}


extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchSections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch searchSections[indexPath.section].results[indexPath.row] {
        case .album(let album):
            guard let albumCell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: album.name ?? "",
                subtitle: album.artists.first?.name ?? "",
                imageURL: URL(string: album.images.first?.url ?? "")
            )
            albumCell.configure(with: viewModel)
            return albumCell
        case .artist(let artist):
            guard let artistCell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultDefaultTableViewCellViewModel(
                title: artist.name ?? "",
                imageURL: URL(string: artist.images?.first?.url ?? "")
            )
            artistCell.configure(with: viewModel)
            return artistCell
        case .playlist(let playlist):
            guard let playlistCell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: playlist.name ?? "",
                subtitle: playlist.owner?.displayName ?? "",
                imageURL: URL(string: playlist.images?.first?.url ?? "")
            )
            playlistCell.configure(with: viewModel)
            return playlistCell
        case.track(let track):
            guard let trackCell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: track.name ?? "",
                subtitle: track.artists.first?.name ?? "",
                imageURL: URL(string: track.album?.images.first?.url ?? "")
            )
            trackCell.configure(with: viewModel)
            return trackCell
        }
    
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchSections[section].title.uppercased()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didTapResult(searchSections[indexPath.section].results[indexPath.row])
        
    }
    

    
    
    
}
