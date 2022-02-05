//
//  PhotoAlbum.swift
//  Virtual Tourist
//
//  Created by Jack McCabe on 1/7/22.
//

import UIKit
import MapKit
import Foundation
import CoreData

private let reuseIdentifier = "Cell"
let group = DispatchGroup()


class PhotoAlbum: UIViewController, UICollectionViewDelegate, NSFetchedResultsControllerDelegate{

    weak var collectionViewFlowLayouts: UICollectionViewFlowLayout?

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mapArea:MKMapRect! = nil
         

    
    @IBOutlet weak var map: MKMapView!
    
    var coordinates: CLLocationCoordinate2D?
    var location = Location()
    var dataController:DataControllerClass!
    var imageArray:[UIImage] = []
    var fetchedResultsCont:NSFetchedResultsController<Pictures>!
    var pictureArray:[Any] = []
    
    @IBAction func testButton(_ sender: Any) {
        fetchedResultsCont = nil
        downloadPic()
        setupFetchController()
        
      collectionView.reloadData()
}
    override func viewDidLoad()  {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        setupFetchController()
        setHeaderMap(loc:location)
        setUpPhotos()
 
     
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //fetchedResultsCont = nil
    }

    fileprivate func setupFetchController() {
        var sortDescriptors = NSSortDescriptor(key: "picture", ascending: false)
        var fetchRequest = Pictures.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptors]
        print("0")
        var pred = NSPredicate(format: "loc == %@", location)
        print("1")
        fetchRequest.predicate = pred
        print("2")
        fetchedResultsCont = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsCont.delegate = self
        print("3")
        
