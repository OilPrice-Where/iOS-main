//
//  CustomAnnotationView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 6..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import MapKit

class ImageAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var colour: UIColor?
    var stationInfo: GasStation?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
        self.stationInfo = nil
        self.colour = UIColor.white
    }
}

class ImageAnnotationView: MKAnnotationView {
    var firstImageView: UIImageView!
    private var logoImageView: UIImageView!
    var priceLabel: UILabel!
    var coordinate: CLLocationCoordinate2D?
    var stationInfo: GasStation?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: 0, y: 0, width: 65, height: 32)
        self.firstImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 32))
        self.firstImageView.image = UIImage(named: "NonMapMarker")
        self.logoImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 15, height: 15))
        
        self.priceLabel = UILabel(frame: CGRect(x: 23, y: 3.5, width: 37, height: 18))
        self.priceLabel.textAlignment = .left
        self.priceLabel.textColor = UIColor.black
        self.priceLabel.font = UIFont.boldSystemFont(ofSize: 13)
        
        self.addSubview(self.firstImageView)
        self.addSubview(self.priceLabel)
        self.addSubview(self.logoImageView)
        
        self.firstImageView.layer.masksToBounds = true
    }
    
    override var image: UIImage? {
        get {
            return self.logoImageView.image
        }
        
        set {
            self.logoImageView.image = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
