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
import Instructions
import SwiftSpinner

public var imageURL = NSURL()

class CodeValidationViewController: UIViewController, MMNumberKeyboardDelegate, CoachMarksControllerDelegate, CoachMarksControllerDataSource {

    let socket = SocketIOClient(socketURL: "https://inmac.org/chat/socket.io/")

    let coachMarksController = CoachMarksController()
    let skipView = CoachMarkSkipDefaultView()
    let pointOfInterest = UIView()

    var avatarView = PASImageView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
    var nickLabel = UILabel()

    var codeFiled = FloatLabelTextField()
    var nextButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        if KeyChain().username() == "AppleTest" {
            self.codeFiled.text = "12345"
            self.verify_code()
        }

        self.avatarView.imageURL(imageURL)

        let keyboard = MMNumberKeyboard()
        keyboard.allowsDecimalPoint = false
        keyboard.delegate = self

        self.codeFiled.inputView = keyboard
        self.nextButton.addTarget(self, action: #selector(self.verify_code), forControlEvents: UIControlEvents.TouchUpInside)

        self.UI()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
         self.socket.connect()
        if NSUserDefaults.standardUserDefaults().objectForKey("tutorShowed") == nil {
            self.coachMarksController.startOn(self)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "tutorShowed")
        } else {
            if NSUserDefaults.standardUserDefaults().boolForKey("tutorShowed") == false {
                self.coachMarksController.startOn(self)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "tutorShowed")
            } else {

            }
        }
    }


    func UI() {

        self.navigationItem.title = "Code Verify"

        self.coachMarksController.dataSource = self
        self.coachMarksController.allowOverlayTap = false
        self.coachMarksController.overlayBlurEffectStyle = UIBlurEffectStyle.Light
        self.coachMarksController.skipView = self.skipView

        self.skipView.setTitle("Skip", forState: .Normal)
        self.skipView.setBackgroundImage(nil, forState: .Normal)
        self.skipView.setBackgroundImage(nil, forState: .Highlighted)
        self.skipView.layer.cornerRadius = 0
        self.skipView.backgroundColor = UIColor.darkGrayColor()

        self.avatarView.backgroundProgressColor = UIColor.whiteColor()
        self.avatarView.progressColor = UIColor.redColor()

        self.nickLabel.text = KeyChain().username()

        self.view.addSubview(self.nickLabel)
        self.view.addSubview(self.avatarView)
        self.view.addSubview(self.pointOfInterest)
        self.view.addSubview(self.codeFiled)
        self.view.addSubview(self.nextButton)

        self.codeFiled.textAlignment = NSTextAlignment.Left
        self.codeFiled.placeholder = "Code"
        self.codeFiled.clearButtonMode = UITextFieldViewMode.WhileEditing

        self.nextButton.layer.borderWidth = 0.1
        self.nextButton.layer.cornerRadius = 9
        self.nextButton.setTitle("Next", forState: UIControlState.Normal)
        self.nextButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

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

        self.pointOfInterest.snp_makeConstraints(closure: { (make) in
            make.width.equalTo(0)
            make.height.equalTo(0)
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
        })

        self.avatarView.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.codeFiled).offset(-150)
            make.height.equalTo(100)
            make.width.equalTo(100)
        }

        self.nickLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.nickLabel.intrinsicContentSize().width)
            make.height.equalTo(45)
            make.centerY.equalTo(self.codeFiled).offset(-80)
        }
    }

    func numberOfCoachMarksForCoachMarksController(coachMarkController: CoachMarksController)
        -> Int {
            return 1
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
                coachMark = coachMarksController.coachMarkForView(self.codeFiled)


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
                coachViews.bodyView.hintLabel.text = "Check your code in web-browser\nby opening inMac.org web-chat"
                coachViews.bodyView.nextLabel.text = "Ok!"

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


    func verify_code() {
        SwiftSpinner.show("Validating your code")
        socket.emitWithAck("app_verification", ["method": "requestCode", "username": KeyChain().username(), "uid": uuid, "verificationCode": self.codeFiled.text!])(timeoutAfter: 0) { data in

            print("VERIFY CODE:\(data)")

            guard (data.count > 0) else {
                print("code_verification empty answer")
                return }

            if let json = JSON(rawValue: data[0]) {
                if let success = json["success"].int {
                    if success > 0 {
                        token = json["token"].stringValue
                        userid = json["userid"].intValue


                        print("Code Confirm Success")
                        SwiftSpinner.hide()
                        self.performSegueWithIdentifier("toChat1", sender: nil)
                        self.socket.disconnect()
                    } else {

                        print(" code_verification unsuccessful ")

                        if let reason = json["reason"].string {
                            print("reason is \(reason) ")

                            if reason == "INVALID_TOKEN" {
                                SwiftSpinner.showWithDelay(2.0, title: "\(reason)", animated:false)
                            }
                        }
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
