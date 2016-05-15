//
//  BookingViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 17/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit
import MapKit
import CVCalendar

class BookingViewController: BaseViewController {
    let dftime = NSDateFormatter();
    let dfalert = NSDateFormatter();
    let dfdate = NSDateFormatter();
    let dfmonth = NSDateFormatter();
    
    var trainer:Trainer?
    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    
    @IBOutlet weak var scrollView:UIScrollView!
    
    @IBOutlet weak var monthLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    
    @IBOutlet weak var startTitleLabel: UILabel!
    
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var endTitleLabel: UILabel!
    @IBOutlet weak var endTimePicker:UIPickerView!
    @IBOutlet weak var startTimePicker:UIPickerView!
    @IBOutlet weak var bookBtn:UIButton!
    @IBOutlet weak var startTimeLabel:UILabel!
    @IBOutlet weak var endTimeLabel:UILabel!
    @IBOutlet weak var priceLabel:UILabel!;
    
    @IBOutlet weak var paymentTypeLabel:UILabel!;
    @IBOutlet weak var paymentTypeIcon:UIImageView!;
    
    @IBOutlet weak var titleDurationLabel: UILabel!
    @IBOutlet weak var titlePeopleLabel: UILabel!
    @IBOutlet weak var titleTotalPriceLabel: UILabel!
    @IBOutlet weak var titlePaymentMethodLabel: UILabel!
    @IBOutlet weak var titleLocationLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    
    @IBOutlet var btnLocations: [UIButton]!
    @IBOutlet var labelLocations: [UILabel]!
    @IBOutlet var titleLocations: [UILabel]!
    @IBOutlet var constraintLocationHeights: [NSLayoutConstraint]!

    
    @IBOutlet weak var skillsView: UICollectionView!
    
    

    
    let durationPoint:CGPoint = CGPoint(x:0, y:270)
    
    let currentNearestTime = APIManager.shared.serverTime.nearest(15)
    var startTime = APIManager.shared.serverTime.nearest(15)
    var duration:Int = 60
    var startTimes:[String] = [];
    var durations:[String] = [];
    
    var toolbar1:UIToolbar?;
    var toolbar2:UIToolbar?;
    
    var selectedLocationOption:LocationType = .Me;
    var possibleLocationOption:LocationType = .Me;
    
    let basefont = UIFont(name:Constants.Fonts.MonsterratRegular, size: 15)!

    @IBOutlet weak var termsCheckbox: CheckBox!
    @IBOutlet weak var numberOfPeopleSegmentedControl:UISegmentedControl!;
    var userLocation:CLLocationCoordinate2D?
    var location:CLLocationCoordinate2D?

    let CellIdentifier = "TrainerSkillCell"
    private var selectedSkillRow: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTime = APIManager.shared.serverTime.nearest(15)
        let nib = UINib(nibName: "TrainerSkillCell", bundle: nil)
        skillsView.registerNib(nib, forCellWithReuseIdentifier: CellIdentifier)
        skillsView.backgroundColor = UIColor.clearColor()
        
        toolbar1 = addToolbarToPicker(startTimePicker)
        toolbar2 = addToolbarToPicker(endTimePicker)

        navigationItem.title = "Request to Book".localized
        startTitleLabel.text = "start".localized
        endTitleLabel.text = "Duration".localized
        startTimeLabel.text = "Now".localized
        activityTitleLabel.text = "activity".localized
        termsLabel.text = "accept_tcs".localized
        
        let appearance = CVCalendarViewAppearance()
        appearance.delegate = self
        calendarView.appearance = appearance
        calendarView.delegate = self
        menuView.delegate = self
        menuView.dayOfWeekTextColor = UIColor.fitiBlue()
        
        self.title = "Book a session".localized
        self.titleDurationLabel.text = "Time".localized;
        self.titlePeopleLabel.text = "People".localized;
        self.titleTotalPriceLabel.text = "Total Price".localized;
        self.titlePaymentMethodLabel.text = "Payment method".localized;
        self.titleLocationLabel.text = "Location".localized;
        endTimePicker.dataSource = self;
        endTimePicker.delegate = self;
        startTimePicker.dataSource = self;
        startTimePicker.delegate = self;
        
