//
//  ViewController.swift
//  CoreDataImages
//
//  Created by Alex Arsentev on 2024-03-22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var ratingLabel: UILabel!
    
    @IBOutlet var timesWornLabel: UILabel!
    
    @IBOutlet var lastWornLabel: UILabel!
    
    @IBOutlet var favoriteLabel: UILabel!
    
    @IBOutlet var wearButton: UIButton!
    
    @IBOutlet var rateButton: UIButton!
    
    var currentBowTie: BowTie!
    
    // Reference CoreData storage
    var managedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get a reference to the app delegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate?.persistentContainer.viewContext
        
        insertSampleData()
        
        let request: NSFetchRequest<BowTie> = BowTie.fetchRequest()
        
        let firstTitle = segmentedControl.titleForSegment(at: 0)!
        
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(BowTie.searchKey), firstTitle])
        
        do {
            let results = try managedContext.fetch(request)
            
            currentBowTie = results.first
            
            populate(bowTie: currentBowTie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        print(appDelegate!.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url)
    }
    
    func insertSampleData() {
        // Insert sample data from the SampleData plist file to get some BowTie objects in the file
        
        let fetch: NSFetchRequest<BowTie> = BowTie.fetchRequest()
        
        fetch.predicate = NSPredicate(format: "searchKey != nil")
        
        let count = (try? managedContext.count(for: fetch)) ?? 0
        
        if count > 0{
            return
        }
        
        let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
        
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "BowTie", in: managedContext)!
            
            let bowTie = BowTie(entity: entity, insertInto: managedContext)
            
            let btDict = dict as! [String: Any]
            
            bowTie.id = UUID(uuidString: btDict["id"] as! String)
            bowTie.name = btDict["name"] as? String
            bowTie.searchKey = btDict["searchKey"] as? String
            bowTie.rating = btDict["rating"] as! Double
            
            let colorDict = btDict["tintColor"] as! [String: Any]
            bowTie.tintColor = UIColor.color(dict: colorDict)
            
            let imageName = btDict["imageName"] as? String
            let image = UIImage(named: imageName!)
            
            bowTie.photoData = image?.pngData()
            
            bowTie.lastWorn = btDict["lastWorn"] as? Date
            
            let timesNumber = btDict["timesWorn"] as! NSNumber
            
            bowTie.timesWorn = timesNumber.int32Value
            
            bowTie.isFavorite = btDict["isFavorite"] as! Bool
            bowTie.url = URL(string: btDict["url"] as! String)
        }
        
        try! managedContext.save()
    }
    
    func populate(bowTie: BowTie) {
        
        guard let imageData = bowTie.photoData as Data?,
              let lastWorn = bowTie.lastWorn as? Date?,
              let tintColor = bowTie.tintColor as? UIColor
        else {
            return
        }
        
        imageView.image = UIImage(data: imageData)
        nameLabel.text = bowTie.name
        ratingLabel.text = "Rating: \(bowTie.rating)/5"
        
        timesWornLabel.text = "# of times worn: \(bowTie.timesWorn)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        lastWornLabel.text = "Last Worn: " + dateFormatter.string(from: lastWorn!)
        
        favoriteLabel.isHidden = !bowTie.isFavorite
        
        view.tintColor = tintColor
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        // Chnaging the segmented control
        
        guard let selectedValue = sender.titleForSegment(at: sender.selectedSegmentIndex) else {return}
        
        let request: NSFetchRequest<BowTie> = BowTie.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(BowTie.searchKey), selectedValue])
        
        do {
            let results = try managedContext.fetch(request)
            currentBowTie = results.first
            populate(bowTie: currentBowTie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func wear(_ sender: UIButton) {
        //MARK: - When the wear button is pressed, we have just worn the bowtie
                
        let times = currentBowTie.timesWorn
        currentBowTie.timesWorn = times + 1 //increment the times worn
        currentBowTie.lastWorn = Date()
                
        do {
            try managedContext.save()
            populate(bowTie: currentBowTie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func rate(_ sender: UIButton) {
        let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: .alert)
        
        //add alert field
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
        }
        
        //rating can be out of 5 stars
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            
            action in
            
            if let textField = alert.textFields?.first {
                self.update(rating: textField.text!)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    func update(rating: String?) {
        
        /*
         save and update rating
         */
        guard let ratingString = rating,
              let rating = Double(ratingString) else {
            return
        }
        
        do {
            currentBowTie.rating = rating
            
            try managedContext.save()
            populate(bowTie: currentBowTie)
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain &&
                (error.code == NSValidationNumberTooLargeError ||
                    error.code == NSValidationNumberTooSmallError) {
                rate(rateButton)
            } else {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }


}

extension UIColor {
    static func color(dict: [String: Any]) -> UIColor? {
     //grab a color from our dictionary
        
        guard let red = dict["red"] as? NSNumber,
              let green = dict["green"] as? NSNumber,
              let blue = dict["blue"] as? NSNumber else {
            return nil
        }
        
        return UIColor(red: CGFloat(truncating: red) / 255.0, green: CGFloat(truncating: green), blue: CGFloat(truncating: blue), alpha: 1)
    }
}

