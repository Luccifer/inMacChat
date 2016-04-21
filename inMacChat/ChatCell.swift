//
//  ChatCell.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 21/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ChatCell: UITableViewCell {

    var usedForMessage: Bool?
    var indexPath: NSIndexPath?

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "NekoNoKage"
        label.font = UIFont.boldSystemFontOfSize(16.0)
        label.textColor = UIColor(red: 0/255.0, green: 128/255.0, blue: 64/255.0, alpha: 1.0)
        return label
    }()

    lazy var bodyLabel: UITextView = {
        let label = UITextView()
        label.textColor = UIColor.blackColor()
        label.scrollEnabled = false
        label.dataDetectorTypes = UIDataDetectorTypes.All
        label.text = ""
        label.editable = false
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "19:30"
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        return label
    }()

    lazy var avatarImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        imageView.backgroundColor = UIColor.clearColor()
        imageView.layer.cornerRadius = 30.0
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureSubviews()
    }

    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configureSubviews() {
        self.addSubview(self.nameLabel)
        self.addSubview(self.bodyLabel)
        self.addSubview(self.timeLabel)
        self.addSubview(self.avatarImage)

        self.avatarImage.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(5)
            make.left.equalTo(self.snp_left).offset(5)
            make.height.equalTo(60)
            make.width.equalTo(60)
        }

        self.nameLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(5)
            make.left.equalTo(self.avatarImage.snp_right).offset(5)

        }

        self.bodyLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp_bottom).offset(2)
            make.bottom.equalTo(self).offset(5)
            make.left.equalTo(self.avatarImage.snp_right).offset(5)
            make.right.equalTo(self).offset(5)
        }

        self.timeLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(5)
            make.right.equalTo(self.snp_right).offset(-5)
        }

    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
