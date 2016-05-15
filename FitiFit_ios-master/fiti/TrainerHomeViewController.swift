//
//  TrainerHomeViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 21/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import CVCalendar
import MapKit
class TrainerHomeViewController: BaseViewController {
    var locationManager: CLLocationManager!
    var lastLocation:CLLocationCoordinate2D?;
    var bookings:[Booking]=[]
    var bookingsForAllDates:[Booking]=[]
    let dftime = NSDateFormatter();
    let dfdate = NSDateFormatter();
    let dfmonth = NSDateFormatter();
    var pickedDate = APIManager.shared.serverTime;
    let basefont = UIFont(name:Constants.Fonts.MonsterratRegular, size: 15)!
    

    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var relativeDateLabel:UILabel!
    
    
    @IBOutlet weak var announceView: UIView!
    @IBOutlet weak var announceViewButton: UIButton!
    @IBOutlet weak var announceLabel: UILabel!
    @IBOutlet weak var announceClockImageView: UIImageView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    private var timeDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .NoStyle
        return formatter
    }()
    
    
    @IBOutlet var bookingsTableView:UITableView!
    
    var leftMenu:LeftMenu?
    
    override func viewDidLoad() {
        setLocalizedTitle("home")
        
        dftime.dateStyle = .NoStyle
        dftime.timeStyle = .ShortStyle
        
        
        dfdate.dateStyle = .LongStyle
        dfdate.timeStyle = .NoStyle
        
        dfmonth.dateFormat = "MMMM"
        
        announceLabel.text = ""
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            if (CLLocationManager.authorizationStatus()==CLAuthorizationStatus.AuthorizedWhenInUse || CLLocationManager.authorizationStatus()==CLAuthorizationStatus.AuthorizedAlways) {
                locationManager.startUpdatingLocation()
            }
        } else {
            //noLocationAvailable()
        }
        bookingsTableView.delegate = self
        bookingsTableView.dataSource = self
        
        
        
        
        let appearance = CVCalendarViewAppearance()
        appearance.delegate = self
        calendarView.appearance = appearance
        
        
        calendarView.delegate = self
        menuView.delegate = self
        presentedDateUpdated(calendarView.presentedDate);
        
        checkForUpcomingSessions(nil)
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkForUpcomingSessions:"), userInfo: nil, repeats: true)
        
        if let me = APIManager.shared.meTrainer {
            if me.status != 1 {
                TrainerTutorial.showTutorial(self.navigationController?.view)
                //and refresh to see if we're approved
                APIManager.shared.refreshMe({
                    //
                    }, error: { msg in
                        //
                })
            }
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshBookingsFromAPI();
    }
    private func refreshBookingsFromAPI() {
        APIManager.shared.getMyBookingsAsTrainer({ the_bookings in
            print("got updated bookings");
            self.bookingsForAllDates = the_bookings.filter({
                let s = $0.status
                return s == .Confirmed || s == .Pending || s == .InProgress || s == .Completed
            })
            self.reload()
            }) { message in
                print("error getting bookings \(message)");
        }
    }
    func checkForUpcomingSessions(obj:AnyObject?) {
        let upcoming = getUpcomingSessions()
        let now = APIManager.shared.serverTime
        if let first = upcoming.first {
            announceView.hidden = false
            let time = first.bestAvailableStartTime
            countdownLabel.textColor = UIColor.fitiBlue()
            announceClockImageView.highlighted = false
            if time > now {
                countdownLabel.text = time.timeIntervalSinceDate(now).asCountdownString()
                let timeStr = timeDateFormatter.stringFromDate(time)
                if (time.timeIntervalSinceDate(now)<Constants.Values.MaxTimeBeforeStartInSeconds) {
                    announceLabel.text = "tap_here_to_start".localized
                } else {
                    announceLabel.text = String(format:"session_starts".localized, first.trainee?.name ?? "",timeStr)
                }
            } else if first.status == .InProgress {
                countdownLabel.text = first.bestAvailableEndTime.timeIntervalSinceDate(now).asCountdownString()
                let time = timeDateFormatter.stringFromDate(time)
                announceLabel.text = String(format:"session_started".localized, time)
            } else {
                countdownLabel.text = now.timeIntervalSinceDate(time).asCountdownString()
                countdownLabel.textColor = UIColor.redColor()
                announceClockImageView.highlighted = true
                announceLabel.text = "tap_here_to_start".localized
            }
            
        } else {
            announceView.hidden = true
        }
        
    }
    @IBAction func onTapAnnounceView(obj:AnyObject) {
        performSegueWithIdentifier("StartSession", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "StartSession") {
            if let nc = segue.destinationViewController as? UINavigationController, vc = nc.viewControllers.first as? TrainerInSessionViewController {
                vc.booking = getUpcomingSessions().first
            }
        } else if segue.identifier==R.segue.trainerHomeViewController.toWeb.identifier {
            if let vc = segue.destinationViewController as? WebViewController {
                vc.url = Util.isChinese() ? NSURL(string:Config.shared.getStr("faq_trainer_zh"))! : NSURL(string:Config.shared.getStr("faq_trainer_en"))!
            }
        }
    }
    private func getUpcomingSessions()->[Booking] {
        if (bookingsForAllDates.count==0) {
            return [];
        }
        let now = APIManager.shared.serverTime
        let bookingsUpcoming = bookingsForAllDates.filter { booking in
            let t = booking.bestAvailableStartTime
            let startsInNextHour =  t > now && t.timeIntervalSinceDate(now)<60*60
            let inProgress = t < now && now.timeIntervalSinceDate(t) < Double(booking.duration)*60
            return startsInNextHour || inProgress
        }
        return bookingsUpcoming
        
    }
    private func getAllInProgressAndFutureSessions()->[Booking] {
        if (bookingsForAllDates.count==0) {
            return [];
        }
        let now = APIManager.shared.serverTime
        let bookingsUpcoming = bookingsForAllDates.filter { booking in
            guard let t = booking.startTime else {
                return false
            }
            let inFuture =  t > now
            let inProgress = t < now && now.timeIntervalSinceDate(t) < Double(booking.duration)*60
            return inFuture || inProgress
        }
        return bookingsUpcoming
        
    }
    private func bookingsForDate(date:CVDate)->[Booking] {
        let bs = self.bookingsForAllDates.filter({ booking in
            if let t = booking.startTime {
                return t.isOnSameDayAs(date)
            }
            return false
        })
        return bs
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    func reload() {
        if let d = calendarView.presentedDate {
            self.bookings = bookingsForDate(d)
        }
        bookingsTableView.reloadData()
        if let cc = calendarView.contentController as? CVCalendarMonthContentViewController {
            cc.refreshPresentedMonth()
        }
        checkForUpcomingSessions(nil);
    }
    @IBAction func onMenu() {
        if (leftMenu == nil) {
            if let l = UIView.fromNIB(filename: "LeftMenu") as? LeftMenu, ncv = self.navigationController?.view  {
                l.attachTo(ncv);
                l.delegate = self
                
                l.menu1Label.text = "complete_my_profile".localized
                l.menu2Label.text = "FAQ".localized
                l.menu3Label.text = "logout".localized
                l.menu4Label.text = ""
                l.nameLabel.text = APIManager.shared.meTrainer?.name
                
                leftMenu = l
            }
        }
        leftMenu?.show();
    }
}
extension TrainerHomeViewController:LeftMenuDelegate {
    func didTapButtonWithIndex(index: Int) {
        leftMenu?.hide()
        if (index==1) {
            FitiLoadingHUD.showHUDForView(self.view, text: "")
            APIManager.shared.refreshMe({
                FitiLoadingHUD.hide()
                self.performSegueWithIdentifier("Profile", sender: nil)
                }, error: { message in
                    print("cant refresh profile");
            })
        } else if (index==2) {
            self.performSegueWithIdentifier(R.segue.trainerHomeViewController.toWeb, sender: nil)
        } else if (index==3) {
            APIManager.shared.logout()
            self.performSegueWithIdentifier("Logout", sender: nil)
        }
    }
}



