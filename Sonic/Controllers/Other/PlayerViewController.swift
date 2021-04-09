//
//  PlayerViewController.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {

    
    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    
    private let controlsView = PlayerControlsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        configureBarButtons()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.width
        )
        
        controlsView.frame = CGRect(
            x: 10,
            y: imageView.bottom+10,
            width: view.width-20,
            height: view.height-imageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15
        )
    }
    
    private func configureBarButtons() {
        navigationController?.navigationBar.barTintColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    func refreshUI() {
        configure()
    }
    
    private func configure() {
        imageView.sd_setImage(with: dataSource?.imageURL, completed: nil)
        controlsView.configure(
            with: PlayerControlsViewModel(
                title: dataSource?.songName,
                subtitle: dataSource?.subtitle
            )
        )
        
    }
    
    @objc func didTapAction() {
        //
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }


}
//MARK: - PlayerControlsDelegate
extension PlayerViewController: PlayerControlsViewDelegate {
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
    
    func playerControlsViewDidTapFowardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
      
        
    }
    
    func playerControlsViewDidTapBackwardsButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
}
