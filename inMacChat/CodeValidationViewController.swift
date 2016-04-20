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

class CodeValidationViewController: UIViewController, MMNumberKeyboardDelegate, CoachMarksControllerDelegate, CoachMarksControllerDataSource {

    let socket = SocketIOClient(socketURL: "https://inmac.org/chat/socket.io/")

    let coachMarksController = CoachMarksController()
    let skipView = CoachMarkSkipDefaultView()
    let pointOfInterest = UIView()

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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
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

        self.coachMarksController.dataSource = self
        self.coachMarksController.allowOverlayTap = false
        self.coachMarksController.overlayBlurEffectStyle = UIBlurEffectStyle.Light
        self.coachMarksController.skipView = self.skipView

        self.skipView.setTitle("Skip", forState: .Normal)
        self.skipView.setBackgroundImage(nil, forState: .Normal)
        self.skipView.setBackgroundImage(nil, forState: .Highlighted)
        self.skipView.layer.cornerRadius = 0
        self.skipView.backgroundColor = UIColor.darkGrayColor()

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

        self.pointOfInterest.snp_makeConstraints(closure: { (make) in
            make.width.equalTo(0)
            make.height.equalTo(0)
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
        })
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)

    }
}