extension TrainerHomeViewController:CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (CLLocationManager.authorizationStatus()==CLAuthorizationStatus.AuthorizedWhenInUse || CLLocationManager.authorizationStatus()==CLAuthorizationStatus.AuthorizedAlways) {
            locationManager.startUpdatingLocation()
        } else if (status == .Restricted || status == .Denied) {
            noLocationAvailable()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            var significant = false
            if let lastLocation = lastLocation {
                let dist = CLLocation.distance(from:lastLocation, to:center)
                if (dist>100) {
                    //significant movement
                    significant = true
                }
            } else {
                significant = true
            }
            if (significant) {
                lastLocation = center
                let loc_date = APIManager.shared.serverTime.toISODate()
                
                APIManager.shared.updateTrainer(["latitude":center.latitude,"longitude":center.longitude, "location_updated":loc_date], success: {
                    print("updated lat/long")
                    }, error: { message in
                    print("error \(message)")
                })
            }
            
        }
    }
    func noLocationAvailable() {
        
    }
   
}
extension TrainerHomeViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int)->Int  {
        return bookings.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookingCell", forIndexPath: indexPath) as! TrainerUpcomingBookingCell
        if let time = bookings[indexPath.row].startTime {
            cell.timeLabel.text = timeDateFormatter.stringFromDate(time)
        }
        cell.descLabel.text = bookings[indexPath.row].quickDescription()
        let isNext = getAllInProgressAndFutureSessions().first == bookings[indexPath.row]
        cell.nextDot.hidden = !isNext
        cell.descLabel.textColor = isNext ? UIColor.fitiGray() : UIColor.fitiLightGray()
        cell.timeLabel.textColor = isNext ? UIColor.fitiGray() : UIColor.fitiLightGray()
        return cell
    }
}
extension TrainerHomeViewController : UITableViewDelegate {
   
}


