//
//  RecipeDetailedViewController.swift
//  RecipeSearch
//
//  Created by Zalzstein, Ziv on 01/11/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import UIKit
import CoreData

class RecipeDetailedViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    var recipeHit: RecipeSearchHit?
    var image: UIImage?
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var ingrLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    @IBOutlet weak var ingredientsText: UITextView!
    @IBOutlet weak var recipeSource: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var fetchedResultsController: NSFetchedResultsController<Recipe>!
    var dataController: DataController!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        guard let dataController = dataController else {
            print ("data controller is nil")
            return
        }
        
        //it doesn't arrive here
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "recipes")
        
        fetchedResultsController.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load been called")
        recipeImage.image = image
        
        if let recipeHitLabel = recipeHit?.label {
            recipeLabel.text = recipeHitLabel
        }
        
        if let recipeHitIngr = recipeHit?.ingredientLines?.count {
            ingrLabel.text = "\(recipeHitIngr) INGREDIENTS"
        }
        
        if let calQuantity = recipeHit?.caloriesLabel {
            calLabel.text = "\(String(format: "%.0f", calQuantity)) CALORIES"
        }
        
        if let ingrLines = recipeHit?.ingredientLines {
            ingredientsText.text = ingrLines.joined(separator: "\n")
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8
            let attributes = [NSAttributedStringKey.paragraphStyle : style,
                              NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)]
            ingredientsText.attributedText = NSAttributedString(string: ingredientsText.text, attributes: attributes)
        }
        
        if let source = recipeHit?.source {
            recipeSource.text = source
            let tapURL = UITapGestureRecognizer(target: self, action: #selector(self.tapURLInLabel))
            recipeSource.isUserInteractionEnabled = true
            recipeSource.addGestureRecognizer(tapURL)
        }
        
        guard let favorited = recipeHit?.isFavorited else {
            return
        }
        
        if !favorited {
            favoritesButton.setImage(UIImage(named: "heart-selected"), for: .normal)
            favoritesButton.titleLabel?.text! = "  Add to Favorites"
            
        } else {
            favoritesButton.setImage(UIImage(named: "heart-deselected"), for: .normal)
            favoritesButton.titleLabel?.text! = "  Remove from Favorites"
        }
        //setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear called")
        setupFetchedResultsController()
    }
    
    @objc func tapURLInLabel(sender:UITapGestureRecognizer) {
        
        if let urlString = recipeHit?.url {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    @IBAction func favoritesButtonTapped(_ sender: Any) {
        
        print("state of button was favorited? \(recipeHit?.isFavorited)")
        
        recipeHit?.isFavorited = !(recipeHit?.isFavorited)!
        
        print("state of button was changed ot favorited =\(recipeHit?.isFavorited)")
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
