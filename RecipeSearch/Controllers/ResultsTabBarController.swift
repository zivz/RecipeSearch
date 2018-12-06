//
//  ResultsTabBarController.swift
//  RecipeSearch
//
//  Created by Zalzstein, Ziv on 23/11/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//


import UIKit

class ResultsTabBarController: UITabBarController {
    
    var dataController: DataController!
    
    fileprivate func injectDataController() {
        let resultsVC = self.viewControllers![0] as! RecipeSearchCollectionView
        
        let favoritesVC = self.viewControllers![1] as! FavoritesCollectionView
        
        if self.selectedViewController == resultsVC {
            resultsVC.dataController = dataController
        } else {
            favoritesVC.dataController = dataController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        injectDataController()
    }
    
    
    
}
