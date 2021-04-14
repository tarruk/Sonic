//
//  LibraryPlaylistViewController.swift
//  Sonic
//
//  Created by Tarek on 09/04/2021.
//

import UIKit

class LibraryPlaylistViewController: BaseViewController {

    
    
    var playlists = [Playlist]()
    private let noPlaylistsView = ActionLabelView()
    
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(
            SearchResultSubtitleTableViewCell.self,
            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier
        )
        tableView.isHidden = true
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noPlaylistsView)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .clear
        setupNoPlaylistView()
        fetchData()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlaylistsView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width, height: 100
        )
        noPlaylistsView.center = view.center
        
        tableView.frame = view.bounds
       
    }
    
    private func setupNoPlaylistView() {
        noPlaylistsView.delegate = self
        noPlaylistsView.configure(
            with: ActionLabelViewModel(
                text: "You don't have any playlists yet.",
                actionTitle: "Create"
            )
        )
    }
    
    private func fetchData() {
        APICaller.shared.getCurrentUserPlaylists()
            .subscribe(
                onNext: { [weak self] playlists in
                    self?.playlists = playlists
                    self?.updateUI()
                },
                onError: { [weak self] error in
                    print(error)
                }).disposed(by: disposeBag)
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            if self.playlists.isEmpty {
                self.noPlaylistsView.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.noPlaylistsView.isHidden = true
            }
        }
        
        
    }
    

    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(
            title: "NewPlaylists",
            message: "Enter playlist name",
            preferredStyle: .alert
        )
        
        alert.addTextField { (textField) in
            textField.placeholder = "Playlist..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            APICaller.shared.createPlaylist(with: text)
                .subscribe(
                    onNext: { [weak self] playlist in
                        //refresh list of playlists
                        print(playlist)
                        self?.fetchData()
                    },
                    onError: { [weak self] error in
                        print("Failed to get playlists")
                    }).disposed(by: self.disposeBag)
        }))
        present(alert, animated: true)
    }

}


extension LibraryPlaylistViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
    
    
}

extension LibraryPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
                        title: playlist.name ?? "",
                        subtitle: playlist.owner?.displayName ?? "",
                        imageURL: URL(string: playlist.images?.first?.url ?? ""))
        )
        return cell
    }
    
    
    
    
    
}
