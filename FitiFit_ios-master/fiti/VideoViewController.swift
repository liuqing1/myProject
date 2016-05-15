//
//  VideoViewController.swift
//  fiti
//
//  Created by Juan Manuel Fluxa on 1/23/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
class VideoViewController: BaseViewController {
    
    @IBOutlet var lbl1 : UILabel!
    @IBOutlet var btnTips : UIButton!
    
    @IBOutlet var btnRecord : UIButton!
    @IBOutlet var btnUpload : UIButton!
    @IBOutlet var btnPlay : UIButton!
    
    let SegueVideoUpload = "NextToVideoUpload"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theme = .White
        lbl1.attributedText = NSAttributedString(string:"video_info".localized, attributes:Constants.Attributes.getFitiSpacedStyleLight())
        btnTips.setTitle("video_tips".localized, forState: .Normal)
        
        
        setLocalizedTitle("video")
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onVideoPathPicked:", name: Constants.Notifications.OnVideoPathPicked, object: nil)
        
        btnRecord.setTitle("record".localized.uppercaseString, forState: .Normal)
        btnUpload.setTitle("upload".localized.uppercaseString, forState: .Normal)
        
        btnPlay.hidden = meHasVideo()
    }
    func meHasVideo()->Bool {
        if let me = APIManager.shared.meTrainer {
            return !me.videoURL.isEmpty
        }
        return false
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if meHasVideo() {
            setNavBarRightButtonWithTitle("skip".localized, action: "onNextButton:")
        } else {
            navigationItem.rightBarButtonItem = nil;
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNextButton(sender: AnyObject?) {
        performSegueWithIdentifier("NextToBio", sender: nil)
    }
    @IBAction func onTipsButton(sender: AnyObject?) {
        let alert = UIAlertController(title: "video_tips".localized, message: "video_tips_info".localized, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title:"OK".localized, style:.Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    @IBAction func onPlayButton(sender: AnyObject?) {
        if let me = APIManager.shared.meTrainer, url = NSURL(string:me.videoURL) {
            let player = MPMoviePlayerViewController(contentURL: url)
            player.moviePlayer.fullscreen = true;
            player.moviePlayer.scalingMode = .AspectFit
            player.moviePlayer.play()
            presentViewController(player, animated:true, completion:nil)
        }
    }
    
    func onVideoPathPicked(notification : NSNotification) {
        if let userInfo = notification.userInfo {
            let videoPath = userInfo["videoPath"]
            performSegueWithIdentifier(SegueVideoUpload, sender: videoPath)
        }
    }

   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueVideoUpload {
            if let vc = segue.destinationViewController as? VideoUploadViewController, videoPath = sender as? String {
                vc.videoPath = videoPath
            }
        }
    }
    
    @IBAction func onVideoPickerButton(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true) { () -> Void in
            
        }
    }


}

extension VideoViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { [unowned self] () -> Void in
            if let mediaURL = info[UIImagePickerControllerMediaURL] as? NSURL {
                self.performSegueWithIdentifier(self.SegueVideoUpload, sender: mediaURL.absoluteString)
            }
        }
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    
}

extension VideoViewController : UINavigationControllerDelegate {
    
}