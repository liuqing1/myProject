//
//  ViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 14/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit
import MapKit
import SnapKit
import MediaPlayer

class TraineeHomeViewController: BaseViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var trainerViewContainer: UIView!
    @IBOutlet weak var trainerViewContainerTop: UIView!
    @IBOutlet weak var bookingBtn: UIButton!
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var announceView: UIView!
    
    @IBOutlet weak var noTrainersView: UIView!
    @IBOutlet weak var noTrainersLabel: UILabel!
    @IBOutlet weak var noTrainersButton: UIButton!
    
    @IBOutlet weak var announceLabel: UILabel!
    @IBOutlet weak var announceClockImageView: UIImageView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    
    @IBOutlet weak var prevBtn: UIBarButtonItem!
    
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let bottomConstraintMin:CGFloat = 44.0
    
    
    let enableLeftRightSwipe = true
    
    private var timeDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .NoStyle
        return formatter
    }()
    
    
    var currentBooking:Booking?;
    var paymentOverdueBooking:Booking?;
    var bookingsForAllDates:[Booking] = [];
    
    var timer:NSTimer?;
    var timerRefresh30:NSTimer?;
    
    var trainerView:TrainerView!;
    var trainerViewTop:TrainerView!;
    var trainerDetailsView:TrainerDetailsView?;
    var locationManager: CLLocationManager!
    var trainers:[Trainer] = [];
    var trainerAnnotations:[TrainerAnnotation] = [];
    var trainerIndex:Int = -1;
    var startY:CGFloat = 0;
    let criticalDrag:CGFloat = 10
    var lastLocation:CLLocationCoordinate2D?
    
    var leftMenu:LeftMenu?
    
    var currentTrainer:Trainer? {
        get {
            return trainers[trainerIndex];
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocalizedTitle("home")
        
        
        trainerView = trainerViewContainer.embedFromNIB("TrainerView") as! TrainerView;
        trainerView.hidden = true
        trainerViewTop = trainerViewContainerTop.embedFromNIB("TrainerView") as! TrainerView;

        announceLabel.text = ""
        
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if (CLLocationManager.authorizationStatus()==CLAuthorizationStatus.AuthorizedWhenInUse || CLLocationManager.authorizationStatus()==CLAuthorizationStatus.AuthorizedAlways) {
                locationManager.startUpdatingLocation()
            }
        } else {
            noLocationAvailable()
        }
        
        toolbar.barTintColor = UIColor.whiteColor();
        toolbar.tintColor = UIColor.fitiBlue();
        toolbar.translucent = false;
        
        
        
        
        trainers = []
        
        announceView.hidden = true

        noTrainersButton.addTarget(self, action: Selector("whyNoTrainers"), forControlEvents: .TouchUpInside)
        noTrainersLabel.text = "no_trainers".localized
        noTrainersButton.setTitle("no_trainers_why".localized, forState: .Normal)
        noTrainersView.hidden = true
      
        
        mapView.delegate = self;
        mapView.userTrackingMode = .Follow
        
        
       
        
        
        let panner = UIPanGestureRecognizer(target: self, action: Selector("onPan:"))
        let tapper = UITapGestureRecognizer(target: self, action: Selector("onTap:"))
        
        if (enableLeftRightSwipe) {
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("onSwipeLeft:"))
            let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("onSwipeRight:"))
            panner.requireGestureRecognizerToFail(swipeLeft)
            panner.requireGestureRecognizerToFail(swipeRight)
            swipeLeft.direction = .Left
            swipeRight.direction = .Right
            trainerViewContainer.addGestureRecognizer(swipeLeft);
            trainerViewContainer.addGestureRecognizer(swipeRight);
            
        
            
        }
        trainerViewContainer.addGestureRecognizer(panner);
        trainerViewContainer.addGestureRecognizer(tapper);
        
        
        let atapper = UITapGestureRecognizer(target: self, action: Selector("onTapAnnounce:"))
        announceView.addGestureRecognizer(atapper)
        
        //load it, but dont add to subview yet!
        trainerDetailsView = UIView.fromNIB(filename:"TrainerDetailsView") as? TrainerDetailsView;
        
        if let trainerDetailsView = trainerDetailsView {
            trainerDetailsView.delegate = self;
            let panner2 = UIPanGestureRecognizer(target: self, action: Selector("onPan:"))
            trainerDetailsView.addGestureRecognizer(panner2)
        }
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        
        bookingBtn.setTitle("Request to Book".localized.uppercaseString, forState: .Normal)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoMap:", name: "GotoMapNotification", object: nil)
       
        
        
        
    }
    override func viewDidLayoutSubviews() {
        if let v = self.trainerDetailsView {
            if (v.superview==nil) {
                self.view.insertSubview(v, belowSubview: bookingBtn)
                v.snp_makeConstraints { (make) -> Void in
                    make.top.equalTo(trainerViewContainer.snp_bottom)
                    make.left.equalTo(trainerViewContainer.snp_left)
                    make.right.equalTo(trainerViewContainer.snp_right)
                    //height is implicit
                }
            }
        }
        self.view.layoutIfNeeded()
    }
    @IBAction func onMenu() {
        if (leftMenu == nil) {
            if let l = UIView.fromNIB(filename: "LeftMenu") as? LeftMenu, ncv = self.navigationController?.view  {
                l.attachTo(ncv);
                l.delegate = self
                
                l.menu1Label.text = "complete_my_profile".localized
                l.menu2Label.text = "Booking History".localized
                l.menu3Label.text = "FAQ".localized
                l.menu4Label.text = "logout".localized
                
                l.nameLabel.text = APIManager.shared.meTrainee?.name
                
                leftMenu = l
            }
        }
        leftMenu?.show();
        
    }
    func onTapAnnounce(sender:UIGestureRecognizer) {
        self.performSegueWithIdentifier("StartSession", sender: nil)
    }
    func pleasePay() {
        let alert = UIAlertController(title: "pay_block".localized, message: nil, preferredStyle: .Alert);
        alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: { action in
            
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    func gotoMap(note:NSNotification) {
        reset()
        if mapView.hidden {
            onFlipMapAndList(nil)
        }
        refreshBookings()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reset();
        refreshBookings()
        
        timer?.invalidate()

        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tick:"), userInfo: nil, repeats: true)
        timerRefresh30?.invalidate()
        timerRefresh30 = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("refreshBookings"), userInfo: nil, repeats: true)
        
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timerRefresh30?.invalidate()
    }
    func tick(timer:NSTimer) {
        paymentOverdueBooking = getOverdueSessions().first
        announceClockImageView.highlighted = false
        if let first = paymentOverdueBooking {
            currentBooking = first
            announceView.hidden = false
            countdownLabel.text = "Finished".localized
            announceLabel.text = "pay_now_overdue".localized
        } else if let first = getUpcomingSessions().first {
            currentBooking = first
            let now = APIManager.shared.serverTime
            announceView.hidden = false
            let df:NSDateFormatter=NSDateFormatter()
            df.dateStyle = .ShortStyle
            df.timeStyle = .ShortStyle
            countdownLabel.textColor = UIColor.fitiBlue()
            let time = first.bestAvailableStartTime
            let timeStr = timeDateFormatter.stringFromDate(time)
            if time > now {
                countdownLabel.text = time.timeIntervalSinceDate(now).asCountdownString()
                
                if (time.timeIntervalSinceDate(now)<Constants.Values.MaxTimeBeforeStartInSeconds) {
                    //1 minute to go
                    announceLabel.text = "tap_here_to_start".localized
                } else {
                    //more than 1 minute to go
                    announceLabel.text = String(format:"session_starts".localized, first.trainee?.name ?? "",timeStr)
                }
            } else {
                if (first.status == .Confirmed || first.status == .Pending) {
                    //overdue
                    announceLabel.text = "tap_here_to_start".localized
                    countdownLabel.textColor = UIColor.redColor()
                    announceClockImageView.highlighted = true
                    countdownLabel.text = now.timeIntervalSinceDate(time).asCountdownString()
                } else {
                    //in progress
                    countdownLabel.text = first.bestAvailableEndTime.timeIntervalSinceDate(now).asCountdownString()
                    announceLabel.text = String(format:"session_started".localized, timeStr)
                }
            }
        } else {
            announceView.hidden = true
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
    private func getOverdueSessions()->[Booking] {
        if (bookingsForAllDates.count==0) {
            return [];
        }
        let bookingsUpcoming = bookingsForAllDates.filter { booking in
            return booking.status == .Completed
        }
        return bookingsUpcoming
    }
    func refreshBookings() {
        print("refresh!")
        APIManager.shared.getMyBookingsAsTrainee({ the_bookings in
            self.bookingsForAllDates = the_bookings.filter({
                let s = $0.status
                return s == .Confirmed || s == .Pending || s == .InProgress || s == .Completed
            })
        }) { err in
                print(err);
        }
    }
    func reset() {
        self.bottomConstraint.constant = bottomConstraintMin
        self.bookingBtn.hidden = true;
        navigationController?.setNavigationBarHidden(false, animated: false)
        setHideBars(false)
        
    }
    @IBAction func onMakeBooking(sender: AnyObject) {
        guard let _ = APIManager.shared.meTrainee else {
            RequireLoginAlert.presentTraineeLoginAlert(self, segueIdentifier: R.segue.traineeHomeViewController.logout.identifier)
            return
        }
        if let _ = getOverdueSessions().first {
            pleasePay()
            return
        }
        self.performSegueWithIdentifier("Book", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier==R.segue.traineeHomeViewController.book.identifier {
            if let vc = segue.destinationViewController as? BookingViewController {
                vc.trainer = currentTrainer
                if let lastLocation = lastLocation {
                    vc.userLocation = lastLocation
                }
            }
        } else if segue.identifier==R.segue.traineeHomeViewController.detail.identifier {
            if let vc = segue.destinationViewController as? TrainerViewController {
                vc.trainer = currentTrainer
            }
        } else if segue.identifier==R.segue.traineeHomeViewController.startSession.identifier {
            if let nc = segue.destinationViewController as? UINavigationController, vc = nc.viewControllers.first as? TraineeInSessionViewController {
                vc.booking = currentBooking
            }
        } else if segue.identifier==R.segue.traineeHomeViewController.toWeb.identifier {
            if let vc = segue.destinationViewController as? WebViewController {
                vc.url = Util.isChinese() ? NSURL(string:Config.shared.getStr("faq_zh"))! : NSURL(string:Config.shared.getStr("faq_en"))!
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onNext(sender: AnyObject?) {
        if trainers.count>0 {
            trainerIndex = (trainerIndex+1)%trainers.count
            updateTrainerView();
        }
    }
    @IBAction func onPrev(sender: AnyObject?) {
        if trainers.count>0 {
            trainerIndex = (trainerIndex-1+trainers.count)%trainers.count
            updateTrainerView();
        }
    }
    @IBAction func onFlipMapAndList(sender:AnyObject?) {
//        if Constants.Values.DemoMode {
//            //if you're in demo mode, tapping map/list button shows a fake booking
//            let booking = Booking()
//            booking.status_string = "inprogress"
//            booking.trainer = trainerView.trainer
//            booking.trainee = APIManager.shared.meTrainee
//            booking.skill = Skill.skillById("pole-dance")
//            booking.startTime = NSDate(timeIntervalSinceNow: -15*60).nearest(15)
//            booking.duration = 60
//            booking.location = "Super Gym"
//            bookingsForAllDates = [booking]
//            self.timerRefresh30?.invalidate()
//            return
//        }
        let mapv = mapView.hidden
        if let _ = getOverdueSessions().first {
            if (!mapv) {
                pleasePay()
                return
            }
        }
        tableView.hidden = mapv
        mapView.hidden = !mapv;
        trainerViewContainer.hidden = !mapv
        prevBtn.enabled = mapv
        nextBtn.enabled = mapv
    }
    func updateTrainerView() {
        if trainers.count > 0 {
            trainerView.hidden = false
            trainerView.trainer = currentTrainer
            trainerViewTop.trainer = currentTrainer
            trainerDetailsView?.trainer = currentTrainer
            let annotation = trainerAnnotations[trainerIndex]
            if (!mapView.selectedAnnotations.contains({$0 as? TrainerAnnotation==annotation})) {
                mapView.selectAnnotation(annotation, animated: true)
            }
            noTrainersView.hidden = true
        } else {
            trainerView.hidden = true
            noTrainersView.hidden = false
        }

    }

    
    func onPan(sender:UIPanGestureRecognizer) {
        if (sender.state == .Began) {
            startY = bottomConstraint.constant
        }
        let maxDrag = trainerDetailsView?.frame.size.height ?? 0
        let newY = min(max(startY-sender.translationInView(self.view).y,bottomConstraintMin),maxDrag)
        bottomConstraint.constant = newY;
        let shouldHideBars = newY > criticalDrag+bottomConstraintMin
        setHideBars(shouldHideBars)
        if (sender.state == .Ended) {
            let velocity:CGPoint = sender.velocityInView(self.view);
            print("velocity \(velocity)");
            let inertialDiff:CGFloat = (velocity.y / 2.5);
            self.view.layoutIfNeeded()
            var newYWithInertia = bottomConstraint.constant - inertialDiff
            newYWithInertia = min(max(newYWithInertia,bottomConstraintMin),maxDrag)
            bottomConstraint.constant = newYWithInertia;
            
            UIView.animateWithDuration(0.8, delay:0, options:[.CurveEaseOut,.AllowUserInteraction], animations: {
                self.view.layoutIfNeeded()
                }, completion: { completed in
                    let shouldHideBars = newYWithInertia > self.criticalDrag+self.bottomConstraintMin
                    self.setHideBars(shouldHideBars)
                    
            })
        }

    }
    func setHideBars(shouldHideBars:Bool) {
        bookingBtn.hidden = !shouldHideBars
        announceView.alpha = shouldHideBars ? 0 : 1
        toolbar.alpha = shouldHideBars ? 0 : 1
        if (shouldHideBars) {
            if (bookingBtn.alpha < 1) {
                bookingBtn.alpha = 0
                UIView.animateWithDuration(Constants.Values.AnimationFast, delay:0.15, options:UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.bookingBtn.alpha = 1;
                    }, completion: { completed  in
                        
                });
            }
        }
        
        let snapDiff = self.view.frame.size.height - self.trainerView!.frame.size.height
        trainerViewContainerTop.hidden = bottomConstraint.constant<snapDiff
    }
    func onSwipeLeft(sender:UIGestureRecognizer) {
        if bottomConstraint.constant<=bottomConstraintMin {
            onPrev(nil);
        }
    }
    func onSwipeRight(sender:UIGestureRecognizer) {
        if bottomConstraint.constant<=bottomConstraintMin {
            onNext(nil);
        }
    }
    func onTap(sender:UIGestureRecognizer) {
        //scroll to top!
        let maxDiff = self.view.frame.size.height - self.trainerView!.frame.size.height
        if bottomConstraint.constant<=bottomConstraintMin {
            setHideBars(true)
            bottomConstraint.constant = maxDiff;
            UIView.animateWithDuration(Constants.Values.AnimationFast) {
                self.view.layoutIfNeeded()
            }
            
        } else {
            bottomConstraint.constant = bottomConstraintMin;
            UIView.animateWithDuration(Constants.Values.AnimationFast) {
                self.view.layoutIfNeeded()
            }
            setHideBars(false)
        }
        
    }
    func showTrainersNear(center:CLLocationCoordinate2D) {
        mapView.centerCoordinate = center;
        mapView.setRegion(MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01)), animated: true)
        APIManager.shared.getTrainers(center,success: { nTrainers in

            self.trainers = nTrainers
            if (nTrainers.count > 0) {
                self.trainerIndex = 0
            } else {
                self.trainerIndex = -1
            }
            self.renderTrainers()
            }) { message in
                print(message);
        }
        
    }
    func renderTrainers() {
        
        
        self.tableView.reloadData()
        
        
        mapView.removeAnnotations(trainerAnnotations)
        
        trainerAnnotations = trainers.map { trainer in
            return TrainerAnnotation(trainer: trainer);
        }
        mapView.addAnnotations(trainerAnnotations)
        
        if trainerIndex>=0 {
            mapView.selectAnnotation(trainerAnnotations[trainerIndex], animated: true);
        }
        
        updateTrainerView();
    }
    @IBAction func didPressCenterLocation(sender:AnyObject) {
        if let location = mapView.userLocation.location {
            mapView.centerCoordinate = location.coordinate
        }
    }
    func whyNoTrainers() {
        let alert = UIAlertController(title: "no_trainers_alert".localized, message: "no_trainers_alert_msg".localized, preferredStyle: .Alert);
        
        alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: { action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}
extension TraineeHomeViewController : LeftMenuDelegate {
    func didTapButtonWithIndex(index:Int) {
        leftMenu?.hide()
        
        
        if (index==3) {
            self.performSegueWithIdentifier(R.segue.traineeHomeViewController.toWeb, sender: nil)
            return
        }
        
        guard let _ = APIManager.shared.meTrainee else {
            //if not logged in, just logout and go home
            APIManager.shared.logout()
            self.performSegueWithIdentifier("Logout", sender: nil)
            return
        }
        
        if (index==1) {
            FitiLoadingHUD.showHUDForView(self.view, text: "")
            APIManager.shared.refreshMe({
                FitiLoadingHUD.hide()
                self.performSegueWithIdentifier("Profile", sender: nil)
                }, error: { message in
                    print("cant refresh profile");
            })
            return
            
        }
        if (index==2) {
            self.performSegueWithIdentifier(R.segue.traineeHomeViewController.history, sender: nil)
            return
        }
        if (index==4) {
            APIManager.shared.logout()
            self.performSegueWithIdentifier("Logout", sender: nil)
            return
        }
    }
    
    
    
    
}
extension TraineeHomeViewController:MKMapViewDelegate {
    func mapView(mapView: MKMapView, didSelectAnnotationView annotationView: MKAnnotationView) {
        if let trainerAnnotation = annotationView.annotation as? TrainerAnnotation {
            if let trainer = trainerAnnotation.trainer {
                let index = trainers.indexOf { $0 == trainer }
                if let index = index {
                    trainerIndex = index;
                    updateTrainerView()
                }
            }
        }
        if let annotation = annotationView.annotation {
            annotationView.image = pinImage(annotation, selected:true)
        }
    }
    func mapView(mapView: MKMapView, didDeselectAnnotationView annotationView: MKAnnotationView) {
        if let annotation = annotationView.annotation {
            annotationView.image = pinImage(annotation, selected:false)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // this part is boilerplate code used to create or reuse a pin annotation
        if let annotation = annotation as? TrainerAnnotation {
            let viewId = "MyCustomPinView";
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(viewId);
            if (annotationView == nil) {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: viewId);
            }
            if let annotationView = annotationView {
                annotationView.image = pinImage(annotation, selected:annotationView.selected)
            }
            return annotationView;
        } else {
            //regular annotation
            return nil;
        }
    }
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //print("change");
    }
    func pinImage(annotation:MKAnnotation, selected:Bool)->UIImage? {
        if let annotation = annotation as? TrainerAnnotation, trainer = annotation.trainer {
            if let skill:Skill = trainer.skills.first {
                return skill.pinImageSelected(selected)
            } else {
                let bigpin = UIImage(named:"pin-big")!
                let smallpin = UIImage(named:"pin-small")!
                return selected ? bigpin : smallpin
            }
        }
        return nil;
    }
   
}

extension TraineeHomeViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainers.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrainerCell", forIndexPath: indexPath)
        if let cell = cell as? TrainerCell {
            cell.trainer = trainers[indexPath.row]
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            trainerIndex = indexPath.row
            updateTrainerView()
            performSegueWithIdentifier("Detail", sender: nil)
    }
    
}
extension TraineeHomeViewController:TrainerDetailsViewDelegate {
    func trainerDetailsViewDidCloseAboutUs() {
        bottomConstraint.constant = 732.5;
        UIView.animateWithDuration(Constants.Values.AnimationFast) {
            self.view.layoutIfNeeded()
        }
    }
    func trainerDetailsViewDidLaunchVideo(url: NSURL) {
        let player = MPMoviePlayerViewController(contentURL: url)
        player.moviePlayer.fullscreen = true;
        player.moviePlayer.scalingMode = .AspectFit
        player.moviePlayer.play()
        presentViewController(player, animated:true, completion:nil)
    }
}
extension TraineeHomeViewController:CLLocationManagerDelegate {
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
            //self.mapView.setRegion(MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01)), animated: true)
            var major = false
            var minor = false
            
            if let lastLocation = lastLocation {
                let dist = CLLocation.distance(from:lastLocation, to:center)
                if (dist>1000) {
                    //significant movement
                    major = true
                    minor = true
                } else if (dist>100) {
                    minor = true
                }
            } else {
                major = true
                minor = true
            }
            if (major) {
                showTrainersNear(center)
            }
            if (minor) {
                trainerView.userLocation = center;
                trainerDetailsView?.userLocation = center;
                lastLocation = center
            }
            
        }
    }
    func noLocationAvailable() {
        let center = CLLocationCoordinate2D(latitude:31.2, longitude: 121.5);
        self.mapView.setRegion(MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01)), animated: true)
        showTrainersNear(center)
        trainerView.userLocation = center;
        trainerDetailsView?.userLocation = center
        lastLocation = center
    }
    
}

class TrainerAnnotation : NSObject,MKAnnotation {
    var trainer: Trainer?
    init(trainer: Trainer? = nil) {
        self.trainer = trainer;
    }
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: trainer?.latitude ?? 0, longitude: trainer?.longitude ?? 0);
    }
    var title:String? {
        return self.trainer?.name;
    }
}


