//
//  AutoCompletionCell.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 25/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class AutoCompletionCell: UITableViewCell {
    
    var indexPath: NSIndexPath?
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "NekoNoKage"
        label.font = UIFont.boldSystemFontOfSize(12.0)
        label.textColor = UIColor(red: 0/255.0, green: 128/255.0, blue: 64/255.0, alpha: 1.0)
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
        self.nameLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(self).offset(20)
            make.height.equalTo(self)
            make.width.equalTo(self)
            make.centerY.equalTo(self)
        }
    }
}
