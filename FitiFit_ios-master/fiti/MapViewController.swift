//
//  LocationPickerViewController.swift
//  fiti
//
//  Created by Tuo on 12/24/15.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import SnapKit

class MapViewController: BaseViewController {

    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchFieldView: UIView!
    @IBOutlet weak var currentAddressLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var currentLocationTypeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var delegate:MapViewDelegate?;
    var location=CLLocationCoordinate2DMake(0, 0)
    var locationType:LocationType = .Me;
    
    var trainer:Trainer?
    private var matchedPlaces:[MKMapItem]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocalizedTitle("map".localized)

        mapView.showsUserLocation = true
        mapView.delegate = self;
        mapView.userTrackingMode = .Follow

        
        confirmButton.setTitle("confirm_location".localized.uppercaseString, forState: .Normal)
       
        let center = location
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        location = center
        addressField.text = ""
        

        addressField.leftView = UIImageView(image: UIImage(named: "searchPin"))
        addressField.leftViewMode = UITextFieldViewMode.Always
        
        switch locationType {
        case .Me:
            currentLocationTypeLabel.text = "my_location".localized;
        case .Trainer:
            currentLocationTypeLabel.text = "trainers_location".localized;
        case .Custom:
            currentLocationTypeLabel.text = "custom_location".localized;
        }
        
        searchView.hidden = true
        
        searchFieldView.hidden = locationType != .Custom
        
        self.tableView.tableFooterView = UIView()
    }

    func updateAddress(location: CLLocationCoordinate2D) {
        currentAddressLabel.text = "getting_address".localized
        MapUtils.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)){
            (address: String) -> Void in
            self.currentAddressLabel.text = address
        }
    }

   

    @IBAction func onConfirm(sender: AnyObject) {
        delegate?.didConfirmLocation(location)
    }
    @IBAction func onCancel(sender: AnyObject) {
        delegate?.didCancelLocation()
    }

}


extension MapViewController:MKMapViewDelegate {
    func mapView(mapView: MKMapView, didSelectAnnotationView annotationView: MKAnnotationView) {
        
    }
    func mapView(mapView: MKMapView, didDeselectAnnotationView annotationView: MKAnnotationView) {
        
    }
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //print("change");
        location = mapView.region.center
        updateAddress(location)
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
    }
}

extension MapViewController:UITextFieldDelegate {

    func textFieldDidBeginEditing(textField: UITextField) {
        searchView.hidden = false
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,replacementString string: String) -> Bool {
        var txtAfterUpdate:NSString = (self.addressField.text ?? "") as NSString
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        searchAddressonQuery(txtAfterUpdate as String)
        return true
    }

    func searchAddressonQuery(query: String) {
        searchView.hidden = false
        let req = MKLocalSearchRequest();
        req.naturalLanguageQuery = query
        req.region = mapView.region
        let search = MKLocalSearch(request: req)
        search.startWithCompletionHandler { (response, error) -> Void in
            if let response = response where query == self.addressField.text {
                let mapitems = response.mapItems
                self.matchedPlaces = mapitems
                self.tableView.reloadData()
            }
        }
    }

}

extension MapViewController : UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchedPlaces != nil ? self.matchedPlaces!.count : 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        let item:MKMapItem = self.matchedPlaces![indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }

}

extension MapViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item:MKMapItem = self.matchedPlaces![indexPath.row]
        mapView.setCenterCoordinate(item.placemark.coordinate, animated: true)
        searchView.hidden = true
        addressField.resignFirstResponder()
    }
}

protocol MapViewDelegate {
    func didConfirmLocation(coord:CLLocationCoordinate2D)
    func didCancelLocation()
}

