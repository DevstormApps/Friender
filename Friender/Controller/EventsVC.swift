//
//  EventsVC.swift
//  Friender
//
//  Created by mac on 7/13/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseUI
import GoogleSignIn

class EventsVC: UIViewController, UICollectionViewDataSource {
    
    let flowLayout = EventCollectionViewFlowLayout()
    let user = Auth.auth().currentUser
    
    // MARK: - Variables
    var ref: DatabaseReference!
    
    var events = [Event]() {
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

        ref.child("events").observe(.value) { snapshot in
            var events = [Event]()
            for eventSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                for userEventSnapshot in eventSnapshot.children.allObjects as! [DataSnapshot] {
                    let event = Event(snapshot: userEventSnapshot)
                    events.append(event)
                }
            }
            self.events = events
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCell
        cell.event = events[indexPath.row]
        return cell
    }
 
   }
