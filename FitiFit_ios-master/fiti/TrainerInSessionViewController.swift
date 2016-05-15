//
//  StartSessionViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 26/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class TrainerInSessionViewController: BaseViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    
    
    var appeared:Bool = false
    var booking:Booking!
    var timer:NSTimer?
    var clock:NSTimer?;
    
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
        descLabel.text = String(format:"skill_with_person_at_location".localized, skill.localizedName() ?? "", booking.trainee?.name ?? "", booking.niceLocation())
        
        closeBtn.setTitle("Close".localized, forState: .Normal)
        startButton.setTitle("start_session".localized, forState: .Normal)
        

        detailsButton.setTitle("see_session_details".localized, forState: .Normal)
        
        
       
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
        updateUI()
    }
    override func viewDidAppear(animated: Bool) {
        appeared=true
        if booking==nil {
            exitScreen()
        }
    }
    func exitScreen() {
        booking = nil
        if (appeared) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? BookingDetailViewController {
            vc.booking = booking
        }
    }
    func updateUI() {
        guard let time = booking.startTime else {
            exitScreen()
            return
        }
        clockLabel.hidden = true
        logoImage.hidden = false
        switch booking.status {
        case .Confirmed:
            //enable start button if there are less than 10 mins to go.
            startButton.hidden = false

            startButton.enabled = time.timeIntervalSinceDate(APIManager.shared.serverTime) < Constants.Values.MaxTimeBeforeStartInSeconds
            if (!startButton.enabled) {
                NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("updateUI"), userInfo: nil, repeats: false)
            }
        case .Unconfirmed,.Rejected,.Cancelled,.Skipped,.Withdrawn,.Expired,.Unknown,.Paid:
            //this shouldnt happen
            startButton.hidden = false
            startButton.enabled = false
            exitScreen()
            return
        case .Pending:
            startButton.hidden = true
            FitiLoadingHUD.showHUDForView(view, text: "Waiting for trainee".localized)
            if (self.timer==nil) {
                startPendingTimer()
            }
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
        case .Completed:
            startButton.hidden = true
            startButton.enabled = true
            logoImage.hidden = true
            clockLabel.hidden = false
            clockLabel.text = "Finished".localized
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
        FitiLoadingHUD.showHUDForView(self.view, text: "Starting session".localized)
        APIManager.shared.updateBooking(booking, fields: ["status":BookingStatus.Pending.rawValue], success: {
            self.startPendingTimer()
            }) { err in
                print("unable to start booking \(err)")
                FitiLoadingHUD.hide()
        }
    }
    func startPendingTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("refreshBooking"), userInfo: nil, repeats: true)
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
