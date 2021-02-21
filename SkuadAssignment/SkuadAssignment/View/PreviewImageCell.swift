//
//  PreviewImageCell.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-20.
//

import Foundation
import UIKit

class PreviewImageCell: UICollectionViewCell {
    @IBOutlet weak var previewImageView: UIImageView!
    
    func configure(_ image: UIImage?) {
        previewImageView.image = image
    }
}
