//
//  CustomAnnotationView.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 8. 6..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import MapKit

class ImageAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var colour: UIColor?
    var price: Int?
    var name: String?
    var distance: Double?
    var katecX: Double?
    var katecY: Double?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
        self.image = nil
        self.price = nil
        self.name = nil
        self.distance = nil
        self.katecX = nil
        self.katecY = nil
        self.colour = UIColor.white
    }
}

class ImageAnnotationView: MKAnnotationView {
    private var firstImageView: UIImageView!
    private var secondImageView: UIImageView!
    private var logoImageView: UIImageView!
    var priceLabel: UILabel!
    var name: String?
    var distance: Double?
    var coordinate: CLLocationCoordinate2D?
    var katecX: Double?
    var katecY: Double?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: 0, y: 0, width: 65, height: 32)
        self.firstImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 65, height: 28))
        self.firstImageView.image = UIImage(named: "v4_tooltip_distance1")
        self.secondImageView = UIImageView(frame: CGRect(x: 29.5, y: 27, width: 7, height: 6))
        self.secondImageView.image = UIImage(named: "v4_tooltip_distance2")
        self.logoImageView = UIImageView(frame: CGRect(x: 5, y: 6.5, width: 15, height: 15))
        
        self.priceLabel = UILabel(frame: CGRect(x: 23, y: 5, width: 37, height: 18))
        self.priceLabel.textAlignment = .left
        self.priceLabel.font = UIFont.systemFont(ofSize: 15)
        
        self.addSubview(self.firstImageView)
        self.addSubview(self.secondImageView)
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
