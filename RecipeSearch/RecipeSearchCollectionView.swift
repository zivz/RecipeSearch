//
//  RecipeSearchCollectionView.swift
//  RecipeSearch
//
//  Created by Zalzstein, Ziv on 20/10/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import UIKit

class RecipeSearchCollectionView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    //MARK: =Outlets
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: -Properties
    var recipeHits = [RecipeSearchHit]()
    var searchQ: String = ""
    var healthString: String = ""
    var caloriesRange: String = ""
    var ingredientsString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("***************")
        print("Restoring data")
        collectionView.restore()
        
        //Might be redundant
        if let indexPaths = collectionView.indexPathsForSelectedItems {
            for index in indexPaths {
                collectionView.deselectItem(at: index, animated: true)
            }
            collectionView.reloadItems(at: indexPaths)
        }
        
        updateData()
    }
    
    func updateData() {
        print("Getting recipes from API")
        getRecipesFromAPI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setItemSize()
    }
    
    /*override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("called viewWillTransition")
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.flowLayout.invalidateLayout()
            self.setItemSize()
        }
    }*/
    
    fileprivate func setItemSize() {
        print("called setItemSize")
        let space: CGFloat = 4.0
        flowLayout.scrollDirection = .vertical
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        let cellsPerRow: CGFloat = 2.0
        
        let widthAvailableForCellsInRow = (collectionView.frame.size.width) - (cellsPerRow - 1.0) * space
        
        flowLayout.itemSize = CGSize(width: widthAvailableForCellsInRow / cellsPerRow, height: widthAvailableForCellsInRow / cellsPerRow)
    }
    
    
    func getRecipesFromAPI() {
        
        RecipeSearchClient.sharedInstance().getRecipes(searchQ: searchQ, health: healthString, caloriesRange: caloriesRange, ingredients: ingredientsString) { (count, results, error) in
            
            guard error == nil else {
                return
            }
            
            guard let results = results else {
                return
            }
            
            performUIUpdatesOnMain {
                print("Got results from API")
                self.recipeHits = results
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Otherwise use the photoURLs.count
        if recipeHits.count == 0 {
            collectionView.setEmptyMessage("Sorry, we could not find anything that matches!")
        } else {
            collectionView.restore()
        }
        
        print("returning \(recipeHits.count) from numberOfItemsInSection")
        return recipeHits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseCellId = "recipesCollectionCell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellId, for: indexPath) as! RecipeCollectionViewCell
        
        setUI(cell, enabled: false)
        
        let recipeDictionary = self.recipeHits[indexPath.row]
        
        RecipeSearchClient.sharedInstance().getPhotoFromRecipe(recipe: recipeDictionary) { (data, error) in
            
            guard error == nil else {
                print (error!.description)
                print ("ERROR in getting photos")
                return
            }
            
            guard let imageData = data else {
                print ("no data in image data")
                return
            }
            
            performUIUpdatesOnMain {
                print ("populating image")
                cell.recipeImageView?.contentMode = .scaleAspectFill
                cell.recipeImageView?.image = UIImage(data: imageData as Data)
                
                let recipeTitle = self.recipeHits[indexPath.row].label ?? ""
                let calories = self.recipeHits[indexPath.row].caloriesLabel ?? 0.0
                var caloriesLabel = (String(format: "%.0f", calories))
                caloriesLabel = caloriesLabel == "0" ? "Cal" : "Cal \(caloriesLabel)"
                
                var ingrCount = 0
               
                if let ingredientArray = self.recipeHits[indexPath.row].ingredientLines {
                    ingrCount = ingredientArray.count
                }
                
                let ingrLabel = ingrCount == 0 ? "Ingr" : "Ingr \(ingrCount)"
                
                print ("populating text")
               
                cell.recipeTitle.text = recipeTitle
                cell.calLabel.text = caloriesLabel
                cell.ingrLabel.text = ingrLabel
                
                self.setUI(cell, enabled: true)
            }
            
        }
        
        return cell
    }
    
    fileprivate func setUI(_ cell: RecipeCollectionViewCell, enabled: Bool) {
        
        if enabled {
            cell.layer.cornerRadius = 0
            cell.recipeImageView.backgroundColor = UIColor.clear
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.alpha = 0.0
        } else {
            cell.recipeImageView.backgroundColor = UIColor.darkGray
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.alpha = 1.0
        }
    }
}

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width:self.bounds.width, height: self.bounds.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 16.0)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
