// =============================================================================
// BRE4CH - Coalition Emergency Shelters
// Official shelter locations for all coalition countries
// Sources:
//   UAE: NCEMA (ncema.gov.ae), ADCDA, Dubai Civil Defence
//   Israel: Pikud HaOref / Home Front Command (oref.org.il)
//   KSA: General Directorate of Civil Defense (998.gov.sa)
//   Bahrain: NEMC — 33 confirmed shelters (bahrain.bh)
//   Kuwait: MOI Civil Defence — public shelter database (moi.gov.kw)
//   Qatar: GA Civil Defence (portal.moi.gov.qa)
//   Oman: PACDA (cdaa.gov.om)
//   Jordan: Civil Defense Directorate (psd.gov.jo)
// =============================================================================

import '../models/shelter.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🇦🇪  UAE — 45 shelters (NCEMA / Civil Defence)
// ═══════════════════════════════════════════════════════════════════════════════

const List<Shelter> _uaeShelters = [
  // ── Abu Dhabi (15) ──
  Shelter(id: 'ae-adnec', name: 'ADNEC — Abu Dhabi National Exhibition Centre', nameAr: 'مركز أبوظبي الوطني للمعارض', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Al Khaleej Al Arabi St', capacity: 5000, status: ShelterStatus.open, levels: 3, lat: 24.4539, lng: 54.6342, notes: '3 underground levels — NCEMA designated assembly point'),
  Shelter(id: 'ae-wahda-mall', name: 'Al Wahda Mall', nameAr: 'الوحدة مول', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Hazza Bin Zayed St', capacity: 3500, status: ShelterStatus.open, levels: 2, lat: 24.4688, lng: 54.3731, notes: '2 underground parking levels — reinforced structure'),
  Shelter(id: 'ae-galleria', name: 'The Galleria Al Maryah Island', nameAr: 'ذا غاليريا جزيرة المارية', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Al Maryah Island', capacity: 2800, status: ShelterStatus.open, levels: 3, lat: 24.5025, lng: 54.3893, notes: '3 UG levels — Al Maryah Island district shelter'),
  Shelter(id: 'ae-wtc', name: 'World Trade Center Abu Dhabi', nameAr: 'مركز التجارة العالمي أبوظبي', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.basement, district: 'Al Markaziyah', capacity: 2000, status: ShelterStatus.open, levels: 4, lat: 24.4870, lng: 54.3555, notes: '4 basement levels — central district, near Corniche'),
  Shelter(id: 'ae-etihad', name: 'Etihad Towers Complex', nameAr: 'أبراج الاتحاد', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Corniche West', capacity: 1800, status: ShelterStatus.open, levels: 3, lat: 24.4624, lng: 54.3282, notes: '3 UG parking levels — 5 tower complex'),
  Shelter(id: 'ae-yas-mall', name: 'Yas Mall', nameAr: 'ياس مول', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Yas Island', capacity: 4000, status: ShelterStatus.standby, levels: 2, lat: 24.4889, lng: 54.6078, notes: '2 UG levels — Yas Island main shelter point'),
  Shelter(id: 'ae-landmark', name: 'The Landmark Tower', nameAr: 'برج اللاند مارك', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Corniche Rd', capacity: 1200, status: ShelterStatus.open, levels: 5, lat: 24.4923, lng: 54.3681, notes: '5 UG parking levels — deepest shelter in Abu Dhabi'),
  Shelter(id: 'ae-capital-gate', name: 'Capital Gate / ADNOC HQ', nameAr: 'بوابة العاصمة / أدنوك', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.basement, district: 'Al Safarat', capacity: 1500, status: ShelterStatus.open, levels: 2, lat: 24.4527, lng: 54.6364, notes: '2 reinforced basement levels — government district'),
  Shelter(id: 'ae-marina-mall', name: 'Marina Mall', nameAr: 'مارينا مول', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Breakwater', capacity: 2200, status: ShelterStatus.open, levels: 2, lat: 24.4764, lng: 54.3232, notes: '2 UG levels — Breakwater district assembly point'),
  Shelter(id: 'ae-mushrif', name: 'Mushrif Mall', nameAr: 'مشرف مول', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Mushrif', capacity: 1800, status: ShelterStatus.standby, levels: 2, lat: 24.4398, lng: 54.4342, notes: '2 UG levels — eastern Abu Dhabi shelter'),
  Shelter(id: 'ae-ncema', name: 'NCEMA Emergency Operations Center', nameAr: 'مركز عمليات الطوارئ — الهيئة الوطنية', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.bunker, district: 'Al Bateen', capacity: 500, status: ShelterStatus.open, levels: 2, lat: 24.4624, lng: 54.3473, notes: 'Hardened bunker — NCEMA national operations center'),
  Shelter(id: 'ae-adcda', name: 'Abu Dhabi Civil Defence Authority HQ', nameAr: 'هيئة أبوظبي للدفاع المدني', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.bunker, district: 'Al Nahyan', capacity: 300, status: ShelterStatus.open, levels: 1, lat: 24.4703, lng: 54.3807, notes: 'Civil defence command — emergency coordination'),
  Shelter(id: 'ae-alain-mall', name: 'Al Ain Mall', nameAr: 'العين مول', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Al Ain — Othman Bin Affan St', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 24.2167, lng: 55.7253, notes: '2 UG levels — Al Ain main shelter, NCEMA designated'),
  Shelter(id: 'ae-bawadi', name: 'Bawadi Mall', nameAr: 'بوادي مول', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Al Ain — Bawadi', capacity: 1800, status: ShelterStatus.open, levels: 2, lat: 24.1919, lng: 55.7480, notes: '2 UG parking — eastern Al Ain shelter'),
  Shelter(id: 'ae-jimi', name: 'Al Jimi Mall', nameAr: 'الجيمي مول', country: ShelterCountry.uae, region: 'Abu Dhabi', type: ShelterType.underground, district: 'Al Ain — Al Jimi', capacity: 1400, status: ShelterStatus.standby, levels: 1, lat: 24.2319, lng: 55.7533, notes: '1 UG level — northern Al Ain shelter point'),
  // ── Dubai (12) ──
  Shelter(id: 'ae-dubai-mall', name: 'The Dubai Mall', nameAr: 'دبي مول', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.underground, district: 'Downtown Dubai', capacity: 8000, status: ShelterStatus.open, levels: 4, lat: 25.1972, lng: 55.2796, notes: '4 UG parking levels — largest shelter capacity in UAE'),
  Shelter(id: 'ae-moe', name: 'Mall of the Emirates', nameAr: 'مول الإمارات', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.underground, district: 'Al Barsha', capacity: 5000, status: ShelterStatus.open, levels: 3, lat: 25.1181, lng: 55.2006, notes: '3 UG levels — Al Barsha district assembly point'),
  Shelter(id: 'ae-ibn-battuta', name: 'Ibn Battuta Mall', nameAr: 'ابن بطوطة مول', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.underground, district: 'Jebel Ali', capacity: 3500, status: ShelterStatus.open, levels: 2, lat: 25.0441, lng: 55.1189, notes: '2 UG levels — Jebel Ali district shelter'),
  Shelter(id: 'ae-difc', name: 'Dubai International Financial Centre', nameAr: 'مركز دبي المالي العالمي', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.basement, district: 'DIFC', capacity: 3000, status: ShelterStatus.open, levels: 4, lat: 25.2100, lng: 55.2788, notes: '4 reinforced basement levels — DIFC district'),
  Shelter(id: 'ae-dwtc', name: 'Dubai World Trade Centre', nameAr: 'مركز دبي التجاري العالمي', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.basement, district: 'Trade Centre', capacity: 4000, status: ShelterStatus.open, levels: 3, lat: 25.2285, lng: 55.2868, notes: '3 basement levels — central Dubai shelter'),
  Shelter(id: 'ae-marina-mall-dxb', name: 'Dubai Marina Mall', nameAr: 'دبي مارينا مول', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.underground, district: 'Dubai Marina', capacity: 2800, status: ShelterStatus.open, levels: 3, lat: 25.0765, lng: 55.1394, notes: '3 UG levels — Marina district shelter'),
  Shelter(id: 'ae-deira-cc', name: 'Deira City Centre', nameAr: 'ديرة سيتي سنتر', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.underground, district: 'Deira', capacity: 3000, status: ShelterStatus.open, levels: 2, lat: 25.2525, lng: 55.3310, notes: '2 UG levels — eastern Dubai main shelter'),
  Shelter(id: 'ae-mirdif', name: 'Mirdif City Centre', nameAr: 'مردف سيتي سنتر', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.underground, district: 'Mirdif', capacity: 2200, status: ShelterStatus.open, levels: 2, lat: 25.2153, lng: 55.4078, notes: '2 UG levels — Mirdif area shelter'),
  Shelter(id: 'ae-ghurair', name: 'Al Ghurair Centre', nameAr: 'مركز الغرير', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.underground, district: 'Al Rigga', capacity: 2500, status: ShelterStatus.standby, levels: 2, lat: 25.2671, lng: 55.3107, notes: '2 UG levels — Deira district backup shelter'),
  Shelter(id: 'ae-dubai-cd', name: 'Dubai Civil Defence HQ', nameAr: 'القيادة العامة للدفاع المدني دبي', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.bunker, district: 'Al Qusais', capacity: 400, status: ShelterStatus.open, levels: 2, lat: 25.2669, lng: 55.3838, notes: 'Hardened bunker — Dubai CD emergency coordination'),
  Shelter(id: 'ae-dragon-mart', name: 'Dragon Mart', nameAr: 'دراغون مارت', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.underground, district: 'International City', capacity: 3000, status: ShelterStatus.standby, levels: 1, lat: 25.1681, lng: 55.4131, notes: '1 UG level — International City area shelter'),
  Shelter(id: 'ae-nakheel', name: 'Nakheel Mall — Palm Jumeirah', nameAr: 'نخيل مول — نخلة جميرا', country: ShelterCountry.uae, region: 'Dubai', type: ShelterType.underground, district: 'Palm Jumeirah', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 25.1124, lng: 55.1380, notes: '2 UG levels — Palm Jumeirah shelter point'),
  // ── Sharjah (5) ──
  Shelter(id: 'ae-sahara', name: 'Sahara Centre', nameAr: 'مركز صحارى', country: ShelterCountry.uae, region: 'Sharjah', type: ShelterType.underground, district: 'Al Nahda', capacity: 3500, status: ShelterStatus.open, levels: 2, lat: 25.3097, lng: 55.3758, notes: '2 UG levels — Sharjah main shelter facility'),
  Shelter(id: 'ae-sharjah-cc', name: 'Sharjah City Centre', nameAr: 'الشارقة سيتي سنتر', country: ShelterCountry.uae, region: 'Sharjah', type: ShelterType.underground, district: 'Al Wahda St', capacity: 2800, status: ShelterStatus.open, levels: 2, lat: 25.3266, lng: 55.3932, notes: '2 UG levels — central Sharjah shelter'),
  Shelter(id: 'ae-mega-mall', name: 'Mega Mall', nameAr: 'ميجا مول', country: ShelterCountry.uae, region: 'Sharjah', type: ShelterType.underground, district: 'Al Taawun', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 25.3183, lng: 55.3767, notes: '2 UG parking levels — Al Taawun area'),
  Shelter(id: 'ae-zero6', name: 'Zero6 Mall', nameAr: 'زيرو6 مول', country: ShelterCountry.uae, region: 'Sharjah', type: ShelterType.underground, district: 'Al Juraina', capacity: 1500, status: ShelterStatus.standby, levels: 1, lat: 25.3411, lng: 55.4128, notes: '1 UG level — eastern Sharjah shelter'),
  Shelter(id: 'ae-sharjah-cd', name: 'Sharjah Civil Defence HQ', nameAr: 'الدفاع المدني الشارقة', country: ShelterCountry.uae, region: 'Sharjah', type: ShelterType.bunker, district: 'Al Majaz', capacity: 300, status: ShelterStatus.open, levels: 1, lat: 25.3371, lng: 55.3867, notes: 'Hardened facility — Sharjah CD coordination'),
  // ── Ajman (3) ──
  Shelter(id: 'ae-ajman-cc', name: 'Ajman City Centre', nameAr: 'عجمان سيتي سنتر', country: ShelterCountry.uae, region: 'Ajman', type: ShelterType.underground, district: 'Sheikh Khalifa Bin Zayed St', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 25.4052, lng: 55.4345, notes: '2 UG levels — main Ajman shelter facility'),
  Shelter(id: 'ae-ajman-mall', name: 'Ajman Al Nuaimia Mall', nameAr: 'مول النعيمية عجمان', country: ShelterCountry.uae, region: 'Ajman', type: ShelterType.underground, district: 'Al Nuaimia', capacity: 1200, status: ShelterStatus.open, levels: 1, lat: 25.3941, lng: 55.4418, notes: '1 UG level — Al Nuaimia area shelter'),
  Shelter(id: 'ae-ajman-cd', name: 'Ajman Civil Defence HQ', nameAr: 'الدفاع المدني عجمان', country: ShelterCountry.uae, region: 'Ajman', type: ShelterType.bunker, district: 'Al Rashidiya', capacity: 200, status: ShelterStatus.open, levels: 1, lat: 25.4142, lng: 55.4478, notes: 'CD command facility — emergency coordination'),
  // ── RAK (4) ──
  Shelter(id: 'ae-rak-mall', name: 'RAK Mall', nameAr: 'راك مول', country: ShelterCountry.uae, region: 'Ras Al Khaimah', type: ShelterType.underground, district: 'Khuzam', capacity: 1800, status: ShelterStatus.open, levels: 1, lat: 25.7617, lng: 55.9500, notes: '1 UG level — RAK main shelter facility'),
  Shelter(id: 'ae-manar', name: 'Manar Mall', nameAr: 'المنار مول', country: ShelterCountry.uae, region: 'Ras Al Khaimah', type: ShelterType.underground, district: 'Al Nakheel', capacity: 2200, status: ShelterStatus.open, levels: 2, lat: 25.7881, lng: 55.9623, notes: '2 UG levels — central RAK district shelter'),
  Shelter(id: 'ae-rak-cd', name: 'RAK Civil Defence HQ', nameAr: 'الدفاع المدني رأس الخيمة', country: ShelterCountry.uae, region: 'Ras Al Khaimah', type: ShelterType.bunker, district: 'Al Nakheel', capacity: 200, status: ShelterStatus.open, levels: 1, lat: 25.7837, lng: 55.9587, notes: 'CD command — RAK emergency operations'),
  Shelter(id: 'ae-hamra', name: 'Al Hamra Mall', nameAr: 'الحمراء مول', country: ShelterCountry.uae, region: 'Ras Al Khaimah', type: ShelterType.basement, district: 'Al Hamra Village', capacity: 1000, status: ShelterStatus.standby, levels: 1, lat: 25.6791, lng: 55.7851, notes: '1 basement level — southern RAK shelter'),
  // ── Fujairah (3) ──
  Shelter(id: 'ae-fujairah-cc', name: 'Fujairah City Centre', nameAr: 'الفجيرة سيتي سنتر', country: ShelterCountry.uae, region: 'Fujairah', type: ShelterType.underground, district: 'Hamad Bin Abdullah Rd', capacity: 1800, status: ShelterStatus.open, levels: 2, lat: 25.1285, lng: 56.3377, notes: '2 UG levels — Fujairah main shelter'),
  Shelter(id: 'ae-fujairah-mall', name: 'Fujairah Mall', nameAr: 'الفجيرة مول', country: ShelterCountry.uae, region: 'Fujairah', type: ShelterType.underground, district: 'Al Faseel', capacity: 1200, status: ShelterStatus.open, levels: 1, lat: 25.1204, lng: 56.3306, notes: '1 UG level — Al Faseel district shelter'),
  Shelter(id: 'ae-fujairah-cd', name: 'Fujairah Civil Defence HQ', nameAr: 'الدفاع المدني الفجيرة', country: ShelterCountry.uae, region: 'Fujairah', type: ShelterType.bunker, district: 'Fujairah City', capacity: 200, status: ShelterStatus.open, levels: 1, lat: 25.1255, lng: 56.3400, notes: 'CD command — Fujairah emergency operations'),
  // ── UAQ (2) ──
  Shelter(id: 'ae-uaq-mall', name: 'UAQ Mall', nameAr: 'مول أم القيوين', country: ShelterCountry.uae, region: 'Umm Al Quwain', type: ShelterType.underground, district: 'King Faisal Rd', capacity: 1200, status: ShelterStatus.open, levels: 1, lat: 25.5512, lng: 55.5553, notes: '1 UG level — UAQ main shelter facility'),
  Shelter(id: 'ae-uaq-cd', name: 'UAQ Civil Defence HQ', nameAr: 'الدفاع المدني أم القيوين', country: ShelterCountry.uae, region: 'Umm Al Quwain', type: ShelterType.bunker, district: 'UAQ City', capacity: 150, status: ShelterStatus.open, levels: 1, lat: 25.5642, lng: 55.5548, notes: 'CD command — UAQ emergency coordination'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// 🇮🇱  ISRAEL — Pikud HaOref public shelters (miklat)
//     Source: oref.org.il — Home Front Command
//     Emergency: 104
// ═══════════════════════════════════════════════════════════════════════════════

const List<Shelter> _israelShelters = [
  // ── Tel Aviv District ──
  Shelter(id: 'il-dizengoff', name: 'Dizengoff Center Underground Shelter', nameAr: 'ملجأ مركز ديزنغوف', country: ShelterCountry.israel, region: 'Tel Aviv', type: ShelterType.publicShelter, district: 'Dizengoff St', capacity: 5000, status: ShelterStatus.open, levels: 3, lat: 32.0753, lng: 34.7748, notes: 'Major public miklat — 3 levels below Dizengoff Center'),
  Shelter(id: 'il-tbs', name: 'Tel Aviv Central Bus Station Shelter', nameAr: 'ملجأ محطة الحافلات المركزية', country: ShelterCountry.israel, region: 'Tel Aviv', type: ShelterType.publicShelter, district: 'Neve Sha\'anan', capacity: 3000, status: ShelterStatus.open, levels: 2, lat: 32.0561, lng: 34.7725, notes: '2 basement levels — designated public miklat'),
  Shelter(id: 'il-azrieli', name: 'Azrieli Center', nameAr: 'مركز عزرائيلي', country: ShelterCountry.israel, region: 'Tel Aviv', type: ShelterType.underground, district: 'Derech Menachem Begin', capacity: 4000, status: ShelterStatus.open, levels: 3, lat: 32.0741, lng: 34.7921, notes: '3 UG parking levels — Azrieli complex, major shelter'),
  Shelter(id: 'il-rabin-sq', name: 'Rabin Square Underground Shelter', nameAr: 'ملجأ ساحة رابين', country: ShelterCountry.israel, region: 'Tel Aviv', type: ShelterType.publicShelter, district: 'Rabin Square', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 32.0809, lng: 34.7806, notes: 'Public miklat beneath Rabin Square — HFC designated'),
  Shelter(id: 'il-hatachana', name: 'HaTachana Complex Shelter', nameAr: 'ملجأ مجمع هتحنا', country: ShelterCountry.israel, region: 'Tel Aviv', type: ShelterType.basement, district: 'Neve Tzedek', capacity: 1500, status: ShelterStatus.open, levels: 1, lat: 32.0589, lng: 34.7647, notes: 'Reinforced basement — southern Tel Aviv shelter point'),
  Shelter(id: 'il-sarona', name: 'Sarona Market Underground', nameAr: 'ملجأ سوق سارونا', country: ShelterCountry.israel, region: 'Tel Aviv', type: ShelterType.underground, district: 'Sarona, Kaplan St', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 32.0720, lng: 34.7870, notes: '2 UG levels — Sarona complex shelter'),
  // ── Jerusalem District ──
  Shelter(id: 'il-mamilla', name: 'Mamilla Mall Underground', nameAr: 'ملجأ ماميلا', country: ShelterCountry.israel, region: 'Jerusalem', type: ShelterType.underground, district: 'Mamilla, Alrov', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 31.7781, lng: 35.2249, notes: '2 UG levels — Jaffa Gate area public shelter'),
  Shelter(id: 'il-malha', name: 'Malha Mall Shelter', nameAr: 'ملجأ مول مالحة', country: ShelterCountry.israel, region: 'Jerusalem', type: ShelterType.underground, district: 'Malha', capacity: 3000, status: ShelterStatus.open, levels: 2, lat: 31.7517, lng: 35.1876, notes: '2 UG parking levels — southern Jerusalem main shelter'),
  Shelter(id: 'il-jlm-cbs', name: 'Jerusalem Central Bus Station', nameAr: 'محطة القدس المركزية', country: ShelterCountry.israel, region: 'Jerusalem', type: ShelterType.publicShelter, district: 'Jaffa Road', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 31.7889, lng: 35.2036, notes: 'Public miklat — 2 reinforced basement levels'),
  // ── Haifa District ──
  Shelter(id: 'il-haifa-grand', name: 'Grand Canyon Haifa', nameAr: 'غراند كانيون حيفا', country: ShelterCountry.israel, region: 'Haifa', type: ShelterType.underground, district: 'Simha Golan St', capacity: 3500, status: ShelterStatus.open, levels: 3, lat: 32.7769, lng: 35.0217, notes: '3 UG levels — Haifa main public shelter'),
  Shelter(id: 'il-haifa-port', name: 'Haifa Port Underground Shelter', nameAr: 'ملجأ ميناء حيفا', country: ShelterCountry.israel, region: 'Haifa', type: ShelterType.bunker, district: 'Haifa Port', capacity: 1500, status: ShelterStatus.open, levels: 2, lat: 32.8198, lng: 34.9886, notes: 'Hardened shelter — Haifa port district'),
  Shelter(id: 'il-carmel-center', name: 'Carmel Center Shelter', nameAr: 'ملجأ مركز الكرمل', country: ShelterCountry.israel, region: 'Haifa', type: ShelterType.publicShelter, district: 'HaNassi Blvd', capacity: 1200, status: ShelterStatus.open, levels: 1, lat: 32.7584, lng: 34.9803, notes: 'Public miklat — Carmel Center neighborhood'),
  // ── Beer Sheva ──
  Shelter(id: 'il-beersh-grand', name: 'Grand Canyon Beer Sheva', nameAr: 'غراند كانيون بئر السبع', country: ShelterCountry.israel, region: 'Beer Sheva', type: ShelterType.underground, district: 'Derech Hebron', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 31.2464, lng: 34.7886, notes: '2 UG levels — Negev main shelter facility'),
  Shelter(id: 'il-bgu', name: 'Ben Gurion University Shelter Complex', nameAr: 'ملجأ جامعة بن غوريون', country: ShelterCountry.israel, region: 'Beer Sheva', type: ShelterType.publicShelter, district: 'BGU Campus', capacity: 2000, status: ShelterStatus.open, levels: 1, lat: 31.2614, lng: 34.7995, notes: 'Campus-wide shelter system — reinforced buildings'),
  // ── Ashdod / Ashkelon ──
  Shelter(id: 'il-ashdod-mall', name: 'Ashdod Lev HaIr Mall', nameAr: 'ملجأ مول أشدود', country: ShelterCountry.israel, region: 'Ashdod', type: ShelterType.underground, district: 'HaAtzmaut Blvd', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 31.8040, lng: 34.6553, notes: '2 UG levels — Ashdod central shelter'),
  Shelter(id: 'il-ashkelon-marina', name: 'Ashkelon Marina Shelter', nameAr: 'ملجأ مارينا عسقلان', country: ShelterCountry.israel, region: 'Ashkelon', type: ShelterType.publicShelter, district: 'Marina District', capacity: 1000, status: ShelterStatus.open, levels: 1, lat: 31.6690, lng: 34.5571, notes: 'Public miklat — southern coast shelter'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// 🇸🇦  SAUDI ARABIA — General Directorate of Civil Defense
//     Source: 998.gov.sa, moi.gov.sa
//     Emergency: 998 / 911 (Riyadh & Makkah)
// ═══════════════════════════════════════════════════════════════════════════════

const List<Shelter> _ksaShelters = [
  // ── Riyadh ──
  Shelter(id: 'sa-riyadh-gallery', name: 'Riyadh Gallery Mall', nameAr: 'الرياض غاليري', country: ShelterCountry.ksa, region: 'Riyadh', type: ShelterType.underground, district: 'King Fahd Rd', capacity: 4000, status: ShelterStatus.open, levels: 3, lat: 24.7116, lng: 46.6753, notes: '3 UG levels — central Riyadh main shelter'),
  Shelter(id: 'sa-kingdom-tower', name: 'Kingdom Centre', nameAr: 'برج المملكة', country: ShelterCountry.ksa, region: 'Riyadh', type: ShelterType.underground, district: 'Olaya, King Fahd Rd', capacity: 2500, status: ShelterStatus.open, levels: 3, lat: 24.7112, lng: 46.6745, notes: '3 reinforced UG levels — Kingdom Tower complex'),
  Shelter(id: 'sa-granada', name: 'Granada Center', nameAr: 'مركز غرناطة', country: ShelterCountry.ksa, region: 'Riyadh', type: ShelterType.underground, district: 'Eastern Ring Rd', capacity: 3000, status: ShelterStatus.open, levels: 2, lat: 24.7589, lng: 46.7350, notes: '2 UG levels — east Riyadh shelter point'),
  Shelter(id: 'sa-panorama', name: 'Panorama Mall', nameAr: 'بانوراما مول', country: ShelterCountry.ksa, region: 'Riyadh', type: ShelterType.underground, district: 'Tahlia St', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 24.6959, lng: 46.6836, notes: '2 UG levels — Tahlia district'),
  Shelter(id: 'sa-riyadh-metro', name: 'Riyadh Metro — KAFD Station', nameAr: 'محطة مترو كافد', country: ShelterCountry.ksa, region: 'Riyadh', type: ShelterType.underground, district: 'King Abdullah Financial District', capacity: 5000, status: ShelterStatus.open, levels: 2, lat: 24.7672, lng: 46.6398, notes: 'Deep underground metro station — major shelter capacity'),
  Shelter(id: 'sa-cd-riyadh', name: 'Civil Defense HQ — Riyadh', nameAr: 'الدفاع المدني — الرياض', country: ShelterCountry.ksa, region: 'Riyadh', type: ShelterType.bunker, district: 'Al Malaz', capacity: 500, status: ShelterStatus.open, levels: 2, lat: 24.6735, lng: 46.7287, notes: 'Hardened CD command — Riyadh operations center'),
  // ── Jeddah ──
  Shelter(id: 'sa-red-sea-mall', name: 'Red Sea Mall', nameAr: 'ردسي مول', country: ShelterCountry.ksa, region: 'Jeddah', type: ShelterType.underground, district: 'King Abdulaziz Rd', capacity: 4000, status: ShelterStatus.open, levels: 2, lat: 21.6177, lng: 39.1134, notes: '2 UG levels — Jeddah main shelter facility'),
  Shelter(id: 'sa-mall-of-arabia', name: 'Mall of Arabia', nameAr: 'مول العرب', country: ShelterCountry.ksa, region: 'Jeddah', type: ShelterType.underground, district: 'Al Muhammadiyah', capacity: 3500, status: ShelterStatus.open, levels: 2, lat: 21.6089, lng: 39.1469, notes: '2 UG levels — western Jeddah shelter'),
  Shelter(id: 'sa-jeddah-hsr', name: 'Jeddah Haramain Station', nameAr: 'محطة جدة للحرمين', country: ShelterCountry.ksa, region: 'Jeddah', type: ShelterType.underground, district: 'Al Sulaymaniyah', capacity: 3000, status: ShelterStatus.open, levels: 1, lat: 21.5625, lng: 39.1813, notes: 'High-speed rail station — reinforced underground'),
  // ── Dhahran / Dammam ──
  Shelter(id: 'sa-dhahran-mall', name: 'Dhahran Mall', nameAr: 'مول الظهران', country: ShelterCountry.ksa, region: 'Dhahran', type: ShelterType.underground, district: 'Dhahran', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 26.2900, lng: 50.1368, notes: '2 UG levels — Eastern Province main shelter'),
  Shelter(id: 'sa-nakheel-mall', name: 'Al Nakheel Mall', nameAr: 'النخيل مول', country: ShelterCountry.ksa, region: 'Dammam', type: ShelterType.underground, district: 'King Fahd Rd, Dammam', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 26.4284, lng: 50.0931, notes: '2 UG levels — Dammam city shelter point'),
  Shelter(id: 'sa-cd-eastern', name: 'Civil Defense — Eastern Province', nameAr: 'الدفاع المدني — المنطقة الشرقية', country: ShelterCountry.ksa, region: 'Dammam', type: ShelterType.bunker, district: 'Dammam', capacity: 400, status: ShelterStatus.open, levels: 1, lat: 26.4345, lng: 50.1010, notes: 'CD coordination — critical infrastructure protection'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// 🇧🇭  BAHRAIN — NEMC (33 confirmed shelters across 5 governorates)
//     Source: bahrain.bh, NEMC public confirmation
//     Emergency: 999
// ═══════════════════════════════════════════════════════════════════════════════

const List<Shelter> _bahrainShelters = [
  // ── Capital Governorate ──
  Shelter(id: 'bh-city-centre', name: 'Bahrain City Centre', nameAr: 'البحرين سيتي سنتر', country: ShelterCountry.bahrain, region: 'Capital', type: ShelterType.underground, district: 'Seef District', capacity: 3000, status: ShelterStatus.open, levels: 2, lat: 26.2295, lng: 50.5340, notes: '2 UG levels — Seef main shelter, NEMC designated'),
  Shelter(id: 'bh-seef-mall', name: 'The Avenues — Bahrain', nameAr: 'ذا أفنيوز — البحرين', country: ShelterCountry.bahrain, region: 'Capital', type: ShelterType.underground, district: 'Seef District', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 26.2230, lng: 50.5290, notes: '2 UG levels — Seef district shelter'),
  Shelter(id: 'bh-bfh', name: 'Bahrain Financial Harbour', nameAr: 'مرفأ البحرين المالي', country: ShelterCountry.bahrain, region: 'Capital', type: ShelterType.basement, district: 'King Faisal Hwy', capacity: 2000, status: ShelterStatus.open, levels: 3, lat: 26.2382, lng: 50.5472, notes: '3 reinforced basement levels — financial district'),
  Shelter(id: 'bh-wtc', name: 'World Trade Center Bahrain', nameAr: 'مركز التجارة العالمي', country: ShelterCountry.bahrain, region: 'Capital', type: ShelterType.basement, district: 'King Faisal Hwy', capacity: 1500, status: ShelterStatus.open, levels: 2, lat: 26.2417, lng: 50.5497, notes: '2 basement levels — Manama central shelter'),
  Shelter(id: 'bh-cd-manama', name: 'NEMC Operations Center', nameAr: 'مركز إدارة الأزمات الوطني', country: ShelterCountry.bahrain, region: 'Capital', type: ShelterType.bunker, district: 'Manama', capacity: 500, status: ShelterStatus.open, levels: 2, lat: 26.2271, lng: 50.5876, notes: 'Hardened NEMC command — national emergency operations'),
  // ── Muharraq Governorate ──
  Shelter(id: 'bh-dragon-city', name: 'Dragon City Bahrain', nameAr: 'مدينة التنين', country: ShelterCountry.bahrain, region: 'Muharraq', type: ShelterType.underground, district: 'Diyar Al Muharraq', capacity: 2000, status: ShelterStatus.open, levels: 1, lat: 26.2750, lng: 50.6260, notes: '1 UG level — Muharraq shelter facility'),
  Shelter(id: 'bh-muharraq-school', name: 'Muharraq Public Shelter #1', nameAr: 'ملجأ المحرق العام 1', country: ShelterCountry.bahrain, region: 'Muharraq', type: ShelterType.publicShelter, district: 'Muharraq City', capacity: 800, status: ShelterStatus.open, levels: 1, lat: 26.2573, lng: 50.6119, notes: 'NEMC designated community shelter — equipped facilities'),
  // ── Northern Governorate ──
  Shelter(id: 'bh-atrium-mall', name: 'Atrium Mall', nameAr: 'أتريوم مول', country: ShelterCountry.bahrain, region: 'Northern', type: ShelterType.underground, district: 'Saar', capacity: 1500, status: ShelterStatus.open, levels: 1, lat: 26.1850, lng: 50.5020, notes: '1 UG level — Saar area shelter'),
  Shelter(id: 'bh-north-shelter1', name: 'Northern Gov. Public Shelter #1', nameAr: 'ملجأ المحافظة الشمالية 1', country: ShelterCountry.bahrain, region: 'Northern', type: ShelterType.publicShelter, district: 'A\'ali', capacity: 600, status: ShelterStatus.open, levels: 1, lat: 26.1658, lng: 50.5268, notes: 'NEMC designated — community hall with emergency provisions'),
  // ── Southern Governorate ──
  Shelter(id: 'bh-riffa-mall', name: 'Riffa Views — Town Centre', nameAr: 'رفاع فيوز', country: ShelterCountry.bahrain, region: 'Southern', type: ShelterType.underground, district: 'Riffa', capacity: 1200, status: ShelterStatus.open, levels: 1, lat: 26.1264, lng: 50.5553, notes: '1 UG level — Riffa district shelter'),
  Shelter(id: 'bh-isa-town', name: 'Isa Town Public Shelter', nameAr: 'ملجأ مدينة عيسى', country: ShelterCountry.bahrain, region: 'Southern', type: ShelterType.publicShelter, district: 'Isa Town', capacity: 800, status: ShelterStatus.open, levels: 1, lat: 26.1728, lng: 50.5478, notes: 'NEMC designated — multipurpose facility with supplies'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// 🇰🇼  KUWAIT — MOI Civil Defence (public shelter database)
//     Source: moi.gov.kw/main/eservices/civildefence/shelters
//     Emergency: 112
// ═══════════════════════════════════════════════════════════════════════════════

const List<Shelter> _kuwaitShelters = [
  // ── Al-Asima (Capital) ──
  Shelter(id: 'kw-avenues', name: 'The Avenues Mall', nameAr: 'مجمع الأفنيوز', country: ShelterCountry.kuwait, region: 'Al-Asima', type: ShelterType.underground, district: 'Al Rai', capacity: 5000, status: ShelterStatus.open, levels: 3, lat: 29.3376, lng: 47.9484, notes: '3 UG levels — Kuwait largest shelter capacity'),
  Shelter(id: 'kw-360-mall', name: '360 Mall', nameAr: '360 مول', country: ShelterCountry.kuwait, region: 'Al-Asima', type: ShelterType.underground, district: 'South Surra', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 29.2987, lng: 48.0272, notes: '2 UG levels — South Surra shelter'),
  Shelter(id: 'kw-liberation', name: 'Kuwait Liberation Tower Shelter', nameAr: 'ملجأ برج التحرير', country: ShelterCountry.kuwait, region: 'Al-Asima', type: ShelterType.basement, district: 'Kuwait City', capacity: 1500, status: ShelterStatus.open, levels: 2, lat: 29.3760, lng: 47.9779, notes: '2 reinforced basement levels — Kuwait City center'),
  Shelter(id: 'kw-cd-hq', name: 'MOI Civil Defence HQ', nameAr: 'الدفاع المدني — وزارة الداخلية', country: ShelterCountry.kuwait, region: 'Al-Asima', type: ShelterType.bunker, district: 'Subhan', capacity: 500, status: ShelterStatus.open, levels: 2, lat: 29.2585, lng: 48.0471, notes: 'Hardened CD command — national coordination'),
  // ── Hawalli ──
  Shelter(id: 'kw-marina-mall', name: 'Marina Mall Kuwait', nameAr: 'مارينا مول', country: ShelterCountry.kuwait, region: 'Hawalli', type: ShelterType.underground, district: 'Salmiya', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 29.3377, lng: 48.0835, notes: '2 UG levels — Salmiya waterfront shelter'),
  Shelter(id: 'kw-mohallab', name: 'Al Mohallab Mall', nameAr: 'مول المهلب', country: ShelterCountry.kuwait, region: 'Hawalli', type: ShelterType.underground, district: 'Hawalli', capacity: 1800, status: ShelterStatus.open, levels: 2, lat: 29.3417, lng: 48.0340, notes: '2 UG levels — Hawalli district'),
  // ── Al-Ahmadi ──
  Shelter(id: 'kw-al-kout', name: 'Al Kout Mall', nameAr: 'مول الكوت', country: ShelterCountry.kuwait, region: 'Al-Ahmadi', type: ShelterType.underground, district: 'Fahaheel', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 29.0849, lng: 48.1335, notes: '2 UG levels — Fahaheel district shelter'),
  Shelter(id: 'kw-ahmadi-shelter', name: 'Al-Ahmadi Governorate Shelter', nameAr: 'ملجأ محافظة الأحمدي', country: ShelterCountry.kuwait, region: 'Al-Ahmadi', type: ShelterType.publicShelter, district: 'Ahmadi', capacity: 1000, status: ShelterStatus.open, levels: 1, lat: 29.0770, lng: 48.0838, notes: 'MOI listed public shelter — equipped facility'),
  // ── Al-Jahra ──
  Shelter(id: 'kw-jahra-mall', name: 'Al Jahra Shopping Center', nameAr: 'مركز الجهراء التجاري', country: ShelterCountry.kuwait, region: 'Al-Jahra', type: ShelterType.underground, district: 'Al Jahra', capacity: 1500, status: ShelterStatus.open, levels: 1, lat: 29.3375, lng: 47.6581, notes: '1 UG level — Al Jahra district shelter'),
  // ── Al-Farwaniya ──
  Shelter(id: 'kw-discovery', name: 'Discovery Mall', nameAr: 'ديسكفري مول', country: ShelterCountry.kuwait, region: 'Al-Farwaniya', type: ShelterType.underground, district: 'Al-Farwaniya', capacity: 1800, status: ShelterStatus.open, levels: 1, lat: 29.2834, lng: 47.9644, notes: '1 UG level — Farwaniya area shelter'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// 🇶🇦  QATAR — GA Civil Defence
//     Source: portal.moi.gov.qa
//     Emergency: 999
// ═══════════════════════════════════════════════════════════════════════════════

const List<Shelter> _qatarShelters = [
  Shelter(id: 'qa-villaggio', name: 'Villaggio Mall', nameAr: 'فيلاجيو مول', country: ShelterCountry.qatar, region: 'Doha', type: ShelterType.underground, district: 'Al Waab', capacity: 3000, status: ShelterStatus.open, levels: 2, lat: 25.2615, lng: 51.4420, notes: '2 UG levels — Al Waab district shelter'),
  Shelter(id: 'qa-mall-of-qatar', name: 'Mall of Qatar', nameAr: 'مول قطر', country: ShelterCountry.qatar, region: 'Doha', type: ShelterType.underground, district: 'Al Rayyan', capacity: 4000, status: ShelterStatus.open, levels: 3, lat: 25.3201, lng: 51.4098, notes: '3 UG levels — major Doha shelter capacity'),
  Shelter(id: 'qa-city-center', name: 'City Center Doha', nameAr: 'سيتي سنتر الدوحة', country: ShelterCountry.qatar, region: 'Doha', type: ShelterType.underground, district: 'West Bay', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 25.3199, lng: 51.5013, notes: '2 UG levels — West Bay shelter point'),
  Shelter(id: 'qa-doha-metro-msheireb', name: 'Doha Metro — Msheireb Station', nameAr: 'محطة مترو مشيرب', country: ShelterCountry.qatar, region: 'Doha', type: ShelterType.underground, district: 'Msheireb Downtown', capacity: 3500, status: ShelterStatus.open, levels: 2, lat: 25.2862, lng: 51.5288, notes: 'Deep underground metro hub — 3 lines interchange'),
  Shelter(id: 'qa-lusail-blvd', name: 'Place Vendome — Lusail', nameAr: 'بلاس فاندوم — لوسيل', country: ShelterCountry.qatar, region: 'Lusail', type: ShelterType.underground, district: 'Lusail Marina', capacity: 3000, status: ShelterStatus.open, levels: 2, lat: 25.4172, lng: 51.4907, notes: '2 UG levels — Lusail new city shelter'),
  Shelter(id: 'qa-cd-hq', name: 'Civil Defence HQ Doha', nameAr: 'الدفاع المدني — الدوحة', country: ShelterCountry.qatar, region: 'Doha', type: ShelterType.bunker, district: 'Al Sadd', capacity: 400, status: ShelterStatus.open, levels: 1, lat: 25.2818, lng: 51.5098, notes: 'CD command — emergency coordination center'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// 🇴🇲  OMAN — PACDA (Royal Oman Police)
//     Source: cdaa.gov.om
//     Emergency: 999
// ═══════════════════════════════════════════════════════════════════════════════

const List<Shelter> _omanShelters = [
  Shelter(id: 'om-oman-avenues', name: 'Oman Avenues Mall', nameAr: 'عمان أفنيوز مول', country: ShelterCountry.oman, region: 'Muscat', type: ShelterType.underground, district: 'Al Ghubra', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 23.5994, lng: 58.3810, notes: '2 UG levels — Muscat main shelter facility'),
  Shelter(id: 'om-city-centre', name: 'City Centre Muscat', nameAr: 'سيتي سنتر مسقط', country: ShelterCountry.oman, region: 'Muscat', type: ShelterType.underground, district: 'Al Qurum', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 23.5883, lng: 58.4103, notes: '2 UG levels — Al Qurum district shelter'),
  Shelter(id: 'om-grand-mall', name: 'Muscat Grand Mall', nameAr: 'مسقط غراند مول', country: ShelterCountry.oman, region: 'Muscat', type: ShelterType.underground, district: 'Al Ghubra', capacity: 1500, status: ShelterStatus.open, levels: 1, lat: 23.5930, lng: 58.3754, notes: '1 UG level — western Muscat shelter'),
  Shelter(id: 'om-pacda-hq', name: 'PACDA Headquarters', nameAr: 'الهيئة العامة للدفاع المدني والإسعاف', country: ShelterCountry.oman, region: 'Muscat', type: ShelterType.bunker, district: 'Bawshar', capacity: 400, status: ShelterStatus.open, levels: 1, lat: 23.5778, lng: 58.3430, notes: 'PACDA command — national emergency operations'),
  Shelter(id: 'om-sohar-shelter', name: 'Sohar Emergency Shelter', nameAr: 'ملجأ صحار', country: ShelterCountry.oman, region: 'Sohar', type: ShelterType.publicShelter, district: 'Sohar', capacity: 1000, status: ShelterStatus.standby, levels: 1, lat: 24.3644, lng: 56.7350, notes: 'PACDA planned shelter — under construction'),
  Shelter(id: 'om-sur-shelter', name: 'Sur Emergency Shelter', nameAr: 'ملجأ صور', country: ShelterCountry.oman, region: 'Sur', type: ShelterType.publicShelter, district: 'Sur', capacity: 800, status: ShelterStatus.standby, levels: 1, lat: 22.5667, lng: 59.5289, notes: 'PACDA planned shelter — under construction'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// 🇯🇴  JORDAN — Civil Defense Directorate (PSD)
//     Source: psd.gov.jo
//     Emergency: 911
// ═══════════════════════════════════════════════════════════════════════════════

const List<Shelter> _jordanShelters = [
  // ── Amman ──
  Shelter(id: 'jo-abdali-mall', name: 'Abdali Mall', nameAr: 'العبدلي مول', country: ShelterCountry.jordan, region: 'Amman', type: ShelterType.underground, district: 'Abdali Boulevard', capacity: 3000, status: ShelterStatus.open, levels: 3, lat: 31.9565, lng: 35.9131, notes: '3 UG levels — central Amman main shelter'),
  Shelter(id: 'jo-city-mall', name: 'City Mall Amman', nameAr: 'سيتي مول', country: ShelterCountry.jordan, region: 'Amman', type: ShelterType.underground, district: 'King Abdullah II St', capacity: 2500, status: ShelterStatus.open, levels: 2, lat: 31.9810, lng: 35.8460, notes: '2 UG levels — western Amman shelter'),
  Shelter(id: 'jo-mecca-mall', name: 'Mecca Mall', nameAr: 'مكة مول', country: ShelterCountry.jordan, region: 'Amman', type: ShelterType.underground, district: 'Mecca St', capacity: 2000, status: ShelterStatus.open, levels: 2, lat: 31.9563, lng: 35.8601, notes: '2 UG levels — Mecca St district shelter'),
  Shelter(id: 'jo-taj-mall', name: 'Taj Mall', nameAr: 'تاج مول', country: ShelterCountry.jordan, region: 'Amman', type: ShelterType.underground, district: 'Abdoun', capacity: 1800, status: ShelterStatus.open, levels: 2, lat: 31.9549, lng: 35.8944, notes: '2 UG levels — Abdoun district shelter'),
  Shelter(id: 'jo-cd-amman', name: 'Civil Defense HQ — Amman', nameAr: 'الدفاع المدني — عمان', country: ShelterCountry.jordan, region: 'Amman', type: ShelterType.bunker, district: 'Amman', capacity: 500, status: ShelterStatus.open, levels: 2, lat: 31.9539, lng: 35.9106, notes: 'CD command — emergency coordination, siren system active'),
  // ── Irbid ──
  Shelter(id: 'jo-arabella', name: 'Arabella Mall Irbid', nameAr: 'ارابيلا مول اربد', country: ShelterCountry.jordan, region: 'Irbid', type: ShelterType.underground, district: 'University St', capacity: 1500, status: ShelterStatus.open, levels: 1, lat: 32.5568, lng: 35.8500, notes: '1 UG level — northern Jordan shelter point'),
  // ── Aqaba ──
  Shelter(id: 'jo-aqaba-gateway', name: 'Aqaba Gateway Mall', nameAr: 'مول بوابة العقبة', country: ShelterCountry.jordan, region: 'Aqaba', type: ShelterType.underground, district: 'King Hussein Rd', capacity: 1200, status: ShelterStatus.open, levels: 1, lat: 29.5265, lng: 35.0076, notes: '1 UG level — Aqaba port district shelter'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// ALL COALITION SHELTERS
// ═══════════════════════════════════════════════════════════════════════════════

const List<Shelter> shelters = [
  ..._uaeShelters,
  ..._israelShelters,
  ..._ksaShelters,
  ..._bahrainShelters,
  ..._kuwaitShelters,
  ..._qatarShelters,
  ..._omanShelters,
  ..._jordanShelters,
];

/// Country filter labels for UI
const shelterCountryLabels = [
  'ALL',
  'UAE',
  'Israel',
  'KSA',
  'Bahrain',
  'Kuwait',
  'Qatar',
  'Oman',
  'Jordan',
];

/// Map display label → ShelterCountry enum
ShelterCountry? shelterCountryFromLabel(String label) {
  for (final c in ShelterCountry.values) {
    if (c.displayName == label) return c;
  }
  return null;
}
