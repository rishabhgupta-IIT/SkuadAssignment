//
//  ImageSearchResultViewController.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-20.
//

import UIKit

class ImageSearchResultViewController: UIViewController {
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var itemInSongleRow = 3
    var itemSpacing = 5
    var currentPage = 1
    var queryString = ""
    var addToLRU: (() -> Void) = {}
    var listItems = [SearchImageItem]()
    let imageCache = ImageCacheManager.shared
    let activityIndicator = UIActivityIndicatorView(style: .medium)
        
    static func viewController(_ queryString: String, _ addToLRU: @escaping (() -> Void)) -> ImageSearchResultViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchImageVC = storyboard.instantiateViewController(withIdentifier: "searchImageVC") as! ImageSearchResultViewController
        searchImageVC.queryString = queryString
        searchImageVC.addToLRU = addToLRU
        return searchImageVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image Search"
        collectionView.register(UINib(nibName: "PreviewImageCell", bundle: nil), forCellWithReuseIdentifier: "previewImageCell")
        setupCollectionViewFlowLayout()
        setupActivityIndicator()
        prepareDataSource(queryString, currentPage)
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
    
    private func setupActivityIndicator() {
        // Create the Activity Indicator.
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // Position it at the center of the ViewController.
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                                        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
        activityIndicator.startAnimating()
    }
    
    private func prepareDataSource(_ title: String, _ pageNumber: Int) {
        NetworkManager.sharedInstance.getImages(with: title, pageNumber) { [weak self] itemList, error in
            if let strongSelf = self {
                DispatchQueue.main.async {
                    strongSelf.activityIndicator.stopAnimating()
                }
                if let itemList = itemList, itemList.count > 0 {
                    // success
                    strongSelf.listItems += itemList
                    DispatchQueue.main.async {
                        strongSelf.addToLRU()
                        strongSelf.collectionView.reloadData()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "No data available!!!", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
                            if strongSelf.currentPage == 1 {
                                strongSelf.navigationController?.popViewController(animated: true)
                            }
                        }))
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension ImageSearchResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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

            imageCache.downloadQueue.addOperation { [weak self] in
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
        if indexPath.item > (currentPage * NetworkManager.sharedInstance.perPage - 30) {
            currentPage += 1
            prepareDataSource(queryString, currentPage)
        }
    }
}

