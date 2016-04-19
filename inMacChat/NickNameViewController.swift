//
//  NickNameViewController.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 18/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
import SCLAlertView

class NickNameViewController: UIViewController {

    let socket = SocketIOClient(socketURL: "https://inmac.org/chat/socket.io/")

    var nickFiled = FloatLabelTextField()
    var nextButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.UI()
    }

    func UI() {
        self.view.addSubview(self.nickFiled)
        self.view.addSubview(self.nextButton)


        self.nickFiled.textAlignment = NSTextAlignment.Left
        self.nickFiled.placeholder = "Login on inMac.org"
        self.nickFiled.clearButtonMode = UITextFieldViewMode.WhileEditing

        self.nextButton.layer.borderWidth = 0.1
        self.nextButton.layer.cornerRadius = 9
        self.nextButton.setTitle("Next", forState: UIControlState.Normal)
        self.nextButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

        self.nextButton.addTarget(self, action: #selector(self.requestCode), forControlEvents: UIControlEvents.TouchUpInside)

        self.nickFiled.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.view).offset(-20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(250)
            make.height.equalTo(50)
        }

        self.nextButton.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.nickFiled).offset(70)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
    }

    func requestCode() {
        if self.nickFiled.text?.characters.count <= 2 {
            SCLAlertView().showWarning("Field is empty", subTitle: "Please ensure that Login-Field contains your nickname") // Warning
        } else {
            if self.nickFiled.text == "AppleTest" {
                self.performSegueWithIdentifier("toCodeValidation", sender: nil)
            }
            self.socket.emitWithAck("app_verification", ["method": "requestCode", "username": self.nickFiled.text!, "uid": uuid, "appid": appid
                ])(timeoutAfter: 10) { data in

                    print("REQUEST CODE:\(data)")

                    guard (data.count > 0) else {
                        print("app_verification empty answer")
                        return }

                    if let json = JSON(rawValue: data[0]) {
                        if let _ = json["success"].int {
                        }
                    }
            }
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
