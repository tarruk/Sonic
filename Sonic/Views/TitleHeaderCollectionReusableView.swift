//
//  TitleHeaderCollectionReusableView.swift
//  Sonic
//
//  Created by Tarek on 24/03/2021.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
        static let identifier = "TitleHeaderCollectionReusableView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(
            x: 10,
            y: 10,
            width: width-20,
            height: 30)
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    
}

