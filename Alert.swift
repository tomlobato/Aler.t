//
//  Aler.swift
//  Antonio Lobato
//
//  Created by Antonio Lobato on 2/25/16.
//  Copyright © 2016 Casare. All rights reserved.
//

import Foundation
import UIKit
import FXBlurView

// Usage examples:

// Aler.t.confirm("Ugh!", subTit: "something wrong :(")

// Aler.t.confirm("Ugh!", subTit: "something wrong :(") {
//    switch $0 {
//    case .Ok:
//        print("ok tapped")
//    case .Cancel:
//        print("cancel tapped")
//    }
// }

// Aler.t.confirm("Ugh!", subTit: "something wrong :(") {
//    navigationController?.popViewControllerAnimated(true)
// }

enum AlertOverlay {
    case Blur
    case BlurDark
    case Transparency
    case None
}

enum AlertType {
    case Success
    case Warning
    case Error
    case Confirm
}

enum AlertReturnType {
    case Ok
    case Cancel
}

typealias AlertReturnBlock = (selection:AlertReturnType) -> ()

class Aler: NSObject {
    var box: UIView!
    var transparency: UIView!
    var blurEffectView: UIImageView!
    var callback: AlertReturnBlock!
    var isConfirm = false

    var trans: Bool {
        get {
            return transparency != nil
        }
    }

    var blur: Bool {
        get {
            return blurEffectView != nil
        }
    }

    override init(){
        super.init()
    }

    // singleton`ize class
    class var t: Aler {
        struct Static {
            static let t: Aler = Aler()
        }
        return Static.t
    }

    func success(
        title: String! = nil,
        sub: String,
        okText: String! = nil,
        cancelText: String! = nil,
        overlay: AlertOverlay! = nil,
        callback: AlertReturnBlock! = nil)
    {
        self.callback = callback
        show(title, sub: sub, okText: okText, cancelText: cancelText, overlay: overlay, type: .Success)
    }

    func warning(
        title: String! = nil,
        sub: String,
        okText: String! = nil,
        cancelText: String! = nil,
        overlay: AlertOverlay! = nil,
        callback: AlertReturnBlock! = nil)
    {
        self.callback = callback
        show(title, sub: sub, okText: okText, cancelText: cancelText, overlay: overlay, type: .Warning)
    }

    func error(
        title: String! = nil,
        sub: String,
        okText: String! = nil,
        cancelText: String! = nil,
        overlay: AlertOverlay! = nil,
        callback: AlertReturnBlock! = nil)
    {
        self.callback = callback
        show(title, sub: sub, okText: okText, cancelText: cancelText, overlay: overlay, type: .Error)
    }

    func confirm(
        title: String! = nil,
        sub: String,
        okText: String! = nil,
        cancelText: String! = nil,
        overlay: AlertOverlay! = nil,
        callback: AlertReturnBlock! = nil)
    {
        isConfirm = true
        self.callback = callback
        show(title, sub: sub, okText: okText, cancelText: cancelText, overlay: overlay, type: .Confirm)
    }

