//
//  TraineeTutorialViewController.swift
//  fiti
//
//  Created by Daniel Contreras on 4/5/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class TraineeTutorialViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    var orderedViewControllers: [UIViewController?] = {
        return [R.storyboard.login.tutorialStepOne(), R.storyboard.login.tutorialStepTwo(), R.storyboard.login.tutorialStepThree()]
    }()
    
    var pageControl:PageControl!
    var page:Int = 0
    let pageControlHeight:CGFloat = 37

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController!],
                               direction: .Forward,
                               animated: true,
                               completion: nil)
        }
        
        self.pageControl = PageControl(activeImage: R.image.pageDotFilled()!, inactiveImage: R.image.pageDot()!)
        self.pageControl.pageIndicatorTintColor = UIColor.clearColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        self.pageControl.frame = CGRectMake(0.0, self.view.frame.height - 80, self.view.frame.width, pageControlHeight)
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.hidesForSinglePage = true
        self.view.addSubview(pageControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UIPageViewControllerDataSource
extension TraineeTutorialViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf({$0 == viewController}) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf({$0 == viewController}) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers vcs:[UIViewController]) {
        page = orderedViewControllers.indexOf({$0 == vcs.first})!
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.pageControl.currentPage = page
        }
    }
    
}
