//
//  FavoritesViewController.swift
//  RecipeSearch
//
//  Created by Zalzstein, Ziv on 22/11/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import UIKit
import CoreData

class FavoritesCollectionView: UIViewController {
    
    //MARK: -Outlets
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningImage: UIImageView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Recipe>!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var blockOp: [BlockOperation] = []
    
    //MARK: -Properties
    //var recipeHits = [RecipeSearchHit]()
    var selectedRecipe: Recipe?
    var selectedImage: Data?
    
    fileprivate func setupFetchedResultsController() {
        
        dataController = appDelegate.dataController
        
        let fetchRequest:NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "recipes")
            
        fetchedResultsController.delegate = self
        
        performFetch()
    }
    
    func performFetch() {
        print("Performing fetch")
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        print("object count :\(fetchedResultsController.fetchedObjects?.count)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = true
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        collectionView.restore()
        if let indexPaths = collectionView.indexPathsForSelectedItems {
            for index in indexPaths {
                collectionView.deselectItem(at: index, animated: true)
            }
            collectionView.reloadItems(at: indexPaths)
        }
        updateData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: -Core Data Handling
    
    func updateData() {
        
        print("updating data")
        if let count = fetchedResultsController.fetchedObjects?.count, count > 0 {
            collectionView.reloadData()
            return
        }
        
        collectionView.setEmptyMessage("You have nothing in your Favorites.")
        
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
                
                guard let selectedRecipe = selectedRecipe else {
                    return
                }
                
                detailVC.calories = selectedRecipe.calories
                detailVC.ingredients = selectedRecipe.ingredients
                detailVC.ingredientLines = selectedRecipe.ingredientLines
                detailVC.source = selectedRecipe.source
                detailVC.recipeTitle = selectedRecipe.recipeTitle
                detailVC.recipeUrl = selectedRecipe.recipeUrl
                detailVC.image = selectedImage
                detailVC.dataController = dataController
            }
        }
    }
    
}

//MARK: -UICollectionViewDelegate
extension FavoritesCollectionView : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let recipe = fetchedResultsController.object(at: indexPath)
        
        selectedImage = recipe.recipeImage
        selectedRecipe = recipe
        
        performSegue(withIdentifier: "recipeDetailSegue", sender: nil)
        
    }
    
}

//MARK: -UICollectionViewDataSource
extension FavoritesCollectionView : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchedResultsController.sections?[section].numberOfObjects, count > 0 {
            return count
        }
        
        //otherwise it's empty
        collectionView.setEmptyMessage("You have nothing in your favorites.")
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseCellId = "recipesCollectionCell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellId, for: indexPath) as! RecipeCollectionViewCell
        
        setCellUI(cell, enabled: false)
        
        if let count = fetchedResultsController.fetchedObjects?.count, count > 0 {
            let recipe = fetchedResultsController.object(at: indexPath)
            cell.recipeImageView.contentMode = .scaleAspectFill
            
            if let recipeImageData = recipe.recipeImage {
                cell.recipeImageView.image = UIImage(data: recipeImageData)
            } else {
                cell.recipeImageView.image = UIImage(named: "recipeFallback")
            }
            
            self.addGradient(cell.recipeImageView)
            setCellUI(cell, enabled: true)
            
            let recipeTitle = recipe.recipeTitle ?? ""
            let calories = recipe.calories
            var caloriesLabel = (String(format: "%.0f", calories))
            caloriesLabel = caloriesLabel == "0" ? "CAL" : "\(caloriesLabel) CAL"
            
            let ingredientsCount =
                recipe.ingredientLines?.count ?? 0
            let ingrLabel = ingredientsCount == 0 ? "INGR" : "\(ingredientsCount) INGR"
            
            cell.recipeTitle.text = recipeTitle
            cell.calLabel.text = caloriesLabel
            cell.ingrLabel.text = ingrLabel
            
            cell.recipeTitle.font = UIFont.boldSystemFont(ofSize: 20.0)
            cell.calLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            cell.ingrLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            
        }
        
        return cell
    }
}

//MARK: -UICollectionViewDelegateFlowLayout
extension FavoritesCollectionView: UICollectionViewDelegateFlowLayout {
    
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

extension FavoritesCollectionView: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOp.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            print ("INSERT")
            blockOp.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        case .delete:
            print ("DELETE")
            blockOp.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        default:
            print ("DEFAULT")
            blockOp.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            print ("insert")
            blockOp.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        if this.fetchedResultsController == nil {
                            this.collectionView!.insertItems(at: [newIndexPath!])
                        }
                        else {
                            if let count = this.fetchedResultsController.fetchedObjects?.count, count == 1 {
                                this.collectionView.reloadData()
                            }
                            else {
                                this.collectionView!.insertItems(at: [newIndexPath!])
                            }
                        }
                    }
                })
            )
        case .delete:
            print ("delete")
            blockOp.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItems(at: [indexPath!])
                    }
                })
            )
        case .update:
            blockOp.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItems(at: [indexPath!])
                    }
                })
            )
        case .move:
            blockOp.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({ () -> Void in
            for blockOperation in self.blockOp {
                blockOperation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOp.removeAll(keepingCapacity: false)
        })
        
    }
}

