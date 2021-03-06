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
    var searchResultViewModel: ImageSearchResultViewModel?
    let activityIndicator = UIActivityIndicatorView(style: .medium)
        
    static func viewController(_ searchResultViewModel: ImageSearchResultViewModel?) -> ImageSearchResultViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchImageVC = storyboard.instantiateViewController(withIdentifier: "searchImageVC") as! ImageSearchResultViewController
        searchImageVC.searchResultViewModel = searchResultViewModel
        return searchImageVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image Search"
        collectionView.register(UINib(nibName: "PreviewImageCell", bundle: nil), forCellWithReuseIdentifier: "previewImageCell")
        // For UI Testing purpose
        collectionView.accessibilityLabel = "imageSearchResultCollectionView"
        setupSearchResultViewModel()
        setupCollectionViewFlowLayout()
        setupActivityIndicator()
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
    
    private func setupSearchResultViewModel() {
        searchResultViewModel?.reloadData = collectionView.reloadData
        searchResultViewModel?.stopAnimating = activityIndicator.stopAnimating
        searchResultViewModel?.onError = {
            let alert = UIAlertController(title: "Error", message: "No data available!!!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in
                if self.searchResultViewModel?.currentPage == 1 {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ImageSearchResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - UICollectionView Datasource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResultViewModel?.listItems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let previewImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewImageCell", for: indexPath) as! PreviewImageCell
        let imageURL = searchResultViewModel?.listItems[indexPath.row].previewURL ?? "dummy_image"
        previewImageCell.identifier = imageURL
        setImage(cell: previewImageCell, at: indexPath)
        return previewImageCell
    }
    
    func setImage(cell: PreviewImageCell, at indexPath: IndexPath) {
        guard let searchResultViewModel = searchResultViewModel else {
            return
        }
        
        let imageURL = searchResultViewModel.listItems[indexPath.row].previewURL
        
        if let imageAvailable = searchResultViewModel.imageCache.getImage(imageURL) {
            cell.configure(imageAvailable)
        }
        else {
            let previewImage = UIImage(named: "dummy_image")
            cell.configure(previewImage)

            searchResultViewModel.imageCache.downloadQueue.addOperation { [weak self] in
                self?.searchResultViewModel?.imageCache.downloadAndSaveImage(imageURL)
                DispatchQueue.main.async {
                    guard cell.identifier == imageURL, let imageAvailable = self?.searchResultViewModel?.imageCache.getImage(imageURL) else { return }
                    cell.configure(imageAvailable)
                }
            }
        }
    }
        
    // MARK: - UICollectionView Delegate methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let searchResultViewModel = searchResultViewModel {
            let fullScreenVC = FullScreenImageViewController.viewController(searchResultViewModel, indexPath)
            navigationController?.pushViewController(fullScreenVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // pagination
        searchResultViewModel?.pagination(indexPath)
    }
}

