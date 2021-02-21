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
    var itemInSongleRow = 3
    var itemSpacing = 5
    var currentPage = 1
    var isLoadingList : Bool = false
    var listItems = [SearchImageItem]()
    var filterContentForSearchText: (() -> Void)?
    let imageCache = ImageCacheManager.shared
    lazy private var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.skuad.downloader"
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image Search"
        collectionView.register(UINib(nibName: "PreviewImageCell", bundle: nil), forCellWithReuseIdentifier: "previewImageCell")
        setupSearchController()
        setupCollectionViewFlowLayout()
        filterContentForSearchText = scheduleFetchImages(withDelay: 1, action: {
            self.currentPage = 1
            self.listItems.removeAll()
            self.prepareDataSource(self.searchController.searchBar.text!, self.currentPage)
        })
        prepareDataSource(searchController.searchBar.text!, currentPage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupCollectionViewFlowLayout() {
        let cellWidth = (((Int(UIScreen.main.bounds.width) - (itemSpacing*(itemInSongleRow+1)))/itemInSongleRow))
        let cellSize = CGSize(width: cellWidth , height:cellWidth)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: CGFloat(itemSpacing), left: CGFloat(itemSpacing), bottom: CGFloat(itemSpacing), right: CGFloat(itemSpacing))
        layout.minimumLineSpacing = CGFloat(itemSpacing)
        layout.minimumInteritemSpacing = CGFloat(itemSpacing)
        collectionView.setCollectionViewLayout(layout, animated: true)
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
        previewImageCell.identifier = imageURL
        setImage(cell: previewImageCell, at: indexPath)
        return previewImageCell
    }
    
    func setImage(cell: PreviewImageCell, at indexPath: IndexPath) {
        let imageURL = listItems[indexPath.row].previewURL
        
        if let imageAvailable = imageCache.getImage(imageURL) {
            cell.configure(imageAvailable)
        }
        else {
            let previewImage = UIImage(named: "dummy_image")
            cell.configure(previewImage)

            downloadQueue.addOperation { [weak self] in
                self?.imageCache.downloadAndSaveImage(imageURL)
                DispatchQueue.main.async {
                    guard cell.identifier == imageURL, let imageAvailable = self?.imageCache.getImage(imageURL) else { return }
                    cell.configure(imageAvailable)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullScreenVC = FullScreenImageViewController.viewController(listItems, indexPath)
        navigationController?.pushViewController(fullScreenVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // pagination
        if indexPath.item > (currentPage * NetworkManager.sharedInstance.perPage - 10) {
            currentPage += 1
            prepareDataSource(searchController.searchBar.text!, currentPage)
        }
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

