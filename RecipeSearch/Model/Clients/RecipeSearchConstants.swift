//
//  RecipeSearchConstants.swift
//  RecipeSearch
//
//  Created by Ziv Zalzstein on 08/09/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import Foundation

extension RecipeSearchClient {
    
    //MARK: Constants
    
    struct Constants {
    
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.edamam.com"
        static let ApiPath = "/search"
        static let ApiKey = "786c355b0aaaa88ae14473faac7552dd"
        static let AppId = "1d3c1c81"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let Q = "q"
        static let AppKey = "app_key"
        static let AppId = "app_id"
        static let From = "from"
        static let To = "to"
        static let Ingredients = "ingr"
        //This is for Diet
        static let diet = "diet"
        //This is for Allergies
        static let health = "health"
        static let calories = "calories"
        
    }
    
    struct ParameterValues {
        struct Diet {
            static let Balanced = "balanced"
            static let HighFiber = "high-fiber"
            static let HighProtein = "high-protein"
            static let LowCarb = "low-carb"
            static let LowFat = "low-fat"
            static let LowSodium = "low-sodium"
        }
        struct Health {
            static let Gluten = "gluten-free"
            static let Daity = "dairy-free"
            static let Eggs = "egg-free"
            static let Soy = "soy-free"
            static let Wheat = "wheat-free"
            static let Fish = "fish-free"
            static let Shellfish = "shellfish-free"
            static let Treenuts = "tree-nut-free"
            static let Peanuts = "peanuts-free"
            
            static let Vegeterian = "vegeterian"
            static let Vegan = "vegan"
            static let Paleo = "paleo"
            static let AlcoholFree = "alcohol-free"
            static let LowSugar = "low-sugar"
        }
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        static let Q = "q"
        static let From = "from"
        static let To = "to"
        
        static let Params = "params"
        
        struct Param {
            static let Sane = "sane"
            static let Q = "q"
            static let AppKey = "app_key"
            static let Health = "health"
            static let From = "from"
            static let To = "to"
            static let Calories = "calories"
            static let AppId = "app_id"
        }
        
        static let More = "more"
        static let Count = "count"
        static let Hits = "hits"
        
        struct Hit {
            static let Recipe = "recipe"
            static let Uri = "uri"
            static let Label = "label"
            static let Image = "image"
            static let URL = "url"
            static let ShareAs = "shareAs"
            static let Yield = "yield"
            static let DietLabels = "dietLabels"
            static let HealthLabels = "healthLabels"
            static let Cautions = "cautions"
            static let IngredientLines = "ingredientLines"
            static let Ingredients = "ingredients"
            static let Calories = "calories"
        }
        
    }
}