        labelLocations[0].text = "";
        labelLocations[1].text = "";
        labelLocations[2].text = "";
        
        titleLocations[0].text = "use_my_location".localized
        titleLocations[1].text = "use_trainers_location".localized
        titleLocations[2].text = "use_custom_location".localized
        
        dftime.dateStyle = .NoStyle
        dftime.timeStyle = .ShortStyle
        
        dfalert.dateStyle = .MediumStyle
        dfalert.timeStyle = .ShortStyle
        
        dfdate.dateStyle = .LongStyle
        dfdate.timeStyle = .NoStyle
        
        dfmonth.dateFormat = "MMMM"
        
        numberOfPeopleSegmentedControl.removeBorders()
        
        calculateTimes()
        // Do any additional setup after loading the view.
        let tapper = UITapGestureRecognizer()
        tapper.addTarget(self, action: Selector("hidePicker"))
        self.view.addGestureRecognizer(tapper)
        didChangeTermsStatus();

        location = userLocation
        
        assert(btnLocations.count >= 3)
       

        selectLocationOptionAnimated(false)
        
        paymentTypeLabel.text = Payment.isAlipayInstalled() ? "pay_alipay".localized : "pay_none".localized
        paymentTypeIcon.hidden = !Payment.isAlipayInstalled()
        
        presentedDateUpdated(calendarView.presentedDate);

        let hitTestTapGesture = UITapGestureRecognizer(target: self, action: "onTapOnScrollView:")
        hitTestTapGesture.numberOfTapsRequired = 1
        self.scrollView.userInteractionEnabled = true
        self.scrollView.addGestureRecognizer(hitTestTapGesture)

        
        bookBtn.setTitle("Book session".localized.uppercaseString, forState: .Normal)
        
