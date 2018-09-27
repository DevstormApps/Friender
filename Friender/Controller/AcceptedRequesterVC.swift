//
//  AcceptedRequesterVC.swift
//  Friender
//
//  Created by mac on 9/26/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import FirebaseDatabase

class AcceptedRequesterVC: UIViewController, UICollectionViewDataSource {
    
    let flowLayout = EventCollectionViewFlowLayout()
    let user = Auth.auth().currentUser
    
    // MARK: - Variables
    var ref: DatabaseReference!
    
    var acceptedEvents = [AcceptedEvents]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = flowLayout
        ref = Database.database().reference()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.child("acceptedEventRequesters").child(user!.uid).observe(.value) { snapshot in
            var acceptedEvents = [AcceptedEvents]()
            for acceptedSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let acceptedEvent = AcceptedEvents(snapshot: acceptedSnapshot)
                acceptedEvents.append(acceptedEvent)
            }
            self.acceptedEvents = acceptedEvents
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return acceptedEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AcceptedCell
        cell.acceptedEvents = acceptedEvents[indexPath.row]
        print("heeeeeeeeeeeeeeeeeeeeey")
        return cell
    }
    
}
