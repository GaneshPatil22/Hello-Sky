#!/usr/bin/env python3
"""Regenerate the bundled city catalogue used for offline search and tests.

Coordinates are city-centre approximations, which is all a sky needs: a tenth
of a degree is about 11 km, far below what changes a sunrise time noticeably.
Time zone identifiers are validated against the system database here, so a typo
fails at generation rather than at runtime.

    python3 Tools/generate-city-catalog.py \
        > Packages/SkyData/Sources/SkyData/Resources/cities.json
"""
import json, sys, zoneinfo

CITIES = [
    # Europe
    ("London", "United Kingdom", 51.51, -0.13, "Europe/London"),
    ("Manchester", "United Kingdom", 53.48, -2.24, "Europe/London"),
    ("Edinburgh", "United Kingdom", 55.95, -3.19, "Europe/London"),
    ("Dublin", "Ireland", 53.35, -6.26, "Europe/Dublin"),
    ("Paris", "France", 48.86, 2.35, "Europe/Paris"),
    ("Lyon", "France", 45.76, 4.84, "Europe/Paris"),
    ("Marseille", "France", 43.30, 5.37, "Europe/Paris"),
    ("Berlin", "Germany", 52.52, 13.40, "Europe/Berlin"),
    ("Munich", "Germany", 48.14, 11.58, "Europe/Berlin"),
    ("Hamburg", "Germany", 53.55, 9.99, "Europe/Berlin"),
    ("Frankfurt", "Germany", 50.11, 8.68, "Europe/Berlin"),
    ("Amsterdam", "Netherlands", 52.37, 4.90, "Europe/Amsterdam"),
    ("Rotterdam", "Netherlands", 51.92, 4.48, "Europe/Amsterdam"),
    ("Brussels", "Belgium", 50.85, 4.35, "Europe/Brussels"),
    ("Zurich", "Switzerland", 47.38, 8.54, "Europe/Zurich"),
    ("Geneva", "Switzerland", 46.20, 6.14, "Europe/Zurich"),
    ("Vienna", "Austria", 48.21, 16.37, "Europe/Vienna"),
    ("Prague", "Czechia", 50.08, 14.44, "Europe/Prague"),
    ("Warsaw", "Poland", 52.23, 21.01, "Europe/Warsaw"),
    ("Krakow", "Poland", 50.06, 19.94, "Europe/Warsaw"),
    ("Budapest", "Hungary", 47.50, 19.04, "Europe/Budapest"),
    ("Bucharest", "Romania", 44.43, 26.10, "Europe/Bucharest"),
    ("Sofia", "Bulgaria", 42.70, 23.32, "Europe/Sofia"),
    ("Athens", "Greece", 37.98, 23.73, "Europe/Athens"),
    ("Rome", "Italy", 41.90, 12.50, "Europe/Rome"),
    ("Milan", "Italy", 45.46, 9.19, "Europe/Rome"),
    ("Naples", "Italy", 40.85, 14.27, "Europe/Rome"),
    ("Madrid", "Spain", 40.42, -3.70, "Europe/Madrid"),
    ("Barcelona", "Spain", 41.39, 2.17, "Europe/Madrid"),
    ("Valencia", "Spain", 39.47, -0.38, "Europe/Madrid"),
    ("Lisbon", "Portugal", 38.72, -9.14, "Europe/Lisbon"),
    ("Porto", "Portugal", 41.15, -8.61, "Europe/Lisbon"),
    ("Copenhagen", "Denmark", 55.68, 12.57, "Europe/Copenhagen"),
    ("Stockholm", "Sweden", 59.33, 18.07, "Europe/Stockholm"),
    ("Oslo", "Norway", 59.91, 10.75, "Europe/Oslo"),
    ("Tromso", "Norway", 69.65, 18.96, "Europe/Oslo"),
    ("Helsinki", "Finland", 60.17, 24.94, "Europe/Helsinki"),
    ("Reykjavik", "Iceland", 64.15, -21.94, "Atlantic/Reykjavik"),
    ("Tallinn", "Estonia", 59.44, 24.75, "Europe/Tallinn"),
    ("Riga", "Latvia", 56.95, 24.11, "Europe/Riga"),
    ("Vilnius", "Lithuania", 54.69, 25.28, "Europe/Vilnius"),
    ("Kyiv", "Ukraine", 50.45, 30.52, "Europe/Kyiv"),
    ("Moscow", "Russia", 55.76, 37.62, "Europe/Moscow"),
    ("Saint Petersburg", "Russia", 59.93, 30.34, "Europe/Moscow"),
    ("Istanbul", "Turkiye", 41.01, 28.98, "Europe/Istanbul"),
    ("Belgrade", "Serbia", 44.79, 20.45, "Europe/Belgrade"),
    ("Zagreb", "Croatia", 45.81, 15.98, "Europe/Zagreb"),

    # Africa
    ("Cairo", "Egypt", 30.04, 31.24, "Africa/Cairo"),
    ("Alexandria", "Egypt", 31.20, 29.92, "Africa/Cairo"),
    ("Casablanca", "Morocco", 33.57, -7.59, "Africa/Casablanca"),
    ("Marrakesh", "Morocco", 31.63, -7.99, "Africa/Casablanca"),
    ("Algiers", "Algeria", 36.75, 3.06, "Africa/Algiers"),
    ("Tunis", "Tunisia", 36.81, 10.18, "Africa/Tunis"),
    ("Lagos", "Nigeria", 6.52, 3.38, "Africa/Lagos"),
    ("Abuja", "Nigeria", 9.06, 7.49, "Africa/Lagos"),
    ("Accra", "Ghana", 5.60, -0.19, "Africa/Accra"),
    ("Dakar", "Senegal", 14.72, -17.47, "Africa/Dakar"),
    ("Nairobi", "Kenya", -1.29, 36.82, "Africa/Nairobi"),
    ("Kampala", "Uganda", 0.35, 32.58, "Africa/Kampala"),
    ("Addis Ababa", "Ethiopia", 9.03, 38.74, "Africa/Addis_Ababa"),
    ("Dar es Salaam", "Tanzania", -6.79, 39.21, "Africa/Dar_es_Salaam"),
    ("Kinshasa", "DR Congo", -4.44, 15.27, "Africa/Kinshasa"),
    ("Luanda", "Angola", -8.84, 13.23, "Africa/Luanda"),
    ("Harare", "Zimbabwe", -17.83, 31.05, "Africa/Harare"),
    ("Johannesburg", "South Africa", -26.20, 28.05, "Africa/Johannesburg"),
    ("Cape Town", "South Africa", -33.92, 18.42, "Africa/Johannesburg"),
    ("Durban", "South Africa", -29.86, 31.03, "Africa/Johannesburg"),

    # Middle East
    ("Dubai", "United Arab Emirates", 25.20, 55.27, "Asia/Dubai"),
    ("Abu Dhabi", "United Arab Emirates", 24.45, 54.38, "Asia/Dubai"),
    ("Doha", "Qatar", 25.29, 51.53, "Asia/Qatar"),
    ("Riyadh", "Saudi Arabia", 24.71, 46.68, "Asia/Riyadh"),
    ("Jeddah", "Saudi Arabia", 21.49, 39.19, "Asia/Riyadh"),
    ("Kuwait City", "Kuwait", 29.38, 47.99, "Asia/Kuwait"),
    ("Manama", "Bahrain", 26.23, 50.59, "Asia/Bahrain"),
    ("Muscat", "Oman", 23.59, 58.41, "Asia/Muscat"),
    ("Tehran", "Iran", 35.69, 51.39, "Asia/Tehran"),
    ("Baghdad", "Iraq", 33.32, 44.36, "Asia/Baghdad"),
    ("Amman", "Jordan", 31.95, 35.93, "Asia/Amman"),
    ("Beirut", "Lebanon", 33.89, 35.50, "Asia/Beirut"),
    ("Tel Aviv", "Israel", 32.09, 34.78, "Asia/Jerusalem"),
    ("Jerusalem", "Israel", 31.78, 35.22, "Asia/Jerusalem"),

    # South and Central Asia
    ("Mumbai", "India", 19.08, 72.88, "Asia/Kolkata"),
    ("Delhi", "India", 28.61, 77.21, "Asia/Kolkata"),
    ("Bengaluru", "India", 12.97, 77.59, "Asia/Kolkata"),
    ("Hyderabad", "India", 17.39, 78.49, "Asia/Kolkata"),
    ("Chennai", "India", 13.08, 80.27, "Asia/Kolkata"),
    ("Kolkata", "India", 22.57, 88.36, "Asia/Kolkata"),
    ("Pune", "India", 18.52, 73.86, "Asia/Kolkata"),
    ("Ahmedabad", "India", 23.02, 72.57, "Asia/Kolkata"),
    ("Jaipur", "India", 26.91, 75.79, "Asia/Kolkata"),
    ("Kochi", "India", 9.93, 76.27, "Asia/Kolkata"),
    ("Kathmandu", "Nepal", 27.72, 85.32, "Asia/Kathmandu"),
    ("Colombo", "Sri Lanka", 6.93, 79.86, "Asia/Colombo"),
    ("Dhaka", "Bangladesh", 23.81, 90.41, "Asia/Dhaka"),
    ("Karachi", "Pakistan", 24.86, 67.01, "Asia/Karachi"),
    ("Lahore", "Pakistan", 31.52, 74.36, "Asia/Karachi"),
    ("Islamabad", "Pakistan", 33.68, 73.05, "Asia/Karachi"),
    ("Kabul", "Afghanistan", 34.56, 69.21, "Asia/Kabul"),
    ("Tashkent", "Uzbekistan", 41.30, 69.24, "Asia/Tashkent"),
    ("Almaty", "Kazakhstan", 43.24, 76.89, "Asia/Almaty"),
    ("Baku", "Azerbaijan", 40.41, 49.87, "Asia/Baku"),
    ("Tbilisi", "Georgia", 41.72, 44.79, "Asia/Tbilisi"),
    ("Yerevan", "Armenia", 40.18, 44.51, "Asia/Yerevan"),

    # East and Southeast Asia
    ("Tokyo", "Japan", 35.68, 139.69, "Asia/Tokyo"),
    ("Osaka", "Japan", 34.69, 135.50, "Asia/Tokyo"),
    ("Kyoto", "Japan", 35.01, 135.77, "Asia/Tokyo"),
    ("Sapporo", "Japan", 43.06, 141.35, "Asia/Tokyo"),
    ("Fukuoka", "Japan", 33.59, 130.40, "Asia/Tokyo"),
    ("Seoul", "South Korea", 37.57, 126.98, "Asia/Seoul"),
    ("Busan", "South Korea", 35.18, 129.08, "Asia/Seoul"),
    ("Beijing", "China", 39.90, 116.41, "Asia/Shanghai"),
    ("Shanghai", "China", 31.23, 121.47, "Asia/Shanghai"),
    ("Shenzhen", "China", 22.54, 114.06, "Asia/Shanghai"),
    ("Guangzhou", "China", 23.13, 113.26, "Asia/Shanghai"),
    ("Chengdu", "China", 30.57, 104.07, "Asia/Shanghai"),
    ("Hong Kong", "Hong Kong", 22.32, 114.17, "Asia/Hong_Kong"),
    ("Macau", "Macau", 22.20, 113.54, "Asia/Macau"),
    ("Taipei", "Taiwan", 25.03, 121.57, "Asia/Taipei"),
    ("Ulaanbaatar", "Mongolia", 47.89, 106.91, "Asia/Ulaanbaatar"),
    ("Bangkok", "Thailand", 13.76, 100.50, "Asia/Bangkok"),
    ("Chiang Mai", "Thailand", 18.79, 98.99, "Asia/Bangkok"),
    ("Hanoi", "Vietnam", 21.03, 105.85, "Asia/Ho_Chi_Minh"),
    ("Ho Chi Minh City", "Vietnam", 10.82, 106.63, "Asia/Ho_Chi_Minh"),
    ("Phnom Penh", "Cambodia", 11.56, 104.92, "Asia/Phnom_Penh"),
    ("Vientiane", "Laos", 17.98, 102.63, "Asia/Vientiane"),
    ("Yangon", "Myanmar", 16.87, 96.20, "Asia/Yangon"),
    ("Singapore", "Singapore", 1.35, 103.82, "Asia/Singapore"),
    ("Kuala Lumpur", "Malaysia", 3.14, 101.69, "Asia/Kuala_Lumpur"),
    ("Jakarta", "Indonesia", -6.21, 106.85, "Asia/Jakarta"),
    ("Bali", "Indonesia", -8.65, 115.22, "Asia/Makassar"),
    ("Manila", "Philippines", 14.60, 120.98, "Asia/Manila"),
    ("Cebu", "Philippines", 10.32, 123.89, "Asia/Manila"),

    # Oceania
    ("Sydney", "Australia", -33.87, 151.21, "Australia/Sydney"),
    ("Melbourne", "Australia", -37.81, 144.96, "Australia/Melbourne"),
    ("Brisbane", "Australia", -27.47, 153.03, "Australia/Brisbane"),
    ("Perth", "Australia", -31.95, 115.86, "Australia/Perth"),
    ("Adelaide", "Australia", -34.93, 138.60, "Australia/Adelaide"),
    ("Darwin", "Australia", -12.46, 130.84, "Australia/Darwin"),
    ("Hobart", "Australia", -42.88, 147.33, "Australia/Hobart"),
    ("Canberra", "Australia", -35.28, 149.13, "Australia/Sydney"),
    ("Auckland", "New Zealand", -36.85, 174.76, "Pacific/Auckland"),
    ("Wellington", "New Zealand", -41.29, 174.78, "Pacific/Auckland"),
    ("Christchurch", "New Zealand", -43.53, 172.64, "Pacific/Auckland"),
    ("Suva", "Fiji", -18.14, 178.44, "Pacific/Fiji"),
    ("Port Moresby", "Papua New Guinea", -9.44, 147.18, "Pacific/Port_Moresby"),
    ("Honolulu", "United States", 21.31, -157.86, "Pacific/Honolulu"),

    # North America
    ("New York", "United States", 40.71, -74.01, "America/New_York"),
    ("Boston", "United States", 42.36, -71.06, "America/New_York"),
    ("Washington", "United States", 38.91, -77.04, "America/New_York"),
    ("Philadelphia", "United States", 39.95, -75.17, "America/New_York"),
    ("Atlanta", "United States", 33.75, -84.39, "America/New_York"),
    ("Miami", "United States", 25.76, -80.19, "America/New_York"),
    ("Detroit", "United States", 42.33, -83.05, "America/Detroit"),
    ("Chicago", "United States", 41.88, -87.63, "America/Chicago"),
    ("Houston", "United States", 29.76, -95.37, "America/Chicago"),
    ("Dallas", "United States", 32.78, -96.80, "America/Chicago"),
    ("Austin", "United States", 30.27, -97.74, "America/Chicago"),
    ("Minneapolis", "United States", 44.98, -93.27, "America/Chicago"),
    ("New Orleans", "United States", 29.95, -90.07, "America/Chicago"),
    ("Denver", "United States", 39.74, -104.99, "America/Denver"),
    ("Salt Lake City", "United States", 40.76, -111.89, "America/Denver"),
    ("Phoenix", "United States", 33.45, -112.07, "America/Phoenix"),
    ("Las Vegas", "United States", 36.17, -115.14, "America/Los_Angeles"),
    ("Los Angeles", "United States", 34.05, -118.24, "America/Los_Angeles"),
    ("San Diego", "United States", 32.72, -117.16, "America/Los_Angeles"),
    ("San Francisco", "United States", 37.77, -122.42, "America/Los_Angeles"),
    ("Seattle", "United States", 47.61, -122.33, "America/Los_Angeles"),
    ("Portland", "United States", 45.52, -122.68, "America/Los_Angeles"),
    ("Anchorage", "United States", 61.22, -149.90, "America/Anchorage"),
    ("Toronto", "Canada", 43.65, -79.38, "America/Toronto"),
    ("Ottawa", "Canada", 45.42, -75.70, "America/Toronto"),
    ("Montreal", "Canada", 45.50, -73.57, "America/Toronto"),
    ("Vancouver", "Canada", 49.28, -123.12, "America/Vancouver"),
    ("Calgary", "Canada", 51.05, -114.07, "America/Edmonton"),
    ("Halifax", "Canada", 44.65, -63.58, "America/Halifax"),
    ("St John's", "Canada", 47.56, -52.71, "America/St_Johns"),
    ("Mexico City", "Mexico", 19.43, -99.13, "America/Mexico_City"),
    ("Guadalajara", "Mexico", 20.66, -103.35, "America/Mexico_City"),
    ("Monterrey", "Mexico", 25.69, -100.32, "America/Monterrey"),
    ("Cancun", "Mexico", 21.16, -86.85, "America/Cancun"),
    ("Havana", "Cuba", 23.11, -82.37, "America/Havana"),
    ("Kingston", "Jamaica", 17.98, -76.79, "America/Jamaica"),
    ("Panama City", "Panama", 8.98, -79.52, "America/Panama"),
    ("San Jose", "Costa Rica", 9.93, -84.09, "America/Costa_Rica"),
    ("Guatemala City", "Guatemala", 14.63, -90.51, "America/Guatemala"),

    # South America
    ("Bogota", "Colombia", 4.71, -74.07, "America/Bogota"),
    ("Medellin", "Colombia", 6.24, -75.58, "America/Bogota"),
    ("Caracas", "Venezuela", 10.49, -66.88, "America/Caracas"),
    ("Quito", "Ecuador", -0.18, -78.47, "America/Guayaquil"),
    ("Lima", "Peru", -12.05, -77.04, "America/Lima"),
    ("La Paz", "Bolivia", -16.49, -68.15, "America/La_Paz"),
    ("Santiago", "Chile", -33.45, -70.67, "America/Santiago"),
    ("Buenos Aires", "Argentina", -34.60, -58.38, "America/Argentina/Buenos_Aires"),
    ("Cordoba", "Argentina", -31.42, -64.18, "America/Argentina/Cordoba"),
    ("Montevideo", "Uruguay", -34.90, -56.16, "America/Montevideo"),
    ("Asuncion", "Paraguay", -25.26, -57.58, "America/Asuncion"),
    ("Sao Paulo", "Brazil", -23.55, -46.63, "America/Sao_Paulo"),
    ("Rio de Janeiro", "Brazil", -22.91, -43.17, "America/Sao_Paulo"),
    ("Brasilia", "Brazil", -15.79, -47.88, "America/Sao_Paulo"),
    ("Salvador", "Brazil", -12.97, -38.50, "America/Bahia"),
    ("Manaus", "Brazil", -3.12, -60.02, "America/Manaus"),
]


def slug(name, country):
    text = f"{name}-{country}".lower()
    return "".join(c if c.isalnum() else "-" for c in text).strip("-").replace("--", "-")


def main():
    seen, rows = set(), []
    for name, country, lat, lon, tz in CITIES:
        try:
            zoneinfo.ZoneInfo(tz)
        except Exception:
            sys.exit(f"unknown time zone {tz} for {name}")
        if not -90 <= lat <= 90 or not -180 <= lon <= 180:
            sys.exit(f"coordinate out of range for {name}")
        identifier = slug(name, country)
        if identifier in seen:
            sys.exit(f"duplicate id {identifier}")
        seen.add(identifier)
        rows.append({"id": identifier, "name": name, "country": country,
                     "latitude": lat, "longitude": lon, "timeZoneIdentifier": tz})
    json.dump(rows, sys.stdout, indent=1, ensure_ascii=False)


if __name__ == "__main__":
    main()
