//
//  GCDBlackBox.swift
//  RecipeSearch
//
//  Created by Zalzstein, Ziv on 19/10/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
