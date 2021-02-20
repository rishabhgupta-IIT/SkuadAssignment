//
//  ViewController.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-20.
//

import UIKit

class ImageSearchViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image Search"
        setupSearchController()
        prepareDataSource("Flowers")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "What are you looking for?"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func prepareDataSource(_ title: String) {
        NetworkManager.sharedInstance.getImages(with: title, pageNumber) { [weak self] itemList, error in
            print(itemList)
        }
    }
}

extension ImageSearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {

    }
}

