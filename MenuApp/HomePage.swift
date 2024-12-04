//
//  ViewController.swift
//  MenuApp
//
//  Created by Dhau Embun Azzahra on 03/12/24.
//

import UIKit

class HomePage: UIViewController {
    // MARK: - UI Elements
    private let searchBar = UISearchBar()
    private let quickFilterScrollView = UIScrollView()
    private let quickFilterStackView = UIStackView()
    private let collectionView: UICollectionView
    
    private var mealData: [Meal] = []
    private var selectedFilters: Set<String> = []
    
    // API Endpoint
    private let apiURL = "https://www.themealdb.com/api/json/v1/1/search.php?"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
       //  Collection View Layout
        let layout = UICollectionViewFlowLayout()
        let cellWidth = (UIScreen.main.bounds.width / 2) - 30
        let cellHeight = UIScreen.main.bounds.height * 0.3 // 30% of screen width
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .lightGray
        
    
       
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        fetchMeals(keyword: nil)
    }
    
    private func setupUI() {
        title = "Choose Your Menu"
        view.backgroundColor = .lightGray
        
        // Search Bar
        searchBar.delegate = self
        searchBar.placeholder = "Search for meals"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)

        
        // Quick Filter
        quickFilterScrollView.showsHorizontalScrollIndicator = false
        quickFilterScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quickFilterScrollView)
        
        quickFilterStackView.axis = .horizontal
        quickFilterStackView.spacing = 8
        quickFilterStackView.translatesAutoresizingMaskIntoConstraints = false
        quickFilterScrollView.addSubview(quickFilterStackView)
        
        // Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MealCell.self, forCellWithReuseIdentifier: "MealCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            quickFilterScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            quickFilterScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickFilterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            quickFilterScrollView.heightAnchor.constraint(equalToConstant: 40),
            
            quickFilterStackView.leadingAnchor.constraint(equalTo: quickFilterScrollView.leadingAnchor, constant: 16),
            quickFilterStackView.trailingAnchor.constraint(equalTo: quickFilterScrollView.trailingAnchor, constant: -16),
            quickFilterStackView.centerYAnchor.constraint(equalTo: quickFilterScrollView.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: quickFilterScrollView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Fetch API
    private func fetchMeals(keyword: String?) {
        var urlComponents = URLComponents(string: apiURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "s", value: keyword ?? "")
        ]
        
        guard let url = urlComponents?.url else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode(MealResponse.self, from: data)
                DispatchQueue.main.async {
                    self.mealData = response.meals ?? []
                    self.updateQuickFilters()
                    self.collectionView.reloadData()
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    private func updateQuickFilters() {
        let areas = Set(mealData.compactMap { $0.strArea })
        quickFilterStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for area in areas {
            let button = UIButton(type: .system)
            button.setTitle(area, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            quickFilterStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func filterTapped(_ sender: UIButton) {
        guard let filter = sender.titleLabel?.text else { return }
        
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
            sender.backgroundColor = .systemBlue
        } else {
            selectedFilters.insert(filter)
            sender.backgroundColor = .systemGreen
        }
        
        let filteredData = mealData.filter { selectedFilters.isEmpty || selectedFilters.contains($0.strArea ?? "") }
        mealData = filteredData
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension HomePage: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mealData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MealCell", for: indexPath) as? MealCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: mealData[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMeal = mealData[indexPath.item]
        let detailPage = RecipeDetailPage(meal: selectedMeal)
        navigationController?.pushViewController(detailPage, animated: true)
    }
}

// MARK: - SearchBar Delegate
extension HomePage: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        fetchMeals(keyword: keyword)
    }
}

// MARK: - MealCell class
class MealCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let areaLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Set border and corner radius for the cell
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 12.0
        layer.masksToBounds = true
        
        // Set background color
        backgroundColor = UIColor.white
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        areaLabel.font = UIFont.systemFont(ofSize: 12)
        areaLabel.textColor = .gray
        areaLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(areaLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            areaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            areaLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            areaLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(with meal: Meal) {
        titleLabel.text = meal.strMeal
        areaLabel.text = meal.strArea
        if let urlString = meal.strMealThumb, let url = URL(string: urlString) {
            // Load image from URL (use a library like SDWebImage for better caching)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
}

