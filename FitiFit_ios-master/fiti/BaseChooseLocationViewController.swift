//
//  BaseChooseLocationViewController.swift
//  fiti
//
//  Created by Tuo on 1/18/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import Foundation
import UIKit

private let ChooseDistrictCellIdentifier = "ChooseDistrictCell"


class BaseChooseLocationViewController: BaseViewController {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    
    
    var locations:[[String: AnyObject]]!;
    
    func getLocations()->[[String: AnyObject]] {
        return [];
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locations = getLocations()
        theme = .White
        
        setLocalizedTitle("choose_your_location")

        
        nextBtn.setTitle("next".localized.uppercaseString, forState: .Normal)
        
        
        tableView.registerNib(UINib(nibName: ChooseDistrictCellIdentifier, bundle: nil), forCellReuseIdentifier: ChooseDistrictCellIdentifier)
        tableView.estimatedRowHeight = 74.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
       
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        for row in 0..<self.locations.count {
            if isInitiallySelected(row) {
                tableView.selectRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0), animated: false, scrollPosition: .None)
            }
        }
    }
    func isInitiallySelected(index:Int)->Bool {
        return false;
    }
    
    
    
    func localizedLocationAtIndex( index : Int)->String {
        return "-"
    }
}

extension BaseChooseLocationViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(ChooseDistrictCellIdentifier) as! ChooseDistrictCell
        cell.locationLabel.text = localizedLocationAtIndex(indexPath.row)
        
        return cell
    }

}

extension BaseChooseLocationViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView.indexPathsForSelectedRows?.count>3) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}
