//
//  RecipeDetailPage.swift
//  MenuApp
//
//  Created by Dhau Embun Azzahra on 04/12/24.
//

import UIKit

class RecipeDetailPage: UIViewController {
    
    // MARK: - Properties
    
    private var meal: Meal
    
    // MARK: - UI Elements
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let recipeImageView = UIImageView()
    private let cuisineLabel = UILabel()
    private let ingredientsLabel = UILabel()
    private let ingredientsTextView = UILabel()
    private let instructionsLabel = UILabel()
    private let instructionsTextView = UILabel()
    private let youtubeLabel = UILabel()
    private let youtubeButton = UIButton(type: .system)
    private let youtubeTextLabel = UILabel()
    
    // MARK: - Initializer
    
    init(meal: Meal) {
        self.meal = meal
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupLayout()
        configureMealDetails()
        configureActions()
    }
    
    // MARK: - Setup Methods
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            recipeImageView,
            cuisineLabel,
            ingredientsLabel,
            ingredientsTextView,
            instructionsLabel,
            instructionsTextView,
            youtubeLabel,
            youtubeButtonWithText()
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            recipeImageView.heightAnchor.constraint(equalTo: recipeImageView.widthAnchor, multiplier: 9/16)
        ])
    }
    
    private func configureActions() {
        youtubeButton.addTarget(self, action: #selector(handleYoutube), for: .touchUpInside)
    }
    
    private func youtubeButtonWithText() -> UIView {
        let button = UIButton(type: .system)
        button.setTitle("Watch Video", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(handleYoutube), for: .touchUpInside)
        button.contentHorizontalAlignment = .leading
        return button
    }

    private func configureMealDetails() {
        titleLabel.text = meal.strMeal
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        
        if let urlString = meal.strMealThumb, let url = URL(string: urlString) {
            // Load image asynchronously
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.recipeImageView.image = UIImage(data: data)
                        self.recipeImageView.contentMode = .scaleAspectFill
                        self.recipeImageView.clipsToBounds = true
                    }
                }
            }
        }
        
        cuisineLabel.text = meal.strArea
        cuisineLabel.font = UIFont.systemFont(ofSize: 14)
        cuisineLabel.textColor = .black
        cuisineLabel.textAlignment = .center
        
        ingredientsLabel.text = "Ingredients"
        ingredientsLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        ingredientsTextView.text = formattedIngredients(from: meal)
        ingredientsTextView.font = UIFont.systemFont(ofSize: 16)
        ingredientsTextView.textColor = .darkGray
        ingredientsTextView.numberOfLines = 0
        
        instructionsLabel.text = "Instructions"
        instructionsLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        instructionsTextView.text = meal.strInstructions
        instructionsTextView.font = UIFont.systemFont(ofSize: 16)
        instructionsTextView.textColor = .darkGray
        instructionsTextView.numberOfLines = 0
        
        youtubeLabel.text = "Available on YouTube"
        youtubeLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        youtubeTextLabel.text = "Watch Video"
        youtubeTextLabel.font = UIFont.systemFont(ofSize: 16)
    }
    
    private func formattedIngredients(from meal: Meal) -> String {
        var ingredients = [String]()
        
        // Create arrays of the ingredients and measures
        let ingredientKeys = [
            meal.strIngredient1, meal.strIngredient2, meal.strIngredient3, meal.strIngredient4, meal.strIngredient5,
            meal.strIngredient6, meal.strIngredient7, meal.strIngredient8, meal.strIngredient9, meal.strIngredient10
        ]
        
        let measureKeys = [
            meal.strMeasure1, meal.strMeasure2, meal.strMeasure3, meal.strMeasure4, meal.strMeasure5,
            meal.strMeasure6, meal.strMeasure7, meal.strMeasure8, meal.strMeasure9, meal.strMeasure10
        ]
        
        // Combine non-empty ingredients and measures
        for (ingredient, measure) in zip(ingredientKeys, measureKeys) {
            if let ingredient = ingredient, let measure = measure, !ingredient.isEmpty, !measure.isEmpty {
                ingredients.append("\(measure) of \(ingredient)")
            }
        }
        
        return ingredients.joined(separator: "\n")
    }

    // MARK: - Actions
    @objc private func handleBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleYoutube() {
        if let urlString = meal.strYoutube, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
