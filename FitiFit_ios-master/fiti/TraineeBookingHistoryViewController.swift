//
//  TraineeBookingHistoryViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 15/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class TraineeBookingHistoryViewController: BaseViewController {
    var allBookings:[Booking]=[];
    var requests:[Booking]=[];
    var currentBooking:Booking?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        theme = .Blue
        setLocalizedTitle("Booking History")
        
        tableView.delegate = self
        tableView.dataSource = self
        themeRightButton()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        requests = []
        tableView.reloadData()
        refreshBookingsFromAPI()
    }
    private func refreshBookingsFromAPI() {
        activityIndicator.startAnimating()
        APIManager.shared.getMyBookingsAsTrainee({ the_bookings in
            print("got updated bookings");
            self.allBookings = the_bookings
            self.activityIndicator.stopAnimating()
            self.reload()
            }) { message in
                print("error getting requests \(message)");
                self.activityIndicator.stopAnimating()
        }
    }
    @IBAction func didClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    private func reload() {
        requests = allBookings
        tableView.reloadData()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.traineeBookingHistoryViewController.bookingDetail.identifier {
            if let vc = segue.destinationViewController as? BookingDetailViewController {
                vc.booking = currentBooking;
            }
        }
    }
    
}
extension TraineeBookingHistoryViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int)->Int  {
        return requests.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.traineeBookingCell.identifier, forIndexPath: indexPath) as! TraineeBookingCell
        let booking = requests[indexPath.row]
        cell.descLabel.text = booking.descriptionForTrainee()
        cell.dateLabel.text = booking.niceDate()
        cell.statusLabel.text = "ts-\(booking.status_string!)".localized
        cell.statusLabel.textColor = UIColor.fitiLightGray()
        if let url = booking.trainer?.getOptionalProfileImageURL() {
            cell.avatarImageView.setImageWithURL(url, placeholderImage: R.image.avatar())
        } else {
            cell.avatarImageView.image = R.image.avatar()
        }
        if (booking.status == .Confirmed || booking.status == .Pending || booking.status == .InProgress) {
            cell.statusLabel.textColor = UIColor.fitiBlue()
        } else if (booking.status == .Unconfirmed) {
            cell.statusLabel.textColor = UIColor.fitiGray()
        }
        
        cell.booking = booking
        return cell
    }
}
extension TraineeBookingHistoryViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let booking = requests[indexPath.row]
        self.currentBooking = booking
        self.performSegueWithIdentifier(R.segue.traineeBookingHistoryViewController.bookingDetail.identifier, sender: nil)
    }
}

