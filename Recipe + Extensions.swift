//
//  Recipe + Extensions.swift
//  RecipeSearch
//
//  Created by Zalzstein, Ziv on 20/11/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import Foundation
import CoreData

extension Recipe {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
