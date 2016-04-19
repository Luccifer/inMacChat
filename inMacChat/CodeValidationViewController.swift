//
//  CodeValidationViewController.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 19/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import SnapKit
import Alamofire
import SwiftyJSON
import MMNumberKeyboard

class CodeValidationViewController: UIViewController, MMNumberKeyboardDelegate {

    let socket = SocketIOClient(socketURL: "https://inmac.org/chat/socket.io/")

    var codeFiled = FloatLabelTextField()
    var nextButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        let keyboard = MMNumberKeyboard()
        keyboard.allowsDecimalPoint = false
        keyboard.delegate = self
        
        self.codeFiled.inputView = keyboard
        
        self.UI()
    }

    func UI() {
        self.view.addSubview(self.codeFiled)
        self.view.addSubview(self.nextButton)


        self.codeFiled.textAlignment = NSTextAlignment.Left
        self.codeFiled.placeholder = "Code"
        self.codeFiled.clearButtonMode = UITextFieldViewMode.WhileEditing

        self.nextButton.layer.borderWidth = 0.1
        self.nextButton.layer.cornerRadius = 9
        self.nextButton.setTitle("Next", forState: UIControlState.Normal)
        self.nextButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

        //        self.nextButton.addTarget(self, action: #selector(self.requestCode), forControlEvents: UIControlEvents.TouchUpInside)

        self.codeFiled.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.view).offset(-20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(250)
            make.height.equalTo(50)
        }

        self.nextButton.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.codeFiled).offset(70)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)

    }
}
