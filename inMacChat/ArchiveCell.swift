//
//  ArchiveCell.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 26/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class  ArchiveCell: UITableViewCell {
    
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
        
        self.nameLabel.snp_makeConstraints { (make) in
            make.left.equalTo(self).offset(5)
            make.height.equalTo(20)
            make.top.equalTo(self).offset(5)
        }
        
        self.bodyLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp_bottom).offset(1)
            make.bottom.equalTo(self).offset(5)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
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