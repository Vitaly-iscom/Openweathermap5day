//
//  NewCityTableViewController.swift
//  TheWeatherApp
//
//  Created by Виталий Исхаков on 08/12/2018.
//  Copyright © 2018 IScom. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class NewCityTableViewController: UITableViewController, UISearchResultsUpdating {
    
    //MARK: - variables for CoreData
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - variables
    private var namesFromData = [String]()
    private var searchResult = [String]()
    private var searchController: UISearchController!
    var citiesCD = [Places]()
    var places = [ModelOfPlace]()
    let activityIndicator = UIActivityIndicatorView()
    
    let mainUrl = "https://samples.openweathermap.org/data/2.5"
    let apiKey = "ca82c54b5e5a7897e443cc13cf1e1c30"
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add new city"
        setupActivityIndicator()
        setupSearchController()
        configureSearchBar()
        setupNavBar()
        
        DispatchQueue.main.async {
            if self.namesFromData.isEmpty {
                self.getData()
                self.activityIndicator.stopAnimating()
            } else {
                return
            }
        }
    }
    
    //MARK: - Methods
    fileprivate func setupActivityIndicator() {
        activityIndicator.style = .gray
        activityIndicator.startAnimating()
        tableView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 18).isActive = true
        activityIndicator.leftAnchor.constraint(equalTo: tableView.leftAnchor, constant: view.bounds.width/2).isActive = true
    }
    
    fileprivate func setupNavBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        definesPresentationContext = true
    }
    
    fileprivate func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
    }
    
    fileprivate func configureSearchBar() {
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search city"
        searchController.searchBar.tintColor = .black
    }
    
    fileprivate func getData() {
        let fileName = Bundle.main.path(forResource: "cityList", ofType: "json")
        let filePath = URL(fileURLWithPath: fileName!)
        var data: Data?
        do {
            data = try Data(contentsOf: filePath, options: Data.ReadingOptions(rawValue: 0))
        } catch let error {
            data = nil
            print("Report error \(error.localizedDescription)")
        }
        
        if let jsonData = data {
            do {
                let json = try JSON(data: jsonData)
                guard let arrayData = json.array else {return}
                for item in arrayData {
                    guard let cityName = item["name"].string else {return}
                    guard let cityId = item["id"].int else {return}
                    guard let lat = item["coord"]["lat"].int else {return}
                    guard let lon = item["coord"]["lon"].int else {return}
                    
                    var place = ModelOfPlace()
                    place.name = cityName
                    place.id = cityId
                    place.lat = lat
                    place.lon = lon
                    
                    namesFromData.append(cityName)
                    places.append(place)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortArray = searchResult.prefix(10)
        return sortArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let cityName = searchResult[indexPath.row]
        
        cell.textLabel?.text = cityName
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let ac = UIAlertController(title: "Add the \(searchResult[indexPath.row]) to list?", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { [unowned self] addCity in
            self.createOkAction(indexPath: indexPath)
            self.fetchDataApi()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { [unowned self] addCity in
            self.refreshSearchBar()
        }
        ac.addAction(ok)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
    
    //MARK: - Method for table view delegate
    fileprivate func createOkAction(indexPath: IndexPath) {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Places", in: self.context) else {return}
        let city = NSManagedObject(entity: entity, insertInto: self.context)
        
        let index = self.namesFromData.indexOf(x: self.searchResult[indexPath.row])
        
        city.setValue(self.searchResult[indexPath.row], forKey: "name")
        city.setValue(self.places[index!].id, forKey: "id")
        city.setValue(self.places[index!].lat, forKey: "lat")
        city.setValue(self.places[index!].lon, forKey: "lon")

        
        do {
            try self.context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        refreshSearchBar()
    }
    
    fileprivate func refreshSearchBar() {
        self.searchController.searchBar.text = ""
        self.searchController.isActive = false
        self.tableView.reloadData()
    }
    
    func fetchDataApi() {
        
        getPlacesFromCoreData()
        
        guard let place = citiesCD.last else {return}
        let stringUrl = "\(mainUrl)/forecast?id=\(place.id)&appid=\(apiKey)"
        
        guard let url = URL(string: stringUrl) else {return}
        var data: Data?
        do {
            data = try Data(contentsOf: url)
        } catch let error {
            data = nil
            print("Report error \(error.localizedDescription)")
        }
        
        if let jsonData = data {
            do {
                let json = try JSON(data: jsonData)
                
                guard let arrayData = json["list"].array else {return}
                
                for item in arrayData {
                    var weather = WeatherModel()
                    
                    guard let date = item["dt_txt"].string else {return}
                    
                    weather.date = date
                    
                    guard let temp = item["main"].dictionary else {return}
                    for (i, j) in temp {
                        if i == "temp_min" {
                            guard let tempMin = j.int else {return}
                            weather.minTemp = "\(tempMin)"
                        } else if i == "temp_max" {
                            guard let tempMax = j.int else {return}
                            weather.maxTemp = "\(tempMax)"
                        }
                    }
                    guard let descriptions = item["weather"].array else {return}
                    for desc in descriptions {
                        guard let description = desc["description"].string else {return}
                        guard let icon = desc["icon"].string else {return}
                        weather.description = description
                        weather.icon = icon
                    }
                    
                    saveWeather(weather: weather, placeName: place)
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func getPlacesFromCoreData() {
        let fetchRequest: NSFetchRequest<Places> = Places.fetchRequest()
        
        do {
            let places = try context.fetch(fetchRequest)
            citiesCD = places
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveWeather(weather: WeatherModel, placeName: Places) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Weather", in: self.context) else {return}
        let addWeather = NSManagedObject(entity: entity, insertInto: self.context)
        
        addWeather.setValue(placeName.name, forKey: "name")
        addWeather.setValue(weather.date, forKey: "date")
        addWeather.setValue(weather.minTemp, forKey: "minTemp")
        addWeather.setValue(weather.maxTemp, forKey: "maxTemp")
        addWeather.setValue(weather.description, forKey: "descript")
        addWeather.setValue(weather.icon, forKey: "icon")
        
        do {
            try self.context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - search methods
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(searchText: searchText)
            tableView.reloadData()
        }
    }
    fileprivate func filterContent(searchText: String) {
        searchResult = namesFromData.filter({(name: String) -> Bool in
            let title = name.range(of: searchText, options: .caseInsensitive)
            return title != nil
        })
    }
    
}

//MARK: - extention
extension Array {
    func indexOf<T : Equatable>(x: T) -> Int? {
        for i in 0..<self.count {
            if self[i] as! T == x {
                return i
            }
        }
        return nil
    }
}
