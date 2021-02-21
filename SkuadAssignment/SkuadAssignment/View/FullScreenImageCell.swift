//
//  FullScreenImageCell.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-21.
//

import Foundation
import UIKit

class FullScreenImageCell: UICollectionViewCell {
    @IBOutlet weak var fullScreenImageView: UIImageView!
    var identifier: String = ""

    func configure(_ image: UIImage?) {
        fullScreenImageView.image = image
    }
}
