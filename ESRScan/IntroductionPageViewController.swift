//
//  IntroductionPageViewController.swift
//  ESRScan
//
//  Created by Michael on 15/12/15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit

class IntroductionPageViewController : UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var myViewControllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self

        let intro1 = storyboard?.instantiateViewControllerWithIdentifier("IntroScreen1")
        intro1?.restorationIdentifier = "IntroScreen1"
        let intro2 = storyboard?.instantiateViewControllerWithIdentifier("IntroScreen2")
        intro2?.restorationIdentifier = "IntroScreen2"
        let intro3 = storyboard?.instantiateViewControllerWithIdentifier("IntroScreen3")
        intro3?.restorationIdentifier = "IntroScreen3"

        myViewControllers = [intro1!, intro2!, intro3!]

        setViewControllers([intro1!], direction: .Forward, animated: true, completion: nil)

        let pageControlAppearance = UIPageControl.appearance()
        pageControlAppearance.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControlAppearance.currentPageIndicatorTintColor = UIColor.darkGrayColor()

        trackView(intro1!.restorationIdentifier!)
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return myViewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        trackView(pendingViewControllers[0].restorationIdentifier!)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = myViewControllers.indexOf(viewController)
        if currentIndex < (myViewControllers.count - 1) {
            return myViewControllers[currentIndex!.advancedBy(1)]
        }
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = myViewControllers.indexOf(viewController)
        if currentIndex > 0 {
            return myViewControllers[currentIndex!.advancedBy(-1)]
        }
        return nil
    }
}
