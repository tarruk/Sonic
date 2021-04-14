//
//  SearchResultsSubtitleTableViewCell.swift
//  Sonic
//
//  Created by Tarek on 04/04/2021.
//

import UIKit
import SDWebImage



class SearchResultSubtitleTableViewCell: UITableViewCell {
    static let identifier = "SearchResultSubtitleTableViewCell"
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageview: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(iconImageview)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-10
        iconImageview.frame = CGRect(
            x: 10,
            y: 5,
            width: imageSize,
            height: imageSize
        )
        
        let labelHeight = (contentView.height/2)-4
        titleLabel.frame = CGRect(
            x: iconImageview.right+10,
            y: 2,
            width: contentView.width-iconImageview.right-15,
            height: labelHeight
        )
        
        subtitleLabel.frame = CGRect(
            x: iconImageview.right+10,
            y: titleLabel.bottom+2,
            width: contentView.width-iconImageview.right-15,
            height: labelHeight
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageview.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel) {
        titleLabel.text = viewModel.title
    
        subtitleLabel.text = viewModel.subtitle
        
        if let imageURL = viewModel.imageURL {
            iconImageview.sd_setImage(
                with: imageURL,
                completed: nil
            )
        } else {
            iconImageview.image = UIImage(systemName: "photo")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            iconImageview.contentMode = .center
        }
        
    }
    
}
