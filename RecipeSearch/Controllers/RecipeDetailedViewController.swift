//
//  RecipeDetailedViewController.swift
//  RecipeSearch
//
//  Created by Zalzstein, Ziv on 01/11/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import UIKit
import CoreData

class RecipeDetailedViewController: UIViewController {

    // MARK: - Properties
    var recipeHit: RecipeSearchHit?
    var calories: Double?
    var recipeUrl: String?
    var ingredientLines: [String]?
    var ingredients: [[String:AnyObject]]?
    var recipeTitle: String?
    var source: String?
    var image: Data?
    
    var isFavorited : Bool = false {
        didSet {
            if !isFavorited {
                favoritesButton.setImage(UIImage(named: "heart-selected"), for: .normal)
                favoritesButton.setTitle("  Add to Favorites", for: .normal)
                favoritesButton.setTitleColor(UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0), for: .normal)
            } else {
                favoritesButton.setImage(UIImage(named: "heart-deselected"), for: .normal)
                favoritesButton.setTitle("  Remove from Favorites", for: .normal)
                favoritesButton.setTitleColor(UIColor.gray, for: .normal)
            }
        }
    }
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var ingrLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    @IBOutlet weak var ingredientsText: UITextView!
    @IBOutlet weak var recipeSource: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Recipe>!
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "recipes")
        
        //fetchedResultsController.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageData = image {
            recipeImage.image = UIImage(data: imageData)
        } else {
            recipeImage.image = UIImage(named: "recipeFallback")
        }
        
        
        if let recipeHitLabel = recipeTitle {
            recipeLabel.text = recipeHitLabel
        }
        
        if let recipeHitIngr = ingredientLines?.count {
            ingrLabel.text = "\(recipeHitIngr) INGREDIENTS"
        }
        
        if let calQuantity = calories {
            calLabel.text = "\(String(format: "%.0f", calQuantity)) CALORIES"
        }
        
        if let ingrLines = ingredientLines {
            ingredientsText.text = ingrLines.joined(separator: "\n")
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8
            let attributes = [NSAttributedStringKey.paragraphStyle : style,
                              NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)]
            ingredientsText.attributedText = NSAttributedString(string: ingredientsText.text, attributes: attributes)
        }
        
        if let source = source {
            recipeSource.text = source
            let tapURL = UITapGestureRecognizer(target: self, action: #selector(self.tapURLInLabel))
            recipeSource.isUserInteractionEnabled = true
            recipeSource.addGestureRecognizer(tapURL)
        }
        
        setupFetchedResultsController()
        
        //TODO: -Grab here the state of the favorites button
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        updateFavoritesButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    @objc func tapURLInLabel(sender:UITapGestureRecognizer) {
        
        if let urlString = recipeUrl {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    fileprivate func countCoreDataObjects() -> Int {
        try? fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    @IBAction func toggleFavorites(_ sender: Any) {
        
        let shouldFavorite = !isFavorited

        let stringManipulate = shouldFavorite ? "add to favorites" : "remove from favorites"
        
        print("Number of Objects before '\(stringManipulate)' operation is \(countCoreDataObjects())")
        
        if shouldFavorite {
            addToFavorites()
        } else {
            removeFromFavorites(recipeHit!)
        }
        
        print("Number of Objects after '\(stringManipulate)' operation is \(countCoreDataObjects())")
        
        //toggle state back after core data been updated by remove/add
        isFavorited = shouldFavorite
        
    }
    
    func addToFavorites() {
        let recipe = Recipe(context: dataController.viewContext)
        recipe.creationDate = Date()
        recipe.recipeImage = image 
        recipe.recipeUrl = recipeUrl
        recipe.calories = calories ?? 0.0
        recipe.ingredientLines = ingredientLines
        recipe.ingredients = ingredients
        recipe.source = source
        recipe.recipeTitle = recipeTitle
        
        do {
        try dataController.viewContext.save()
        } catch {
            print("Couldn't save object")
        }
    }
    
    func removeFromFavorites(_ hit: RecipeSearchHit) {
     
        guard let hitUrl = recipeUrl else {
            print("hitURL is nil")
            return
        }
        
        try? fetchedResultsController.performFetch()
        
        for recipe in (fetchedResultsController.fetchedObjects)! {
            
            guard let recipeUrl = recipe.recipeUrl else {
                print("recipeURL is nil")
                return
            }
            
            if hitUrl == recipeUrl {
                print("Deleting object")
                dataController.viewContext.delete(recipe)
                try? dataController.viewContext.save()
            }
        }
        
    }
    
    func updateFavoritesButton() {
        
        guard let hitUrl = recipeHit?.url else {
            isFavorited = false
            return
        }
        
        try? fetchedResultsController.performFetch()
        for recipe in (fetchedResultsController.fetchedObjects)! {
            
            guard let recipeUrl = recipe.recipeUrl else {
                isFavorited = false
                return
            }
            
            if hitUrl == recipeUrl {
                isFavorited = true
                return
            }
        }
        isFavorited = false
    }
    
    @IBAction func shareRecipe(_ sender: Any) {
        
        let urlString = recipeHit?.url ?? ""
        let url = URL(string: urlString)!
        let recipeLabel = recipeHit?.label ?? ""
        let sharingString = "I'd like to share with you an amazing recipe for \(recipeLabel)"
        
        let items: [Any] = [sharingString, url]
        
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        controller.completionWithItemsHandler = { [weak self] activity, completed, items, error in
            
            guard let strongSelf = self else { return }
            if !completed {
                // User cancelled
                return
            }
            // User completed activity
            strongSelf.dismiss(animated: true, completion: nil)
            
        }//completion
        self.present(controller, animated: true, completion: nil)
        
    }
    

}
