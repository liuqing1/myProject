//
//  MyRequestsViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 22/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class MyRequestsViewController: BaseViewController {
    var allBookings:[Booking]=[];
    var requests:[Booking]=[];
    var currentBooking:Booking?
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalizedTitle("my_requests")
        theme = .Blue
        tableView.delegate = self
        tableView.dataSource = self
        refreshBookingsFromAPI()
        segmentedControl.removeBorders()
        segmentedControl.setTitle("Pending".localized, forSegmentAtIndex: 0)
        segmentedControl.setTitle("Accepted".localized, forSegmentAtIndex: 1)
        
    }
    private func refreshBookingsFromAPI() {
        APIManager.shared.getMyBookingsAsTrainer({ the_bookings in
            print("got updated bookings");
            self.allBookings = the_bookings
            self.reload()
            }) { message in
                print("error getting requests \(message)");
                FitiLoadingHUD.hide()
        }
    }
    @IBAction func didChangeSegment(sender: AnyObject) {
        reload()
    }
    private func reload() {
        if segmentedControl.selectedSegmentIndex==0 {
            requests = allBookings.filter({
                let s = $0.status
                return s == .Unconfirmed
            })
        } else if segmentedControl.selectedSegmentIndex==1 {
            requests = allBookings.filter({
                let s = $0.status
                return s == .Confirmed
            })
        }
        tableView.reloadData()
        FitiLoadingHUD.hide()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BookingDetail" {
            if let vc = segue.destinationViewController as? BookingDetailViewController {
                vc.booking = currentBooking;
            }
        }
    }
}
extension MyRequestsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int)->Int  {
        return requests.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrainerRequestCell", forIndexPath: indexPath) as! TrainerRequestCell
        let booking = requests[indexPath.row]
        cell.nameLabel.text = booking.trainee?.name
        cell.descLabel.text = booking.descriptionForTrainer()
        cell.booking = booking
        cell.delegate = self
        cell.showsButtons = booking.status == .Unconfirmed
        if let url = booking.trainee?.getOptionalProfileImageURL() {
            cell.avatarImageView.setImageWithURL(url, placeholderImage: R.image.avatar())
        } else {
            cell.avatarImageView.image = R.image.avatar()
        }
        
        return cell
    }
}
extension MyRequestsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let booking = requests[indexPath.row]
        self.currentBooking = booking
        self.performSegueWithIdentifier("BookingDetail", sender: nil)
    }
}
extension MyRequestsViewController : TrainerRequestCellDelegate {
    func didAccept(booking: Booking) {
        FitiLoadingHUD.showHUDForView(self.view, text: "Confirming booking".localized)
        APIManager.shared.updateBooking(booking, fields: ["status":BookingStatus.Confirmed.rawValue], success: {
                print("updated status to confirmed")
                self.refreshBookingsFromAPI()
            }) { message in
                print(message);
        }
    }
    func didReject(booking: Booking) {
        FitiLoadingHUD.showHUDForView(self.view, text: "Rejecting booking".localized)
        APIManager.shared.updateBooking(booking, fields: ["status":BookingStatus.Rejected.rawValue], success: {
            print("updated status to confirmed")
            self.refreshBookingsFromAPI()
            }) { message in
                print(message);
        }
    }
}
