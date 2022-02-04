//
//  DataControllerClass.swift
//  Virtual Tourist
//
//  Created by Jack McCabe on 1/13/22.
//

import Foundation
import CoreData

class DataControllerClass {
    
    
    //Persistent Data controller shouldn't change
    
    let persistentContainer:NSPersistentContainer
    
    //This goes ont he main thread
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    //takes the Data Model name to intiialize
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
        print("initializing model")
        print(modelName)
       
    }
    
    func load(completion: (()->Void)? = nil ){
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else{
            
                fatalError(error!.localizedDescription)
          
            }
            print("Print Persisent Store Description "); print(storeDescription)
            completion?()
        }
                                                 }
}
