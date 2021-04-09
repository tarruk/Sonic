//
//  SearchResultDefaultTableViewCell.swift
//  Sonic
//
//  Created by Tarek on 04/04/2021.
//

import UIKit
import SDWebImage



class SearchResultDefaultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultDefaultTableViewCell"
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageview: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
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
        
        iconImageview.layer.cornerRadius = imageSize/2
        iconImageview.layer.masksToBounds = true
        
        label.frame = CGRect(
            x: iconImageview.right+10,
            y: 0,
            width: contentView.width-iconImageview.right-15,
            height: contentView.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageview.image = nil
        label.text = nil
    }
    
    func configure(with viewModel: SearchResultDefaultTableViewCellViewModel) {
        label.text = viewModel.title
    
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
