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


//Maybe instinate a fetched REsults controller and use it directly
//insitate dfetch reustls controller, then update the bojects at secionts.  stuff for each coolcetoin view delate
//look up documentatoin of fetched reuslts controller
//deinit and updates


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
    
    
    @IBAction func testButton(_ sender: Any) {
        fetchedResultsCont = nil
     //Add this in?    dataController.viewContext.reset()
        
        downloadPic()

    }

  
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        


        print("Loading PhotoAlbum with lat/long/pics")
        print(location.latitude)
        print(location.longitude)
        setUpCollectView()
        // Register cell classes
        self.collectionView.delegate = self
       // didn't work self.collectionView.collectionViewLayout = self
        self.collectionView.dataSource = self

        setupFetchController()
       
        
        setHeaderMap(loc:location)
        setUpPhotos()
 
     
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //fetchedResultsCont = nil
    }

    fileprivate func setupFetchController() {
        var sortDescriptors = NSSortDescriptor(key: "picture", ascending: false)
        var fetchRequest = Pictures.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchedResultsCont = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsCont.delegate = self
        do{
            try fetchedResultsCont.performFetch()
            print("In Fetched Resutls ")
            print( fetchedResultsCont.fetchedObjects )
        }catch{
            fatalError("Fatal error in fetch reuslts call \(error.localizedDescription)")
        }
    }
    
    func setUpPhotos(){
        var fetchResults = Pictures.fetchRequest()
        var sortDescriptor = NSSortDescriptor(key:"picture", ascending: false)
        fetchResults.sortDescriptors = [sortDescriptor]
        
      //  if let picure =  try? dataController.viewContext.fetch(fetchResults){
        print("In perform Fetch")
      //  print(picure)
            var foundPictures:Bool = true
            
        if let picure = fetchedResultsCont.fetchedObjects{
            for x in picure{
                if(x.loc == self.location){
                    print("type of x.picture"); print(type(of: x.picture))
                    self.imageArray.append((x.picture as! UIImage))
                    foundPictures = false
                }
            }
            
            if(foundPictures){
                downloadPic()
            }
        }
        collectionView.reloadData()
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
        var page = String(Int.random(in:1...10))
        var format = "format=json&nojsoncallback=1"
        var baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=43fdc91422a379b5907e54449dddda9f&"
        
        var flickURLCall = baseURL + "lat=\(lat)&" + "lon=\(long)&" + "radius=\(radius)&" + "page=\(page)&" + "\(format)"
        print("consructing URL: " + "\(flickURLCall)")
        //NEED TO PUT IN THE LAT LONG PAGE, MAKE SURE THESE EQUAL
    //"https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=43fdc91422a379b5907e54449dddda9f&lat=37&lon=122&radius=5&format=json&nojsoncallback=1"
        var request:URLRequest = URLRequest(url: URL(string: flickURLCall )!)
        request.httpMethod = "GET"
        APICalls.flickrDownload(urlReq: request, responseStructure: APICalls.flickrPhoto.self) { data, error in
            
            guard let data = data else {
                print("Error with URL ID Download Requests")
                print(error)
                return
            }

            var server_id:String = ""; var id:String = ""; var secret:String = "";  var imageURL:String = "";

            var photoCount = data.photos.photo.count
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
                   
                   if(x == photoCount-1){
                       DispatchQueue.main.async{
                      self.collectionView.reloadData()
                      self.savePhotos(photoArray: self.imageArray)
                           print("Finished saving and the collection view updating")
                       }
                       
                   }
               }
               print("X: \(x) \nPhotoCount: \(photoCount)")
               
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
        DispatchQueue.main.async{
        for x in photoArray{
            var pictureStore =  Pictures(context:  self.dataController.viewContext)
            if let pA = x {
                //Update CoreSTack
                pictureStore.picture = pA
                pictureStore.loc = self.location
                
                //Update run time data is already done
            }
            
        }
            do {try! self.dataController.viewContext.save()}
            catch{
                print(error.localizedDescription)
            }
        }
        
        
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
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPicture" , for:   indexPath) as! pictureViewCells
        
        //where we sould pull from the core data
        cell.image.image = imageArray[indexPath.row]
    
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
    
    func deletePictureFromStore(indexPath: IndexPath){
        dataController.viewContext.delete(fetchedResultsCont.object(at: indexPath))
        try? dataController.viewContext.save()
        print("Picture deleted")
    }
    
    
}







