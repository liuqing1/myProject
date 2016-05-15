//
//  TrainerChooseDistrictViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 09/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

class TrainerChooseDistrictViewController : BaseChooseLocationViewController {
    private let SegueToVideo = "ToVideo"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        titleLabel.attributedText = NSAttributedString(string:"we_dont_share".localized, attributes:Constants.Attributes.getFitiSpacedStyleLight())
    }
    override func getLocations()->[[String: AnyObject]] {
        
        let city = APIManager.shared.meTrainer?.city
        let cityDistrictDict:[String: AnyObject] = Util.loadJsonDict("locations") ?? [String: AnyObject]()
        let formatKey = city?.lowercaseString
        if let formatKey=formatKey, val = cityDistrictDict[formatKey] as? [[String: AnyObject]]{
            return val;
        }
        return []
       
    }
    override func isInitiallySelected(index:Int)->Bool {
        guard let trainer = APIManager.shared.meTrainer else {
            return false
        }
        let district = localizedLocationAtIndex(index)
        
        return trainer.districts.contains(district)
        
    }
    override func localizedLocationAtIndex(index:Int)->String {
        let district: [String: AnyObject] = self.locations[index]
        let langPrefix = Util.isChinese() ? "zh" : "en"
        let key = "\(langPrefix)_name"
        return (district[key] as? String) ?? ""
    }
    @IBAction func onNext() {
        
        let indexPaths = tableView.indexPathsForSelectedRows
        var district_names:[String]=[]
        if let indexPaths = indexPaths {
            district_names = indexPaths.map({ indexPath -> String in
                return localizedLocationAtIndex(indexPath.row)
            })
        }
        
        let fields = ["districts":district_names]
        if let me = APIManager.shared.meTrainer {
            APIManager.shared.applyRealmTransaction {
                me.setDistrictsWithArray(district_names)
            }
            
            APIManager.shared.updateTrainer(fields, success: {
                print("updated districts")
                }) { message in
                    print(message);
            }
            
            
            self.performSegueWithIdentifier(SegueToVideo, sender: nil)
        }
    }
}