        do{
            print("4")
            try fetchedResultsCont.performFetch()
            print("In Fetched Resutls ")
           
        }catch{
            fatalError("Fatal error in fetch reuslts call \(error.localizedDescription)")
        }
        
    }
    
    func setUpPhotos(){
        var fetchResults = Pictures.fetchRequest()
        var sortDescriptor = NSSortDescriptor(key:"picture", ascending: false)
        fetchResults.sortDescriptors = [sortDescriptor]


        
        print("Number in fetched results")
        print(fetchedResultsCont.fetchedObjects!.count)
        if(fetchedResultsCont!.fetchedObjects!.count > 0){
        if let picure = fetchedResultsCont.fetchedObjects{
            for x in picure{
                if(x.loc == self.location){
                 print("In location x in picutres")
                    collectionView.reloadData()
                }
            }
        }
        }else{
            print("In download pics")
            downloadPic()
        }
       
    }
    
    func setHeaderMap(loc:Location){
        
        map.setVisibleMapRect(mapArea, animated: false)
      
        var point = MKPointAnnotation()
        var coordindate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        point.coordinate = coordindate
        map.setCenter(coordindate, animated: true)
        point.title = "Picture Download Area"
       
        map.addAnnotation(point)
    }
   
    
    func downloadPic() {
        var lat = String(round(location.latitude))
        var long = String(round(location.longitude))
        var radius = "5"
        var page = String(Int.random(in:1...3))
        var format = "format=json&nojsoncallback=1"
        var baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=43fdc91422a379b5907e54449dddda9f&"
        
        
        var flickURLCall = baseURL + "lat=\(lat)&" + "lon=\(long)&" + "radius=\(radius)&" + "page=\(page)&" + "\(format)"
     
        print(flickURLCall)
        var request:URLRequest = URLRequest(url: URL(string: flickURLCall )!)
        request.httpMethod = "GET"
        APICalls.flickrDownload(urlReq: request, responseStructure: APICalls.flickrPhoto.self) { data, error in
            
            guard let data = data else {
                print("Error with URL ID Download Requests")
                print(error)
                return
            }
            self.pictureArray = []

            var server_id:String = ""; var id:String = ""; var secret:String = "";  var imageURL:String = "";

            var photoCount = data.photos.photo.count
            print("Photo count \(photoCount)")
            for x in 0..<photoCount {
            
                server_id = String(data.photos.photo[x].server)
                id = String(data.photos.photo[x].id)
                secret = String(data.photos.photo[x].secret)
               
               imageURL = "https://live.staticflickr.com/"
               imageURL = imageURL + "\(server_id)/" + "\(id)_\(secret).jpg"
               
                APICalls.downloadImage(urlReq: URL(string:imageURL)!){
                   (data, error) in
                   guard let data = data else{
                       print(error)
                       return
                   }
                   self.imageArray.append(UIImage(data: data)!)
                    self.pictureArray.append(data)
                   if(x == photoCount-1){
                       DispatchQueue.main.async{
          
                           self.savePhotos(photoArray: self.imageArray)
                           self.collectionView.reloadData()
                           print("Finished saving and the collection view updating")
                       }
                       
                   }
               }
        
           
           }
       
        }
 
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

   
    

extension PhotoAlbum: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func savePhotos(photoArray: [UIImage?]){
        print("Got to savePhotos")
        for x in photoArray{
            var pictureStore =  Pictures(context:  self.dataController.viewContext)
            if let pA = x {
            
                var pngDataType = pA.pngData()
                pictureStore.picture = pngDataType as! NSData
                pictureStore.loc = self.location
                do {try! self.dataController.viewContext.save()}
                catch{
                    print(error.localizedDescription)
                }
            }
            
        }

    
        
        setupFetchController()
        self.collectionView.reloadData()
        print("finished saving")
    }



    func setUpCollectView(){
        
        let itemSizes = CGSize(width: (view.frame.size.width / 3), height:  (view.frame.size.width / 3))
        var layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.itemSize = CGSize(width:dimension, height:dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let  numbOfSections = fetchedResultsCont.sections{
    
            print("Number of objects in collectionView:\n\(fetchedResultsCont.sections?[section].numberOfObjects)")
            if(numbOfSections[section].numberOfObjects == 0){
                return 1
            }
            return numbOfSections[section].numberOfObjects
        }else{
            print("In if statement for collection view:")
            return 1
        }
        
    //    return fetchedResultsCont.sections?[section].numberOfObjects ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPicture" , for:   indexPath) as! pictureViewCells
        if let  numbOfSections = fetchedResultsCont.sections{
    
        
            if(numbOfSections[0].numberOfObjects == 0){
                cell.activityIndicator.startAnimating()
                cell.image.isHidden = true
                return cell
            }
        }
       
        DispatchQueue.main.async{
            var corePicture = self.fetchedResultsCont.object(at:indexPath)
            if let coreImage = corePicture.picture{
            cell.image.image = UIImage(data: coreImage as! Data)
                cell.image.isHidden = false
                let dimension = (self.view.frame.size.width - 6) / 3.0
                cell.image.bounds = CGRect(x: 0, y: 0, width: dimension, height: dimension)
            cell.activityIndicator.stopAnimating()
            }
        }
        return cell
            
    }
    func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath){
        deletePictureFromStore(indexPath: indexPath)
        collectionView.reloadData()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
      ) -> CGSize {
        // 2
          print("In collection view sizeForItemAt")
      
          let space:CGFloat = 3.0
          let dimension = (view.frame.size.width - (2 * space)) / 3.0
     
          print("Printing Deminsions and then screen width")
          print(dimension)
          print(UIScreen.main.bounds.width)
        return CGSize(width: dimension, height: dimension)
      }
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        print("In minimumInteritemSpacingForSectionAt")
        return 0
    }
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        print("In minimumLineSpacingForSectionAt")
        return 0
    }
    func deletePictureFromStore(indexPath: IndexPath){
        dataController.viewContext.delete(fetchedResultsCont.object(at: indexPath))
        try? dataController.viewContext.save()
        collectionView.deleteItems(at: [indexPath])
        print("Picture deleted")
    }
    
    
}







