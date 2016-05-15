//
//  TrainerViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 22/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit
import MediaPlayer
class TrainerViewController: BaseViewController {

    @IBOutlet weak var trainerViewContainer: UIView!
    
    @IBOutlet weak var trainerDetailViewContainer: UIView!
    
    @IBOutlet weak var makeBookingBtn: UIButton!
    var trainerView:TrainerView!;
    var trainerDetailView:TrainerDetailsView!;
    
    var trainer:Trainer? {didSet { updateUI() }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainerView = trainerViewContainer.embedFromNIB("TrainerView") as? TrainerView
        trainerDetailView = trainerDetailViewContainer.embedFromNIB("TrainerDetailsView") as? TrainerDetailsView
        trainerDetailView.delegate = self
        makeBookingBtn.setTitle("Request to Book".localized.uppercaseString, forState: .Normal)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    func updateUI() {
        guard let trainerView = trainerView, trainerDetailView = trainerDetailView else {
            return;
        }
        trainerDetailView.trainer = trainer;
        trainerView.trainer = trainer;
        self.title = trainer?.name
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onMakeBooking(sender: AnyObject) {
        guard let _ = APIManager.shared.meTrainee else {
            RequireLoginAlert.presentTraineeLoginAlert(self, segueIdentifier: R.segue.trainerViewController.logout.identifier)
            return
        }
        self.performSegueWithIdentifier("Book", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="Book" {
            if let vc = segue.destinationViewController as? BookingViewController {
                vc.trainer = trainer
            }
        }
    }
    
    


}
extension TrainerViewController:TrainerDetailsViewDelegate {
    func trainerDetailsViewDidLaunchVideo(url: NSURL) {
        let player = MPMoviePlayerViewController(contentURL: url)
        player.moviePlayer.fullscreen = true;
        player.moviePlayer.scalingMode = .AspectFit
        player.moviePlayer.play()
        presentViewController(player, animated:true, completion:nil)
    }
    func trainerDetailsViewDidCloseAboutUs() {
        
    }
}
