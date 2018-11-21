//
//  RecipeSearchHit.swift
//  RecipeSearch
//
//  Created by Zalzstein, Ziv on 15/10/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import Foundation

struct RecipeSearchHit {
    
    // -MARK: -Properties
    let uri: String?
    let label: String?
    let caloriesLabel: Double?
    let imageURL: String?
    let url: String?
    let shareAs: String?
    let source: String?
    let ingredients: [[String:AnyObject]]?
    let ingredientLines: [String]?
    var isFavorited: Bool
    
    // MARK: -Initalizers
    
    init(dictionary: [String:AnyObject]) {
        
        uri = dictionary[RecipeSearchClient.JSONResponseKeys.Hit.Uri] as? String
        label = dictionary[RecipeSearchClient.JSONResponseKeys.Hit.Label] as? String
        imageURL = dictionary[RecipeSearchClient.JSONResponseKeys.Hit.Image] as? String
        url = dictionary[RecipeSearchClient.JSONResponseKeys.Hit.URL] as? String
        shareAs = dictionary[RecipeSearchClient.JSONResponseKeys.Hit.ShareAs] as? String
        source = dictionary[RecipeSearchClient.JSONResponseKeys.Hit.Source] as? String
        ingredientLines = dictionary[RecipeSearchClient.JSONResponseKeys.Hit.IngredientLines] as? [String]
        caloriesLabel = dictionary[RecipeSearchClient.JSONResponseKeys.Hit.Calories] as? Double
        ingredients = dictionary[RecipeSearchClient.JSONResponseKeys.Hit.Ingredients] as? [[String:AnyObject]]
        
        isFavorited = false
        
    }
    
    static func recipeFromResults(_ results: [[String:AnyObject]]) -> [RecipeSearchHit] {
        
        var recipes = [RecipeSearchHit]()
        
        //iterate through array of dictionaries, each recipe is a dictionary
        for result in results {
            recipes.append(RecipeSearchHit(dictionary: result[RecipeSearchClient.JSONResponseKeys.Hit.Recipe] as! [String : AnyObject]))
        }
        
        return recipes
        
    }
    
    
}
