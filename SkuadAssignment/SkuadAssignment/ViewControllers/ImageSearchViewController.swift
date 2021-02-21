//
//  ViewController.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-20.
//

import UIKit

class ImageSearchViewController: UIViewController {
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var currentPage = 0
//    var latestScrolledIndex = 0
    var isLoadingList : Bool = false
    var listItems = [SearchImageItem]()
    var filterContentForSearchText: (() -> Void)?
    var imageCache = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image Search"
        collectionView.register(UINib(nibName: "PreviewImageCell", bundle: nil), forCellWithReuseIdentifier: "previewImageCell")
        setupSearchController()
        filterContentForSearchText = scheduleFetchImages(withDelay: 1, action: {
            self.currentPage = 1
            self.listItems.removeAll()
            self.prepareDataSource(self.searchController.searchBar.text!, self.currentPage)
        })
//        prepareDataSource("Flowers", currentPage)
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
    
    private func scheduleFetchImages(withDelay delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {
        var workItem: DispatchWorkItem?

        return {
            workItem?.cancel()
            workItem = DispatchWorkItem(block: action)
            queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
        }
    }
    
    private func prepareDataSource(_ title: String, _ pageNumber: Int) {
        NetworkManager.sharedInstance.getImages(with: title, pageNumber) { [weak self] itemList, error in
            if let strongSelf = self {
                if let itemList = itemList {
                    print("Received \(itemList.count)")
                    strongSelf.listItems += itemList
                    DispatchQueue.main.async {
                        strongSelf.isLoadingList = false
                        strongSelf.collectionView.reloadData()
                    }
                }
                else if error != nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension ImageSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let previewImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewImageCell", for: indexPath) as! PreviewImageCell
        let imageURL = listItems[indexPath.row].previewURL
        if let imageAvailable = imageCache[imageURL] {
            print("Data already available for \(indexPath.row)")
            previewImageCell.configure(imageAvailable)
        }
        else {
            print("fetching data for \(indexPath.row)")
            var previewImage = UIImage(named: "avatar-empty")
            previewImageCell.configure(previewImage)
            DispatchQueue.global().async { [weak self] in
                let index = indexPath
                if let url = URL(string: imageURL),
                   let data = try? Data(contentsOf: url) {
                    print("fetched data for \(index.row) with \(imageURL)")
//                    self?.listItems[index.item].previewImageData = data
//                    previewImage = UIImage(data: data)
                    self?.imageCache[imageURL] = UIImage(data: data)
                }
                
                DispatchQueue.main.async {
//                    if let previewImageData = self?.listItems[index.item].previewImageData {
//                        previewImageCell.configure(UIImage(data: previewImageData))
//                    }
                    if let image = self?.imageCache[imageURL] {
                        previewImageCell.configure(image)
                    }
                }
            }
        }
        return previewImageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullScreenVC = FullScreenImageViewController.viewController(listItems)
        navigationController?.pushViewController(fullScreenVC, animated: true)
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.item > (currentPage * NetworkManager.sharedInstance.perPage - 10) {
//            currentPage += 1
//            prepareDataSource("Flowers", currentPage)
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList) {
            self.isLoadingList = true
            self.loadMoreItemsForList()
        }
    }
    
    func loadMoreItemsForList() {
        currentPage += 1
        prepareDataSource("Flowers", currentPage)
    }
}

extension ImageSearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.searchBar.text!.isEmpty {
            filterContentForSearchText!()
        }
    }
}

