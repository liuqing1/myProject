//
//  Extensions.swift
//  fiti
//
//  Created by Matthew Mayer on 15/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit
import MapKit
import SnapKit
import CVCalendar



extension CLLocation {
    class func distance(from from: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distanceFromLocation(to)
    }
}
extension UIView {
    func embedFromNIB(filename:String)->UIView? {
        let items = NSBundle.mainBundle().loadNibNamed(filename, owner: nil, options: nil)
        if let v = items[0] as? UIView {
        
            self.addSubview(v)
            v.snp_makeConstraints { (make) -> Void in
                make.edges.equalTo(self).inset(UIEdgeInsetsZero);
            }
            
            return v
        }
        return nil
    }
    static func fromNIB(filename filename:String)->UIView? {
        let items = NSBundle.mainBundle().loadNibNamed(filename, owner: nil, options: nil)
        if let v = items[0] as? UIView {
            return v
        }
        return nil
    }
    
    /**
     Rounds the given set of corners to the specified radius
     
     - parameter corners: Corners to round
     - parameter radius:  Radius to round to
     */
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        _roundCorners(corners, radius: radius)
    }
    
    /**
     Rounds the given set of corners to the specified radius with a border
     
     - parameter corners:     Corners to round
     - parameter radius:      Radius to round to
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func roundCorners(corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let mask = _roundCorners(corners, radius: radius)
        addBorder(mask, borderColor: borderColor, borderWidth: borderWidth)
    }
}
extension UILabel {
    func setLineSpacing(lineHeight: CGFloat) {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            
            style.lineSpacing = lineHeight
            attributeString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, text.characters.count))
            self.attributedText = attributeString
        }
    }
    func setCharacterSpacing(characterSpacing: CGFloat) {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSKernAttributeName, value: CGFloat(characterSpacing), range: NSMakeRange(0, text.characters.count))

            self.attributedText = attributeString
        }
    }
}
private extension UIView {
    
    func _roundCorners(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
        return mask
    }
    
    func addBorder(mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clearColor().CGColor
        borderLayer.strokeColor = borderColor.CGColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
    
}
extension NSDate {
    func nearest(minutes: Int) -> NSDate {
        assert(minutes <= 30, "nearest(m) suppport rounding up to 30 minutes");
        let cal = NSCalendar.currentCalendar();
        let units:NSCalendarUnit = [.Minute , .Second]
        let time:NSDateComponents = cal.components(units, fromDate: self);
        let rem = time.minute % minutes
        if rem > 0 {
            time.minute = minutes - rem;
        }
        time.second = -time.second;
        
        let date = cal.dateByAddingComponents(time, toDate: self, options: NSCalendarOptions([]));
        return date!;
    }
    func datePartIsStrictlyBefore(other:NSDate)->Bool {
        
        return numberOfDaysUntilDate(other)>0
    }
    func numberOfDaysUntilDate(toDateTime: NSDate, inTimeZone timeZone: NSTimeZone? = nil) -> Int {
        let calendar = NSCalendar.currentCalendar()
        if let timeZone = timeZone {
            calendar.timeZone = timeZone
        } else {
            calendar.timeZone = NSTimeZone.localTimeZone()
        }
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: self)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
        
        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.day
    }
    func isOnSameDayAs(time2:CVDate) -> Bool {
        let cal = NSCalendar.currentCalendar();
        let units:NSCalendarUnit = [.Day, .Month, .Year]
        let time1:NSDateComponents = cal.components(units, fromDate: self);
        return (time1.year == time2.year) && (time1.month == time2.month) && (time1.day == time2.day)
    }
    func dateWithSameTimeOnCVDate(cv:CVDate) -> NSDate? {
        let cal = NSCalendar.currentCalendar();
        let units:NSCalendarUnit = [.Minute , .Second, .Hour, .Day, .Month, .Year]
        let time:NSDateComponents = cal.components(units, fromDate: self);
        time.year = cv.year
        time.month = cv.month
        time.day = cv.day
        return cal.dateFromComponents(time);
    }
    func toISODate()->String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return(formatter.stringFromDate(self))
    }
}
extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
}
extension UIColor {
    static func colorWithHexString(hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    static func fitiBlue() ->UIColor {
        return colorWithHexString("2F96FF")
    }
    static func fitiGray() ->UIColor {
        return colorWithHexString("585963")
    }
    static func fitiLightGray() -> UIColor {
        return colorWithHexString("A4A5A9")
    }
}
extension UIImageView {
    func circle() {
        self.layer.cornerRadius = self.frame.size.height/2
    }
}
extension Int {
    func inHours()->String {
        let h = Util.isChinese() ?  "小时" : "h"
        let time = Float(self)/60
        var rounded = String(format: "%.2f\(h)", time)
        rounded = rounded.replace(".50", withString: ".5")
        rounded = rounded.replace(".00", withString: "")
        return rounded
    }
}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(UIImage(named: "clear"), forState: .Normal, barMetrics: .Default)
        setDividerImage(UIImage(), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        let font = UIFont(name:Constants.Fonts.MonsterratRegular, size:15)!
        setTitleTextAttributes([NSFontAttributeName:font, NSForegroundColorAttributeName:UIColor.fitiLightGray()], forState: .Normal)
        setTitleTextAttributes([NSFontAttributeName:font, NSForegroundColorAttributeName:UIColor.fitiBlue()], forState: .Selected)
    }
}
extension Double {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:Double {
        get {
            return Double(arc4random()) / 0xFFFFFFFF
        }
    }
}
extension NSTimeInterval {
    func asCountdownString()->String {
        if (self>0) {
            return String(format:"countdown".localized,Int(self/60), Int(self%60))
        } else {
            return "Finished".localized
        }
    }
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
//make dates comparible

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }