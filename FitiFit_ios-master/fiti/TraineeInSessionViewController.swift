//
//  TraineeInSessionViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 29/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import Social

class TraineeInSessionViewController: BaseViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    
    var ratingView:RatingView?
    var dislikeView:DislikeView?
    var ratingInProgress = false
    
    var ratingViewStars:Int = 0
    var ratingViewComment:String = ""
    var ratingViewPrivateFeedback:String = ""
    
    
    var coverView:UIView?
    
    var modalCommentVC:UINavigationController?
    var modalCustomFeedbackVC:UINavigationController?
    
    
    var appeared:Bool = false
    var booking:Booking!
    var timer:NSTimer?
    var clock:NSTimer?;
    let shareFitiText = "- http://letsfiti.com/"
    
    @IBOutlet weak var closeBtn: UIButton!
    private var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    private var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .NoStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .White
        setLocalizedTitle("")
        guard let time = booking.startTime, time2 = booking.endTime, skill = booking.skill else {
            return
        }
        
        let date = dateFormatter.stringFromDate(time)
        let start = timeFormatter.stringFromDate(time)
        let end = timeFormatter.stringFromDate(time2)
        
        dateLabel.text = "\(start) - \(end) \(date)"
        
        
        if Constants.Values.DemoMode {
            let timeFake = NSDate(timeIntervalSince1970: 1456790400)
            let timeFake2 = NSDate(timeIntervalSince1970: 1456790400+3600)
            let dateFake = dateFormatter.stringFromDate(timeFake)
            let startFake = timeFormatter.stringFromDate(timeFake)
            let endFake = timeFormatter.stringFromDate(timeFake2)
            
            dateLabel.text = "\(startFake) - \(endFake) \(dateFake)"
        }
        
        descLabel.text = String(format:"skill_with_person_at_location".localized, skill.localizedName() ?? "", booking.trainer?.name ?? "", booking.niceLocation())
        
        closeBtn.setTitle("Close".localized, forState: .Normal)
        
        detailsButton.setTitle("see_session_details".localized, forState: .Normal)
        
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
        updateUI()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? BookingDetailViewController {
            vc.booking = booking
        } else if segue.identifier == R.segue.traineeInSessionViewController.comment.identifier {
            if let nvc = segue.destinationViewController as? UINavigationController, vc = nvc.viewControllers.first as? RatingCommentViewController {
                vc.delegate = self
                vc.comment = ratingView?.comment
                modalCommentVC = nvc
            }
        } else if segue.identifier == R.segue.traineeInSessionViewController.customFeedback.identifier {
            if let nvc = segue.destinationViewController as? UINavigationController, vc = nvc.viewControllers.first as? RatingCustomFeedbackViewController {
                vc.delegate = self
                modalCustomFeedbackVC = nvc
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        appeared=true
        if booking==nil {
            exitScreen()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("paymentDidPay"), name: "dummyacceptpayment", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("paymentDidFail"), name: "dummyrejectpayment", object: nil)
    }
    override func viewDidDisappear(animated: Bool) {
        appeared=true
        if booking==nil {
            exitScreen()
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func exitScreen() {
        booking = nil
        if (appeared) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func updateUI() {
        guard let _ = booking.startTime else {
            exitScreen()
            return
        }
        clockLabel.hidden = true
        logoImage.hidden = false
        startButton.setTitle("start_session".localized.uppercaseString, forState: .Normal)
        switch booking.status {
        case .Confirmed:
            //waiting for trainer
            startButton.hidden = false
            startButton.enabled = false
            if (self.timer==nil) {
                startConfirmedTimer()
            }
        case .Unconfirmed,.Rejected,.Cancelled,.Skipped,.Withdrawn,.Expired,.Unknown,.Paid:
            //this shouldnt happen
            startButton.hidden = false
            startButton.enabled = false
            exitScreen()
            return
        case .Pending:
            startButton.hidden = false
            startButton.enabled = true
        case .InProgress:
            clockLabel.hidden = false
            if let ast = booking.actualStartTime {
                clockLabel.text = hms(Double(booking.duration)*60 + ast.timeIntervalSinceDate(APIManager.shared.serverTime))
            }
            if self.clock==nil {
                self.clock = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateUI"), userInfo: nil, repeats: true)
            }
            logoImage.hidden = true
            FitiLoadingHUD.hide()
            self.timer?.invalidate()
            startButton.hidden = true
            if (booking.isTimeUp) {
                markComplete();
            }
        case .Completed:
            startButton.hidden = false
            startButton.enabled = true
            logoImage.hidden = true
            clockLabel.hidden = false
            clockLabel.text = "Finished".localized
            startButton.setTitle("pay_now".localized.uppercaseString, forState: .Normal)
            if (!booking.rated && !ratingInProgress) {
                print("adding rating view \(ratingView)")
                ratingInProgress = true
                coverView = UIView(frame: view.bounds)
                ratingView = UIView.fromNIB(filename: "RatingView") as? RatingView
                
                if let coverView = coverView, ratingView = ratingView {
                    ratingView.layer.cornerRadius = 4
                    ratingView.layer.masksToBounds = true
                    
                    coverView.backgroundColor = UIColor(white: 0, alpha: 0.5);
                    view.addSubview(coverView)
                    view.addSubview(ratingView)
                    coverView.snp_makeConstraints(closure: { make in
                        make.edges.equalTo(view).inset(UIEdgeInsetsZero);
                    })
                    ratingView.snp_makeConstraints(closure: { make in
                        make.centerX.equalTo(view.snp_centerX)
                        make.centerY.equalTo(view.snp_centerY)
                        make.width.equalTo(RatingView.RatingViewWidth)
                        make.height.equalTo(RatingView.RatingViewHeight)
                    })
                    ratingView.delegate = self
                    ratingView.booking = booking
                    
                }
            }
        }
        
        
    }
    func hms(secs_db:Double)->String {
        if (secs_db<=0) {
            return "Finished".localized
        }
        let secsint = Int(secs_db)
        let hours = secsint / 3600
        let mins = (secsint - 3600*hours) / 60
        let secs = (secsint - 3600*hours - 60*mins)
        return String(format:"hms".localized, hours, mins, secs)
    }
    func markComplete() {
        if (booking.status == .InProgress) {
            booking.markCompleted()
            APIManager.shared.updateBooking(booking, fields: ["status":BookingStatus.Completed.rawValue], success: {
                print("end booking")
            }) { err in
                print("unable to mark booking as completed \(err)")
            }
        }
    }
    func markPaid() {
        if (booking.status == .Completed) {
            booking.markPaid()
            APIManager.shared.updateBooking(booking, fields: ["status":BookingStatus.Paid.rawValue], success: {
                print("end booking")
            }) { err in
                print("unable to mark booking as paid \(err)")
            }
        }
    }
    
    func checkStatus() {
        guard let booking = booking, time = booking.startTime where time.timeIntervalSinceDate(APIManager.shared.serverTime) < Constants.Values.MaxTimeBeforeStartInSeconds else {
            startButton.enabled = false
            return
        }
        APIManager.shared.getBooking(booking.id!, success: { newBooking -> Void in
            self.booking = newBooking
            
        }) { err in
            print(err)
            print("retry in 5 seconds")
            
        }
    }
    @IBAction func didTapStartButton(sender: AnyObject) {
        if (booking.status == .Pending) {
            FitiLoadingHUD.showHUDForView(self.view, text: "Starting session".localized)
            APIManager.shared.updateBooking(booking, fields: ["status":BookingStatus.InProgress.rawValue, "actualStartTime":APIManager.shared.serverTime.toISODate()], success: {
                self.refreshBooking()
            }) { err in
                print("unable to start booking \(err)")
                FitiLoadingHUD.hide()
            }
        } else if (booking.status == .Completed) {
            if (booking.cost>0) {
                Payment.pay(booking.cost, name:"Fiti Fitness", desc: booking.descriptionForTrainee(), callback: { status in
                    if (status  == .PaySuccess) {
                        self.paymentDidPay()
                    } else {
                        self.paymentDidFail()
                    }
                })
            } else {
                self.markPaid()
                let alert = UIAlertController(title: "pay_free".localized, message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    func paymentDidPay() {
        self.markPaid()
        let alert = UIAlertController(title: "pay_success".localized, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: { action in
            self.exitScreen()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func paymentDidFail() {
        let alert = UIAlertController(title: "pay_failed".localized, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func startConfirmedTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("refreshBooking"), userInfo: nil, repeats: true)
    }
    deinit {
        self.timer?.invalidate()
    }
    
    func refreshBooking() {
        APIManager.shared.getBooking(booking.id!, success: { newBooking in
            self.booking = newBooking
            self.updateUI()
        }) { err in
            print("unable to get booking \(err)")
            
        }
    }
    @IBAction func didTapClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
extension TraineeInSessionViewController : RatingViewDelegate {
    func ratingViewDidDismiss(stars stars: Int, comment: String) {
        
        ratingViewStars = stars
        ratingViewComment = comment
        print("removing rating view \(ratingView)")
        ratingView?.removeFromSuperview()
        ratingView = nil
        
        
        if (stars<=3) {
            dislikeView = UIView.fromNIB(filename: "DislikeView") as? DislikeView
            if let dislikeView = dislikeView {
                dislikeView.layer.cornerRadius = 4
                dislikeView.layer.masksToBounds = true
                view.addSubview(dislikeView)
                dislikeView.snp_makeConstraints(closure: { make in
                    make.centerX.equalTo(view.snp_centerX)
                    make.centerY.equalTo(view.snp_centerY)
                    make.width.equalTo(DislikeView.DislikeViewWidth)
                    make.height.equalTo(DislikeView.DislikeViewHeight)
                })
                dislikeView.delegate = self
            }
        } else {
            showAlertAndDismiss()
            sendFeedback()
        }
        
        // Display view to present sharing options
        SharePopup.showPopupForView(view, animated: true)
        SharePopup.sharePopupView?.delegate = self
    }
    private func showAlertAndDismiss() {
        
        dislikeView?.removeFromSuperview()
        dislikeView = nil
        coverView?.removeFromSuperview()
        coverView = nil
        let alert = UIAlertController(title: "", message: "thanks_for_feedback".localized, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                alert.dismissViewControllerAnimated(true, completion: nil)
                self.coverView?.removeFromSuperview()
                self.coverView = nil
            }
        }
    }
    func ratingViewDidRequestComment() {
        performSegueWithIdentifier(R.segue.traineeInSessionViewController.comment.identifier, sender: nil)
    }
    private func sendFeedback() {
        print("Sending feedback now. Rating was \(ratingViewStars), comment \(ratingViewComment), privateFeedback \(ratingViewPrivateFeedback)")
                APIManager.shared.rate(booking, stars: ratingViewStars, comment: ratingViewComment, privateFeedback: ratingViewPrivateFeedback, success: {
                    print("sucessfully left feedback")
                    }) { err in
                        print("err while leaving feedback - \(err)")
                }
    }
}
extension TraineeInSessionViewController : RatingCommentViewControllerDelegate {
    func ratingCommentViewControllerDidCancel() {
        modalCommentVC?.dismissViewControllerAnimated(true, completion: nil)
        modalCommentVC = nil
    }
    func ratingCommentViewControllerDidSubmitComment(comment: String) {
        modalCommentVC?.dismissViewControllerAnimated(true, completion: nil)
        modalCommentVC = nil
        ratingView?.comment = comment
    }
}
extension TraineeInSessionViewController : DislikeViewDelegate {
    func dislikeViewDidGivePrivateFeedback(privateFeedback: String) {
        ratingViewPrivateFeedback = privateFeedback
        showAlertAndDismiss()
        sendFeedback()
        
    }
    func dislikeViewDidRequestCustomFeedback() {
        performSegueWithIdentifier(R.segue.traineeInSessionViewController.customFeedback.identifier, sender: nil)
    }
}
extension TraineeInSessionViewController : RatingCustomFeedbackViewControllerDelegate {
    func ratingCustomFeedbackViewControllerDidCancel() {
        modalCustomFeedbackVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    func ratingCustomFeedbackViewControllerDidSubmitPrivateFeedback(privateFeedback: String) {
        modalCustomFeedbackVC?.dismissViewControllerAnimated(true, completion: nil)
        ratingViewPrivateFeedback = privateFeedback
        showAlertAndDismiss()
        sendFeedback()
    }
}
extension TraineeInSessionViewController:SharePopupViewDelegate {
    func shareOnWeChat() {
        var image = R.image.avatar()
        if let imageURL = booking.trainer?.getOptionalProfileImageURL() {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: imageURL)
                dispatch_async(dispatch_get_main_queue(), {
                    SharePopup.hide()
                    image = UIImage(data: data!)
                    APIManager.shared.sendImageContentToWeixin(image!, success: { (Success) in
                        print("Success")
                    }) { (Error) in
                        print("Error")
                    }
                });
            }
        } else {
            SharePopup.hide()
        }
    }
    
    func shareOnWeibo() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeSinaWeibo) {
            let weiboComposerVC = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
            let shareText = "\(self.ratingViewComment) \(self.shareFitiText)"
            weiboComposerVC.setInitialText(shareText)
            self.presentViewController(weiboComposerVC, animated: true, completion: nil)
            SharePopup.hide()
        }
        else {
            print("You are not connected to your Weibo account.")
        }
    }
    
    func shareOnFacebook() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            self.presentViewController(facebookComposeVC, animated: true, completion: nil)
            SharePopup.hide()
        }
        else {
            print("You are not connected to your Facebook account.")
        }
    }
    
    func skipShare() {
        SharePopup.hide()
    }
}
