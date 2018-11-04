//
//  NKExtension.swift
//  NKTube
//
//  Created by GibongKim on 2016/02/03.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

import UIKit

// MARK: - NavigationBar {

extension UIView {
    
    class func animate(duration: TimeInterval = aniDuration, animateions: @escaping () -> ()) {
        UIView.animate(withDuration: duration, animations: animateions)
    } 
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIViewController {
    
    func setEmptyBackButton() {
        let backButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButtonItem


    }
}

// MARK: - NSObject
extension NSObject {
    func isNotNull() -> Bool {
        
        return !self.isKind(of: NSNull.self)
    }
    
    func validateNull() -> AnyObject {
        
        if self.isNotNull() {
            return "" as AnyObject
        } else {
            return self
        }
    }
    
    func stringToDatetime() -> Date {
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone.localizedName(for: .shortStandard, locale: Locale(identifier: "jp_JP"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyyyMMdd"
        return dateFormat.date(from: self as! String)!
    }
    
}

extension String {
    
    
    func formatDurations () -> String{
        var timeDuration : NSString!
        
        let string: NSString = self as NSString
        if string.range(of: "H").location == NSNotFound && string.range(of: "M").location == NSNotFound{
            
            if string.range(of: "S").location == NSNotFound {
                timeDuration = NSString(format: "0:00")
            } else {
                var secs: NSString = self as NSString
                secs = secs.substring(from: secs.range(of: "PT").location + "PT".characters.count) as NSString
                secs = secs.substring(to: secs.range(of: "S").location) as NSString
                
                timeDuration = NSString(format: "0:%d", secs.integerValue)
            }
        }
        else if string.range(of: "H").location == NSNotFound {
            var mins: NSString = self as NSString
            mins = mins.substring(from: mins.range(of: "PT").location + "PT".characters.count) as NSString
            mins = mins.substring(to: mins.range(of: "M").location) as NSString
            
            if string.range(of: "S").location == NSNotFound {
                timeDuration = NSString(format: "%d:00", mins.integerValue)
            } else {
                var secs: NSString = self as NSString
                secs = secs.substring(from: secs.range(of: "M").location + "M".characters.count) as NSString
                secs = secs.substring(to: secs.range(of: "S").location) as NSString
                
                timeDuration = NSString(format: "%d:%02d", mins.integerValue, secs.integerValue)
            }
        } else {
            var hours: NSString = self as NSString
            if hours.range(of: "DT").length > 0 {
                hours = hours.substring(from: hours.range(of: "DT").location + "DT".characters.count) as NSString
                hours = hours.substring(to: hours.range(of: "H").location) as NSString
            } else {
                hours = hours.substring(from: hours.range(of: "PT").location + "PT".characters.count) as NSString
                hours = hours.substring(to: hours.range(of: "H").location) as NSString
            }

            
            if string.range(of: "M").location == NSNotFound && string.range(of: "S").location == NSNotFound {
                timeDuration = NSString(format: "%d:00:00", hours.integerValue)
            } else if string.range(of: "M").location == NSNotFound {
                var secs: NSString = self as NSString
                secs = secs.substring(from: secs.range(of: "H").location + "H".characters.count) as NSString
                secs = secs.substring(to: secs.range(of: "S").location) as NSString
                
                timeDuration = NSString(format: "%d:00:%d", hours.integerValue, secs.integerValue)
            } else if string.range(of: "S").location == NSNotFound {
                var mins: NSString = self as NSString
                mins = mins.substring(from: mins.range(of: "H").location + "H".characters.count) as NSString
                mins = mins.substring(to: mins.range(of: "M").location) as NSString
                
                timeDuration = NSString(format: "%d:%d:00", hours.integerValue, mins.integerValue)
            } else {
                var secs: NSString = self as NSString
                secs = secs.substring(from: secs.range(of: "M").location + "M".characters.count) as NSString
                secs = secs.substring(to: secs.range(of: "S").location) as NSString
                var mins: NSString = self as NSString
                mins = mins.substring(from: mins.range(of: "H").location + "H".characters.count) as NSString
                mins = mins.substring(to: mins.range(of: "M").location) as NSString
                
                timeDuration = NSString(format: "%d:%d:%d", hours.integerValue, mins.integerValue, secs.integerValue)
            }
        }
        return timeDuration as String
        
    }

    
    func playTime() -> String {
        if let time = Int(self) {
            let min = String(format: "%02d", time/60)
            let sec = String(format: "%02d", time%60)
            let h: Int = time/60/60
            if h > 0 {
                let hour = String(format: "%2d", h)
                
                let min = String(format: "%02d", (time/60)%60)
                
                return hour + ":" + min + ":" + sec
            } else {
                return min + ":" + sec
            }
        }
        
        return "00:00"
    }
    
    // スペースと改行のみでないか
    func isEmptyString() -> Bool {
        var checkText: String = self.replacingOccurrences(of: "\n", with: "", options: [], range: nil)
        
        checkText = checkText.trimmingCharacters(in: CharacterSet.whitespaces)
        
        return checkText == ""
    }
    
    // 文頭、文末のスペースと改行をトリムする
    func trimSpaceAndBreak() -> String {
        
        var checkText: String = self.trimmingCharacters(in: CharacterSet.whitespaces)
        checkText = self.trimmingCharacters(in: CharacterSet.newlines)
        
        return checkText
    }
    
    // カンマをトリムする
    func trimComma() -> String {
        return self.replacingOccurrences(of: ",", with: "", options: [], range: nil)
    }
    
    // 数字の先頭の0をトリムする
    func trimZero() -> String {
        
        if let intValue: Int = Int(self) {
            return String(intValue)
        } else {
            return self
        }
    }
    
    func dateFormatChange(_ fromFormat: String, toFormat: String) -> String {
        let datetime = self.stringToDatetime(fromFormat)!
        return datetime.dateToString(toFormat)
    }
    
    func stringToDatetime(_ format: String = "yyyyMMdd") -> Date? {
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone.localizedName(for: .shortStandard, locale: Locale(identifier: "jp_JP"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = format
        return dateFormat.date(from: self)
    }
    
    func decimal() -> String? {
        
        let trimedStr = self.trimComma()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        
        if let value = Int(trimedStr) {
            return formatter.string(from: NSNumber(value: value as Int))
        } else {
            return trimedStr
        }
    }
    
    // TODO: 12以上の数値が設定される場合処理必要
    func preMonth(_ month: Int = 1) -> String {
        
        var yyyy: Int = Int(self.substring(to: self.characters.index(self.startIndex, offsetBy: 4)))!
        var mm: Int = Int(self.substring(from: self.characters.index(self.startIndex, offsetBy: 4)))!
        mm -= month
        if (mm) <= 0 {
            yyyy -= 1
            mm = 12 + mm
        }
        return "\(yyyy)\(String(format: "%02d", mm))"
    }
    
    // TODO: 12以上の数値が設定される場合処理必要
    func nextMonth(_ month: Int = 1) -> String {
        var yyyy: Int = Int(self.substring(to: self.characters.index(self.startIndex, offsetBy: 4)))!
        var mm: Int = Int(self.substring(from: self.characters.index(self.startIndex, offsetBy: 4)))!
        
        mm += month
        if (mm) > 12 {
            yyyy += 1
            mm = mm%12
            
            if mm == 0 {
                mm = 12
            }
        } else if (mm) <= 0 {
            yyyy -= 1
            mm = 12 + mm
        }
        return "\(yyyy)\(String(format: "%02d", mm))"
    }
    
}

// MARK: - NSDate
extension Date {
    
    func dateToDatetimeFormat(_ format: String = "yyyyMMdd") -> String {
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone.localizedName(for: .shortStandard, locale: Locale(identifier: "jp_JP"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
    
    func dateToMonthFormat() -> String {
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone.localizedName(for: .shortStandard, locale: Locale(identifier: "jp_JP"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyyyMMdd"
        
        return dateFormat.string(from: self)
    }
    
    func dateToSupportInfoFormat(_ format: String = "yyyy年MM月dd日(%@) HH:mm") -> String {
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone.localizedName(for: .shortStandard, locale: Locale(identifier: "jp_JP"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = format
        
        let tempDateTimeFormat = dateFormat.string(from: self)
        return String(format:tempDateTimeFormat, self.getDayOfWeek())
    }
    
    fileprivate func getDayOfWeek() -> String {
        let weekdays: [String]  = ["", "日", "月", "火", "水", "木", "金", "土"]
        let calender: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let comps: DateComponents = (calender as NSCalendar).components(.weekday, from: self)
        
        return weekdays[comps.weekday!]
    }
    
    func dateToString(_ format: String) -> String {
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone.localizedName(for: .shortStandard, locale: Locale(identifier: "jp_JP"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
    
    func dateToTimeFormat() -> String {
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone.localizedName(for: .shortStandard, locale: Locale(identifier: "jp_JP"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        return dateFormat.string(from: self)
    }
    
    func dateToHourFormat() -> String {
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone.localizedName(for: .shortStandard, locale: Locale(identifier: "jp_JP"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "HH"
        
        return dateFormat.string(from: self)
    }
    
    
    func timeRemainingByNow() -> Int {
        
        let now: Date = Date()
        let dateFormat = DateFormatter()
        dateFormat.timeZone.localizedName(for: .shortStandard, locale: Locale(identifier: "jp_JP"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let jpNow: String = dateFormat.string(from: now)
        
        let time = self.timeIntervalSince(jpNow.stringToDatetime())
        
        return Int(time/60/60)
    }
    
    func addMonth(_ addMonth: Int = 1) -> Date? {
        
        let components: DateComponents = DateComponents()
        (components as NSDateComponents).setValue(addMonth, forComponent: NSCalendar.Unit.month);
        return (Calendar.current as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options(rawValue: 0))
    }
}

extension NSNumber {
    
    func decimal() -> String? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        
        return formatter.string(from: self)
    }
}

// MARK: - Array
extension Array {
    
    mutating func removeObj<U: Equatable>(_ object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if((index) != nil) {
            self.remove(at: index!)
        }
    }
}


// MARK: - UILabel
extension UILabel {
    
    func getUpdatedHeight() -> CGFloat {
        
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0))
        label.numberOfLines = self.numberOfLines
        label.lineBreakMode = self.lineBreakMode
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        //        KLLog("label.frame.height > \(label.frame.height)")
        return label.frame.size.height
    }
    
    func getUpdatedWidth() -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: self.frame.size.height))
        label.numberOfLines = self.numberOfLines
        label.lineBreakMode = self.lineBreakMode
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        //        KLLog("label.frame.width > \(label.frame.width)")
        return label.frame.size.width
    }
    
    
}

// MARK: - UITextView
private var textViewIndexPathKey: UInt8 = 0
extension UITextView {
    
    var indexPathTag: IndexPath {
        get {
            return objc_getAssociatedObject(self, &textViewIndexPathKey) as! IndexPath
        }
        set(newValue) {
            objc_setAssociatedObject(self, &textViewIndexPathKey, newValue as IndexPath, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            
        }
    }
    
    func removePadding() {
        self.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0)
    }
    
}

// MARK: - UITextField
private var textFieldIndexPathKey: UInt8 = 0
extension UITextField {
    
    var indexPathTag: IndexPath {
        get {
            return objc_getAssociatedObject(self, &textFieldIndexPathKey) as! IndexPath
        }
        set(newValue) {
            objc_setAssociatedObject(self, &textFieldIndexPathKey, newValue as IndexPath, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            
        }
    }
}

// MARK: - UISwitch
private var switchIndexPathKey: UInt8 = 0
extension UISwitch {
    
    var indexPathTag: IndexPath {
        get {
            return objc_getAssociatedObject(self, &switchIndexPathKey) as! IndexPath
        }
        set(newValue) {
            objc_setAssociatedObject(self, &switchIndexPathKey, newValue as IndexPath, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

// MARK: - UIImageView
private var imageViewIndexPathKey: UInt8 = 0
extension UIImageView {
    
    var indexPathTag: IndexPath {
        get {
            return objc_getAssociatedObject(self, &imageViewIndexPathKey) as! IndexPath
        }
        set(newValue) {
            objc_setAssociatedObject(self, &imageViewIndexPathKey, newValue as IndexPath, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

// MARK: - CGRect
extension CGRect {
    
    func getScreenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
    
    func getScreenSize() -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.getWidth()
    }
    
    func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.getHeight()
    }
    
    func getHeight() -> CGFloat {
        return self.height
    }
    
    func getWidth() -> CGFloat {
        return self.width
    }
    
    func getMaxX() -> CGFloat {
        return self.maxX
    }
    
    func getMidX() -> CGFloat {
        return self.midX
    }
    
    func getMinX() -> CGFloat {
        return self.minX
    }
    
    func getMaxY() -> CGFloat {
        return self.maxY
    }
    
    func getMidY() -> CGFloat {
        return self.midY
    }
    
    func getMinY() -> CGFloat {
        return self.minY
    }
}

extension UITableView {
    
    func registerCell(_ nibName: String, cellId: String) {
        
        let cellNib: UINib = UINib(nibName: nibName, bundle: nil)
        self.register(cellNib, forCellReuseIdentifier: cellId)
    }
}

extension UICollectionView {
    
    func registerCell(_ nibName: String, cellId: String) {
        
        let cellNib: UINib = UINib(nibName: nibName, bundle: nil)
        self.register(cellNib, forCellWithReuseIdentifier: cellId)
    }
}

extension UINavigationController {
    
    func pushWithIdentifier(_ storyboard: String, viewControllerId: String, animated: Bool) {
        
        let controller: UIViewController = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: viewControllerId)
        
        self.pushViewController(controller, animated: animated)
    }
}

extension Dictionary {
    
    func getValue(_ key: Key) -> AnyObject? {
        
        if let value = self[key] {
            if let value = value as? NSObject {
                if value.isNotNull() {
                    return value
                }
            }
        }
        return nil
    }
}

extension String {
    func validateSpace() -> Bool {
        var valString: String = self
        valString = valString.replacingOccurrences(of: " ", with: "")
        valString = valString.replacingOccurrences(of: "　", with: "")
        return (valString != "")
    }
}

