//
//  RecipeSearchConvenience.swift
//  RecipeSearch
//
//  Created by Ziv Zalzstein on 14/10/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import UIKit

extension RecipeSearchClient {
    
    //MARK: GET Convenience Methods
    
    func getRecipes(searchQ: String, health: [String], caloriesRange: String, ingredients: String,  completionHandlerForGetRecipes: @escaping (_ totalRecipes: Int, _ result: [RecipeSearchHit]?, _ errorString: String?) -> Void) {
        
        var methodParameters = [ParameterKeys.Q:
                                searchQ] as [String : AnyObject]
        
        var myQueryItems = [URLQueryItem]()
        
        for item in health {
            myQueryItems.append(URLQueryItem(name: ParameterKeys.health, value: item))
        }

        if !caloriesRange.isEmpty {
            methodParameters.updateValue(caloriesRange as AnyObject, forKey: ParameterKeys.calories)
        }
        
        if !ingredients.isEmpty {
            methodParameters.updateValue(ingredients as AnyObject, forKey: ParameterKeys.Ingredients)
        }
        
        let _ = taskForGETMethod(parameters: methodParameters, urlQueryItems: myQueryItems) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForGetRecipes(0, nil, error.localizedDescription)
            } else {
                
                guard let hitsArray = results?[JSONResponseKeys.Hits] as? [[String:AnyObject]] else {
                    completionHandlerForGetRecipes(0, nil, "Cannot find key hits in results")
                    return
                }
                
                if hitsArray.count == 0 {
                    completionHandlerForGetRecipes(0, nil, "No Recipes Found. Search Again")
                    return
                } else {
                    let recipes = RecipeSearchHit.recipeFromResults(hitsArray)
                    completionHandlerForGetRecipes(hitsArray.count, recipes, nil)
                }
            }
            
        }
    }
    
    func getPhotoFromRecipe(recipe: RecipeSearchHit?, completionHandlerForGetPhoto: @escaping (_ data: NSData?, _ errorString: String?) -> Void) {
        
        guard let recipe = recipe else {
            return
        }
        
        guard let recipePhotoURL = recipe.imageURL else {
            return
        }
        
        let methodParameters = [String:AnyObject]()
        let myQueryItems = [URLQueryItem]()
        
        let _ = taskForGETMethod(imageURL: recipePhotoURL, parameters: methodParameters, urlQueryItems: myQueryItems) { (result, error) in
            
            if let error = error {
                completionHandlerForGetPhoto(nil, error.localizedDescription)
            } else {
                guard let result = result else {
                    print ("result is nil")
                    return
                }
                print("arrived to completion handler for getPhoto")
                completionHandlerForGetPhoto(result as? NSData, nil)
            }
            
        }
    }
    
    
    
}

