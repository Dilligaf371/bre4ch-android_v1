// =============================================================================
// BRE4CH - Regional Airport Database
// Verified ICAO/IATA codes, coordinates, and FlightRadar24 links
// Countries: UAE, KSA, Oman, Qatar, Bahrain, Israel, Lebanon
//
// Sources:
// - ICAO Doc 7910 (Location Indicators)
// - OurAirports (CC-BY-SA, ourairports.com)
// - FlightRadar24 (public airport pages)
// =============================================================================

class AirportData {
  final String icao;
  final String iata;
  final String name;
  final String city;
  final String country;
  final String countryCode;
  final String flag;
  final double lat;
  final double lng;
  final bool isMilitary;
  final String fr24Url;        // FlightRadar24 airport page
  final String notamUrl;       // ICAO NOTAM source

  const AirportData({
    required this.icao,
    required this.iata,
    required this.name,
    required this.city,
    required this.country,
    required this.countryCode,
    required this.flag,
    required this.lat,
    required this.lng,
    this.isMilitary = false,
    required this.fr24Url,
    required this.notamUrl,
  });
}

const List<AirportData> regionalAirports = [
  // ── UAE ──────────────────────────────────────────────────────────
  AirportData(
    icao: 'OMDB', iata: 'DXB', name: 'Dubai International Airport',
    city: 'Dubai', country: 'UAE', countryCode: 'AE', flag: '\u{1F1E6}\u{1F1EA}',
    lat: 25.2528, lng: 55.3644,
    fr24Url: 'https://www.flightradar24.com/airport/dxb',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OMDB',
  ),
  AirportData(
    icao: 'OMAA', iata: 'AUH', name: 'Abu Dhabi International Airport',
    city: 'Abu Dhabi', country: 'UAE', countryCode: 'AE', flag: '\u{1F1E6}\u{1F1EA}',
    lat: 24.4330, lng: 54.6511,
    fr24Url: 'https://www.flightradar24.com/airport/auh',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OMAA',
  ),
  AirportData(
    icao: 'OMSJ', iata: 'SHJ', name: 'Sharjah International Airport',
    city: 'Sharjah', country: 'UAE', countryCode: 'AE', flag: '\u{1F1E6}\u{1F1EA}',
    lat: 25.3286, lng: 55.5172,
    fr24Url: 'https://www.flightradar24.com/airport/shj',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OMSJ',
  ),
  AirportData(
    icao: 'OMDW', iata: 'DWC', name: 'Al Maktoum International Airport',
    city: 'Dubai', country: 'UAE', countryCode: 'AE', flag: '\u{1F1E6}\u{1F1EA}',
    lat: 24.8960, lng: 55.1614,
    fr24Url: 'https://www.flightradar24.com/airport/dwc',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OMDW',
  ),
  AirportData(
    icao: 'OMRK', iata: 'RKT', name: 'Ras Al Khaimah International Airport',
    city: 'Ras Al Khaimah', country: 'UAE', countryCode: 'AE', flag: '\u{1F1E6}\u{1F1EA}',
    lat: 25.6135, lng: 55.9388,
    fr24Url: 'https://www.flightradar24.com/airport/rkt',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OMRK',
  ),

  // ── KSA ─────────────────────────────────────────────────────────
  AirportData(
    icao: 'OEJN', iata: 'JED', name: 'King Abdulaziz International Airport',
    city: 'Jeddah', country: 'Saudi Arabia', countryCode: 'SA', flag: '\u{1F1F8}\u{1F1E6}',
    lat: 21.6796, lng: 39.1565,
    fr24Url: 'https://www.flightradar24.com/airport/jed',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OEJN',
  ),
  AirportData(
    icao: 'OERK', iata: 'RUH', name: 'King Khalid International Airport',
    city: 'Riyadh', country: 'Saudi Arabia', countryCode: 'SA', flag: '\u{1F1F8}\u{1F1E6}',
    lat: 24.9576, lng: 46.6988,
    fr24Url: 'https://www.flightradar24.com/airport/ruh',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OERK',
  ),
  AirportData(
    icao: 'OEDF', iata: 'DMM', name: 'King Fahd International Airport',
    city: 'Dammam', country: 'Saudi Arabia', countryCode: 'SA', flag: '\u{1F1F8}\u{1F1E6}',
    lat: 26.4712, lng: 49.7979,
    fr24Url: 'https://www.flightradar24.com/airport/dmm',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OEDF',
  ),
  AirportData(
    icao: 'OEMA', iata: 'MED', name: 'Prince Mohammed bin Abdulaziz Airport',
    city: 'Madinah', country: 'Saudi Arabia', countryCode: 'SA', flag: '\u{1F1F8}\u{1F1E6}',
    lat: 24.5534, lng: 39.7051,
    fr24Url: 'https://www.flightradar24.com/airport/med',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OEMA',
  ),

  // ── OMAN ────────────────────────────────────────────────────────
  AirportData(
    icao: 'OOMS', iata: 'MCT', name: 'Muscat International Airport',
    city: 'Muscat', country: 'Oman', countryCode: 'OM', flag: '\u{1F1F4}\u{1F1F2}',
    lat: 23.5933, lng: 58.2844,
    fr24Url: 'https://www.flightradar24.com/airport/mct',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OOMS',
  ),
  AirportData(
    icao: 'OOSA', iata: 'SLL', name: 'Salalah Airport',
    city: 'Salalah', country: 'Oman', countryCode: 'OM', flag: '\u{1F1F4}\u{1F1F2}',
    lat: 17.0387, lng: 54.0913,
    fr24Url: 'https://www.flightradar24.com/airport/sll',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OOSA',
  ),

  // ── QATAR ───────────────────────────────────────────────────────
  AirportData(
    icao: 'OTHH', iata: 'DOH', name: 'Hamad International Airport',
    city: 'Doha', country: 'Qatar', countryCode: 'QA', flag: '\u{1F1F6}\u{1F1E6}',
    lat: 25.2731, lng: 51.6081,
    fr24Url: 'https://www.flightradar24.com/airport/doh',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OTHH',
  ),

  // ── BAHRAIN ─────────────────────────────────────────────────────
  AirportData(
    icao: 'OBBI', iata: 'BAH', name: 'Bahrain International Airport',
    city: 'Manama', country: 'Bahrain', countryCode: 'BH', flag: '\u{1F1E7}\u{1F1ED}',
    lat: 26.2708, lng: 50.6336,
    fr24Url: 'https://www.flightradar24.com/airport/bah',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OBBI',
  ),

  // ── ISRAEL ──────────────────────────────────────────────────────
  AirportData(
    icao: 'LLBG', iata: 'TLV', name: 'Ben Gurion International Airport',
    city: 'Tel Aviv', country: 'Israel', countryCode: 'IL', flag: '\u{1F1EE}\u{1F1F1}',
    lat: 32.0114, lng: 34.8867,
    fr24Url: 'https://www.flightradar24.com/airport/tlv',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=LLBG',
  ),
  AirportData(
    icao: 'LLER', iata: 'ETH', name: 'Ramon International Airport',
    city: 'Eilat', country: 'Israel', countryCode: 'IL', flag: '\u{1F1EE}\u{1F1F1}',
    lat: 29.7270, lng: 35.0124,
    fr24Url: 'https://www.flightradar24.com/airport/eth',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=LLER',
  ),

  // ── LEBANON ─────────────────────────────────────────────────────
  AirportData(
    icao: 'OLBA', iata: 'BEY', name: 'Rafic Hariri International Airport',
    city: 'Beirut', country: 'Lebanon', countryCode: 'LB', flag: '\u{1F1F1}\u{1F1E7}',
    lat: 33.8209, lng: 35.4884,
    fr24Url: 'https://www.flightradar24.com/airport/bey',
    notamUrl: 'https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do?reportType=Raw&retrieveLocId=OLBA',
  ),
];
