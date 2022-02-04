//
//  MapCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Jack McCabe on 1/24/22.
//

import UIKit
import MapKit

class MapCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mapView: MKMapView!
    required init(coder: NSCoder){
        print("Initaliing map 1")
        super.init(coder:  coder)!
        print("Initaliing map 2")
        var point = MKPointAnnotation()
        var coordindate = CLLocationCoordinate2D(latitude: 10, longitude: 20)
         point.coordinate = coordindate
         point.title = "Picture Download Area"
        
         mapView.addAnnotation(point)
    }
    

}
