//
//  WeatherViewController.swift
//  TheWeatherApp
//
//  Created by Виталий Исхаков on 10/12/2018.
//  Copyright © 2018 IScom. All rights reserved.
//

import UIKit
import CoreData

class WeatherViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - variables for CoreData
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - variables
    var weather = [Weather]()
    var filterWeather = ArraySlice<Weather>()
    var indexPath = 0

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "The Weather for 5 day"
        filterArray(i: indexPath)
    }
    
    //MARK: - methods
    func filterArray(i: Int) {
        let weatherArray = weather
        var array = ArraySlice<Weather>()
        array = weatherArray.prefix(upTo: 39 + ((i) * 40))
        let filter = array.suffix(from: (40 * (i)))
        for item in filter {
            self.filterWeather.append(item)
        }
        
        
    }
}

//MARK: - extensions
extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        
        cell.setWeather(weather: filterWeather[indexPath.row])
        
        return cell
    }
}
