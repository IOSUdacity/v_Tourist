//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Jack McCabe on 1/4/22.
//


 

import UIKit
import MapKit
import CoreData

class TravelMap: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var map: MKMapView!
    var coordinates:CLLocationCoordinate2D?
    
   //var  dataController
    var dataController:DataControllerClass!
    
    var locationArray:[Location]? = []
    

    override func viewDidLoad() {
        print("TravelMap Loaded")
   
        super.viewDidLoad()
        map.delegate = self
        map.isScrollEnabled = true
        map.isZoomEnabled = true
        map.showsCompass = true
        map.showsTraffic = true
    
        tapToPin()

        //Create user defaulted location
        var UDArray = UserDefaults.standard.array(forKey: "MapZoom") as? [Double] ?? [259903612.84426913, 73902085.73368837, 27297766.28560701, 53936166.23581289]
        let startMapRegion =  MKMapRect.init(x: UDArray[0], y: UDArray[1] , width: UDArray[2], height: UDArray[3] )
        map.setVisibleMapRect(startMapRegion, animated: false)
    
        setupLocations()
        }
    
    func setupLocations(){
        let fetchRequest:NSFetchRequest = Location.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let results = try?  dataController.viewContext.fetch(fetchRequest){
            print("Printing locations from CoreData Fetch")
            print(results)
            for i in 0..<results.count{
                print("Adding Points to map\nLatitdue_Longitude: "); print(results[i].latitude); print(results[i].longitude)
                addPinsToMap(lat: results[i].latitude, long:results[i].longitude)
            }
        }else{
            print("Error loading locations")
            return
        }
        
        //next 3 lines can be deleted
        var point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2D(latitude: 33.22, longitude: 43.23)
        map.addAnnotation(point)

    }
    
    
    func addPinsToMap(lat:Double, long:Double){
        let point = MKPointAnnotation()
        var cor = CLLocationCoordinate2D(latitude: lat, longitude: long)
        point.coordinate = cor
        point.title = "Point Title"
        self.map.addAnnotation(point)
    }
 
    func tapToPin(){
        var longTap = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
        longTap.minimumPressDuration = 0.3
        longTap.delegate = self
        var xLoc = longTap.location(in: self.map)
        self.map.addGestureRecognizer(longTap)
    }
    

    
    @objc func addPin(_ fromTap: UILongPressGestureRecognizer){
        if fromTap.state != .began{
            return
        }
        var cor = fromTap.location(in: self.map)
        var CLcor = self.map.convert(cor, toCoordinateFrom : self.map)
   
        let point = MKPointAnnotation()
        point.coordinate = CLcor
        point.subtitle = "Test Subtitle"
        point.title = "Does this work "
        self.map.addAnnotation(point)
        addPintoStore(point:point)
    
}
    func addPintoStore(point:MKPointAnnotation){
        var location = Location(context:dataController.viewContext)
        location.latitude = point.coordinate.latitude
        location.longitude = point.coordinate.longitude
        
        try? dataController.viewContext.save()
        print("added datat to controller")
        
    }
    
    //Map Delegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
          
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView){
    
        print("Printing Coordinates")
        print(view.annotation?.coordinate)
        print(type(of:view.annotation?.coordinate ))
      
        var fetchRequest:NSFetchRequest = Location.fetchRequest()
        var sortDescriptors = NSSortDescriptor(key: "latitude", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptors]
        
        if let _results = try? dataController.viewContext.fetch(fetchRequest){
            for x in _results{
                if(x.latitude == view.annotation?.coordinate.latitude && x.longitude == view.annotation?.coordinate.longitude){
                    self.performSegue(withIdentifier: "presentAlbum", sender: x)
                }
            }
        }
        var fetchedDataController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "locations")
        fetchedDataController.delegate = self
        
        do{
      let results = try?  fetchedDataController.performFetch()
            print("1 Printing fetched data results")
          //  print(results)
            guard results == nil else{
                print("Feteched Data was empty"); return
            }
           print(" 2 Printing Fetched Data Results")
      //      print(results)
        }catch{
            fatalError("Issue with fetching all the Location\n\(error.localizedDescription)")
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
       if(segue.identifier == "presentAlbum"){
     
         if let VC = segue.destination as? PhotoAlbum{
             VC.location = sender as! Location
             VC.dataController = dataController
             
             let currentPin = UserDefaults.standard.array(forKey: "MapZoom")
             var MKRect =  MKMapRect.init(x: currentPin![0] as! Double, y: currentPin![1] as! Double, width: currentPin![2] as! Double, height: currentPin![3] as! Double )
             
             VC.mapArea = MKRect
             
           }
       }
   }
    
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated animated: Bool){
       
        var x = map.visibleMapRect
        var mapArea:[Double] = []
        
        mapArea.append(x.origin.x)
        mapArea.append(x.origin.y)
        mapArea.append(x.width)
        mapArea.append(x.height)
       
        print(mapArea)
        UserDefaults.standard.set(mapArea, forKey: "MapZoom")
}

   
}




