//
//  RecipeSearchCollectionView.swift
//  RecipeSearch
//
//  Created by Zalzstein, Ziv on 20/10/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import UIKit

class RecipeSearchCollectionView: UIViewController {
    
    //MARK: -Outlets
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningImage: UIImageView!
    
    //MARK: -Properties
    var recipeHits = [RecipeSearchHit]()
    var selectedRecipe: RecipeSearchHit?
    var selectedImage: UIImage?
    var searchQ: String = ""
    var healthArray = [String]()
    var caloriesRange: String = ""
    var ingredientsString: String = ""
    var newSearch: Bool?
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let newSearch = newSearch, newSearch {
            collectionView.restore()
            updateData()
        }        
    }
    
    //MARK: -API Handling
    
    func updateData() {
        
        if recipeHits.count == 0 {
          getRecipesFromAPI()
            return
        }
        
        collectionView.reloadData()
        
    }
    
    func getRecipesFromAPI() {
        
        setCollectionViewUI(enabled: false)
        
        RecipeSearchClient.sharedInstance().getRecipes(searchQ: searchQ, health: healthArray, caloriesRange: caloriesRange, ingredients: ingredientsString) { (count, results, error) in
            
            guard error == nil else {
                performUIUpdatesOnMain {
                    self.setCollectionViewUI(enabled: true)
                    self.collectionView.setEmptyMessage(error!)
                    self.warningImage.isHidden = false
                }
                return
            }
            
            guard let results = results else {
                performUIUpdatesOnMain {
                    self.setCollectionViewUI(enabled: true)
                    self.warningImage.isHidden = false
                    self.collectionView.setEmptyMessage("Sorry, we could not find anything that matches!")
                }
                return
            }
            
            performUIUpdatesOnMain {
                self.setCollectionViewUI(enabled: true)
                self.recipeHits = results
                
                if self.recipeHits.count == 0 {
                    self.collectionView.setEmptyMessage("Sorry, we could not find anything that matches!")
                    self.warningImage.isHidden = false
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: -UI
    
    fileprivate func setCollectionViewUI(enabled: Bool) {
        
        collectionView.backgroundColor = enabled ? UIColor.clear : UIColor.lightGray
        enabled ? activityIndicator.stopAnimating() :  activityIndicator.startAnimating()
        activityIndicator.alpha = enabled ? 0.0 : 1.0
        
    }
    
    fileprivate func setCellUI(_ cell: RecipeCollectionViewCell, enabled: Bool) {
        
        if enabled {
            cell.layer.cornerRadius = 6
            cell.recipeImageView.backgroundColor = UIColor.clear
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.alpha = 0.0
        } else {
            cell.recipeImageView.backgroundColor = UIColor.clear
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            cell.recipeImageView.contentMode = .scaleAspectFit
            cell.recipeImageView.image = UIImage(named: "recipeFallback")
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.alpha = 1.0
        }
    }
    
    fileprivate func addGradient(_ view: UIView) {
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = view.frame.size
        
        gradient.colors = [
            UIColor(white: 1, alpha: 0.85).cgColor,
            UIColor(white: 1, alpha: 0).cgColor,
            UIColor(white: 1, alpha: 0).cgColor,
            UIColor(white: 1, alpha: 0.85).cgColor
        ]
        
        view.layer.addSublayer(gradient)
    }
    
    //MARK: -Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "recipeDetailSegue" {
            if let detailVC = segue.destination as? RecipeDetailedViewController {
                detailVC.recipeHit = selectedRecipe
                detailVC.image = selectedImage
            }
        }
    }
    
    //MARK: -LifeCycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        newSearch = false
    }
}

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width:self.bounds.width, height: self.bounds.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.textAlignment = .center
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16.0)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

//MARK: -UICollectionViewDelegate
extension RecipeSearchCollectionView : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedRecipe = recipeHits[indexPath.row]
        let selectedCell = collectionView.cellForItem(at: indexPath) as! RecipeCollectionViewCell
        selectedImage = selectedCell.recipeImageView.image
        performSegue(withIdentifier: "recipeDetailSegue", sender: nil)
        
    }
    
}

//MARK: -UICollectionViewDataSource
extension RecipeSearchCollectionView : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipeHits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseCellId = "recipesCollectionCell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellId, for: indexPath) as! RecipeCollectionViewCell
        
        setCellUI(cell, enabled: false)
        
        let recipeDictionary = self.recipeHits[indexPath.row]
        
        RecipeSearchClient.sharedInstance().getPhotoFromRecipe(recipe: recipeDictionary) { (data, error) in
            
            guard error == nil else {
                cell.recipeImageView?.contentMode = .scaleAspectFit
                cell.recipeImageView?.image = UIImage(named: "recipeFallback")
                return
            }
            
            performUIUpdatesOnMain {
                
                if let imageData = data {
                    cell.recipeImageView?.contentMode = .scaleAspectFill
                    cell.recipeImageView?.image = UIImage(data: imageData as Data)
                } else {
                    print("fall back")
                    cell.recipeImageView?.contentMode = .scaleAspectFill
                    cell.recipeImageView?.image = UIImage(named: "recipeFallback")
                }
                
                self.addGradient(cell.recipeImageView)
                
                self.setCellUI(cell, enabled: true)
            }
        }
        
        let recipeTitle = self.recipeHits[indexPath.row].label ?? ""
        let calories = self.recipeHits[indexPath.row].caloriesLabel ?? 0.0
        var caloriesLabel = (String(format: "%.0f", calories))
        caloriesLabel = caloriesLabel == "0" ? "CAL" : "\(caloriesLabel) CAL"
        
        let ingredientsCount = self.recipeHits[indexPath.row].ingredientLines?.count ?? 0
        let ingrLabel = ingredientsCount == 0 ? "INGR" : "\(ingredientsCount) INGR"
        
        cell.recipeTitle.text = recipeTitle
        cell.calLabel.text = caloriesLabel
        cell.ingrLabel.text = ingrLabel
        
        cell.recipeTitle.font = UIFont.boldSystemFont(ofSize: 20.0)
        cell.calLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        cell.ingrLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        return cell
    }
}

//MARK: -UICollectionViewDelegateFlowLayout
extension RecipeSearchCollectionView: UICollectionViewDelegateFlowLayout {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setItemSize()
    }
    
    fileprivate func setItemSize() {
        let space: CGFloat = 4.0
        flowLayout.scrollDirection = .vertical
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        let cellsPerRow: CGFloat = 2.0
        
        let widthAvailableForCellsInRow = (collectionView.frame.size.width) - (cellsPerRow - 1.0) * space
        
        flowLayout.itemSize = CGSize(width: widthAvailableForCellsInRow / cellsPerRow, height: widthAvailableForCellsInRow / cellsPerRow)
    }
}
