//
//  FullScreenImageViewController.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-21.
//

import Foundation
import UIKit

class FullScreenImageViewController: UIViewController {
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    var searchResultViewModel: ImageSearchResultViewModel?
    var indexNumber = IndexPath(item: 0, section: 1)
    
    static func viewController(_ searchResultViewModel: ImageSearchResultViewModel?, _ indexNumber: IndexPath) -> FullScreenImageViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fullScreenImageVC = storyboard.instantiateViewController(withIdentifier: "fullScreenImageVC") as! FullScreenImageViewController
        fullScreenImageVC.searchResultViewModel = searchResultViewModel
        fullScreenImageVC.indexNumber = indexNumber
        return fullScreenImageVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        
        // For UI Testing purpose
        collectionView.accessibilityLabel = "fullScreenCollectionView"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollToItem(at: indexNumber, at: .right, animated: false)
        collectionView.setNeedsLayout()
    }
    
    private func setupCollectionViewLayout() {
        let cellWidth = UIScreen.main.bounds.width
        let cellSize = CGSize(width: cellWidth , height:cellWidth)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.isPagingEnabled = true
        collectionView.register(UINib(nibName: "FullScreenImageCell", bundle: nil), forCellWithReuseIdentifier: "fullScreenImageCell")
    }
}

extension FullScreenImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionView Datasource methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResultViewModel?.listItems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fullScreenImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullScreenImageCell", for: indexPath) as! FullScreenImageCell
        let imageURL = searchResultViewModel?.listItems[indexPath.row].webformatURL ?? "dummy_image"
        fullScreenImageCell.identifier = imageURL
        setImage(cell: fullScreenImageCell, at: indexPath)
        return fullScreenImageCell
    }
    
    func setImage(cell: FullScreenImageCell, at indexPath: IndexPath) {
        let imageURL = searchResultViewModel?.listItems[indexPath.row].webformatURL ?? "dummy_image"
        let previewURL = searchResultViewModel?.listItems[indexPath.row].previewURL ?? "dummy_image"
        
        if let imageAvailable = searchResultViewModel?.imageCache.getImage(imageURL) {
            cell.configure(imageAvailable)
        }
        else {
            let previewImage = UIImage(named: "dummy_image")
            cell.configure(previewImage)
            
            if let imageAvailable = searchResultViewModel?.imageCache.getImage(previewURL) {
                cell.configure(imageAvailable)
            }
            
            searchResultViewModel?.imageCache.downloadQueue.addOperation { [weak self] in
                self?.searchResultViewModel?.imageCache.downloadAndSaveImage(imageURL)
                DispatchQueue.main.async {
                    guard cell.identifier == imageURL, let imageAvailable = self?.searchResultViewModel?.imageCache.getImage(imageURL) else { return }
                    cell.configure(imageAvailable)
                }
            }
        }
    }
}
