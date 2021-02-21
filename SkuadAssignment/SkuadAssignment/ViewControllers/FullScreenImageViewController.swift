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
    
    var listItems = [SearchImageItem]()
    var indexNumber = IndexPath(item: 0, section: 1)
    let imageCache = ImageCacheManager.shared
    
    static func viewController(_ listItems: [SearchImageItem], _ indexNumber: IndexPath) -> FullScreenImageViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fullScreenImageVC = storyboard.instantiateViewController(withIdentifier: "fullScreenImageVC") as! FullScreenImageViewController
        fullScreenImageVC.listItems = listItems
        fullScreenImageVC.indexNumber = indexNumber
        return fullScreenImageVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollToItem(at: indexNumber, at: .right, animated: false)
        collectionView.setNeedsLayout()
    }
}

extension FullScreenImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fullScreenImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullScreenImageCell", for: indexPath) as! FullScreenImageCell
        let imageURL = listItems[indexPath.row].webformatURL
        fullScreenImageCell.identifier = imageURL
        setImage(cell: fullScreenImageCell, at: indexPath)
        return fullScreenImageCell
    }
    
    func setImage(cell: FullScreenImageCell, at indexPath: IndexPath) {
        let imageURL = listItems[indexPath.row].webformatURL
        let previewURL = listItems[indexPath.row].previewURL
        
        if let imageAvailable = imageCache.getImage(imageURL) {
            cell.configure(imageAvailable)
        }
        else {
            let previewImage = UIImage(named: "dummy_image")
            cell.configure(previewImage)
            
            if let imageAvailable = imageCache.getImage(previewURL) {
                cell.configure(imageAvailable)
            }
            
            imageCache.downloadQueue.addOperation { [weak self] in
                self?.imageCache.downloadAndSaveImage(imageURL)
                DispatchQueue.main.async {
                    guard cell.identifier == imageURL, let imageAvailable = self?.imageCache.getImage(imageURL) else { return }
                    cell.configure(imageAvailable)
                }
            }
        }
    }
}
