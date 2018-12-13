//
//  WeatherTableViewCell.swift
//  TheWeatherApp
//
//  Created by Виталий Исхаков on 09/12/2018.
//  Copyright © 2018 IScom. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
   
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    
    public func setWeather(weather: Weather) {

        dateLabel.text = "\(weather.date!.dropLast(3))"

        let minTemp = 9 / 5 * (Int(weather.minTemp!)! - 273) + 32
        let maxTemp = 9 / 5 * (Int(weather.maxTemp!)! - 273) + 32
        tempLabel.text = "Temperature: \(minTemp) - \(maxTemp) C˚"
        
        guard let image = weather.icon else {return}
        imageWeather.image = UIImage(named: image)
       
     }
}



