//
//  TestAnimationModel.swift
//  AITO
//
//  Created by Юра Ганкович on 3.11.22.
//


import Foundation
import UIKit

private extension TimeInterval {
    static let animationDuration = 0.5
}

private extension String {
    static let modelName = "astronaut_"
    static let fileFormat = ".png"
}

private extension Int {
    static let startImageNumber = 1
    static let endImageNumber = 3
}

final class Astronaut: UIImageView {
    
    private var imgAnimationSet: [UIImage] = []
    private var staticModel = UIImage()
    
    private func setImageAnimationSet() -> [UIImage] {
        var imgListArray: [UIImage] = []
        
        for countValue in Int.startImageNumber...Int.endImageNumber {
            let strImageName: String = .modelName + String(countValue) + .fileFormat
            let image = UIImage(named: strImageName)
            
            if let image = image {
                imgListArray.append(image)
            }
        }
        
        return imgListArray
    }
    
    func addSelfAnimation() {
        self.layer.contentsGravity = .resize
        self.layer.borderWidth = 2
        self.animationImages = setImageAnimationSet()
        self.animationDuration = .animationDuration
        self.image = UIImage(named: .modelName + String(Int.startImageNumber) + .fileFormat)
    }
    
}