        markFirstSkillSelected()
    }

    func markFirstSkillSelected() {
        if let trainer = trainer {
            if Int(trainer.skills.count) > 0 {
                selectedSkillRow = 0
                let firstItem = NSIndexPath(forRow: selectedSkillRow!, inSection: 0)
                skillsView.selectItemAtIndexPath(firstItem, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
            }
        }
    }

    func onTapOnScrollView(sender : UITapGestureRecognizer){
        let touchPoint: CGPoint = sender.locationOfTouch(0, inView: self.skillsView)
        let indexPath: NSIndexPath? = self.skillsView.indexPathForItemAtPoint(touchPoint)

        if let indexPath = indexPath {
            selectedSkillRow = indexPath.row
            skillsView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
        }
    }
    
    func calculateTimes() {
        startTimes = []
        
        for (var mins = 0; mins<24*60; mins+=15) {
            startTimes.append(dftime.stringFromDate(dateAheadOfMidnightOn(startTime, mins: mins)))
        }
        
        
        durations = []
        for (var mins = 30; mins<4*60; mins+=15) {
            durations.append(mins.inHours())
        }
        endTimeLabel.text = duration.inHours()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
   

    @IBAction func openMap(sender : UIButton){
        self.possibleLocationOption = LocationType(rawValue:sender.tag)!
        self.performSegueWithIdentifier("Map", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="Map" {
            if let nav = segue.destinationViewController as? UINavigationController, let vc = nav.topViewController as? MapViewController{
                let zero:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0,0);
                vc.locationType = self.possibleLocationOption
                switch self.possibleLocationOption {
                case .Me:
                    vc.location = self.userLocation ?? zero
                case .Trainer:
                    vc.location = trainer?.coordinate() ?? zero
                case .Custom:
                    vc.location = self.userLocation ?? zero
                };

                vc.trainer = trainer
                vc.delegate = self;
            }
        }
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        self.navigationController?.setToolbarHidden(true, animated: animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segmentedControlDidUpdate() {
        updateUI()
        hidePicker()
    }
    func updateUI() {
        //guard let trainer = trainer else {return}
        priceLabel.text = String(format:"¥%.02f",getCost())
        if (NSCalendar.currentCalendar().isDateInToday(startTime) && abs(startTime.timeIntervalSinceDate(currentNearestTime))<60) {
            startTimeLabel.text = "Now".localized
        } else {
            startTimeLabel.text = dftime.stringFromDate(startTime)
        }
    }
    private func getCost()->Float {
        guard let trainer = trainer else {return 0}
        let cost = Float(trainer.price)*(Float(numberOfPeopleSegmentedControl.selectedSegmentIndex)+1.0)*(Float(duration)/60.0)
        return cost;
        
    }
    func hidePicker() {
        startTimePicker.hidden = true;
        toolbar1?.hidden = true;
        endTimePicker.hidden = true;
        toolbar2?.hidden = true
    }
    @IBAction func tapStart() {
        
        if (startTimePicker.hidden) {
            scrollView.setContentOffset(durationPoint, animated: true)
            startTimePicker.hidden = false
            toolbar1?.hidden = false
            if startTimeLabel.text == "Now".localized {
                let row = Int(startTime.timeIntervalSinceDate(dateAheadOfMidnightOn(startTime, mins: 0))/(60*15))
                startTimePicker.selectRow(row, inComponent: 0, animated: false)
            } else if let index = startTimes.indexOf(startTimeLabel.text ?? "") {
                startTimePicker.selectRow(index, inComponent: 0, animated: false)
            }
        } else {
            startTimePicker.hidden = true
            toolbar1?.hidden = true
        }
        
    }
    @IBAction func tapDuration() {
        if (endTimePicker.hidden) {
            scrollView.setContentOffset(durationPoint, animated: true)
            endTimePicker.hidden = false
            toolbar2?.hidden = false
            if let index = durations.indexOf(endTimeLabel.text ?? "") {
                endTimePicker.selectRow(index, inComponent: 0, animated: false)
            }
        } else {
            endTimePicker.hidden = true
            toolbar2?.hidden = true
        }
        
    }
    @IBAction func didChangeTermsStatus() {
        bookBtn.enabled = termsCheckbox.isChecked;
        let blue:UIColor = UIColor.colorWithHexString("2F95FB")
        bookBtn.backgroundColor = termsCheckbox.isChecked ? blue : UIColor.grayColor()
    }
    @IBAction func onConfirm() {
        if startTime.timeIntervalSinceReferenceDate - currentNearestTime.timeIntervalSinceReferenceDate < -10*60 {
            let alert = UIAlertController(title: "Cannot book".localized, message: "You cannot book a session in the past".localized, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return;
        }
        if (!Payment.isAlipayInstalled()) {
            let alert = UIAlertController(title: nil, message: "pay_noapp".localized, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return;
        }
        if let trainer = trainer {
            guard let selectedSkillRow = selectedSkillRow else {
                return
            }
            let selectedSkill = trainer.skills[selectedSkillRow]
            
            let datestr = dfalert.stringFromDate(startTime)
            let skillTitle = selectedSkill.localizedName() ?? ""
            let message = String(format:"confirm_alert".localized, skillTitle, self.duration.inHours(), trainer.name, datestr, priceLabel.text!)
            let alert = UIAlertController(title: "Confirm Booking".localized, message:message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Book".localized, style: .Default, handler: { action in
                
               
                
                let people = self.numberOfPeopleSegmentedControl.selectedSegmentIndex+1
                let latitude = self.location?.latitude ?? 0
                let longitude = self.location?.longitude ?? 0
                var location = self.labelLocations[self.selectedLocationOption.rawValue].text ?? "?"
                if (location=="") {
                    location="?"
                }
                
                FitiLoadingHUD.showHUDForView(self.view, text: "Making booking".localized)
                
                APIManager.shared.makeBooking(trainer, skill: selectedSkill, duration: self.duration, startTime: self.startTime, people: people, latitude: latitude, longitude: longitude, location: location, success: {
                        FitiLoadingHUD.hide()
                        NSNotificationCenter.defaultCenter().postNotificationName("GotoMapNotification", object: nil)
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }, error: { message in
                        FitiLoadingHUD.hide()
                        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                })
                
                
            }))
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .Cancel, handler: { action in
                //cancel
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func dateAheadOfMidnightOn(date:NSDate, mins:Int)->NSDate {
        let ti = NSTimeInterval(mins*60)
        let midnight = NSCalendar.currentCalendar().startOfDayForDate(date)
        return midnight.dateByAddingTimeInterval(ti)
    }
    func stringForTimeAheadOfStartTimeBy(mins:Int)->String {
        let ti = NSTimeInterval(mins*60)
        let time = dftime.stringFromDate(startTime.dateByAddingTimeInterval(ti))
        return time
    }
   
    
    
    
    
    func selectLocationOptionAnimated(animated: Bool){
        let targetTag = self.selectedLocationOption.rawValue
        for (index, btn) in self.btnLocations.enumerate() {
            if targetTag == index {
                btn.selected = true
                self.constraintLocationHeights[index].constant = 14
                self.titleLocations[index].textColor = UIColor.fitiBlue()
            } else {
                btn.selected = false
                self.constraintLocationHeights[index].constant = 0.1
                self.titleLocations[index].textColor = UIColor.fitiGray()
            }
        }
        let layoutBlock: () -> Void = { () -> Void in
            for (index, _) in self.btnLocations.enumerate() {
                if targetTag == index {
                    self.labelLocations[index].alpha = 1.0
                } else {
                    self.labelLocations[index].alpha = 0.0
                }
            }
            self.view.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration(Constants.Values.AnimationFast, animations: layoutBlock)
        } else {
            layoutBlock()
        }
        if let location = location {
            MapUtils.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)){
                (address: String) -> Void in
                self.labelLocations[targetTag].text = address
            }
        }
        
        
    }
    func addToolbarToPicker(picker:UIPickerView)->UIToolbar {
        let toolbar = UIToolbar(frame:CGRectZero)
        self.view.addSubview(toolbar)
        toolbar.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(picker.snp_top)
            make.left.equalTo(picker.snp_left)
            make.right.equalTo(picker.snp_right)
            make.height.equalTo(44)
        }
        
        let stretchy = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .Done , target: self, action: "hidePicker")
        toolbar.setItems([stretchy, done], animated: false)
        toolbar.hidden = true;
        return toolbar
    }


}
extension BookingViewController: UIPickerViewDataSource,UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView==endTimePicker) {
            return durations.count
        } else {
            return startTimes.count
        }
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView==endTimePicker) {
            let mins = 15*row+30;
            duration = mins
            endTimeLabel.text = durations[row]
            updateUI()
        } else {
            let mins = 15*row;
            startTime = dateAheadOfMidnightOn(startTime, mins: mins);
            updateUI()
            calculateTimes()
            
            
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView==endTimePicker) {
            return durations[row]
        } else {
            return startTimes[row]
        }
    }
}
extension BookingViewController:UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        hidePicker()
    }
}
extension BookingViewController:CVCalendarViewDelegate,CVCalendarMenuViewDelegate {
    func presentationMode() -> CalendarMode {
        return CalendarMode.MonthView
    }
    func firstWeekday() -> Weekday {
        return Weekday.Monday
    }
    func presentedDateUpdated(date: Date) {
        if let newdate = startTime.dateWithSameTimeOnCVDate(date) {
            startTime = newdate
            calculateTimes()
            updateUI()
        }
        monthLabel.text = dfmonth.stringFromDate(date.convertedDate()!).uppercaseString
        dateLabel.text = dfdate.stringFromDate(date.convertedDate()!)
    }
}
extension BookingViewController:CVCalendarViewAppearanceDelegate {
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

extension BookingViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let trainer = trainer {
            return Int(trainer.skills.count)
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! TrainerSkillCell
        if let trainer = trainer {
            let skill = trainer.skills[indexPath.row];
            cell.skill = skill
        }
        return cell
    }
}

extension BookingViewController : UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("did select: \(indexPath.row)")
    }

}
extension BookingViewController : MapViewDelegate {
    func didConfirmLocation(latestLocation:CLLocationCoordinate2D) {
        selectedLocationOption = possibleLocationOption
        location = latestLocation;
        selectLocationOptionAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func didCancelLocation() {
        possibleLocationOption = selectedLocationOption
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

enum LocationType : Int {
    case Me=0
    case Trainer=1
    case Custom=2
}
