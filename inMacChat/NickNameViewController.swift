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
import Instructions
import SwiftSpinner
import EZSwiftExtensions

class NickNameViewController: UIViewController, CoachMarksControllerDelegate, CoachMarksControllerDataSource {

    let coachMarksController = CoachMarksController()
    let skipView = CoachMarkSkipDefaultView()
    let pointOfInterest = UIView()

    var timer = NSTimer()
    var trigger: Bool = false

    var nickFiled = FloatLabelTextField()
    var nextButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.UI()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if KeyChain().token().isEmpty == false {
            pushVC(ChatViewController())
        }
        socket.connect()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.checkFirstResponder), userInfo: nil, repeats: true)

        if KeyChain().token().characters.count < 2 {
            if NSUserDefaults.standardUserDefaults().objectForKey("tutorShowed1") == nil {
                self.coachMarksController.startOn(self)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "tutorShowed1")
            } else {
                if NSUserDefaults.standardUserDefaults().boolForKey("tutorShowed1") == false {
                    self.coachMarksController.startOn(self)
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "tutorShowed1")

                } else {

                }
            }
        }
    }
    override func viewDidDisappear(animated: Bool) {
        socket.disconnect()
    }

    func UI() {

        self.navigationItem.title = "Login"

        self.coachMarksController.dataSource = self
        self.coachMarksController.allowOverlayTap = false
        self.coachMarksController.overlayBlurEffectStyle = UIBlurEffectStyle.Light
        self.coachMarksController.skipView = self.skipView

        self.skipView.setTitle("Skip", forState: .Normal)
        self.skipView.setBackgroundImage(nil, forState: .Normal)
        self.skipView.setBackgroundImage(nil, forState: .Highlighted)
        self.skipView.layer.cornerRadius = 0
        self.skipView.backgroundColor = UIColor.darkGrayColor()

        self.view.addSubview(self.nickFiled)
        self.view.addSubview(self.nextButton)
        self.view.addSubview(self.pointOfInterest)

        self.nickFiled.textAlignment = NSTextAlignment.Left
        self.nickFiled.placeholder = "Nickname"
        self.nickFiled.clearButtonMode = UITextFieldViewMode.WhileEditing

        self.nextButton.layer.borderWidth = 0.1
        self.nextButton.layer.cornerRadius = 9
        self.nextButton.setTitle("Next", forState: UIControlState.Normal)
        self.nextButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

        self.nextButton.addTarget(self, action: #selector(self.requestCode), forControlEvents: UIControlEvents.TouchUpInside)

        if UIDevice.deviceModelReadable() == "iPhone 4" || UIDevice.deviceModelReadable() == "iPhone 4S" {
            
            self.nickFiled.snp_makeConstraints { (make) in
                make.centerY.equalTo(self.view).offset(-100)
                make.centerX.equalTo(self.view)
                make.width.equalTo(250)
                make.height.equalTo(50)
            }
            
            self.nextButton.snp_makeConstraints { (make) in
                make.centerX.equalTo(self.view)
                make.centerY.equalTo(self.nickFiled).offset(65)
                make.width.equalTo(100)
                make.height.equalTo(40)
            }
            
            self.pointOfInterest.snp_makeConstraints(closure: { (make) in
                make.width.equalTo(0)
                make.height.equalTo(0)
                make.centerX.equalTo(self.view)
                make.centerY.equalTo(self.view)
            })
            
        } else {
            
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

            self.pointOfInterest.snp_makeConstraints(closure: { (make) in
                make.width.equalTo(0)
                make.height.equalTo(0)
                make.centerX.equalTo(self.view)
                make.centerY.equalTo(self.view)
            })
        }

    }

    func requestCode() {
        self.nickFiled.resignFirstResponder()
        if self.nickFiled.text?.characters.count <= 2 {
            SCLAlertView().showWarning("Invalid login", subTitle: "Please ensure that Login-Field contains your nickname") // Warning
        } else {
            SwiftSpinner.setTitleFont(UIFont(name: "Futura", size: 22.0))
            SwiftSpinner.show("Connecting to inMac")
            socket.emitWithAck("app_verification", ["method": "requestCode", "username": self.nickFiled.text!, "uid": uuid, "appid": appid
                ])(timeoutAfter: 10) { data in

                    print("REQUEST CODE:\(data)")

                    guard (data.count > 0) else {
                        print("app_verification empty answer")
                        return
                    }

                    if let json = JSON(rawValue: data[0]) {
                        if json["success"].int == 1 {

                            KeyChain().saveUsername(self.nickFiled.text!)
                            KeyChain().saveUUID(json["uuid"].stringValue)

                            if KeyChain().username() == "AppleTest" {
                                KeyChain().savePassword("12345")
                            }

                            let avatar = json["useravatar"].stringValue
                            imageURL = NSURL(string:"http://st.inmac.org/images/avatars/\(avatar)")!
                            SwiftSpinner.showWithDuration(0.6, title:"Success!")
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
                            dispatch_after(delayTime, dispatch_get_main_queue()) {
                                self.performSegueWithIdentifier("toCodeValidation", sender: nil)
                            }
                            socket.disconnect()
                        } else {
                            let message = json["message"].stringValue
                            if message == "USER_NOT_FOUND" {
                                SwiftSpinner.showWithDuration(0.5, title:"Error!\n User not found")
                            } else {
                                SwiftSpinner.showWithDuration(0.5, title:"Unknown Error")
                            }
                        }
                    }
            }
        }
    }

    func numberOfCoachMarksForCoachMarksController(coachMarkController: CoachMarksController)
        -> Int {
            return 2
    }

    func coachMarksController(coachMarksController: CoachMarksController, coachMarksForIndex: Int)
        -> CoachMark {

            var coachMark = coachMarksController.coachMarkForView(pointOfInterest) {
                (frame: CGRect) -> UIBezierPath in
                // This will create an oval cutout a bit larger than the view.
                return UIBezierPath(ovalInRect: CGRectInset(frame, -4, -4))
            }

            switch(coachMarksForIndex) {
            case 0:
                coachMark = coachMarksController.coachMarkForView(self.pointOfInterest)

            case 1:
                coachMark = coachMarksController.coachMarkForView(self.nickFiled)
                coachMark.arrowOrientation = . Bottom

            default:
                coachMark = coachMarksController.coachMarkForView()
            }

            coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0

            return coachMark
    }

    func coachMarksController(coachMarksController: CoachMarksController, coachMarkViewsForIndex: Int, coachMark: CoachMark)
        -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
            let coachViews = coachMarksController.defaultCoachViewsWithArrow(true, arrowOrientation: coachMark.arrowOrientation)


            switch(coachMarkViewsForIndex) {
            case 0:
                coachViews.bodyView.hintLabel.text = "Hello! Let's Start!"
                coachViews.bodyView.nextLabel.text = "Ok!"

            case 1:
                coachViews.bodyView.hintLabel.text = "Type your login\n from inMac.org"
                coachViews.bodyView.nextLabel.text = "Done"
                self.nickFiled.becomeFirstResponder()
                
            default: break
            }

            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }


    func coachMarksController(coachMarksController: CoachMarksController, constraintsForSkipView skipView: UIView, inParentView parentView: UIView) -> [NSLayoutConstraint]? {

        var constraints: [NSLayoutConstraint] = []

        let constraint1 = NSLayoutConstraint(item: skipView, attribute:.Bottom, relatedBy: .Equal, toItem: parentView, attribute: .Bottom, multiplier: 1, constant: 0)
        let constraint2 = NSLayoutConstraint(item: skipView, attribute: .Width, relatedBy: .Equal, toItem: parentView, attribute: .Width, multiplier: 1, constant: 0)
        let constraint3 = NSLayoutConstraint(item: skipView, attribute: .CenterX, relatedBy: .Equal, toItem: parentView, attribute: .CenterX, multiplier: 1, constant: 0)
        let constraint4 = NSLayoutConstraint(item: skipView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 45)

        constraints.append(constraint1)
        constraints.append(constraint2)
        constraints.append(constraint3)
        constraints.append(constraint4)
        return constraints
    }

    func checkFirstResponder() {
        if self.nickFiled.isFirstResponder() == true {
            self.trigger = true
        } else {
            if self.trigger == true {
                view.endEditing(true)
                self.timer.invalidate()
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
