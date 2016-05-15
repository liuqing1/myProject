//
//  BookingDetailViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 01/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import MapKit
class BookingDetailViewController: BaseViewController {
    
    var booking:Booking!
    let df1 = NSDateFormatter()
    let df2 = NSDateFormatter()
    //header
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    //3 cells
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var skillLabel: UILabel!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var titleDurationLabel: UILabel!
    @IBOutlet weak var titleSkillLabel: UILabel!
    @IBOutlet weak var titlePeopleLabel: UILabel!
    
    
    
    //details
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var cancelButtonHeight: NSLayoutConstraint!

    @IBOutlet weak var titleDateLabel: UILabel!
    @IBOutlet weak var titleTimeLabel: UILabel!
    @IBOutlet weak var titlePriceLabel: UILabel!
    @IBOutlet weak var titleLocationLabel: UILabel!
    @IBOutlet weak var titleDetailsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var timeFromHereLabel: UILabel!
    @IBOutlet weak var distanceFromhereLabel: UILabel!
    
    @IBOutlet weak var mapOverlayView: UIView!
    @IBOutlet weak var pinView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Booking Detail".localized
        
        df1.dateStyle = .MediumStyle
        df1.timeStyle = .NoStyle
        
        df2.dateStyle = .NoStyle
        df2.timeStyle = .ShortStyle
        
       
        
        dateLabel.text = df1.stringFromDate(booking.startTime!)
        timeLabel.text  = df2.stringFromDate(booking.startTime!)
        timeLabel.text  = df2.stringFromDate(booking.startTime!)
        priceLabel.text = String(format:"¥%.02f",booking.cost)
        durationLabel.text = booking.duration.inHours()
        skillLabel.text = booking.skill?.localizedName()
        peopleLabel.text = "\(booking.people)"
        locationLabel.text = booking.location
        let c = booking.coordinate()
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(c, 1000, 1000), animated: false)
        if let skill = booking.skill {
            pinView.image = skill.pinImageSelected(true)
        }
    
        cancelButton.setTitle("cancel_session".localized, forState: .Normal)
        callButton.setTitle("call".localized.uppercaseString, forState: .Normal)
        var cancellable = false
        if let _ = APIManager.shared.meTrainee {
            cancellable = (booking.status == .Confirmed || booking.status == .Unconfirmed)
        }
        cancelButtonHeight.constant = cancellable ? 60 : 0
        cancelButton.hidden = !cancellable
        
        
        titleDurationLabel.text = "Duration".localized
        titlePeopleLabel.text = "People".localized
        titleSkillLabel.text = "activity".localized
        titleDateLabel.text = "Date".localized
        titleTimeLabel.text = "Time".localized
        titlePriceLabel.text = "price".localized
        titleDetailsLabel.text = "Details".localized
        titleLocationLabel.text = "Location".localized

        photoImageView.circle()
        if let _ = APIManager.shared.meTrainee {
            nameLabel.text = booking.trainer?.name
            if let url = booking.trainer?.getOptionalProfileImageURL() {
                photoImageView.setImageWithURL(url, placeholderImage: R.image.avatar())
            } else {
                photoImageView.image = R.image.avatar()
            }
        } else if let _ = APIManager.shared.meTrainer {
            nameLabel.text = booking.trainee?.name
            if let url = booking.trainee?.getOptionalProfileImageURL() {
                photoImageView.setImageWithURL(url, placeholderImage: R.image.avatar())
            } else {
                photoImageView.image = R.image.avatar()
            }
        }
        
        mapView.showsUserLocation = true
        mapView.delegate = self;
        refreshMapDistances()
        mapOverlayView.layer.zPosition = 1
        

        // Do any additional setup after loading the view.
    }
    func refreshMapDistances() {
        let userLocationCoord = mapView.userLocation.coordinate
        
        let distance = CLLocation.distance(from: userLocationCoord, to:booking.coordinate());
        if (distance<20000) {
            distanceFromhereLabel.text = String(format: "km".localized, distance/1000);
            timeFromHereLabel.text = String(format: "%.0f mins".localized, distance/800); // driving pace 30mph = 800metres/minute 
                mapOverlayView.hidden = false
        } else {
            mapOverlayView.hidden = true
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCall() {
        
        if let _ = APIManager.shared.meTrainer {
            if let phone = booking?.trainee?.phone, let url = NSURL(string:"tel://\(phone)") {
                UIApplication.sharedApplication().openURL(url)
            }
        } else {
            if let phone = booking?.trainer?.phone, let url = NSURL(string:"tel://\(phone)") {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        
        
    }
    @IBAction func onCancel() {
        
        let alert = UIAlertController(title: "cancel_alert_title".localized, message: "cancel_alert_msg".localized, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title:"cancel_yes".localized, style:.Default, handler: { action in
            self.actuallyCancel()
        }))
        alert.addAction(UIAlertAction(title:"cancel_no".localized, style:.Cancel, handler: { action in
            
        }))
        presentViewController(alert, animated: true, completion: nil)
        
    }
    func actuallyCancel() {
        //https://github.com/reigndesign/FitiFit/issues/307
        if let _ = APIManager.shared.meTrainee {
            if booking.status == .Unconfirmed {
                FitiLoadingHUD.showHUDForView(view, text: "")
                APIManager.shared.updateBooking(booking, fields: ["status":BookingStatus.Withdrawn.rawValue], success: { booking in
                    self.dismiss()
                    FitiLoadingHUD.hide()
                    }, error: { msg in
                        FitiLoadingHUD.hide()
                        print(msg)
                })
            } else if booking.status == .Confirmed {
                APIManager.shared.updateBooking(booking, fields: ["status":BookingStatus.Cancelled.rawValue], success: { booking in
                    self.dismiss()
                    FitiLoadingHUD.hide()
                    }, error: { msg in
                        print(msg)
                        FitiLoadingHUD.hide()
                })
            } else {
                print("cant cancel since in wrong state")
            }
        }
    }

    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension BookingDetailViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        refreshMapDistances();
    }
}