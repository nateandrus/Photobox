//
//  SegmentedControlViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class SegmentedControlViewController: UIPageViewController {

    let allViewControllers = [
        UIStoryboard(name: "MainFeed", bundle: nil).instantiateViewController(withIdentifier: "EventPhotosVC"),
        UIStoryboard(name: "MainFeed", bundle: nil).instantiateViewController(withIdentifier: "ActivityLogVC")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([allViewControllers.first!], direction: .forward, animated: true, completion: nil)
    }
}

extension SegmentedControlViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = allViewControllers.firstIndex(of: viewController) else { return UIViewController()}
        if index == 0 {
            return nil
        }
        let newIndex = index - 1
        return allViewControllers[newIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = allViewControllers.firstIndex(of: viewController) else { return UIViewController()}
        if index == allViewControllers.count - 1 {
            return nil
        }
        let newIndex = index + 1
        return allViewControllers[newIndex]
    }
}
