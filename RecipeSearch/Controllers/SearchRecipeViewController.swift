//
//  SearchRecipeViewController.Swift
//  RecipeSearch
//
//  Created by Ziv Zalzstein on 02/09/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import UIKit

class SearchRecipeViewController: UIViewController {

    //MARK: -Properties
    
    var activeTextField : UITextField? = nil
    var healthArray = [String]()
    var caloriesRange: String = ""
    var ingredientsString: String = ""
    
    let checkboxesDictionary = [0:HealthLabels.Vegeterian.rawValue,
                                1:HealthLabels.Vegan.rawValue,
                                2:HealthLabels.Paleo.rawValue,
                                3:HealthLabels.LowSugar.rawValue,
                                4:HealthLabels.AlcoholFree.rawValue,
                                10:HealthLabels.GlutenFree.rawValue,
                                11:HealthLabels.DairyFree.rawValue,
                                12:HealthLabels.Eggs.rawValue,
                                13:HealthLabels.Eggs.rawValue,
                                14:HealthLabels.Wheat.rawValue,
                                15:HealthLabels.Fish.rawValue,
                                16:HealthLabels.Shellfish.rawValue,
                                17:HealthLabels.Treenuts.rawValue,
                                18:HealthLabels.Peanuts.rawValue]
        
    fileprivate func handleSearchBarPosition(centered: Bool) {
        
        if centered {
            self.searchBarYPosition.constant = 0
            UIView.transition(with: view, duration: 0.75, options: .transitionCrossDissolve, animations:{ self.searchBarYPosition.constant=0} )
        } else {
            //if activeTextField == recipeSearchTextField { return }
            let safeAreaHeight = self.view.safeAreaLayoutGuide.layoutFrame.height
            let searchBarHeight = self.searchBarStack.frame.size.height
            UIView.transition(with: view, duration: 0.75, options: .transitionCrossDissolve, animations: {self.searchBarYPosition.constant = -safeAreaHeight/2 + searchBarHeight/2 + 50})
            self.viewWillLayoutSubviews()
        }
    }
    
    var isScrollViewHidden: Bool = true {
        didSet{
            UIView.transition(with: scrollView, duration: 0.75, options: .transitionCrossDissolve, animations: {self.scrollView.isHidden = self.isScrollViewHidden})
            //self.scrollView.isHidden = self.isScrollViewHidden
            self.toolBar.isHidden = self.isScrollViewHidden
            handleSearchBarPosition(centered: self.isScrollViewHidden)
        }
    }
    
    var isClearFiltersEnabled: Bool = false {
        didSet {
            self.toolBar.items?[0].isEnabled = isClearFiltersEnabled
        }
    }
    
    //MARK: -Outlets
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var searchBarYPosition: NSLayoutConstraint!
    @IBOutlet weak var searchFiltersStack: UIStackView!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet var checkBoxButtonCollection:[UIButton]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchBarStack: UIStackView!
    @IBOutlet weak var clearFilter: UIBarButtonItem!
    
    @IBOutlet weak var recipeSearchTextField: UITextField!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var upToTextField: UITextField!
    
    //MARK: -UI Configuration Helpers
    fileprivate func setToolbar() {
        let clearFiltersButton = UIButton.init(type: .custom)
        
        clearFiltersButton.setImage(UIImage(named: "clear-filters"), for: .normal)
        
        clearFiltersButton.addTarget(self, action: #selector(resetCheckBoxes), for: .touchUpInside)
      
        let close = UIBarButtonItem(customView: clearFiltersButton)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(filterResultsTapped(_:)))
        
        toolBar.items = [close,spacer,done]
        updateFilterButton()
    }
    
    fileprivate func configureUI() {
        setToolbar()
        isScrollViewHidden = true
        configureTextField(recipeSearchTextField)
        configureTextField(fromTextField)
        configureTextField(toTextField)
        configureTextField(upToTextField)
    }
    
    fileprivate func updateFilterButton() {
        for checkbox in checkBoxButtonCollection {
            if checkbox.isSelected {
                isClearFiltersEnabled = true
                return
            }
        }
        isClearFiltersEnabled = false
    }
    
