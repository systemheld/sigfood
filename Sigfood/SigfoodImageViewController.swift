//
//  SigfoodImageView.swift
//  Sigfood
//
//  Created by Kett, Oliver on 30.11.15.
//  Copyright © 2015 Kett, Oliver. All rights reserved.
//

import UIKit
import JGProgressHUD

class SigfoodImageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageID: Int = 0
    // initialize loading animation bevore first use
    var loadingAnimation = JGProgressHUD(style: JGProgressHUDStyle.Dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // SwiftSpinner.show()
        loadingAnimation.showInView(self.view)
        NSOperationQueue().addOperationWithBlock {
            guard let data = NSData(contentsOfURL: NSURL(string: "https://www.sigfood.de/?do=getimage&bildid=\(self.imageID)&width=800")!) else { self.hideView(nil); return }
            guard let image = UIImage(data: data) else { self.hideView(nil); return }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.view.backgroundColor = UIColor(red: 0.016, green: 0.710, blue: 0.788, alpha: 1.00)
                self.imageView.contentMode = .ScaleAspectFit
                self.imageView.image = image
                // SwiftSpinner.hide()
                self.loadingAnimation.dismissAnimated(false)
            }
        }
    }
    
    @IBAction func hideView(sender: AnyObject?) {
        // SwiftSpinner.hide()
        self.loadingAnimation.dismissAnimated(false)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
