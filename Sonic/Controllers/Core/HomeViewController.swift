//
//  ViewController.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        fetchData()
    }
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    private func fetchData() {
        APICaller.shared.getRecommendedGenres { [weak self] (result) in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                APICaller.shared.getRecommendations(genres: seeds) { result in
                    switch result {
                    case .success(let model):
                        print(model)
                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                    }
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }


}