    //MARK: -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(filterResultsTapped(_:)))
        searchFiltersStack.addGestureRecognizer(tap)
        configureUI()
        getCheckboxUserDefaults()
    
    }
    
    //MARK: -Helpers
    @objc func filterResultsTapped(_ sender: UITapGestureRecognizer) {
        isScrollViewHidden = !isScrollViewHidden
    }
    
    @objc func resetCheckBoxes(_ sender: Any) {
        for checkbox in checkBoxButtonCollection {
            if checkbox.isSelected {
                checkbox.isSelected = false
                saveCheckboxDefaults(checkbox, isSelected: false)
                checkbox.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            }
        }
        updateFilterButton()
    }

    @IBAction func checkboxPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            saveCheckboxDefaults(sender, isSelected: true)
        } else {
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            saveCheckboxDefaults(sender, isSelected: false)
        }
        
        updateFilterButton()
    }
    
    func saveCheckboxDefaults(_ sender: UIButton, isSelected: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(isSelected, forKey: String(sender.tag))
    }
    
    func getCheckboxUserDefaults() {
        let defaults = UserDefaults.standard
        
        for checkbox in checkBoxButtonCollection {
            
            if let isSelected = defaults.object(forKey: String(checkbox.tag)) {
                checkbox.isSelected = isSelected as! Bool
                checkbox.titleLabel?.font = checkbox.isSelected ? UIFont.boldSystemFont(ofSize: 17) : UIFont.systemFont(ofSize: 17)
            }
        }
        
        updateFilterButton()

        
    }
    
    
    //MARK:- Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchResultsSegue" {
            
            if let barVC = segue.destination as? UITabBarController {
                
                let searchResultsVC = barVC.viewControllers![0] as! RecipeSearchCollectionView
                
                    if let searchQ = recipeSearchTextField.text, !searchQ.isEmpty {
                        searchResultsVC.searchQ = searchQ
                    }
                
                    searchResultsVC.healthArray = populateHealthParams()
                    searchResultsVC.caloriesRange = handleCaloriesRange()
                    searchResultsVC.ingredientsString = handleIngredients()
                    searchResultsVC.newSearch = true
                
            }
        }
    }
    
    func handleIngredients() -> String {
        
        if let ingredients = upToTextField.text {
            return ingredients
        }
        return ""
    }
    
    func handleCaloriesRange() -> String {
        
        if let fromText = fromTextField.text, let toText = toTextField.text {
            
            if fromText.isEmpty && !toText.isEmpty {
                return toText
            }
            else if fromText.isEmpty && toText.isEmpty {
                return fromText
            }
            else {
                if (Int(fromText)! > Int(toText)!) {
                    return "\(toText)-\(fromText)"
                } else {
                    return "\(fromText)-\(toText)"
                }
            }
        }
        return ""
    }
    
    func populateHealthParams() -> [String] {
        
        for checkbox in checkBoxButtonCollection {
            if checkbox.isSelected {
                if let checkboxValue = checkboxesDictionary[checkbox.tag] {
                    healthArray.append(checkboxValue)
                }
                
            }
        }
        return healthArray
    }
    
}

extension SearchRecipeViewController: UITextFieldDelegate {
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if activeTextField == recipeSearchTextField {
            print("Should handle search bar position")
            handleSearchBarPosition(centered: false)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSegue(withIdentifier: "searchResultsSegue", sender: nil)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // We ignore any change that doesn't add characters to the text field.
        // These changes are things like character deletions and cuts, as well
        // as moving the insertion point.
        //
        // We still return true to allow the change to take place.
        if string.count == 0 && textField != recipeSearchTextField {
            return true
        }
        
        // Check to see if the text field's contents still fit the constraints
        // with the new content added to it.
        // If the contents still fit the constraints, allow the change
        // by returning true; otherwise disallow the change by returning false.
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
            
        // Allow only digits in this field,
        // and limit its contents to a maximum of 3 characters.
        case fromTextField, toTextField:
            return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: prospectiveText)) && prospectiveText.count <= 3
            
        // Allow only digits in this field,
        // and limit its contents to a maximum of 2 characters.
        case upToTextField:
           return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: prospectiveText)) && prospectiveText.count <= 2
            
        case recipeSearchTextField:
            searchButton.isUserInteractionEnabled = (prospectiveText.count > 0)
            searchButton.alpha = (prospectiveText.count > 0) ? 1.0 : 0.5
            return true
        // Do not put constraints on any other text field in this view
        // that uses this class as its delegate.
        default:
            return true
        }
    }
    
    // Dismiss the keyboard when the user taps the "Return" key or its equivalent
    // while editing a text field.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //dismiss the keyboard when the user taps the return button
        textField.resignFirstResponder()
        performSegue(withIdentifier: "searchResultsSegue", sender: nil)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchButton.isUserInteractionEnabled = false
        searchButton.alpha = 0.5
        return true
    }
    
    //MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let activeTextField = self.activeTextField, activeTextField == recipeSearchTextField {
            handleSearchBarPosition(centered: false)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let activeTextField = self.activeTextField, activeTextField == recipeSearchTextField {
            handleSearchBarPosition(centered: true)
        }
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func keyboardY(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.minY
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: Any) {
        //TODO: -Add tapGestureRecognizer for the view and resign textFields
        guard let activeTextField = self.activeTextField else { return }
        if activeTextField == recipeSearchTextField {
            resignIfFirstResponder(recipeSearchTextField)
            handleSearchBarPosition(centered: true)
        } else {
            resignIfFirstResponder(activeTextField)
        }
    }

}


private extension SearchRecipeViewController {
    
    func configureTextField(_ textField: UITextField) {
        
        if textField != recipeSearchTextField {
            textField.keyboardType = .numberPad
        } else {
            let text = textField.text ?? ""
            searchButton.isUserInteractionEnabled = !text.isEmpty
            searchButton.alpha = !text.isEmpty ? 1.0 : 0.5
        }
        textField.delegate = self
        
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: -Keyboard notification un-subscription
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}

enum HealthLabels: String {
    case Vegeterian = "vegetarian"
    case Vegan = "vegan"
    case Paleo = "paleo"
    case LowSugar = "low-sugar"
    case AlcoholFree = "alcohol-free"
    case GlutenFree = "gluten-free"
    case DairyFree = "dairy-free"
    case Eggs = "eggs-free"
    case Soy = "soy-free"
    case Wheat = "wheat-free"
    case Fish = "fish-free"
    case Shellfish = "shellfish-free"
    case Treenuts = "tree-nut-free"
    case Peanuts = "peanut-free"
}

