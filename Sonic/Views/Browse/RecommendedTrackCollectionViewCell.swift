//
//  RecommendedTrackCollectionViewCell.swift
//  Sonic
//
//  Created by Tarek on 21/03/2021.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    private let trackNameLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.textAlignment = .left
        return label
            
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        setConstrains()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setConstrains() {
        [albumCoverImageView, trackNameLabel, artistNameLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        albumCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        albumCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
        albumCoverImageView.widthAnchor.constraint(equalToConstant: contentView.height-4).isActive = true
        albumCoverImageView.heightAnchor.constraint(equalToConstant: contentView.height-4).isActive = true
        
        trackNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: 10).isActive = true
        trackNameLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -25).isActive = true
        trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 5).isActive = true
        trackNameLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        artistNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: 10).isActive = true
        artistNameLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 5).isActive = true
        artistNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func configure(with viewModel: RecommendedTrackCellViewModel) {
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
