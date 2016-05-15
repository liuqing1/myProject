//
//  TrainerCertsViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 21/03/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import Toucan
class TrainerCertsViewController: BaseViewController {
    @IBOutlet var tableView:UITableView!;
    @IBOutlet var introLabel:UILabel!;
    @IBOutlet var nextButton:FitiButton!;
    var picker:UIImagePickerController?;
    var selectedSkill:Skill?
    override func viewDidLoad() {
        theme = .White
        super.viewDidLoad()
        setLocalizedTitle("upload_cert")
        tableView.delegate = self
        tableView.dataSource = self
        introLabel.text = "upload_cert_intro".localized
        nextButton.setTitle("next".localized.uppercaseString, forState: .Normal)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func checkButton() {
        var ok = true
        if let me = APIManager.shared.meTrainer {
            for skill in me.skills {
                let matchingCerts = me.skillCertificates.filter(NSPredicate(format: "skill.id == %@", skill.id!))
                if matchingCerts.count==0 {
                    ok = false
                }
            }
        }
        nextButton.enabled = ok
    }
    func gotoPicker(existing:Bool) {
        if (existing) {
            
            if (UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)) {
                let p = UIImagePickerController()
                p.sourceType = .PhotoLibrary
                p.allowsEditing = false
                p.delegate = self
                self.presentViewController(p, animated: true, completion: nil)
                picker = p
            }
            
        } else {
            if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
                let p = UIImagePickerController()
                p.sourceType = .Camera
                p.allowsEditing = false
                p.cameraDevice = .Front
                p.delegate = self
                self.presentViewController(p, animated: true, completion: nil)
                picker = p
            }
        }
    }
    @IBAction func onNext(sender:AnyObject) {
        if let me = APIManager.shared.meTrainer {
            for skill in me.skills {
                let matchingCerts = me.skillCertificates.filter(NSPredicate(format: "skill.id == %@", skill.id!))
                if matchingCerts.count==0 {
                    let alert = UIAlertController(title: "upload_cert_error".localized, message: "", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return;
                }
            }
            performSegueWithIdentifier(R.segue.trainerCertsViewController.next.identifier, sender: nil)
        }
        
    }
}
extension TrainerCertsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIManager.shared.meTrainer?.skills.count ?? 0;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.certCell.identifier, forIndexPath: indexPath) as! CertCell;
        if let me = APIManager.shared.meTrainer {
            let skills = me.skills
            let skill = skills[indexPath.row]
            cell.skillLabel.text = skill.localizedName();
            cell.skillImage.image = UIImage(named:skill.icon!.stringByAppendingString("-active"))
            let matchingCerts = me.skillCertificates.filter(NSPredicate(format: "skill.id == %@", skill.id!))
            cell.setUploaded(matchingCerts.count>0)
        }
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let skills = APIManager.shared.meTrainer?.skills {
            selectedSkill = skills[indexPath.row]
            let sheet = UIAlertController(title: "upload_cert".localized, message: "", preferredStyle: .ActionSheet)
            sheet.addAction(UIAlertAction(title: "Take Photo".localized, style: .Default, handler: { action in
                self.gotoPicker(false);
            }))
            sheet.addAction(UIAlertAction(title: "Choose Existing".localized, style: .Default, handler: { action in
                self.gotoPicker(true);
            }))
            sheet.addAction(UIAlertAction(title: "cancel".localized, style: .Cancel, handler: { action in
                
            }))
            
            presentViewController(sheet, animated: true, completion: nil)
        }
    }
}

extension TrainerCertsViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage, me = APIManager.shared.meTrainer {
            let apiimg = Toucan(image: img).resize(CGSize(width: 1200, height: 1200), fitMode: .Clip).image
            let name:String = selectedSkill?.enName ?? "";
            FitiLoadingHUD.showHUDForView(view, text: "")
            APIManager.shared.uploadCertificate("\(name) Certificate", skill: selectedSkill!, image: apiimg, success: {
                APIManager.shared.applyRealmTransaction({
                    let cert = Certificate();
                    cert.skill = self.selectedSkill;
                    cert.id = NSUUID().UUIDString
                    cert.title = "Uploaded certificate"
                    me.skillCertificates.append(cert)
                })
                print("success")
                FitiLoadingHUD.hide()
                self.tableView.reloadData()
                self.checkButton()
                }, error: { msg in
                    FitiLoadingHUD.hide()
                    print("error \(msg)")
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

