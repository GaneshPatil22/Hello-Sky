import Foundation

/// The shape Open-Meteo returns. Never leaves this file's neighbours.
struct OpenMeteoResponse: Decodable {
    let hourly: Hourly

    struct Hourly: Decodable {
        let time: [String]
        let temperature2m: [Double?]
        let cloudCover: [Double?]
        let cloudCoverLow: [Double?]?
        let cloudCoverMid: [Double?]?
        let cloudCoverHigh: [Double?]?
        let precipitation: [Double?]
        let weatherCode: [Int?]

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case cloudCover = "cloud_cover"
            case cloudCoverLow = "cloud_cover_low"
            case cloudCoverMid = "cloud_cover_mid"
            case cloudCoverHigh = "cloud_cover_high"
            case precipitation
            case weatherCode = "weather_code"
        }
    }
}