extension TrainerHomeViewController:CVCalendarViewDelegate,CVCalendarMenuViewDelegate {
    func presentationMode() -> CalendarMode {
        return CalendarMode.MonthView
    }
    func firstWeekday() -> Weekday {
        return Weekday.Monday
    }
    func presentedDateUpdated(date: Date) {
        if let d = date.convertedDate() {
            pickedDate = d
            reload()
            monthLabel.text = dfmonth.stringFromDate(d).uppercaseString
            dateLabel.text = dfdate.stringFromDate(d)
            let now = APIManager.shared.serverTime
            let dstr = dfdate.stringFromDate(d)
            if (NSCalendar.currentCalendar().isDateInToday(d)) {
                relativeDateLabel.text = "today".localized
            } else if (d.datePartIsStrictlyBefore(now)) {
                let rel = String(format:"x_days_ago".localized, d.numberOfDaysUntilDate(now))
                relativeDateLabel.text = "\(dstr) \(rel)"
            } else {
                let rel = String(format:"x_days_hence".localized, now.numberOfDaysUntilDate(d))
                relativeDateLabel.text = "\(dstr) \(rel)"
            }

            
        }
    }
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        return bookingsForDate(dayView.date).count>0
    }
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [UIColor.fitiGray()]
    }
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 12;
    }
    func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat {
        return 11;
    }
}
extension TrainerHomeViewController:CVCalendarViewAppearanceDelegate {
    func dayLabelWeekdayFont()->UIFont  {
        return basefont
    }
    func dayLabelPresentWeekdayFont()->UIFont {
        return basefont
    }
    func dayLabelPresentWeekdayBoldFont()->UIFont {
        return basefont
    }
    func dayLabelPresentWeekdayHighlightedFont()->UIFont {
        return basefont
    }
    func dayLabelPresentWeekdaySelectedFont()->UIFont {
        return basefont
    }
    func dayLabelWeekdayHighlightedFont()->UIFont {
        return basefont
    }
    func dayLabelWeekdaySelectedFont()->UIFont {
        return basefont
    }
    func dayLabelPresentWeekdaySelectedBackgroundColor()->UIColor {
        return UIColor.fitiBlue()
    }
    func dayLabelWeekdaySelectedBackgroundColor()->UIColor {
        return UIColor.fitiBlue()
    }
    func dayLabelPresentWeekdayTextColor()->UIColor {
        return UIColor.fitiGray()
    }
    func dayLabelWeekdayInTextColor()->UIColor {
        return UIColor.fitiGray()
    }
}

