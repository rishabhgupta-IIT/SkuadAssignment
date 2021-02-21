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
    
    static func viewController(_ listItems: [SearchImageItem]) -> FullScreenImageViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fullScreenImageVC = storyboard.instantiateViewController(withIdentifier: "fullScreenImageVC") as! FullScreenImageViewController
        fullScreenImageVC.listItems = listItems
        return fullScreenImageVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
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
        collectionView.reloadData()
        collectionView.register(UINib(nibName: "FullScreenImageCell", bundle: nil), forCellWithReuseIdentifier: "fullScreenImageCell")
    }
}

extension FullScreenImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullScreenImageCell", for: indexPath) as! FullScreenImageCell
        let imageURL = listItems[indexPath.row].userImageURL
        if let previewImageData = listItems[indexPath.row].userImageData {
            imageCell.configure(UIImage(data: previewImageData))
        }
        else {
            var previewImage = UIImage(named: "avatar-empty")
            imageCell.configure(previewImage)
            DispatchQueue.global().async { [weak self] in
                if let url = URL(string: imageURL),
                   let data = try? Data(contentsOf: url) {
                    print("fetched data for \(indexPath.row) with \(imageURL)")
                    self?.listItems[indexPath.row].userImageData = data
                    previewImage = UIImage(data: data)
                }
                
                DispatchQueue.main.async {
                    if let largeImageData = self?.listItems[indexPath.row].userImageData {
                        imageCell.configure(UIImage(data: largeImageData))
                    }
                }
            }
        }
        return imageCell
    }
}
