import Foundation
import CoreLocation

protocol WeahterManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=d7f2d0d847c7d06183ffe2bf214021cd&units=metric"
    
    var delegate: WeahterManagerDelegate?
    
    func fetchWeather(cityName : String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude : CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String){
        // 1.create a url string
        if let url = URL(string: urlString){
            // 2.create a url session
            let session = URLSession(configuration: .default)
            // 3.give the session a task
            let task = session.dataTask(with: url) { (data,response,error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    let dataString = String(data: safeData, encoding: .utf8)
                    if let weather = parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // 4.start task
            task.resume()
        }
        
        func parseJSON(weatherData: Data) -> WeatherModel?{
            let decoder = JSONDecoder()
            do {
                let decodedData =  try decoder.decode(WeatherData.self, from: weatherData)
                let id = decodedData.weather[0].id
                let name = decodedData.name
                let temp = decodedData.main.temp
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                return weather
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
    }
}
