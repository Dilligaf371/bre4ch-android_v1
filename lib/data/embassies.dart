// =============================================================================
// BRE4CH - Embassy Database
// Verified consular missions with coordinates, contact info
// =============================================================================

class Embassy {
  final String flag;
  final String name;
  final String nationality;
  final String country;
  final String address;
  final String phone;
  final String emergency;
  final String website;
  final double? lat;
  final double? lng;

  const Embassy({
    required this.flag,
    required this.name,
    required this.nationality,
    required this.country,
    required this.address,
    required this.phone,
    this.lat,
    this.lng,
    this.emergency = '',
    this.website = '',
  });
}

const nationalityLabels = ['ALL', 'USA', 'FRANCE', 'UK', 'GERMANY', 'ITALY', 'SPAIN', 'NL', 'CANADA', 'AUSTRALIA', 'BRAZIL', 'INDIA', 'PHILIPPINES'];
const embassyCountryLabels = ['ALL', 'UAE', 'Israel', 'KSA', 'Bahrain', 'Qatar', 'Kuwait', 'Oman', 'Jordan'];

const List<Embassy> embassies = [
  // ═══════ USA ═══════
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Embassy — Abu Dhabi', nationality: 'USA', country: 'UAE', address: 'Embassies District, Plot 38, Abu Dhabi', phone: '+971 2 414 2200', emergency: '+971 2 414 2200', website: 'https://ae.usembassy.gov/', lat: 24.4241, lng: 54.4340),
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Consulate — Dubai', nationality: 'USA', country: 'UAE', address: 'Corner of Al Seef Rd & Sheikh Khalifa bin Zayed Rd, Dubai', phone: '+971 4 309 4000', emergency: '+971 4 309 4000', website: 'https://ae.usembassy.gov/', lat: 25.2340, lng: 55.2888),
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Embassy — Tel Aviv', nationality: 'USA', country: 'Israel', address: '71 HaYarkon St, Tel Aviv', phone: '+972 3 519 7475', emergency: '+972 3 519 7575', website: 'https://il.usembassy.gov/', lat: 32.0853, lng: 34.7700),
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Embassy — Riyadh', nationality: 'USA', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 488 3800', emergency: '+966 11 488 3800', website: 'https://sa.usembassy.gov/', lat: 24.6761, lng: 46.6250),
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Consulate — Jeddah', nationality: 'USA', country: 'KSA', address: 'Falastin St, Al Rawdah District, Jeddah', phone: '+966 12 220 5000', emergency: '+966 12 220 5000', website: 'https://sa.usembassy.gov/', lat: 21.5340, lng: 39.1729),
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Embassy — Manama', nationality: 'USA', country: 'Bahrain', address: 'Building 979, Road 3119, Zinj District', phone: '+973 1724 2700', emergency: '+973 1727 5532', website: 'https://bh.usembassy.gov/', lat: 26.2106, lng: 50.5882),
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Embassy — Doha', nationality: 'USA', country: 'Qatar', address: '22 February St, Doha', phone: '+974 4496 6000', emergency: '+974 4496 6000', website: 'https://qa.usembassy.gov/', lat: 25.3125, lng: 51.4390),
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Embassy — Kuwait City', nationality: 'USA', country: 'Kuwait', address: 'Al-Masjid Al-Aqsa St, Bayan', phone: '+965 2259 1001', emergency: '+965 2259 1001', website: 'https://kw.usembassy.gov/', lat: 29.3230, lng: 48.0530),
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Embassy — Muscat', nationality: 'USA', country: 'Oman', address: 'PCRS Q1 Area 322, Muscat', phone: '+968 2464 3400', emergency: '+968 2464 3400', website: 'https://om.usembassy.gov/', lat: 23.6100, lng: 58.5399),
  Embassy(flag: '\u{1F1FA}\u{1F1F8}', name: 'U.S. Embassy — Amman', nationality: 'USA', country: 'Jordan', address: 'Al-Umayyaween St, Abdoun, Amman', phone: '+962 6 590 6000', emergency: '+962 6 590 6000', website: 'https://jo.usembassy.gov/', lat: 31.9539, lng: 35.8781),
  // ═══════ FRANCE ═══════
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Ambassade de France — Abu Dhabi', nationality: 'FRANCE', country: 'UAE', address: 'Etihad Towers, Tower 3, Abu Dhabi', phone: '+971 2 813 1000', emergency: '+971 50 224 7440', website: 'https://ae.ambafrance.org/', lat: 24.4539, lng: 54.3218),
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Consulat de France — Dubai', nationality: 'FRANCE', country: 'UAE', address: 'Al Habtoor City, Sheikh Zayed Rd, Dubai', phone: '+971 4 408 4900', emergency: '+971 50 224 7440', website: 'https://dubai.consulfrance.org/', lat: 25.1880, lng: 55.2460),
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Ambassade de France — Tel Aviv', nationality: 'FRANCE', country: 'Israel', address: '112 Herbert Samuel Promenade, Tel Aviv', phone: '+972 3 520 8300', emergency: '+972 54 343 1981', website: 'https://il.ambafrance.org/', lat: 32.0700, lng: 34.7644),
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Ambassade de France — Riyadh', nationality: 'FRANCE', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 434 1100', emergency: '+966 53 437 4449', website: 'https://sa.ambafrance.org/', lat: 24.6756, lng: 46.6213),
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Consulat de France — Jeddah', nationality: 'FRANCE', country: 'KSA', address: 'Al Hamra District, Jeddah', phone: '+966 12 668 1550', website: 'https://jeddah.consulfrance.org/', lat: 21.5427, lng: 39.1727),
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Ambassade de France — Manama', nationality: 'FRANCE', country: 'Bahrain', address: 'Diplomatic Area, Manama', phone: '+973 1729 8600', emergency: '+973 3921 4508', website: 'https://bh.ambafrance.org/', lat: 26.2361, lng: 50.5860),
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Ambassade de France — Doha', nationality: 'FRANCE', country: 'Qatar', address: 'West Bay, Doha', phone: '+974 4402 3400', emergency: '+974 5558 8302', website: 'https://qa.ambafrance.org/', lat: 25.3290, lng: 51.4355),
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Ambassade de France — Kuwait', nationality: 'FRANCE', country: 'Kuwait', address: 'Mansouriya, Kuwait City', phone: '+965 2257 1061', website: 'https://kw.ambafrance.org/', lat: 29.3492, lng: 47.9804),
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Ambassade de France — Muscat', nationality: 'FRANCE', country: 'Oman', address: 'Shatti Al Qurum, Muscat', phone: '+968 2468 1800', website: 'https://om.ambafrance.org/', lat: 23.6000, lng: 58.4190),
  Embassy(flag: '\u{1F1EB}\u{1F1F7}', name: 'Ambassade de France — Amman', nationality: 'FRANCE', country: 'Jordan', address: 'Jabal Amman, Mutanabbi St, Amman', phone: '+962 6 460 4630', emergency: '+962 79 777 3991', website: 'https://jo.ambafrance.org/', lat: 31.9525, lng: 35.9231),
  // ═══════ UK ═══════
  Embassy(flag: '\u{1F1EC}\u{1F1E7}', name: 'British Embassy — Abu Dhabi', nationality: 'UK', country: 'UAE', address: 'Khalid Bin Al Waleed St, Abu Dhabi', phone: '+971 2 610 1100', emergency: '+44 20 7008 5000', website: 'https://www.gov.uk/world/organisations/british-embassy-abu-dhabi', lat: 24.4938, lng: 54.3712),
  Embassy(flag: '\u{1F1EC}\u{1F1E7}', name: 'British Consulate — Dubai', nationality: 'UK', country: 'UAE', address: 'Al Seef Rd, Bur Dubai', phone: '+971 4 309 4444', emergency: '+44 20 7008 5000', website: 'https://www.gov.uk/world/organisations/british-embassy-abu-dhabi', lat: 25.2555, lng: 55.2913),
  Embassy(flag: '\u{1F1EC}\u{1F1E7}', name: 'British Embassy — Tel Aviv', nationality: 'UK', country: 'Israel', address: '192 HaYarkon St, Tel Aviv', phone: '+972 3 725 1222', emergency: '+44 20 7008 5000', website: 'https://www.gov.uk/world/organisations/british-embassy-tel-aviv', lat: 32.0868, lng: 34.7695),
  Embassy(flag: '\u{1F1EC}\u{1F1E7}', name: 'British Embassy — Riyadh', nationality: 'UK', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 481 9100', emergency: '+44 20 7008 5000', website: 'https://www.gov.uk/world/organisations/british-embassy-riyadh', lat: 24.6780, lng: 46.6230),
  Embassy(flag: '\u{1F1EC}\u{1F1E7}', name: 'British Embassy — Manama', nationality: 'UK', country: 'Bahrain', address: '21 Government Ave, Manama', phone: '+973 1757 4100', emergency: '+44 20 7008 5000', website: 'https://www.gov.uk/world/organisations/british-embassy-manama', lat: 26.2330, lng: 50.5830),
  Embassy(flag: '\u{1F1EC}\u{1F1E7}', name: 'British Embassy — Doha', nationality: 'UK', country: 'Qatar', address: 'West Bay, Doha', phone: '+974 4496 2000', emergency: '+44 20 7008 5000', website: 'https://www.gov.uk/world/organisations/british-embassy-doha', lat: 25.3280, lng: 51.4340),
  Embassy(flag: '\u{1F1EC}\u{1F1E7}', name: 'British Embassy — Kuwait', nationality: 'UK', country: 'Kuwait', address: 'Arabian Gulf St, Dasman', phone: '+965 2259 4320', emergency: '+44 20 7008 5000', website: 'https://www.gov.uk/world/organisations/british-embassy-kuwait', lat: 29.3690, lng: 47.9850),
  Embassy(flag: '\u{1F1EC}\u{1F1E7}', name: 'British Embassy — Muscat', nationality: 'UK', country: 'Oman', address: 'Al Khuwair, Muscat', phone: '+968 2460 9000', emergency: '+44 20 7008 5000', website: 'https://www.gov.uk/world/organisations/british-embassy-muscat', lat: 23.6090, lng: 58.4870),
  Embassy(flag: '\u{1F1EC}\u{1F1E7}', name: 'British Embassy — Amman', nationality: 'UK', country: 'Jordan', address: 'Abdoun, Amman', phone: '+962 6 590 9200', emergency: '+44 20 7008 5000', website: 'https://www.gov.uk/world/organisations/british-embassy-amman', lat: 31.9530, lng: 35.8780),
  // ═══════ GERMANY ═══════
  Embassy(flag: '\u{1F1E9}\u{1F1EA}', name: 'German Embassy — Abu Dhabi', nationality: 'GERMANY', country: 'UAE', address: 'Al Nahyan Camp Area, Abu Dhabi', phone: '+971 2 644 6693', emergency: '+49 30 5000 2000', website: 'https://abu-dhabi.diplo.de/', lat: 24.4700, lng: 54.3700),
  Embassy(flag: '\u{1F1E9}\u{1F1EA}', name: 'German Consulate — Dubai', nationality: 'GERMANY', country: 'UAE', address: 'API World Tower, Sheikh Zayed Rd, Dubai', phone: '+971 4 349 8888', website: 'https://abu-dhabi.diplo.de/', lat: 25.2100, lng: 55.2700),
  Embassy(flag: '\u{1F1E9}\u{1F1EA}', name: 'German Embassy — Tel Aviv', nationality: 'GERMANY', country: 'Israel', address: '16 Daniel Frisch St, Tel Aviv', phone: '+972 3 693 1313', emergency: '+49 30 5000 2000', website: 'https://tel-aviv.diplo.de/', lat: 32.0730, lng: 34.7870),
  Embassy(flag: '\u{1F1E9}\u{1F1EA}', name: 'German Embassy — Riyadh', nationality: 'GERMANY', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 277 0511', website: 'https://riyadh.diplo.de/', lat: 24.6770, lng: 46.6250),
  Embassy(flag: '\u{1F1E9}\u{1F1EA}', name: 'German Embassy — Doha', nationality: 'GERMANY', country: 'Qatar', address: 'Al Jazira Al Arabiya St, West Bay, Doha', phone: '+974 4408 7200', website: 'https://doha.diplo.de/', lat: 25.3290, lng: 51.4370),
  Embassy(flag: '\u{1F1E9}\u{1F1EA}', name: 'German Embassy — Kuwait', nationality: 'GERMANY', country: 'Kuwait', address: 'Diplomatic Area, Kuwait City', phone: '+965 2252 0827', website: 'https://kuwait.diplo.de/', lat: 29.3750, lng: 47.9770),
  Embassy(flag: '\u{1F1E9}\u{1F1EA}', name: 'German Embassy — Muscat', nationality: 'GERMANY', country: 'Oman', address: 'Diplomatic Quarter, Muscat', phone: '+968 2483 2482', website: 'https://maskat.diplo.de/', lat: 23.6050, lng: 58.4900),
  Embassy(flag: '\u{1F1E9}\u{1F1EA}', name: 'German Embassy — Amman', nationality: 'GERMANY', country: 'Jordan', address: 'Benghazi St 25, Jabal Amman', phone: '+962 6 590 1170', website: 'https://amman.diplo.de/', lat: 31.9540, lng: 35.9200),
  // ═══════ ITALY ═══════
  Embassy(flag: '\u{1F1EE}\u{1F1F9}', name: 'Italian Embassy — Abu Dhabi', nationality: 'ITALY', country: 'UAE', address: 'Al Khaleej Al Arabi St, Abu Dhabi', phone: '+971 2 414 4100', website: 'https://ambabud.esteri.it/', lat: 24.4640, lng: 54.3410),
  Embassy(flag: '\u{1F1EE}\u{1F1F9}', name: 'Italian Consulate — Dubai', nationality: 'ITALY', country: 'UAE', address: 'Sheikh Zayed Rd, Dubai', phone: '+971 4 314 1440', website: 'https://consdubai.esteri.it/', lat: 25.2090, lng: 55.2680),
  Embassy(flag: '\u{1F1EE}\u{1F1F9}', name: 'Italian Embassy — Tel Aviv', nationality: 'ITALY', country: 'Israel', address: '25 Hamered St, Tel Aviv', phone: '+972 3 510 4004', website: 'https://ambtelaviv.esteri.it/', lat: 32.0620, lng: 34.7680),
  Embassy(flag: '\u{1F1EE}\u{1F1F9}', name: 'Italian Embassy — Riyadh', nationality: 'ITALY', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 488 1212', website: 'https://ambriad.esteri.it/', lat: 24.6760, lng: 46.6240),
  Embassy(flag: '\u{1F1EE}\u{1F1F9}', name: 'Italian Embassy — Amman', nationality: 'ITALY', country: 'Jordan', address: 'Jabal El Hussein, Amman', phone: '+962 6 463 8185', website: 'https://ambamman.esteri.it/', lat: 31.9570, lng: 35.9130),
  // ═══════ SPAIN ═══════
  Embassy(flag: '\u{1F1EA}\u{1F1F8}', name: 'Spanish Embassy — Abu Dhabi', nationality: 'SPAIN', country: 'UAE', address: 'Capital Plaza Tower, Abu Dhabi', phone: '+971 2 626 9544', website: 'https://www.exteriores.gob.es/Embajadas/abudhabi/', lat: 24.4880, lng: 54.3630),
  Embassy(flag: '\u{1F1EA}\u{1F1F8}', name: 'Spanish Consulate — Dubai', nationality: 'SPAIN', country: 'UAE', address: 'Jumeirah Emirates Towers, Dubai', phone: '+971 4 330 0110', website: 'https://www.exteriores.gob.es/Consulados/dubai/', lat: 25.2174, lng: 55.2801),
  Embassy(flag: '\u{1F1EA}\u{1F1F8}', name: 'Spanish Embassy — Tel Aviv', nationality: 'SPAIN', country: 'Israel', address: '3 Daniel Frisch St, Tel Aviv', phone: '+972 3 696 9218', website: 'https://www.exteriores.gob.es/Embajadas/telaviv/', lat: 32.0730, lng: 34.7870),
  Embassy(flag: '\u{1F1EA}\u{1F1F8}', name: 'Spanish Embassy — Riyadh', nationality: 'SPAIN', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 488 0606', website: 'https://www.exteriores.gob.es/Embajadas/riad/', lat: 24.6760, lng: 46.6230),
  Embassy(flag: '\u{1F1EA}\u{1F1F8}', name: 'Spanish Embassy — Amman', nationality: 'SPAIN', country: 'Jordan', address: 'Zahran St 22, Amman', phone: '+962 6 461 4166', website: 'https://www.exteriores.gob.es/Embajadas/amman/', lat: 31.9530, lng: 35.9090),
  // ═══════ NETHERLANDS ═══════
  Embassy(flag: '\u{1F1F3}\u{1F1F1}', name: 'Dutch Embassy — Abu Dhabi', nationality: 'NL', country: 'UAE', address: 'Al Muroor Rd, Abu Dhabi', phone: '+971 2 407 4200', website: 'https://www.netherlandsworldwide.nl/countries/uae', lat: 24.4530, lng: 54.3870),
  Embassy(flag: '\u{1F1F3}\u{1F1F1}', name: 'Dutch Consulate — Dubai', nationality: 'NL', country: 'UAE', address: 'One Central, DWTC, Dubai', phone: '+971 4 440 7600', website: 'https://www.netherlandsworldwide.nl/countries/uae', lat: 25.2280, lng: 55.2830),
  Embassy(flag: '\u{1F1F3}\u{1F1F1}', name: 'Dutch Embassy — Tel Aviv', nationality: 'NL', country: 'Israel', address: '14 Abba Hillel St, Ramat Gan', phone: '+972 3 754 0777', website: 'https://www.netherlandsworldwide.nl/countries/israel', lat: 32.0830, lng: 34.8100),
  Embassy(flag: '\u{1F1F3}\u{1F1F1}', name: 'Dutch Embassy — Riyadh', nationality: 'NL', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 460 7012', website: 'https://www.netherlandsworldwide.nl/countries/saudi-arabia', lat: 24.6770, lng: 46.6230),
  Embassy(flag: '\u{1F1F3}\u{1F1F1}', name: 'Dutch Embassy — Amman', nationality: 'NL', country: 'Jordan', address: 'Ibrahim Ayoub St 5, Amman', phone: '+962 6 590 2200', website: 'https://www.netherlandsworldwide.nl/countries/jordan', lat: 31.9550, lng: 35.9050),
  // ═══════ CANADA ═══════
  Embassy(flag: '\u{1F1E8}\u{1F1E6}', name: 'Canadian Embassy — Abu Dhabi', nationality: 'CANADA', country: 'UAE', address: 'Abu Dhabi Trade Towers, West Tower', phone: '+971 2 694 0300', emergency: '+1 613 996 8885', website: 'https://www.international.gc.ca/country-pays/uae-eau/', lat: 24.4870, lng: 54.3550),
  Embassy(flag: '\u{1F1E8}\u{1F1E6}', name: 'Canadian Embassy — Tel Aviv', nationality: 'CANADA', country: 'Israel', address: '35 Nirim St, Tel Aviv', phone: '+972 3 636 3300', emergency: '+1 613 996 8885', website: 'https://www.international.gc.ca/country-pays/israel/', lat: 32.0560, lng: 34.7830),
  Embassy(flag: '\u{1F1E8}\u{1F1E6}', name: 'Canadian Embassy — Riyadh', nationality: 'CANADA', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 488 2288', emergency: '+1 613 996 8885', website: 'https://www.international.gc.ca/country-pays/saudi_arabia-arabie_saoudite/', lat: 24.6760, lng: 46.6260),
  Embassy(flag: '\u{1F1E8}\u{1F1E6}', name: 'Canadian Embassy — Doha', nationality: 'CANADA', country: 'Qatar', address: 'Tornado Tower, West Bay, Doha', phone: '+974 4419 9000', emergency: '+1 613 996 8885', website: 'https://www.international.gc.ca/country-pays/qatar/', lat: 25.3220, lng: 51.4340),
  Embassy(flag: '\u{1F1E8}\u{1F1E6}', name: 'Canadian Embassy — Kuwait', nationality: 'CANADA', country: 'Kuwait', address: "Da'iyah, Kuwait City", phone: '+965 2256 3025', emergency: '+1 613 996 8885', website: 'https://www.international.gc.ca/country-pays/kuwait-koweit/', lat: 29.3640, lng: 47.9920),
  Embassy(flag: '\u{1F1E8}\u{1F1E6}', name: 'Canadian Embassy — Amman', nationality: 'CANADA', country: 'Jordan', address: 'Abdoun, Amman', phone: '+962 6 590 1500', emergency: '+1 613 996 8885', website: 'https://www.international.gc.ca/country-pays/jordan-jordanie/', lat: 31.9540, lng: 35.8780),
  // ═══════ AUSTRALIA ═══════
  Embassy(flag: '\u{1F1E6}\u{1F1FA}', name: 'Australian Embassy — Abu Dhabi', nationality: 'AUSTRALIA', country: 'UAE', address: 'Al Muhairy Centre, Abu Dhabi', phone: '+971 2 401 7500', emergency: '+61 2 6261 3305', website: 'https://uae.embassy.gov.au/', lat: 24.4870, lng: 54.3560),
  Embassy(flag: '\u{1F1E6}\u{1F1FA}', name: 'Australian Consulate — Dubai', nationality: 'AUSTRALIA', country: 'UAE', address: 'Level 25, Burj Daman Tower, DIFC', phone: '+971 4 508 7100', website: 'https://uae.embassy.gov.au/', lat: 25.2130, lng: 55.2800),
  Embassy(flag: '\u{1F1E6}\u{1F1FA}', name: 'Australian Embassy — Tel Aviv', nationality: 'AUSTRALIA', country: 'Israel', address: 'Discount Bank Tower, 23 Yehuda Halevi St', phone: '+972 3 693 5000', emergency: '+61 2 6261 3305', website: 'https://israel.embassy.gov.au/', lat: 32.0640, lng: 34.7730),
  Embassy(flag: '\u{1F1E6}\u{1F1FA}', name: 'Australian Embassy — Riyadh', nationality: 'AUSTRALIA', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 481 7788', website: 'https://saudiarabia.embassy.gov.au/', lat: 24.6770, lng: 46.6250),
  Embassy(flag: '\u{1F1E6}\u{1F1FA}', name: 'Australian Embassy — Amman', nationality: 'AUSTRALIA', country: 'Jordan', address: 'Abdoun, Amman', phone: '+962 6 580 7000', website: 'https://jordan.embassy.gov.au/', lat: 31.9530, lng: 35.8790),
  // ═══════ BRAZIL ═══════
  Embassy(flag: '\u{1F1E7}\u{1F1F7}', name: 'Brazilian Embassy — Abu Dhabi', nationality: 'BRAZIL', country: 'UAE', address: 'Al Nahyan Camp Area, Abu Dhabi', phone: '+971 2 632 6006', website: 'https://www.gov.br/mre/pt-br/embaixada-abu-dhabi', lat: 24.4700, lng: 54.3700),
  Embassy(flag: '\u{1F1E7}\u{1F1F7}', name: 'Brazilian Consulate — Dubai', nationality: 'BRAZIL', country: 'UAE', address: 'Business Bay, Dubai', phone: '+971 4 361 6600', website: 'https://www.gov.br/mre/pt-br/consulado-dubai', lat: 25.1850, lng: 55.2620),
  Embassy(flag: '\u{1F1E7}\u{1F1F7}', name: 'Brazilian Embassy — Tel Aviv', nationality: 'BRAZIL', country: 'Israel', address: '23 Yehuda Halevi St, Tel Aviv', phone: '+972 3 797 1500', website: 'https://www.gov.br/mre/pt-br/embaixada-tel-aviv', lat: 32.0640, lng: 34.7730),
  Embassy(flag: '\u{1F1E7}\u{1F1F7}', name: 'Brazilian Embassy — Riyadh', nationality: 'BRAZIL', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 488 0025', website: 'https://www.gov.br/mre/pt-br/embaixada-riade', lat: 24.6760, lng: 46.6250),
  Embassy(flag: '\u{1F1E7}\u{1F1F7}', name: 'Brazilian Embassy — Doha', nationality: 'BRAZIL', country: 'Qatar', address: 'West Bay, Doha', phone: '+974 4483 3700', website: 'https://www.gov.br/mre/pt-br/embaixada-doha', lat: 25.3280, lng: 51.4350),
  Embassy(flag: '\u{1F1E7}\u{1F1F7}', name: 'Brazilian Embassy — Kuwait', nationality: 'BRAZIL', country: 'Kuwait', address: 'Surra, Kuwait City', phone: '+965 2524 8284', website: 'https://www.gov.br/mre/pt-br/embaixada-kuwait', lat: 29.3400, lng: 47.9800),
  Embassy(flag: '\u{1F1E7}\u{1F1F7}', name: 'Brazilian Embassy — Amman', nationality: 'BRAZIL', country: 'Jordan', address: 'Deir Ghbar, Amman', phone: '+962 6 592 3441', website: 'https://www.gov.br/mre/pt-br/embaixada-ama', lat: 31.9550, lng: 35.8700),
  // ═══════ INDIA ═══════
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Embassy — Abu Dhabi', nationality: 'INDIA', country: 'UAE', address: 'Plot 10, Sector W-59/02, Abu Dhabi', phone: '+971 2 449 2700', emergency: '+971 50 648 3537', website: 'https://www.indembassyuae.gov.in/', lat: 24.4670, lng: 54.3710),
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Consulate — Dubai', nationality: 'INDIA', country: 'UAE', address: 'Al Hamriya, Khalid Bin Al Waleed Rd, Dubai', phone: '+971 4 397 1222', emergency: '+971 50 955 5531', website: 'https://cgidubai.gov.in/', lat: 25.2610, lng: 55.2960),
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Embassy — Tel Aviv', nationality: 'INDIA', country: 'Israel', address: '140 HaYarkon St, Tel Aviv', phone: '+972 3 691 4600', emergency: '+972 54 990 1434', website: 'https://www.indembassytlv.gov.in/', lat: 32.0860, lng: 34.7690),
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Embassy — Riyadh', nationality: 'INDIA', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 488 4144', emergency: '+966 11 488 4144', website: 'https://www.indianembassy.org.sa/', lat: 24.6780, lng: 46.6240),
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Consulate — Jeddah', nationality: 'INDIA', country: 'KSA', address: 'Al Hamra District, Jeddah', phone: '+966 12 672 1334', website: 'https://www.cgijeddah.gov.in/', lat: 21.5430, lng: 39.1730),
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Embassy — Manama', nationality: 'INDIA', country: 'Bahrain', address: 'Building 182, Road 2608, Adliya', phone: '+973 1771 2785', emergency: '+973 3944 3041', website: 'https://www.indianembassybahrain.gov.in/', lat: 26.2130, lng: 50.5870),
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Embassy — Doha', nationality: 'INDIA', country: 'Qatar', address: 'Diplomatic Area, West Bay, Doha', phone: '+974 4425 5777', emergency: '+974 5540 1017', website: 'https://www.indianembassyqatar.gov.in/', lat: 25.3260, lng: 51.4370),
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Embassy — Kuwait', nationality: 'INDIA', country: 'Kuwait', address: 'Diplomatic Enclave, Arabian Gulf St', phone: '+965 2225 3981', emergency: '+965 9422 3370', website: 'https://www.indembkwt.gov.in/', lat: 29.3690, lng: 47.9850),
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Embassy — Muscat', nationality: 'INDIA', country: 'Oman', address: 'Diplomatic Area, Jami Al Akbar St, Muscat', phone: '+968 2468 4500', emergency: '+968 9439 0895', website: 'https://www.indemb-oman.gov.in/', lat: 23.5880, lng: 58.4070),
  Embassy(flag: '\u{1F1EE}\u{1F1F3}', name: 'Indian Embassy — Amman', nationality: 'INDIA', country: 'Jordan', address: '1st Circle, Jabal Amman', phone: '+962 6 462 2098', website: 'https://www.indianembassyamman.gov.in/', lat: 31.9530, lng: 35.9240),
  // ═══════ PHILIPPINES ═══════
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Embassy — Abu Dhabi', nationality: 'PHILIPPINES', country: 'UAE', address: 'Al Qubaisat, Abu Dhabi', phone: '+971 2 632 3478', emergency: '+971 56 501 1574', website: 'https://abudhabi.philembassy.ph/', lat: 24.4690, lng: 54.3540),
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Consulate — Dubai', nationality: 'PHILIPPINES', country: 'UAE', address: 'Al Qusais, Dubai', phone: '+971 4 220 7100', emergency: '+971 56 501 1574', website: 'https://dubaipcg.dfa.gov.ph/', lat: 25.2740, lng: 55.3780),
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Embassy — Tel Aviv', nationality: 'PHILIPPINES', country: 'Israel', address: '1 Ben Yehuda St, Tel Aviv', phone: '+972 3 510 0551', website: 'https://telaviv.philembassy.ph/', lat: 32.0670, lng: 34.7640),
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Embassy — Riyadh', nationality: 'PHILIPPINES', country: 'KSA', address: 'Diplomatic Quarter, Riyadh', phone: '+966 11 482 3559', emergency: '+966 54 803 0446', website: 'https://riyadhpe.dfa.gov.ph/', lat: 24.6770, lng: 46.6230),
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Consulate — Jeddah', nationality: 'PHILIPPINES', country: 'KSA', address: 'Al Rawdah District, Jeddah', phone: '+966 12 665 5737', website: 'https://jeddahpcg.dfa.gov.ph/', lat: 21.5370, lng: 39.1730),
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Embassy — Manama', nationality: 'PHILIPPINES', country: 'Bahrain', address: 'Villa 939, Road 3220, Mahooz', phone: '+973 1772 1234', website: 'https://manamape.dfa.gov.ph/', lat: 26.2120, lng: 50.5890),
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Embassy — Doha', nationality: 'PHILIPPINES', country: 'Qatar', address: 'Villa 22, Zone 66, West Bay Lagoon', phone: '+974 4483 5525', emergency: '+974 6685 3537', website: 'https://dohape.dfa.gov.ph/', lat: 25.3500, lng: 51.4290),
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Embassy — Kuwait', nationality: 'PHILIPPINES', country: 'Kuwait', address: 'Faiha, Kuwait City', phone: '+965 2253 4278', emergency: '+965 9760 8870', website: 'https://kuwaitpe.dfa.gov.ph/', lat: 29.3380, lng: 47.9970),
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Embassy — Muscat', nationality: 'PHILIPPINES', country: 'Oman', address: 'Shatti Al Qurum, Muscat', phone: '+968 2460 5152', website: 'https://muscatpe.dfa.gov.ph/', lat: 23.5980, lng: 58.4120),
  Embassy(flag: '\u{1F1F5}\u{1F1ED}', name: 'Philippine Embassy — Amman', nationality: 'PHILIPPINES', country: 'Jordan', address: 'Deir Ghbar, Amman', phone: '+962 6 592 2183', website: 'https://ammanpe.dfa.gov.ph/', lat: 31.9540, lng: 35.8690),
];
