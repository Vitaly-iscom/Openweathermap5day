//
//  WeatherScreenTableViewController.swift
//  TheWeatherApp
//
//  Created by Виталий Исхаков on 08/12/2018.
//  Copyright © 2018 IScom. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class CitiesScreenTableViewController: UITableViewController {
    
    //MARK: - variables for CoreData
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - variables
    public var places = [Places]()
    var weatherFromCoreData = [Weather]()
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPlacesFromCoreData()
        if places.count != 0 && places.count != weatherFromCoreData.count {
            fetchWeatherFromCoreData()
        }
        tableView.reloadData()
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
    }

    //MARK: - Methods
    func fetchPlacesFromCoreData() {
        let fetchRequest: NSFetchRequest<Places> = Places.fetchRequest()
        
        do {
            let places = try context.fetch(fetchRequest)
            self.places = places
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchWeatherFromCoreData() {
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        
        do {
            let weather = try context.fetch(fetchRequest)
            self.weatherFromCoreData = weather
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    func filterArray(i: Int) {
    
    
//        let weatherArray = weatherFromCoreData
//        var array = ArraySlice<Weather>()
//        array = weatherArray.prefix(upTo: 39 + ((i) * 40))
//        let filter = array.suffix(from: (40 * (i)))
//        for item in filter {
//            self.filterWeather.append(item)
//        }
//    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)

        cell.textLabel?.text = "\(places[indexPath.row].name!)"

        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            context.delete(places[indexPath.row])
            places.remove(at: indexPath.row)
            
            if places.count == 0 {
                for item in weatherFromCoreData {
                    context.delete(item)
                }
                weatherFromCoreData.remove(at: indexPath.section)
            }
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
        default: return
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let dvc = segue.destination as! WeatherViewController
                
                dvc.indexPath = indexPath.row
                dvc.weather = weatherFromCoreData

            }
        }
    }
    
}