    func show(title: String! = nil,
              sub: String,
              type: AlertType = .Success,
              okText: String = "OK",
              cancelText: String = "Cancel",
              var overlay: AlertOverlay! = nil,
              callback: AlertReturnBlock! = nil
    ){
        let winSize = UIScreen.mainScreen().bounds
        let screen = UIApplication.sharedApplication().windows.first!.rootViewController!.view!

        if overlay == nil {
            overlay = .BlurDark
        }

        //
        // Transparency / Blur
        //

        if overlay == .Blur || overlay == .BlurDark {
            blurEffectView = UIImageView(frame: CGRect(x: 0, y: 0, width: screen.w, height: screen.h))
            blurEffectView.alpha = 0
            blurEffectView.image = screen.toImage().blurredImageWithRadius(CGFloat(3), iterations: 20, tintColor: nil)
        }

        if overlay == .Transparency || overlay == .BlurDark {
            transparency = UIView(frame: UIScreen.mainScreen().bounds)
            transparency.alpha = 0
            transparency.backgroundColor = UIColor.blackColor()
        }

        //
        // Box
        //

        box = UIView(frame: CGRect(x: 25, y: 0, width: winSize.width - 50, height: 0))
//        box.nuiClass = "alertBox"
        box.layer.cornerRadius = 2
        box.layer.masksToBounds = true
        box.alpha = 0

        box.layer.shadowOffset = CGSizeMake(0, 2)
        box.layer.shadowRadius = 2
        box.layer.masksToBounds = false
        box.layer.shadowOpacity = 0.3

        //
        // Icon
        //

        var iconName = ""
        switch type {
        case .Success:
            iconName = "icon-success"
        case .Warning:
            iconName = "icon-fail"
        case .Error:
            iconName = "icon-fail"
        case .Confirm:
            iconName = "icon-fail"
        }

        let icon = UIImageView(image: UIImage(named: iconName))
        icon.frame = CGRect(x: box.frame.width/2 - 15, y: 34, width: 30, height: 30)

        //
        // Title
        //

        var titLbl: UILabel!

        if title != nil && !title.isBlank() {
            titLbl = mkLbl(title, y: icon.bottom + 10, nuiClass: "alertTitleLbl")
        }

        //
        // Subtitle
        //

        var lastViewYEnd: CGFloat!

        if titLbl != nil {
            lastViewYEnd = titLbl.bottom + 5
        } else {
            lastViewYEnd = icon.bottom
        }

        let subTitLbl = mkLbl(sub, y: lastViewYEnd, nuiClass: "alertDescLbl")

        //
        // Buttons
        //

        let btnHeight: CGFloat = 36
        let btnWidth: CGFloat = 105

        // Cancel

        var cancelBtn: UIButton!

        if isConfirm {
            cancelBtn = UIButton(frame: CGRect(x: box.frame.width/2 - btnWidth - 5, y: subTitLbl.bottom + 15, width: btnWidth, height: btnHeight))
//            cancelBtn.nuiClass = "ButtonBig:ButtonBigLightWithBorder"
            cancelBtn.setTitle(cancelText, forState: .Normal)
            cancelBtn.tag = 1
            cancelBtn.addTarget(self, action: "btnTapped:", forControlEvents: .TouchUpInside)
        }

        // Ok

        var okBtnX: CGFloat!

        if isConfirm {
            okBtnX = box.frame.width/2 + 5
        } else {
            okBtnX = box.frame.width/2 - btnWidth/2
        }

        let okBtn = UIButton(frame: CGRect(x: okBtnX, y: subTitLbl.bottom + 15, width: btnWidth, height: btnHeight))
//        okBtn.nuiClass = "ButtonBig"
        okBtn.setTitle(okText, forState: .Normal)
        okBtn.tag = 0
        okBtn.addTarget(self, action: "btnTapped:", forControlEvents: .TouchUpInside)

        //
        // Populate box
        //

        box.addSubview(icon)
        if titLbl != nil { box.addSubview(titLbl) }
        box.addSubview(subTitLbl)
        if cancelBtn != nil { box.addSubview(cancelBtn) }
        box.addSubview(okBtn)

        // Adjust dimensions
        box.sizeToFit()
        box.frame.size.height = okBtn.bottom + 40 // box bottom padding
        box.frame.origin.y = winSize.height/2 - box.frame.height/2 // box height
        box.alpha = 0

        //
        // Add to screen with fadeIn
        //

        if blurEffectView != nil { screen.addSubview(blurEffectView) }
        if transparency != nil { screen.addSubview(transparency) }
        screen.addSubview(box)

        UIView.animateWithDuration(0.3) {
            self.box.alpha = 1
            self.blurEffectView?.alpha = 1
            self.transparency?.alpha = 0.3
        }
    }

    func btnTapped(sender: UIButton){
        let selection: AlertReturnType = sender.tag == 0 ? .Ok : .Cancel

        UIView.animateWithDuration(0.1, animations: {() in
            self.blurEffectView?.layer.opacity = 0
            self.transparency?.layer.opacity = 0

        }, completion: { (value: Bool) in
            UIView.animateWithDuration(0.1, animations: {() in
                self.box.layer.opacity = 0

            }, completion: { (value: Bool) in
                self.box.removeFromSuperview()
                self.blurEffectView?.removeFromSuperview()
                self.transparency?.removeFromSuperview()
                if self.callback != nil {
                    self.callback(selection: selection)
                }
            })
        })
    }

    func mkLbl(text: String, y: CGFloat = 0, nuiClass: String! = nil) -> UILabel {
        let lbl = UILabel(frame: CGRect(x: 20, y: y, width: box.frame.width - 40, height: 0))

//        if nuiClass != nil {lbl.nuiClass = nuiClass}

        lbl.numberOfLines = 0
        lbl.lineBreakMode = .ByWordWrapping
        lbl.textAlignment = .Center
        lbl.text = text

        let originalWidth = lbl.frame.width
        lbl.sizeToFit()
        let f = lbl.frame
        lbl.frame = CGRect(x: f.origin.x, y: f.origin.y, width: originalWidth, height: lbl.frame.height)

        return lbl
    }
}
