//
//  PlaceViewController.swift
//  TravelBook
//
//  Created by Furkan Sarı on 29.03.2022.
//

import UIKit
import CoreData

class PlaceViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var places = [String]()
    var id = [UUID]()
    var selectedName = ""
    var selectedId : UUID?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        getData()
        navigationController?.navigationBar.topItem?.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addPlace))
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    @objc func addPlace(){
        selectedName=""
        performSegue(withIdentifier: "addPlace", sender: self)
        
    }
    
   @objc func getData(){
        id.removeAll(keepingCapacity: false)
        places.removeAll(keepingCapacity: false)
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        do {
           let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject]{
                if let placeName = result.value(forKey: "title") as? String{
                    places.append(placeName)
                }
                if let placeId = result.value(forKey: "id") as? UUID{
                    id.append(placeId)
                }
                tableView.reloadData()
            }
        }catch{
            print("error")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = places[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        var stringId = id[indexPath.row].uuidString
        fetchRequest.predicate=NSPredicate(format: "id=%@", stringId)
        
        
        do{
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject]{
                if let singleId = result.value(forKey: "id") as? UUID{
                    if singleId==id[indexPath.row]{
                        context.delete(result)
                        places.remove(at: indexPath.row)
                        id.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.tableView.reloadData()
                        
                        do{
                            try context.save()
                        }catch{
                            print("error saving")
                        }
                    }
                }
            }
            
        }catch{
            print("Delete Error")
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedId = id[indexPath.row]
        selectedName = places[indexPath.row]
        performSegue(withIdentifier: "addPlace", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ViewController
        destination.choosenId = selectedId
        destination.choosenTitle = selectedName
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
