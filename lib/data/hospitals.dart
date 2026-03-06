// =============================================================================
// BRE4CH - Regional Hospital, Clinic & Veterinary Database
// Medical facilities with emergency contacts and coordinates
// Countries: UAE, Israel, KSA, Bahrain, Qatar, Kuwait, Oman, Jordan, Lebanon
// =============================================================================

enum HospitalType { hospital, clinic, fieldHospital, veterinary }

enum HospitalCountry { uae, israel, ksa, bahrain, qatar, kuwait, oman, jordan, lebanon }

class Hospital {
  final String id;
  final String name;
  final String nameAr;
  final HospitalCountry country;
  final String city;
  final HospitalType type;
  final String phone;
  final String emergency;
  final double lat;
  final double lng;
  final String notes;

  const Hospital({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.country,
    required this.city,
    required this.type,
    required this.phone,
    this.emergency = '',
    required this.lat,
    required this.lng,
    this.notes = '',
  });
}

// =============================================================================
// Extensions
// =============================================================================

extension HospitalCountryExtension on HospitalCountry {
  String get displayName {
    switch (this) {
      case HospitalCountry.uae:
        return 'UAE';
      case HospitalCountry.israel:
        return 'Israel';
      case HospitalCountry.ksa:
        return 'KSA';
      case HospitalCountry.bahrain:
        return 'Bahrain';
      case HospitalCountry.qatar:
        return 'Qatar';
      case HospitalCountry.kuwait:
        return 'Kuwait';
      case HospitalCountry.oman:
        return 'Oman';
      case HospitalCountry.jordan:
        return 'Jordan';
      case HospitalCountry.lebanon:
        return 'Lebanon';
    }
  }

  String get flag {
    switch (this) {
      case HospitalCountry.uae:
        return '\u{1F1E6}\u{1F1EA}';
      case HospitalCountry.israel:
        return '\u{1F1EE}\u{1F1F1}';
      case HospitalCountry.ksa:
        return '\u{1F1F8}\u{1F1E6}';
      case HospitalCountry.bahrain:
        return '\u{1F1E7}\u{1F1ED}';
      case HospitalCountry.qatar:
        return '\u{1F1F6}\u{1F1E6}';
      case HospitalCountry.kuwait:
        return '\u{1F1F0}\u{1F1FC}';
      case HospitalCountry.oman:
        return '\u{1F1F4}\u{1F1F2}';
      case HospitalCountry.jordan:
        return '\u{1F1EF}\u{1F1F4}';
      case HospitalCountry.lebanon:
        return '\u{1F1F1}\u{1F1E7}';
    }
  }

  String get emergencyNumber {
    switch (this) {
      case HospitalCountry.uae:
        return '998';
      case HospitalCountry.israel:
        return '101';
      case HospitalCountry.ksa:
        return '997';
      case HospitalCountry.bahrain:
        return '999';
      case HospitalCountry.qatar:
        return '999';
      case HospitalCountry.kuwait:
        return '112';
      case HospitalCountry.oman:
        return '9999';
      case HospitalCountry.jordan:
        return '911';
      case HospitalCountry.lebanon:
        return '140';
    }
  }
}

extension HospitalTypeExtension on HospitalType {
  String get label {
    switch (this) {
      case HospitalType.hospital:
        return 'HOSPITAL';
      case HospitalType.clinic:
        return 'CLINIC';
      case HospitalType.fieldHospital:
        return 'FIELD';
      case HospitalType.veterinary:
        return 'VET';
    }
  }
}

// =============================================================================
// Filter labels
// =============================================================================

const hospitalCountryLabels = [
  'ALL', 'UAE', 'Israel', 'KSA', 'Bahrain', 'Qatar', 'Kuwait', 'Oman', 'Jordan', 'Lebanon',
];

HospitalCountry? hospitalCountryFromLabel(String label) {
  switch (label) {
    case 'UAE':
      return HospitalCountry.uae;
    case 'Israel':
      return HospitalCountry.israel;
    case 'KSA':
      return HospitalCountry.ksa;
    case 'Bahrain':
      return HospitalCountry.bahrain;
    case 'Qatar':
      return HospitalCountry.qatar;
    case 'Kuwait':
      return HospitalCountry.kuwait;
    case 'Oman':
      return HospitalCountry.oman;
    case 'Jordan':
      return HospitalCountry.jordan;
    case 'Lebanon':
      return HospitalCountry.lebanon;
    default:
      return null;
  }
}

// =============================================================================
// Hospital Data
// =============================================================================

const List<Hospital> hospitals = [

  // ═══════════════════════════════════════════════════════════════════════════
  // UAE — Abu Dhabi Emirate
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Abu Dhabi City — Government / SEHA ──
  Hospital(id: 'ae-skmc-ad', name: 'Sheikh Khalifa Medical City', nameAr: 'مدينة الشيخ خليفة الطبية', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 819 0000', emergency: '+971 2 819 0000', lat: 24.4620, lng: 54.3690, notes: 'SEHA — Trauma center, Burns, ICU, 650 beds'),
  Hospital(id: 'ae-ssmc-ad', name: 'Sheikh Shakhbout Medical City', nameAr: 'مدينة الشيخ شخبوط الطبية', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 314 4444', emergency: '+971 2 314 4444', lat: 24.3725, lng: 54.5450, notes: 'SEHA / Mayo Clinic — 732 beds, Oncology, Transplant, Cardiac'),
  Hospital(id: 'ae-corniche-ad', name: 'Corniche Hospital', nameAr: 'مستشفى الكورنيش', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 672 4000', emergency: '+971 2 672 4000', lat: 24.5021, lng: 54.3701, notes: 'SEHA — Women & Newborn referral, NICU, 254 beds'),
  Hospital(id: 'ae-mafraq-ad', name: 'Al Mafraq Hospital', nameAr: 'مستشفى المفرق', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 501 1111', emergency: '+971 2 501 1111', lat: 24.3307, lng: 54.6233, notes: 'SEHA — Trauma, Largest burn unit in UAE, 451 beds'),
  Hospital(id: 'ae-rahba-ad', name: 'Al Rahba Hospital', nameAr: 'مستشفى الرحبة', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 506 4444', emergency: '+971 2 506 4444', lat: 24.5727, lng: 54.6946, notes: 'SEHA — 185 beds, Shahama area, 24/7 ER'),
  Hospital(id: 'ae-zayed-military-ad', name: 'Zayed Military Hospital', nameAr: 'مستشفى زايد العسكري', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 405 5000', emergency: '+971 2 405 5000', lat: 24.4208, lng: 54.4282, notes: 'Military — Armed Forces medical center'),

  // ── Abu Dhabi City — Private ──
  Hospital(id: 'ae-cleveland-ad', name: 'Cleveland Clinic Abu Dhabi', nameAr: 'كليفلاند كلينك أبوظبي', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 501 9000', emergency: '+971 2 501 9000', lat: 24.4970, lng: 54.3879, notes: 'Multi-specialty — Heart, Neuro, Oncology, Transplant, Al Maryah Island'),
  Hospital(id: 'ae-reem-ad', name: 'Reem Hospital', nameAr: 'مستشفى ريم', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 800 7444', emergency: '+971 800 7444', lat: 24.4907, lng: 54.4138, notes: 'VPS Healthcare — Multi-specialty, Al Reem Island'),
  Hospital(id: 'ae-burjeel-ad', name: 'Burjeel Hospital Abu Dhabi', nameAr: 'مستشفى برجيل أبوظبي', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 508 5555', emergency: '+971 2 508 5555', lat: 24.4795, lng: 54.3811, notes: 'Multi-specialty — Oncology, Ortho, Cardiology'),
  Hospital(id: 'ae-burjeel-mc-ad', name: 'Burjeel Medical City', nameAr: 'مدينة برجيل الطبية', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 777 3333', emergency: '+971 2 777 3333', lat: 24.3549, lng: 54.5388, notes: 'M42 — 400 beds, Comprehensive cancer center, MBZ City'),
  Hospital(id: 'ae-healthpoint-ad', name: 'Healthpoint Hospital', nameAr: 'هيلث بوينت', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 492 9000', lat: 24.4175, lng: 54.4456, notes: 'M42/Mubadala — Ortho, Sports medicine, Zayed Sports City'),
  Hospital(id: 'ae-danat-ad', name: 'Danat Al Emarat Hospital', nameAr: 'مستشفى دانة الإمارات', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 614 9999', emergency: '+971 2 614 9999', lat: 24.3967, lng: 54.5011, notes: 'M42 — Women & Children, High-risk pregnancy, 150 beds'),
  Hospital(id: 'ae-nmc-ad', name: 'NMC Royal Hospital Abu Dhabi', nameAr: 'مستشفى إن إم سي رويال أبوظبي', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 632 2555', emergency: '+971 2 632 2555', lat: 24.4521, lng: 54.3920, notes: 'Multi-specialty — 24/7 ER, Pediatrics, Khalifa Street'),
  Hospital(id: 'ae-nmc-khalifa-ad', name: 'NMC Royal Hospital Khalifa City', nameAr: 'مستشفى إن إم سي رويال مدينة خليفة', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 557 1711', lat: 24.4113, lng: 54.5708, notes: 'Multi-specialty — Khalifa City A'),
  Hospital(id: 'ae-mediclinic-alnoor-ad', name: 'Mediclinic Al Noor Hospital', nameAr: 'مستشفى ميديكلينيك النور', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 626 5265', emergency: '+971 2 626 5265', lat: 24.4870, lng: 54.3650, notes: 'Private — 33 specialties, Open heart surgery, IVF'),
  Hospital(id: 'ae-mediclinic-airport-ad', name: 'Mediclinic Airport Road Hospital', nameAr: 'مستشفى ميديكلينيك طريق المطار', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 444 4199', lat: 24.4170, lng: 54.4614, notes: 'Private — Multi-specialty, 24/7 ER'),
  Hospital(id: 'ae-llh-ad', name: 'LLH Hospital Abu Dhabi', nameAr: 'مستشفى إل إل إتش أبوظبي', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 2 633 5522', lat: 24.4870, lng: 54.3667, notes: 'VPS Healthcare — Multi-specialty, Electra Street'),
  Hospital(id: 'ae-ahalia-ad', name: 'Ahalia Hospital', nameAr: 'مستشفى أهالي', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.hospital, phone: '+971 800 66666', lat: 24.4870, lng: 54.3700, notes: 'Private — Multi-specialty, Hamdan Street'),

  // ── Abu Dhabi — Veterinary ──
  Hospital(id: 'ae-falcon-ad', name: 'Abu Dhabi Falcon Hospital', nameAr: 'مستشفى أبوظبي للصقور', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.veterinary, phone: '+971 2 575 5155', lat: 24.4089, lng: 54.6992, notes: 'World largest falcon hospital — Near airport'),
  Hospital(id: 'ae-bvc-kc-ad', name: 'British Veterinary Centre Khalifa City', nameAr: 'المركز البيطري البريطاني', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.veterinary, phone: '+971 2 550 4111', lat: 24.3972, lng: 54.5552, notes: '24/7 emergency — Small animals'),
  Hospital(id: 'ae-german-vet-ad', name: 'German Veterinary Clinic', nameAr: 'العيادة البيطرية الألمانية', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.veterinary, phone: '+971 2 556 2024', lat: 24.4177, lng: 54.5635, notes: 'Khalifa City — Small animals, Surgery'),
  Hospital(id: 'ae-aus-vet-ad', name: 'Australian Veterinary Hospital', nameAr: 'المستشفى البيطري الأسترالي', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.veterinary, phone: '+971 2 556 2990', lat: 24.4081, lng: 54.5513, notes: 'Khalifa City — 24/7, Surgery, Diagnostics'),
  Hospital(id: 'ae-american-vet-ad', name: 'American Veterinary Clinic', nameAr: 'العيادة البيطرية الأمريكية', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.veterinary, phone: '+971 2 665 5044', lat: 24.4700, lng: 54.3500, notes: 'Khalidiyah — Est. 2005'),
  Hospital(id: 'ae-canadian-vet-ad', name: 'Canadian Veterinary Clinic', nameAr: 'العيادة البيطرية الكندية', country: HospitalCountry.uae, city: 'Abu Dhabi', type: HospitalType.veterinary, phone: '+971 2 666 6886', lat: 24.4700, lng: 54.3300, notes: 'Khalidiyah — Small animals'),

  // ── Al Ain ──
  Hospital(id: 'ae-tawam-alain', name: 'Tawam Hospital', nameAr: 'مستشفى توام', country: HospitalCountry.uae, city: 'Al Ain', type: HospitalType.hospital, phone: '+971 3 707 7777', emergency: '+971 3 707 7777', lat: 24.1957, lng: 55.6488, notes: 'SEHA — Oncology center, ICU, Trauma, 461 beds'),
  Hospital(id: 'ae-alain-hospital', name: 'Al Ain Hospital', nameAr: 'مستشفى العين', country: HospitalCountry.uae, city: 'Al Ain', type: HospitalType.hospital, phone: '+971 3 702 2000', emergency: '+971 3 702 2000', lat: 24.2075, lng: 55.7447, notes: 'SEHA — Largest in Al Ain, Teaching hospital, Trauma'),
  Hospital(id: 'ae-mediclinic-alain', name: 'Mediclinic Al Ain Hospital', nameAr: 'مستشفى ميديكلينيك العين', country: HospitalCountry.uae, city: 'Al Ain', type: HospitalType.hospital, phone: '+971 3 716 3400', lat: 24.2241, lng: 55.7676, notes: 'Private — Multi-specialty, JCI accredited'),
  Hospital(id: 'ae-nmc-alain', name: 'NMC Specialty Hospital Al Ain', nameAr: 'مستشفى إن إم سي التخصصي العين', country: HospitalCountry.uae, city: 'Al Ain', type: HospitalType.hospital, phone: '+971 3 703 0300', lat: 24.2300, lng: 55.7426, notes: 'Private — Multi-specialty'),
  Hospital(id: 'ae-universal-alain', name: 'Universal Hospital Al Ain', nameAr: 'المستشفى العالمي العين', country: HospitalCountry.uae, city: 'Al Ain', type: HospitalType.hospital, phone: '+971 3 799 0000', lat: 24.2502, lng: 55.7347, notes: 'Private — 100 beds, JCI accredited'),
  Hospital(id: 'ae-burjeel-alain', name: 'Burjeel Royal Hospital Al Ain', nameAr: 'مستشفى برجيل رويال العين', country: HospitalCountry.uae, city: 'Al Ain', type: HospitalType.hospital, phone: '+971 800 55', lat: 24.2240, lng: 55.7590, notes: 'VPS Healthcare — Multi-specialty'),

  // ── Al Dhafra / Western Region ──
  Hospital(id: 'ae-madinat-zayed', name: 'Madinat Zayed Hospital', nameAr: 'مستشفى مدينة زايد', country: HospitalCountry.uae, city: 'Madinat Zayed', type: HospitalType.hospital, phone: '+971 2 807 0000', lat: 23.6588, lng: 53.6796, notes: 'SEHA — Western Region referral'),
  Hospital(id: 'ae-ghayathi', name: 'Ghayathi Hospital', nameAr: 'مستشفى غياثي', country: HospitalCountry.uae, city: 'Ghayathi', type: HospitalType.hospital, phone: '+971 2 807 6011', lat: 23.8993, lng: 52.8018, notes: 'SEHA — Western Region'),
  Hospital(id: 'ae-mirfa', name: 'Al Mirfa Hospital', nameAr: 'مستشفى المرفأ', country: HospitalCountry.uae, city: 'Al Mirfa', type: HospitalType.hospital, phone: '+971 2 883 5000', lat: 24.0882, lng: 53.4969, notes: 'SEHA — Coastal western region'),

  // ═══════════════════════════════════════════════════════════════════════════
  // UAE — Dubai
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'ae-rashid-dxb', name: 'Rashid Hospital', nameAr: 'مستشفى راشد', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 219 2000', emergency: '+971 4 219 2000', lat: 25.2442, lng: 55.3189, notes: 'DHA — Level 1 Trauma center, Burns, 786 beds'),
  Hospital(id: 'ae-dubai-hospital', name: 'Dubai Hospital', nameAr: 'مستشفى دبي', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 219 5000', emergency: '+971 4 219 5000', lat: 25.2833, lng: 55.3178, notes: 'DHA — 625 beds, Cardiology, Oncology, Neurology'),
  Hospital(id: 'ae-latifa-dxb', name: 'Latifa Women & Children Hospital', nameAr: 'مستشفى لطيفة', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 219 3000', emergency: '+971 4 219 3000', lat: 25.2229, lng: 55.3179, notes: 'DHA — Women & Children, NICU, 344 beds'),
  Hospital(id: 'ae-jalila-dxb', name: 'Al Jalila Children\'s Specialty Hospital', nameAr: 'مستشفى الجليلة التخصصي للأطفال', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 556 6777', emergency: '+971 4 556 6777', lat: 25.2300, lng: 55.3190, notes: 'DHA — 200 beds, Only pediatric tertiary in UAE'),
  Hospital(id: 'ae-mediclinic-city-dxb', name: 'Mediclinic City Hospital', nameAr: 'ميديكلينيك سيتي هوسبيتال', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 435 9999', emergency: '+971 4 435 9999', lat: 25.2340, lng: 55.3199, notes: 'Private — 280 beds, 24/7 ER, Maternity, NICU, DHCC'),
  Hospital(id: 'ae-american-dxb', name: 'American Hospital Dubai', nameAr: 'المستشفى الأمريكي دبي', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 377 6111', emergency: '+971 4 377 6111', lat: 25.2355, lng: 55.3130, notes: 'Private — 254 beds, Mayo Clinic Network, JCI'),
  Hospital(id: 'ae-saudi-german-dxb', name: 'Saudi German Hospital Dubai', nameAr: 'المستشفى السعودي الألماني دبي', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 389 0000', emergency: '+971 4 389 0000', lat: 25.0972, lng: 55.1838, notes: 'Multi-specialty — Al Barsha, 24/7 ER'),
  Hospital(id: 'ae-emirates-jumeirah-dxb', name: 'Emirates Hospital Jumeirah', nameAr: 'مستشفى الإمارات جميرا', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 349 6666', emergency: '+971 4 349 6666', lat: 25.1970, lng: 55.2369, notes: 'Private — 100 beds, Cardiology, Ortho, Cosmetic'),
  Hospital(id: 'ae-canadian-dxb', name: 'Canadian Specialist Hospital', nameAr: 'المستشفى الكندي التخصصي', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 707 2222', emergency: '+971 4 707 2222', lat: 25.2773, lng: 55.3470, notes: 'Private — 200 beds, Deira'),
  Hospital(id: 'ae-welcare-dxb', name: 'Mediclinic Welcare Hospital', nameAr: 'ميديكلينيك مستشفى ويلكير', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 282 7788', emergency: '+971 4 282 7788', lat: 25.2469, lng: 55.3401, notes: 'Private — 127 beds, Al Garhoud'),
  Hospital(id: 'ae-iranian-dxb', name: 'Iranian Hospital Dubai', nameAr: 'المستشفى الإيراني', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 344 0250', emergency: '+971 4 344 0250', lat: 25.2304, lng: 55.2694, notes: 'Non-profit — 220 beds, Est. 1972, Jumeirah'),
  Hospital(id: 'ae-medcare-dxb', name: 'Medcare Hospital Al Safa', nameAr: 'مستشفى ميدكير', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 407 9100', emergency: '+971 4 407 9100', lat: 25.1833, lng: 55.2427, notes: 'Aster DM — JCI accredited'),
  Hospital(id: 'ae-aster-mankhool-dxb', name: 'Aster Hospital Mankhool', nameAr: 'مستشفى أستر المنخول', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 440 0500', lat: 25.2490, lng: 55.2960, notes: 'Multi-specialty — 100 beds, 24/7 ER'),
  Hospital(id: 'ae-aster-qusais-dxb', name: 'Aster Hospital Al Qusais', nameAr: 'مستشفى أستر القصيص', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 440 0500', lat: 25.2782, lng: 55.3721, notes: 'Multi-specialty — 150 beds'),
  Hospital(id: 'ae-fakeeh-dxb', name: 'Fakeeh University Hospital', nameAr: 'مستشفى فقيه الجامعي', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 360 5777', lat: 25.1213, lng: 55.3873, notes: 'Silicon Oasis — 350 beds, Teaching hospital'),
  Hospital(id: 'ae-kings-college-dxb', name: 'King\'s College Hospital Dubai', nameAr: 'مستشفى كينغز كوليج دبي', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 519 9999', lat: 25.1290, lng: 55.2480, notes: 'NHS affiliate — Dubai Hills, 100 beds'),
  Hospital(id: 'ae-cedars-dxb', name: 'Aster Cedars Hospital Jebel Ali', nameAr: 'مستشفى أستر سيدارز جبل علي', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 881 4000', lat: 25.0200, lng: 55.1000, notes: 'Private — Jebel Ali, Est. 1999'),
  Hospital(id: 'ae-medeor-dxb', name: 'Medeor 24x7 Hospital', nameAr: 'مستشفى ميديور 24/7', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 350 6006', lat: 25.2370, lng: 55.3097, notes: '100 beds, JCI — Bur Dubai'),
  Hospital(id: 'ae-parkview-dxb', name: 'Mediclinic Parkview Hospital', nameAr: 'ميديكلينيك مستشفى بارك فيو', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 709 9900', lat: 25.0587, lng: 55.2388, notes: 'Private — 182 beds, MBR City'),
  Hospital(id: 'ae-zahra-dxb', name: 'Al Zahra Hospital', nameAr: 'مستشفى الزهراء', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 378 6666', lat: 25.1040, lng: 55.1890, notes: '187 beds — Al Barsha, Multi-specialty'),
  Hospital(id: 'ae-zulekha-dxb', name: 'Zulekha Hospital Dubai', nameAr: 'مستشفى زليخة دبي', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 267 8866', lat: 25.2911, lng: 55.3844, notes: 'Private — Al Nahda, 24/7 ER'),
  Hospital(id: 'ae-thumbay-dxb', name: 'Thumbay Hospital Dubai', nameAr: 'مستشفى ثمباي دبي', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.hospital, phone: '+971 4 240 1444', lat: 25.2815, lng: 55.3651, notes: 'Private — Al Qusais'),

  // ── Dubai — Veterinary ──
  Hospital(id: 'ae-vet-hospital-dxb', name: 'The Veterinary Hospital', nameAr: 'المستشفى البيطري', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.veterinary, phone: '+971 4 340 8601', lat: 25.1553, lng: 55.2107, notes: '24/7 emergency — Est. 1979, Umm Suqeim'),
  Hospital(id: 'ae-modern-vet-dxb', name: 'Modern Vet Hospital', nameAr: 'مستشفى مودرن فيت', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.veterinary, phone: '+971 4 395 3553', lat: 25.1680, lng: 55.2210, notes: '24hr — Multi-specialty vet, Al Wasl'),
  Hospital(id: 'ae-british-vet-dxb', name: 'British Veterinary Hospital', nameAr: 'المستشفى البيطري البريطاني', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.veterinary, phone: '+971 4 342 8710', lat: 25.1783, lng: 55.2244, notes: 'Jumeirah 3 — Surgery, Diagnostics'),
  Hospital(id: 'ae-canadian-vet-dxb', name: 'Canadian Veterinary Clinic', nameAr: 'العيادة البيطرية الكندية', country: HospitalCountry.uae, city: 'Dubai', type: HospitalType.veterinary, phone: '+971 4 395 9495', lat: 25.1700, lng: 55.2200, notes: 'Al Manara — Small animals'),

  // ═══════════════════════════════════════════════════════════════════════════
  // UAE — Sharjah
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'ae-qassimi-shj', name: 'Al Qassimi Hospital', nameAr: 'مستشفى القاسمي', country: HospitalCountry.uae, city: 'Sharjah', type: HospitalType.hospital, phone: '+971 6 518 8888', emergency: '+971 6 518 8888', lat: 25.3418, lng: 55.4324, notes: 'EHS flagship — 365 beds, Cardiac center, 24 specialties'),
  Hospital(id: 'ae-university-shj', name: 'University Hospital Sharjah', nameAr: 'المستشفى الجامعي بالشارقة', country: HospitalCountry.uae, city: 'Sharjah', type: HospitalType.hospital, phone: '+971 6 505 8555', emergency: '+971 6 505 8555', lat: 25.2900, lng: 55.4800, notes: 'Teaching — 225 beds, JCI accredited'),
  Hospital(id: 'ae-zulekha-shj', name: 'Zulekha Hospital Sharjah', nameAr: 'مستشفى زليخة الشارقة', country: HospitalCountry.uae, city: 'Sharjah', type: HospitalType.hospital, phone: '+971 6 561 9999', emergency: '+971 6 561 9999', lat: 25.3691, lng: 55.4045, notes: 'Private — 185 beds, Est. 1964, JCI'),
  Hospital(id: 'ae-nmc-shj', name: 'NMC Royal Hospital Sharjah', nameAr: 'مستشفى إن إم سي رويال الشارقة', country: HospitalCountry.uae, city: 'Sharjah', type: HospitalType.hospital, phone: '+971 6 516 8888', emergency: '+971 6 516 8888', lat: 25.3575, lng: 55.3880, notes: 'Private — 137 beds, Cardiology, IVF, Oncology'),
  Hospital(id: 'ae-kuwait-shj', name: 'Kuwait Hospital Sharjah', nameAr: 'مستشفى الكويت الشارقة', country: HospitalCountry.uae, city: 'Sharjah', type: HospitalType.hospital, phone: '+971 6 524 1111', lat: 25.3650, lng: 55.3850, notes: 'EHS — Est. 1968'),
  Hospital(id: 'ae-kalba', name: 'Kalba Hospital', nameAr: 'مستشفى كلباء', country: HospitalCountry.uae, city: 'Kalba', type: HospitalType.hospital, phone: '+971 9 277 1000', lat: 25.0352, lng: 56.3441, notes: 'EHS — 91 beds, Eastern coast'),
  Hospital(id: 'ae-khorfakkan', name: 'Khorfakkan Hospital', nameAr: 'مستشفى خورفكان', country: HospitalCountry.uae, city: 'Khorfakkan', type: HospitalType.hospital, phone: '+971 9 238 6666', lat: 25.3390, lng: 56.3510, notes: 'EHS — Eastern coast'),

  // ═══════════════════════════════════════════════════════════════════════════
  // UAE — Ajman, RAK, Fujairah, UAQ
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'ae-skmca-ajman', name: 'Sheikh Khalifa Medical City Ajman', nameAr: 'مدينة الشيخ خليفة الطبية عجمان', country: HospitalCountry.uae, city: 'Ajman', type: HospitalType.hospital, phone: '+971 6 714 7444', emergency: '+971 6 714 7444', lat: 25.4150, lng: 55.5100, notes: 'Govt — 300+ beds, Women & Children, Diabetes center'),
  Hospital(id: 'ae-thumbay-ajman', name: 'Thumbay Hospital Ajman', nameAr: 'مستشفى ثمباي عجمان', country: HospitalCountry.uae, city: 'Ajman', type: HospitalType.hospital, phone: '+971 6 746 3333', emergency: '+971 6 711 9108', lat: 25.4052, lng: 55.4478, notes: 'Private Teaching — JCI accredited'),
  Hospital(id: 'ae-thumbay-uni-ajman', name: 'Thumbay University Hospital', nameAr: 'مستشفى ثمباي الجامعي', country: HospitalCountry.uae, city: 'Ajman', type: HospitalType.hospital, phone: '+971 6 747 0077', lat: 25.4120, lng: 55.5200, notes: 'Largest private academic — 350 beds'),
  Hospital(id: 'ae-saudi-german-ajman', name: 'Saudi German Hospital Ajman', nameAr: 'المستشفى السعودي الألماني عجمان', country: HospitalCountry.uae, city: 'Ajman', type: HospitalType.hospital, phone: '+971 6 717 0777', lat: 25.4180, lng: 55.4630, notes: 'JCI — Multi-specialty'),
  Hospital(id: 'ae-sksh-rak', name: 'Sheikh Khalifa Specialty Hospital RAK', nameAr: 'مستشفى الشيخ خليفة التخصصي', country: HospitalCountry.uae, city: 'Ras Al Khaimah', type: HospitalType.hospital, phone: '+971 7 244 4444', emergency: '+971 7 244 4444', lat: 25.6167, lng: 55.9500, notes: 'Govt/SNUH — 246 beds, Oncology, Neuro, Cardiac ICU'),
  Hospital(id: 'ae-saqr-rak', name: 'Saqr Hospital', nameAr: 'مستشفى صقر', country: HospitalCountry.uae, city: 'Ras Al Khaimah', type: HospitalType.hospital, phone: '+971 7 204 9999', emergency: '+971 7 204 9999', lat: 25.7833, lng: 55.9500, notes: 'EHS — 287 beds, Surgical referral, Trauma'),
  Hospital(id: 'ae-rak-hospital', name: 'RAK Hospital', nameAr: 'مستشفى رأس الخيمة', country: HospitalCountry.uae, city: 'Ras Al Khaimah', type: HospitalType.hospital, phone: '+971 7 207 4444', emergency: '+971 7 207 4444', lat: 25.7700, lng: 55.9600, notes: 'Private — JCI, Multi-specialty'),
  Hospital(id: 'ae-fujairah-hospital', name: 'Fujairah Hospital', nameAr: 'مستشفى الفجيرة', country: HospitalCountry.uae, city: 'Fujairah', type: HospitalType.hospital, phone: '+971 9 224 2999', emergency: '+971 9 224 2999', lat: 25.1300, lng: 56.3340, notes: 'EHS — Largest in Eastern Region, 330 beds'),
  Hospital(id: 'ae-dibba-hospital', name: 'Dibba Hospital', nameAr: 'مستشفى دبا', country: HospitalCountry.uae, city: 'Dibba Al Fujairah', type: HospitalType.hospital, phone: '+971 9 244 3055', lat: 25.6518, lng: 56.3032, notes: 'EHS — Northern Fujairah'),
  Hospital(id: 'ae-sharq-fujairah', name: 'Al Sharq Hospital Fujairah', nameAr: 'مستشفى الشرق الفجيرة', country: HospitalCountry.uae, city: 'Fujairah', type: HospitalType.hospital, phone: '+971 9 222 8866', lat: 25.1513, lng: 56.3510, notes: 'Private — 100 beds, JCI'),
  Hospital(id: 'ae-uaq-hospital', name: 'Umm Al Quwain Hospital', nameAr: 'مستشفى أم القيوين', country: HospitalCountry.uae, city: 'Umm Al Quwain', type: HospitalType.hospital, phone: '+971 6 706 0500', emergency: '+971 6 706 0500', lat: 25.5731, lng: 55.5609, notes: 'EHS — 203 beds, JCI accredited'),

  // ═══════════════════════════════════════════════════════════════════════════
  // ISRAEL — 30 hospitals
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'il-sheba', name: 'Sheba Medical Center (Tel HaShomer)', nameAr: 'مركز شيبا الطبي', country: HospitalCountry.israel, city: 'Ramat Gan', type: HospitalType.hospital, phone: '+972 3 530 3030', emergency: '+972 3 530 3030', lat: 32.0450, lng: 34.8420, notes: 'Largest in Israel — 2000 beds, Trauma, Burns, Cardiac'),
  Hospital(id: 'il-ichilov', name: 'Ichilov Hospital (Sourasky Medical Center)', nameAr: 'مستشفى إيخيلوف', country: HospitalCountry.israel, city: 'Tel Aviv', type: HospitalType.hospital, phone: '+972 3 697 4444', emergency: '+972 3 697 4444', lat: 32.0808, lng: 34.7875, notes: 'Level 1 Trauma center — Central Tel Aviv'),
  Hospital(id: 'il-hadassah-ein', name: 'Hadassah Ein Kerem', nameAr: 'هداسا عين كارم', country: HospitalCountry.israel, city: 'Jerusalem', type: HospitalType.hospital, phone: '+972 2 677 7111', emergency: '+972 2 677 7111', lat: 31.7650, lng: 35.1470, notes: 'Major — Trauma, Transplant, Oncology, 1000 beds'),
  Hospital(id: 'il-hadassah-scopus', name: 'Hadassah Mount Scopus', nameAr: 'مستشفى هداسا جبل المشارف', country: HospitalCountry.israel, city: 'Jerusalem', type: HospitalType.hospital, phone: '+972 2 584 4111', emergency: '+972 2 584 4111', lat: 31.7974, lng: 35.2423, notes: '350 beds — Rehab, NICU, East Jerusalem coverage'),
  Hospital(id: 'il-shaare-zedek', name: 'Shaare Zedek Medical Center', nameAr: 'المركز الطبي شعاري تسيديك', country: HospitalCountry.israel, city: 'Jerusalem', type: HospitalType.hospital, phone: '+972 2 655 5111', emergency: '+972 2 655 5111', lat: 31.7700, lng: 35.1775, notes: '1000 beds — Largest maternity in Israel'),
  Hospital(id: 'il-rambam', name: 'Rambam Health Care Campus', nameAr: 'مستشفى رامبام', country: HospitalCountry.israel, city: 'Haifa', type: HospitalType.hospital, phone: '+972 4 777 2222', emergency: '+972 4 777 2222', lat: 32.8349, lng: 34.9850, notes: 'Level 1 Trauma — Underground emergency hospital, 1000 beds'),
  Hospital(id: 'il-carmel', name: 'Carmel Medical Center', nameAr: 'مستشفى الكرمل', country: HospitalCountry.israel, city: 'Haifa', type: HospitalType.hospital, phone: '+972 4 825 0211', emergency: '+972 4 825 0211', lat: 32.7926, lng: 34.9862, notes: '477 beds — Cardiovascular center'),
  Hospital(id: 'il-bnai-zion', name: 'Bnai Zion Medical Center', nameAr: 'مستشفى بني تسيون', country: HospitalCountry.israel, city: 'Haifa', type: HospitalType.hospital, phone: '+972 4 835 9359', emergency: '+972 4 835 9359', lat: 32.8173, lng: 34.9897, notes: '430 beds — Formerly Italian Hospital'),
  Hospital(id: 'il-rabin', name: 'Rabin Medical Center (Beilinson)', nameAr: 'مركز رابين الطبي', country: HospitalCountry.israel, city: 'Petah Tikva', type: HospitalType.hospital, phone: '+972 3 937 7377', emergency: '+972 3 937 7377', lat: 32.0873, lng: 34.8671, notes: '1300 beds — Largest transplant center, Davidoff Cancer'),
  Hospital(id: 'il-schneider', name: 'Schneider Children\'s Medical Center', nameAr: 'مركز شنايدر لطب الأطفال', country: HospitalCountry.israel, city: 'Petah Tikva', type: HospitalType.hospital, phone: '+972 3 925 3253', emergency: '+972 3 925 3210', lat: 32.0881, lng: 34.8675, notes: 'Only comprehensive pediatric tertiary center in ME'),
  Hospital(id: 'il-soroka', name: 'Soroka Medical Center', nameAr: 'مركز سوروكا الطبي', country: HospitalCountry.israel, city: 'Beer Sheva', type: HospitalType.hospital, phone: '+972 8 640 0111', emergency: '+972 8 640 0111', lat: 31.2580, lng: 34.8003, notes: 'Negev regional trauma center — 1200 beds'),
  Hospital(id: 'il-barzilai', name: 'Barzilai Medical Center', nameAr: 'مستشفى بارزيلاي', country: HospitalCountry.israel, city: 'Ashkelon', type: HospitalType.hospital, phone: '+972 8 674 5555', emergency: '+972 8 674 5555', lat: 31.6619, lng: 34.5598, notes: '602 beds — Closest to Gaza (~10km), Fortified ER'),
  Hospital(id: 'il-wolfson', name: 'Wolfson Medical Center', nameAr: 'مستشفى وولفسون', country: HospitalCountry.israel, city: 'Holon', type: HospitalType.hospital, phone: '+972 3 502 8111', emergency: '+972 3 502 8111', lat: 32.0353, lng: 34.7628, notes: '685 beds — Pediatric cardiology & cardiac surgery'),
  Hospital(id: 'il-kaplan', name: 'Kaplan Medical Center', nameAr: 'مركز كابلان الطبي', country: HospitalCountry.israel, city: 'Rehovot', type: HospitalType.hospital, phone: '+972 8 944 1211', emergency: '+972 8 944 1211', lat: 31.8735, lng: 34.8147, notes: '535 beds — JCI, Teaching hospital'),
  Hospital(id: 'il-meir', name: 'Meir Medical Center', nameAr: 'مركز مئير الطبي', country: HospitalCountry.israel, city: 'Kfar Saba', type: HospitalType.hospital, phone: '+972 9 747 2555', emergency: '+972 9 747 2555', lat: 32.1817, lng: 34.8956, notes: '7th largest — Spinal surgery, Pulmonary, JCI'),
  Hospital(id: 'il-galilee', name: 'Galilee Medical Center', nameAr: 'مركز الجليل الطبي', country: HospitalCountry.israel, city: 'Nahariya', type: HospitalType.hospital, phone: '+972 4 910 7107', emergency: '+972 4 910 7107', lat: 33.0101, lng: 35.1171, notes: '733 beds — Underground hospital, Near Lebanon border'),
  Hospital(id: 'il-hillel-yaffe', name: 'Hillel Yaffe Medical Center', nameAr: 'مستشفى هيلل يافه', country: HospitalCountry.israel, city: 'Hadera', type: HospitalType.hospital, phone: '+972 4 630 4304', emergency: '+972 4 630 4304', lat: 32.4340, lng: 34.8840, notes: '495 beds — Technion affiliated'),
  Hospital(id: 'il-herzliya', name: 'Herzliya Medical Center', nameAr: 'مركز هرتسليا الطبي', country: HospitalCountry.israel, city: 'Herzliya', type: HospitalType.hospital, phone: '+972 9 959 4888', emergency: '+972 9 959 2999', lat: 32.1777, lng: 34.8030, notes: 'Largest private — Neurosurgery, Ortho, IVF'),
  Hospital(id: 'il-assuta-ta', name: 'Assuta Medical Center Tel Aviv', nameAr: 'مركز أسوتا الطبي', country: HospitalCountry.israel, city: 'Tel Aviv', type: HospitalType.hospital, phone: '+972 3 764 4400', emergency: '+972 3 764 4400', lat: 32.0590, lng: 34.7910, notes: 'Private — Surgery, Oncology, IVF'),
  Hospital(id: 'il-assuta-ashdod', name: 'Assuta Ashdod University Hospital', nameAr: 'مستشفى أسوتا أشدود', country: HospitalCountry.israel, city: 'Ashdod', type: HospitalType.hospital, phone: '+972 8 868 2000', emergency: '+972 8 868 2000', lat: 31.7964, lng: 34.6338, notes: '300 beds — Opened 2017, Ben Gurion Univ affiliated'),
  Hospital(id: 'il-ziv', name: 'Ziv Medical Center', nameAr: 'مركز زيف الطبي', country: HospitalCountry.israel, city: 'Safed', type: HospitalType.hospital, phone: '+972 4 682 8811', emergency: '+972 4 682 8811', lat: 32.9670, lng: 35.4900, notes: '350 beds — Upper Galilee/Golan referral'),
  Hospital(id: 'il-poriya', name: 'Poriya Medical Center', nameAr: 'مستشفى بورية', country: HospitalCountry.israel, city: 'Tiberias', type: HospitalType.hospital, phone: '+972 4 665 2211', emergency: '+972 4 665 2211', lat: 32.7380, lng: 35.5500, notes: '350 beds — Sea of Galilee region'),
  Hospital(id: 'il-emek', name: 'Emek Medical Center', nameAr: 'مركز العمق الطبي', country: HospitalCountry.israel, city: 'Afula', type: HospitalType.hospital, phone: '+972 4 649 4000', emergency: '+972 4 649 4000', lat: 32.6080, lng: 35.2900, notes: '500 beds — Jezreel Valley referral'),
  Hospital(id: 'il-laniado', name: 'Laniado Hospital', nameAr: 'مستشفى لانيادو', country: HospitalCountry.israel, city: 'Netanya', type: HospitalType.hospital, phone: '+972 9 860 4666', emergency: '+972 9 860 4666', lat: 32.3370, lng: 34.8680, notes: '500 beds — Cardiology, Maternity'),
  Hospital(id: 'il-yoseftal', name: 'Yoseftal Hospital', nameAr: 'مستشفى يوسفتال', country: HospitalCountry.israel, city: 'Eilat', type: HospitalType.hospital, phone: '+972 8 635 8011', emergency: '+972 8 635 8011', lat: 29.5560, lng: 34.9510, notes: 'Southernmost hospital — 65 beds, Eilat'),
  Hospital(id: 'il-augusta-victoria', name: 'Augusta Victoria Hospital', nameAr: 'مستشفى المطلع (أوغستا فيكتوريا)', country: HospitalCountry.israel, city: 'Jerusalem', type: HospitalType.hospital, phone: '+972 2 627 9911', emergency: '+972 2 627 9911', lat: 31.7740, lng: 35.2470, notes: 'Lutheran — Mt of Olives, Oncology, Dialysis, East Jerusalem'),
  Hospital(id: 'il-makassed-jer', name: 'Makassed Hospital', nameAr: 'مستشفى المقاصد', country: HospitalCountry.israel, city: 'Jerusalem', type: HospitalType.hospital, phone: '+972 2 627 0222', emergency: '+972 2 627 0222', lat: 31.7780, lng: 35.2420, notes: '250 beds — Largest Palestinian hospital, Mt of Olives'),

  // ═══════════════════════════════════════════════════════════════════════════
  // KSA — 30 hospitals
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Riyadh ──
  Hospital(id: 'sa-kfsh-riyadh', name: 'King Faisal Specialist Hospital', nameAr: 'مستشفى الملك فيصل التخصصي', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 464 7272', emergency: '+966 11 464 7272', lat: 24.6681, lng: 46.6803, notes: 'Referral — Oncology, Transplant, Cardiac surgery'),
  Hospital(id: 'sa-kfmc', name: 'King Fahad Medical City', nameAr: 'مدينة الملك فهد الطبية', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 288 9999', emergency: '+966 11 288 9999', lat: 24.6250, lng: 46.7300, notes: 'Major govt complex — Rehab, Pediatrics, Women'),
  Hospital(id: 'sa-kamc-ng-riyadh', name: 'King Abdulaziz Medical City (National Guard)', nameAr: 'مدينة الملك عبدالعزيز الطبية للحرس الوطني', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 801 1111', emergency: '+966 11 801 1111', lat: 24.7136, lng: 46.8468, notes: 'Level I Trauma — 1973 beds, Transplant'),
  Hospital(id: 'sa-psmmc-riyadh', name: 'Prince Sultan Military Medical City', nameAr: 'مدينة الأمير سلطان الطبية العسكرية', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 477 7714', emergency: '+966 11 477 7714', lat: 24.6920, lng: 46.7135, notes: 'Military — 1200 beds, Cardiac, Transplant, Rehab'),
  Hospital(id: 'sa-ksmc-riyadh', name: 'King Saud Medical City', nameAr: 'مدينة الملك سعود الطبية', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 435 5555', emergency: '+966 11 435 5555', lat: 24.6530, lng: 46.6975, notes: 'Level 1 Trauma — 1500 beds, Burn center'),
  Hospital(id: 'sa-security-forces-riyadh', name: 'Security Forces Hospital', nameAr: 'مستشفى قوى الأمن', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 805 4444', emergency: '+966 11 805 4444', lat: 24.7280, lng: 46.7040, notes: 'MOI — 500 beds, Multi-specialty, JCI'),
  Hospital(id: 'sa-kkesh', name: 'King Khaled Eye Specialist Hospital', nameAr: 'مستشفى الملك خالد التخصصي للعيون', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 482 1234', lat: 24.6780, lng: 46.6880, notes: 'Ophthalmology referral — 265 beds'),
  Hospital(id: 'sa-saudi-german-riyadh', name: 'Saudi German Hospital Riyadh', nameAr: 'المستشفى السعودي الألماني الرياض', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 920 007 997', emergency: '+966 920 007 997', lat: 24.7327, lng: 46.6550, notes: 'Private multi-specialty — 24/7 ER'),
  Hospital(id: 'sa-dallah-riyadh', name: 'Dallah Hospital Riyadh', nameAr: 'مستشفى دلة الرياض', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 250 1000', emergency: '+966 11 250 1000', lat: 24.7640, lng: 46.6550, notes: 'Private — Cardiology, Ortho, IVF'),
  Hospital(id: 'sa-alhabib-riyadh', name: 'Dr. Sulaiman Al Habib Hospital', nameAr: 'مستشفى الدكتور سليمان الحبيب', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 525 9999', emergency: '+966 11 525 9999', lat: 24.6968, lng: 46.6792, notes: 'Private — Cardiology, Oncology, IVF, JCI'),
  Hospital(id: 'sa-mouwasat-riyadh', name: 'Mouwasat Hospital Riyadh', nameAr: 'مستشفى المواساة الرياض', country: HospitalCountry.ksa, city: 'Riyadh', type: HospitalType.hospital, phone: '+966 11 413 0000', emergency: '+966 11 413 0000', lat: 24.7936, lng: 46.7181, notes: 'Private — 200 beds'),

  // ── Jeddah ──
  Hospital(id: 'sa-king-abdulaziz-jeddah', name: 'King Abdulaziz University Hospital', nameAr: 'مستشفى جامعة الملك عبدالعزيز', country: HospitalCountry.ksa, city: 'Jeddah', type: HospitalType.hospital, phone: '+966 12 640 0000', emergency: '+966 12 640 0000', lat: 21.4935, lng: 39.2453, notes: 'Teaching — ER, Surgery, Dialysis'),
  Hospital(id: 'sa-king-fahd-jeddah', name: 'King Fahd General Hospital Jeddah', nameAr: 'مستشفى الملك فهد العام بجدة', country: HospitalCountry.ksa, city: 'Jeddah', type: HospitalType.hospital, phone: '+966 12 660 6111', emergency: '+966 12 660 6111', lat: 21.5270, lng: 39.1655, notes: 'Govt — General, Trauma, ICU'),
  Hospital(id: 'sa-imc-jeddah', name: 'International Medical Center', nameAr: 'المركز الطبي الدولي', country: HospitalCountry.ksa, city: 'Jeddah', type: HospitalType.hospital, phone: '+966 12 650 9000', emergency: '+966 12 650 9000', lat: 21.5135, lng: 39.1741, notes: 'Private — 300 beds, 30+ specialties, JCI'),
  Hospital(id: 'sa-saudi-german-jeddah', name: 'Saudi German Hospital Jeddah', nameAr: 'المستشفى السعودي الألماني جدة', country: HospitalCountry.ksa, city: 'Jeddah', type: HospitalType.hospital, phone: '+966 12 682 9000', emergency: '+966 12 682 9000', lat: 21.5973, lng: 39.1336, notes: 'Private — 218 beds, Est. 1988'),
  Hospital(id: 'sa-fakeeh-jeddah', name: 'Dr. Soliman Fakeeh Hospital', nameAr: 'مستشفى الدكتور سليمان فقيه', country: HospitalCountry.ksa, city: 'Jeddah', type: HospitalType.hospital, phone: '+966 12 665 5000', emergency: '+966 12 665 5000', lat: 21.5440, lng: 39.1700, notes: 'Private — 700 beds, Largest private in Jeddah'),
  Hospital(id: 'sa-king-abdullah-jeddah', name: 'King Abdullah Medical Complex', nameAr: 'مجمع الملك عبدالله الطبي بجدة', country: HospitalCountry.ksa, city: 'Jeddah', type: HospitalType.hospital, phone: '+966 12 222 0000', lat: 21.6100, lng: 39.1200, notes: 'MOH — North Jeddah, 1000 beds planned'),

  // ── Eastern Province ──
  Hospital(id: 'sa-mouwasat-dammam', name: 'Mouwasat Hospital Dammam', nameAr: 'مستشفى المواساة الدمام', country: HospitalCountry.ksa, city: 'Dammam', type: HospitalType.hospital, phone: '+966 13 820 0000', emergency: '+966 13 820 0000', lat: 26.4697, lng: 50.1151, notes: 'Private — 250 beds'),
  Hospital(id: 'sa-king-fahd-specialist-dammam', name: 'King Fahd Specialist Hospital Dammam', nameAr: 'مستشفى الملك فهد التخصصي بالدمام', country: HospitalCountry.ksa, city: 'Dammam', type: HospitalType.hospital, phone: '+966 13 844 2222', emergency: '+966 13 844 2222', lat: 26.4117, lng: 50.0975, notes: 'Govt — 640 beds, Oncology, Transplant'),
  Hospital(id: 'sa-saad-khobar', name: 'Saad Specialist Hospital', nameAr: 'مستشفى سعد التخصصي', country: HospitalCountry.ksa, city: 'Al Khobar', type: HospitalType.hospital, phone: '+966 13 882 6666', emergency: '+966 13 882 6666', lat: 26.2617, lng: 50.2117, notes: 'Private — 600 beds, Oncology, Transplant, Cardiac'),
  Hospital(id: 'sa-kfmmc-dhahran', name: 'King Fahd Military Medical Complex', nameAr: 'مجمع الملك فهد الطبي العسكري', country: HospitalCountry.ksa, city: 'Dhahran', type: HospitalType.hospital, phone: '+966 13 844 0000', emergency: '+966 13 844 0000', lat: 26.3213, lng: 50.0154, notes: 'Military — Cardiac, Ortho, Neuro, Trauma'),
  Hospital(id: 'sa-jhah-dhahran', name: 'Johns Hopkins Aramco Healthcare', nameAr: 'جونز هوبكنز أرامكو للرعاية الصحية', country: HospitalCountry.ksa, city: 'Dhahran', type: HospitalType.hospital, phone: '+966 13 877 3000', emergency: '+966 13 877 3000', lat: 26.2970, lng: 50.1440, notes: 'Johns Hopkins affiliate — Saudi Aramco employees'),

  // ── Makkah / Madinah ──
  Hospital(id: 'sa-alnoor-makkah', name: 'Al Noor Specialist Hospital', nameAr: 'مستشفى النور التخصصي', country: HospitalCountry.ksa, city: 'Makkah', type: HospitalType.hospital, phone: '+966 12 566 5000', emergency: '+966 12 566 5000', lat: 21.3861, lng: 39.8601, notes: 'Govt — 500 beds, Largest ER in Makkah'),
  Hospital(id: 'sa-kamc-makkah', name: 'King Abdullah Medical City', nameAr: 'مدينة الملك عبدالله الطبية', country: HospitalCountry.ksa, city: 'Makkah', type: HospitalType.hospital, phone: '+966 12 554 9999', emergency: '+966 12 554 9999', lat: 21.3814, lng: 39.8808, notes: 'Quaternary referral — 1550 beds, Oncology, Transplant'),
  Hospital(id: 'sa-king-fahd-madinah', name: 'King Fahd Hospital Madinah', nameAr: 'مستشفى الملك فهد بالمدينة المنورة', country: HospitalCountry.ksa, city: 'Madinah', type: HospitalType.hospital, phone: '+966 14 846 1500', emergency: '+966 14 846 1500', lat: 24.4764, lng: 39.6463, notes: 'Govt — 500 beds, Stroke network'),

  // ═══════════════════════════════════════════════════════════════════════════
  // BAHRAIN — 12 hospitals
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'bh-salmaniya', name: 'Salmaniya Medical Complex', nameAr: 'مجمع السلمانية الطبي', country: HospitalCountry.bahrain, city: 'Manama', type: HospitalType.hospital, phone: '+973 1728 8888', emergency: '+973 1728 8888', lat: 26.2186, lng: 50.5880, notes: 'Largest govt — 1200 beds, Trauma, ICU, Burns'),
  Hospital(id: 'bh-king-hamad', name: 'King Hamad University Hospital', nameAr: 'مستشفى الملك حمد الجامعي', country: HospitalCountry.bahrain, city: 'Muharraq', type: HospitalType.hospital, phone: '+973 1744 4444', emergency: '+973 1744 4444', lat: 26.2380, lng: 50.6320, notes: 'Teaching — 24/7 ER, 300 beds'),
  Hospital(id: 'bh-royal-bahrain', name: 'Royal Bahrain Hospital', nameAr: 'مستشفى رويال البحرين', country: HospitalCountry.bahrain, city: 'Manama', type: HospitalType.hospital, phone: '+973 1724 6800', emergency: '+973 1724 6800', lat: 26.2240, lng: 50.5120, notes: 'Private — Multi-specialty, 24/7 ER'),
  Hospital(id: 'bh-bdf', name: 'BDF Hospital (Bahrain Defence Force)', nameAr: 'مستشفى قوة دفاع البحرين', country: HospitalCountry.bahrain, city: 'West Riffa', type: HospitalType.hospital, phone: '+973 1776 6666', emergency: '+973 1776 6666', lat: 26.1357, lng: 50.5253, notes: 'Military — 463 beds, Cardiac center'),
  Hospital(id: 'bh-specialist', name: 'Bahrain Specialist Hospital', nameAr: 'مستشفى البحرين التخصصي', country: HospitalCountry.bahrain, city: 'Juffair', type: HospitalType.hospital, phone: '+973 1781 2222', emergency: '+973 1781 2111', lat: 26.2146, lng: 50.6063, notes: 'Private — JCI accredited'),
  Hospital(id: 'bh-ibn-nafees', name: 'Ibn Al Nafees Hospital', nameAr: 'مستشفى ابن النفيس', country: HospitalCountry.bahrain, city: 'Manama', type: HospitalType.hospital, phone: '+973 1728 2282', emergency: '+973 1728 2282', lat: 26.2100, lng: 50.5900, notes: 'Private — Multi-specialty'),
  Hospital(id: 'bh-hilal', name: 'Al Hilal Hospital', nameAr: 'مستشفى الهلال', country: HospitalCountry.bahrain, city: 'Muharraq', type: HospitalType.clinic, phone: '+973 1734 4700', lat: 26.2575, lng: 50.6120, notes: '50 beds — Badr Al Samaa Group'),
  Hospital(id: 'bh-international', name: 'International Hospital of Bahrain', nameAr: 'مستشفى البحرين الدولي', country: HospitalCountry.bahrain, city: 'Jidhafs', type: HospitalType.hospital, phone: '+973 1759 8222', emergency: '+973 1759 8222', lat: 26.2199, lng: 50.5330, notes: 'Oldest private — Est. 1978'),
  Hospital(id: 'bh-american-mission', name: 'American Mission Hospital', nameAr: 'مستشفى الإرسالية الأمريكية', country: HospitalCountry.bahrain, city: 'Manama', type: HospitalType.clinic, phone: '+973 1725 3447', lat: 26.2350, lng: 50.5790, notes: 'Primary care, Pediatrics, Dental'),
  Hospital(id: 'bh-gulf-dental', name: 'Gulf Dental Specialty Hospital', nameAr: 'مستشفى الخليج التخصصي لطب الأسنان', country: HospitalCountry.bahrain, city: 'Adliya', type: HospitalType.clinic, phone: '+973 1724 0800', lat: 26.2158, lng: 50.5825, notes: 'Dental specialty — JCI accredited'),
  Hospital(id: 'bh-middle-east', name: 'Middle East Hospital', nameAr: 'مستشفى الشرق الأوسط', country: HospitalCountry.bahrain, city: 'Manama', type: HospitalType.hospital, phone: '+973 1736 2233', lat: 26.2250, lng: 50.5750, notes: 'Private — Multi-specialty, 24/7'),
  Hospital(id: 'bh-vet-bahrain', name: 'Bahrain Veterinary Hospital', nameAr: 'المستشفى البيطري البحرين', country: HospitalCountry.bahrain, city: 'Manama', type: HospitalType.veterinary, phone: '+973 1729 3001', lat: 26.2200, lng: 50.5600, notes: 'Government veterinary center'),

  // ═══════════════════════════════════════════════════════════════════════════
  // QATAR — 12 hospitals
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'qa-hamad', name: 'Hamad General Hospital', nameAr: 'مستشفى حمد العام', country: HospitalCountry.qatar, city: 'Doha', type: HospitalType.hospital, phone: '+974 4439 4444', emergency: '+974 4439 9999', lat: 25.2990, lng: 51.5150, notes: 'Main trauma center — Level 1, Burns, ICU'),
  Hospital(id: 'qa-sidra', name: 'Sidra Medicine', nameAr: 'سدرة للطب', country: HospitalCountry.qatar, city: 'Doha', type: HospitalType.hospital, phone: '+974 4003 3333', emergency: '+974 4003 3333', lat: 25.3230, lng: 51.4440, notes: 'Women & Children — NICU, Pediatric surgery, 400 beds'),
  Hospital(id: 'qa-al-ahli', name: 'Al Ahli Hospital', nameAr: 'مستشفى الأهلي', country: HospitalCountry.qatar, city: 'Doha', type: HospitalType.hospital, phone: '+974 4489 8888', emergency: '+974 4489 8888', lat: 25.2830, lng: 51.5220, notes: 'Private — 24/7 ER, Multi-specialty'),
  Hospital(id: 'qa-heart', name: 'Heart Hospital (HMC)', nameAr: 'مستشفى القلب', country: HospitalCountry.qatar, city: 'Doha', type: HospitalType.hospital, phone: '+974 4439 8800', emergency: '+974 4439 5777', lat: 25.2925, lng: 51.5110, notes: 'HMC — 116 beds, Cardiac specialist'),
  Hospital(id: 'qa-hazm', name: 'Hazm Mebaireek General Hospital', nameAr: 'مستشفى حزم مبيريك العام', country: HospitalCountry.qatar, city: 'Doha', type: HospitalType.hospital, phone: '+974 4439 5777', emergency: '+974 4439 5777', lat: 25.1814, lng: 51.4305, notes: 'HMC — Surgery, Ortho, Urology'),
  Hospital(id: 'qa-turkish', name: 'Turkish Hospital', nameAr: 'المستشفى التركي', country: HospitalCountry.qatar, city: 'Doha', type: HospitalType.hospital, phone: '+974 4499 2444', emergency: '+974 4499 2444', lat: 25.2750, lng: 51.5200, notes: 'Private — Qatari-Turkish joint venture'),
  Hospital(id: 'qa-wakra', name: 'Al Wakra Hospital', nameAr: 'مستشفى الوكرة', country: HospitalCountry.qatar, city: 'Al Wakrah', type: HospitalType.hospital, phone: '+974 4011 4444', emergency: '+974 4011 4314', lat: 25.1669, lng: 51.5878, notes: 'HMC — Southern Qatar, 325 beds'),
  Hospital(id: 'qa-khor', name: 'Al Khor Hospital', nameAr: 'مستشفى الخور', country: HospitalCountry.qatar, city: 'Al Khor', type: HospitalType.hospital, phone: '+974 4474 5555', emergency: '+974 4474 5555', lat: 25.6800, lng: 51.4970, notes: 'HMC — 115 beds, North Qatar'),
  Hospital(id: 'qa-cuban', name: 'The Cuban Hospital', nameAr: 'المستشفى الكوبي', country: HospitalCountry.qatar, city: 'Dukhan', type: HospitalType.hospital, phone: '+974 4015 7777', emergency: '+974 4015 7777', lat: 25.4230, lng: 50.7820, notes: 'HMC/Qatar-Cuba — West Qatar'),
  Hospital(id: 'qa-aster-doha', name: 'Aster Hospital Doha', nameAr: 'مستشفى أستر الدوحة', country: HospitalCountry.qatar, city: 'Doha', type: HospitalType.hospital, phone: '+974 4400 4400', lat: 25.2900, lng: 51.5100, notes: 'Private — Multi-specialty, 24/7'),
  Hospital(id: 'qa-qri', name: 'Qatar Rehabilitation Institute', nameAr: 'معهد قطر لإعادة التأهيل', country: HospitalCountry.qatar, city: 'Doha', type: HospitalType.hospital, phone: '+974 4439 6063', lat: 25.2970, lng: 51.5120, notes: 'HMC — Specialized rehab, 100 beds'),
  Hospital(id: 'qa-vet-center', name: 'Qatar Veterinary Center', nameAr: 'المركز البيطري القطري', country: HospitalCountry.qatar, city: 'Doha', type: HospitalType.veterinary, phone: '+974 4468 4444', lat: 25.3100, lng: 51.4800, notes: 'Government vet services + private clinics'),

  // ═══════════════════════════════════════════════════════════════════════════
  // KUWAIT — 14 hospitals
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'kw-mubarak', name: 'Mubarak Al-Kabeer Hospital', nameAr: 'مستشفى مبارك الكبير', country: HospitalCountry.kuwait, city: 'Jabriya', type: HospitalType.hospital, phone: '+965 2531 2700', emergency: '+965 2531 2700', lat: 29.3080, lng: 48.0750, notes: 'Teaching — Cardiac surgery, Neuro, Trauma'),
  Hospital(id: 'kw-jaber', name: 'Jaber Al-Ahmad Al-Sabah Hospital', nameAr: 'مستشفى جابر الأحمد الصباح', country: HospitalCountry.kuwait, city: 'South Surra', type: HospitalType.hospital, phone: '+965 2246 4700', emergency: '+965 2246 4700', lat: 29.2900, lng: 47.9920, notes: 'Newest — Smart hospital, 1168 beds'),
  Hospital(id: 'kw-amiri', name: 'Al Amiri Hospital', nameAr: 'المستشفى الأميري', country: HospitalCountry.kuwait, city: 'Kuwait City', type: HospitalType.hospital, phone: '+965 2245 0005', emergency: '+965 2245 0005', lat: 29.3780, lng: 47.9870, notes: 'Central govt — ER, Surgery, ICU'),
  Hospital(id: 'kw-dar-shifa', name: 'Dar Al Shifa Hospital', nameAr: 'مستشفى دار الشفاء', country: HospitalCountry.kuwait, city: 'Hawally', type: HospitalType.hospital, phone: '+965 1802 555', emergency: '+965 1802 555', lat: 29.3520, lng: 47.9710, notes: 'Private — Multi-specialty, 24/7 ER'),
  Hospital(id: 'kw-farwaniya', name: 'Farwaniya Hospital', nameAr: 'مستشفى الفروانية', country: HospitalCountry.kuwait, city: 'Sabah Al Nasser', type: HospitalType.hospital, phone: '+965 2488 8000', emergency: '+965 2488 8000', lat: 29.2702, lng: 47.9055, notes: 'Govt — 945 beds'),
  Hospital(id: 'kw-adan', name: 'Adan Hospital', nameAr: 'مستشفى العدان', country: HospitalCountry.kuwait, city: 'Hadiya', type: HospitalType.hospital, phone: '+965 2394 0600', emergency: '+965 2394 0600', lat: 29.1200, lng: 48.1000, notes: 'Govt — Al-Ahmadi, All specialties'),
  Hospital(id: 'kw-sabah', name: 'Sabah Hospital', nameAr: 'مستشفى الصباح', country: HospitalCountry.kuwait, city: 'Shuwaikh', type: HospitalType.hospital, phone: '+965 2481 2000', emergency: '+965 2481 2000', lat: 29.3500, lng: 47.9500, notes: 'Govt — Capital Governorate, ICU'),
  Hospital(id: 'kw-new-mowasat', name: 'New Mowasat Hospital', nameAr: 'مستشفى المواساة الجديد', country: HospitalCountry.kuwait, city: 'Salmiya', type: HospitalType.hospital, phone: '+965 1826 666', emergency: '+965 1826 666', lat: 29.3370, lng: 48.0760, notes: 'Private — Est. 1965, JCI'),
  Hospital(id: 'kw-royale-hayat', name: 'Royale Hayat Hospital', nameAr: 'مستشفى رويال حياة', country: HospitalCountry.kuwait, city: 'Jabriya', type: HospitalType.hospital, phone: '+965 2536 0000', emergency: '+965 2536 0000', lat: 29.3200, lng: 48.0300, notes: 'Premium private — OB/GYN focus'),
  Hospital(id: 'kw-hadi', name: 'Hadi Hospital', nameAr: 'مستشفى هادي', country: HospitalCountry.kuwait, city: 'Jabriya', type: HospitalType.hospital, phone: '+965 1828 282', emergency: '+965 1828 282', lat: 29.3180, lng: 48.0350, notes: 'First private (1976) — Diamond accreditation'),
  Hospital(id: 'kw-chest', name: 'Chest Diseases Hospital', nameAr: 'مستشفى الأمراض الصدرية', country: HospitalCountry.kuwait, city: 'Shuwaikh', type: HospitalType.hospital, phone: '+965 2481 0814', lat: 29.3550, lng: 47.9400, notes: 'Pulmonary & respiratory referral'),
  Hospital(id: 'kw-ibn-sina', name: 'Ibn Sina Hospital', nameAr: 'مستشفى ابن سينا', country: HospitalCountry.kuwait, city: 'Shuwaikh', type: HospitalType.hospital, phone: '+965 2484 0600', lat: 29.3420, lng: 47.9560, notes: 'Neurosurgery & neurology referral'),
  Hospital(id: 'kw-maternity', name: 'Maternity Hospital', nameAr: 'مستشفى الولادة', country: HospitalCountry.kuwait, city: 'Kuwait City', type: HospitalType.hospital, phone: '+965 2243 7381', lat: 29.3700, lng: 47.9900, notes: 'Govt — OB/GYN referral, NICU'),
  Hospital(id: 'kw-jahra', name: 'Jahra Hospital', nameAr: 'مستشفى الجهراء', country: HospitalCountry.kuwait, city: 'Jahra', type: HospitalType.hospital, phone: '+965 2458 3333', emergency: '+965 2458 3333', lat: 29.3350, lng: 47.6700, notes: 'Govt — Western Kuwait, 900 beds'),

  // ═══════════════════════════════════════════════════════════════════════════
  // OMAN — 12 hospitals
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'om-royal', name: 'Royal Hospital Muscat', nameAr: 'المستشفى السلطاني', country: HospitalCountry.oman, city: 'Muscat', type: HospitalType.hospital, phone: '+968 2459 9000', emergency: '+968 2459 9000', lat: 23.5950, lng: 58.4070, notes: 'National referral — Trauma, Cardiac, Transplant, 700 beds'),
  Hospital(id: 'om-khoula', name: 'Khoula Hospital', nameAr: 'مستشفى خولة', country: HospitalCountry.oman, city: 'Muscat', type: HospitalType.hospital, phone: '+968 2456 3625', emergency: '+968 2456 3625', lat: 23.6020, lng: 58.4880, notes: 'National trauma & ortho referral'),
  Hospital(id: 'om-sultan-qaboos', name: 'Sultan Qaboos University Hospital', nameAr: 'مستشفى جامعة السلطان قابوس', country: HospitalCountry.oman, city: 'Muscat', type: HospitalType.hospital, phone: '+968 2414 1000', emergency: '+968 2414 1000', lat: 23.5870, lng: 58.1740, notes: 'Teaching — Oncology, Neuro, 600 beds'),
  Hospital(id: 'om-muscat-private', name: 'Muscat Private Hospital', nameAr: 'مستشفى مسقط الخاص', country: HospitalCountry.oman, city: 'Muscat', type: HospitalType.hospital, phone: '+968 2458 3600', emergency: '+968 2458 3600', lat: 23.6000, lng: 58.5200, notes: 'Private — Multi-specialty, 24/7 ER'),
  Hospital(id: 'om-nahda', name: 'Al Nahdha Hospital', nameAr: 'مستشفى النهضة', country: HospitalCountry.oman, city: 'Muscat', type: HospitalType.hospital, phone: '+968 2250 3333', emergency: '+968 2250 3333', lat: 23.5888, lng: 58.5321, notes: 'MOH — ENT, Ophthalmology referral'),
  Hospital(id: 'om-badr-alsamaa', name: 'Badr Al Samaa Hospital', nameAr: 'مستشفى بدر السماء', country: HospitalCountry.oman, city: 'Muscat', type: HospitalType.hospital, phone: '+968 2271 7171', emergency: '+968 2271 7171', lat: 23.5860, lng: 58.5400, notes: 'Private — JCI, 30+ specialties'),
  Hospital(id: 'om-starcare', name: 'Starcare Hospital', nameAr: 'مستشفى ستاركير', country: HospitalCountry.oman, city: 'Muscat', type: HospitalType.hospital, phone: '+968 2455 7200', emergency: '+968 2455 7200', lat: 23.5950, lng: 58.1720, notes: 'Private — JCI/ISO, 35+ specialties'),
  Hospital(id: 'om-aster-raffah', name: 'Aster Al Raffah Hospital', nameAr: 'مستشفى أستر الرفة', country: HospitalCountry.oman, city: 'Muscat', type: HospitalType.hospital, phone: '+968 2457 1616', lat: 23.5980, lng: 58.4960, notes: 'Private — 70 beds, Multi-specialty'),
  Hospital(id: 'om-sohar', name: 'Sohar Hospital', nameAr: 'مستشفى صحار', country: HospitalCountry.oman, city: 'Sohar', type: HospitalType.hospital, phone: '+968 2684 4555', emergency: '+968 2684 4555', lat: 24.3259, lng: 56.6781, notes: 'MOH — 408 beds, Teaching, Tertiary'),
  Hospital(id: 'om-nizwa', name: 'Nizwa Hospital', nameAr: 'مستشفى نزوى', country: HospitalCountry.oman, city: 'Nizwa', type: HospitalType.hospital, phone: '+968 2521 1000', emergency: '+968 2521 1000', lat: 22.9330, lng: 57.5300, notes: 'MOH — 555+ beds, Burn unit, Regional referral'),
  Hospital(id: 'om-buraimi', name: 'Al Buraimi Hospital', nameAr: 'مستشفى البريمي', country: HospitalCountry.oman, city: 'Al Buraimi', type: HospitalType.hospital, phone: '+968 2565 0019', lat: 24.2450, lng: 55.7650, notes: 'MOH — Near UAE border, 271 beds'),
  Hospital(id: 'om-sur', name: 'Sur Hospital', nameAr: 'مستشفى صور', country: HospitalCountry.oman, city: 'Sur', type: HospitalType.hospital, phone: '+968 2556 4030', lat: 22.5700, lng: 59.5230, notes: 'MOH — Eastern Region, 308 beds'),

  // ═══════════════════════════════════════════════════════════════════════════
  // JORDAN — 14 hospitals
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'jo-jordan-hospital', name: 'Jordan Hospital', nameAr: 'المستشفى الأردني', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 560 7007', emergency: '+962 6 560 7007', lat: 31.9570, lng: 35.8560, notes: 'Major private — Cardiac, Oncology, ER'),
  Hospital(id: 'jo-king-hussein', name: 'King Hussein Medical Center', nameAr: 'مدينة الملك حسين الطبية', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 580 4800', emergency: '+962 6 580 4800', lat: 31.9850, lng: 35.8630, notes: 'Royal Medical Services — Military & Civilian trauma'),
  Hospital(id: 'jo-abdali', name: 'Abdali Hospital', nameAr: 'مستشفى العبدلي', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 592 2100', emergency: '+962 6 592 2100', lat: 31.9580, lng: 35.9110, notes: 'Private — Multi-specialty, 24/7 ER'),
  Hospital(id: 'jo-khaldi', name: 'Al Khalidi Hospital & Medical Center', nameAr: 'مستشفى الخالدي', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 464 4281', emergency: '+962 6 464 4281', lat: 31.9520, lng: 35.9000, notes: 'Private — Cardiac, Neuro, IVF'),
  Hospital(id: 'jo-university', name: 'Jordan University Hospital', nameAr: 'مستشفى الجامعة الأردنية', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 535 3444', emergency: '+962 6 535 3444', lat: 32.0130, lng: 35.8740, notes: 'Teaching — First JCI in Arab region'),
  Hospital(id: 'jo-prince-hamzah', name: 'Prince Hamzah Hospital', nameAr: 'مستشفى الأمير حمزة بن الحسين', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 505 3826', emergency: '+962 6 505 3826', lat: 31.9844, lng: 35.9361, notes: 'Govt — 436 beds, Cardiac surgery, Transplants'),
  Hospital(id: 'jo-islamic', name: 'Islamic Hospital', nameAr: 'المستشفى الإسلامي', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 510 1010', emergency: '+962 6 510 1010', lat: 31.9560, lng: 35.9050, notes: 'Non-profit charity — 273 beds'),
  Hospital(id: 'jo-specialty', name: 'The Specialty Hospital', nameAr: 'المستشفى التخصصي', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 200 1111', emergency: '+962 6 200 1111', lat: 31.9700, lng: 35.8900, notes: 'Premier private — 265 beds, 750 consultants'),
  Hospital(id: 'jo-ibn-alhaytham', name: 'Ibn Al Haytham Hospital', nameAr: 'مستشفى ابن الهيثم', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 520 5555', emergency: '+962 6 520 5555', lat: 31.9630, lng: 35.8650, notes: 'Private — 207 beds'),
  Hospital(id: 'jo-bashir', name: 'Al Bashir Hospital', nameAr: 'مستشفى البشير', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 477 7111', emergency: '+962 6 477 7111', lat: 31.9430, lng: 35.9250, notes: 'Largest MOH — 1000 beds, All specialties'),
  Hospital(id: 'jo-istiklal', name: 'Istiklal Military Hospital', nameAr: 'المستشفى العسكري الاستقلال', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 500 6750', lat: 31.9800, lng: 35.8600, notes: 'Armed Forces — All specialties'),
  Hospital(id: 'jo-kauh-irbid', name: 'King Abdullah University Hospital', nameAr: 'مستشفى الملك عبدالله الجامعي', country: HospitalCountry.jordan, city: 'Irbid', type: HospitalType.hospital, phone: '+962 2 720 0600', emergency: '+962 2 720 0600', lat: 32.4900, lng: 35.9900, notes: 'JUST — 683 beds, Largest in North Jordan'),
  Hospital(id: 'jo-princess-basma', name: 'Princess Basma Teaching Hospital', nameAr: 'مستشفى الأميرة بسمة التعليمي', country: HospitalCountry.jordan, city: 'Irbid', type: HospitalType.hospital, phone: '+962 2 724 5822', lat: 32.5500, lng: 35.8600, notes: 'MOH — 265 beds, North Jordan referral'),
  Hospital(id: 'jo-hussein-cancer', name: 'King Hussein Cancer Center', nameAr: 'مركز الحسين للسرطان', country: HospitalCountry.jordan, city: 'Amman', type: HospitalType.hospital, phone: '+962 6 530 0460', lat: 31.9770, lng: 35.8690, notes: 'Largest cancer center in ME — 352 beds, JCI'),

  // ═══════════════════════════════════════════════════════════════════════════
  // LEBANON — 15 hospitals
  // ═══════════════════════════════════════════════════════════════════════════

  Hospital(id: 'lb-aubmc', name: 'AUBMC (American University of Beirut Medical Center)', nameAr: 'المركز الطبي في الجامعة الأمريكية في بيروت', country: HospitalCountry.lebanon, city: 'Beirut', type: HospitalType.hospital, phone: '+961 1 350 000', emergency: '+961 1 350 000', lat: 33.9000, lng: 35.4790, notes: 'Top teaching — Trauma, Oncology, Transplant, 350 beds'),
  Hospital(id: 'lb-hotel-dieu', name: 'Hotel-Dieu de France Hospital', nameAr: 'مستشفى أوتيل ديو دو فرانس', country: HospitalCountry.lebanon, city: 'Beirut', type: HospitalType.hospital, phone: '+961 1 615 300', emergency: '+961 1 615 300', lat: 33.8920, lng: 35.5080, notes: 'Major — Cardiac surgery, Neuro, 24/7 ER, 600 beds'),
  Hospital(id: 'lb-rafik-hariri', name: 'Rafik Hariri University Hospital', nameAr: 'مستشفى رفيق الحريري الجامعي', country: HospitalCountry.lebanon, city: 'Beirut', type: HospitalType.hospital, phone: '+961 1 830 000', emergency: '+961 1 830 000', lat: 33.8460, lng: 35.4930, notes: 'Largest govt — Trauma, Infectious diseases, 400 beds'),
  Hospital(id: 'lb-mount-lebanon', name: 'Mount Lebanon Hospital', nameAr: 'مستشفى جبل لبنان', country: HospitalCountry.lebanon, city: 'Hazmieh', type: HospitalType.hospital, phone: '+961 5 957 000', emergency: '+961 5 957 000', lat: 33.8530, lng: 35.5410, notes: 'Private — General surgery, Ortho, Maternity'),
  Hospital(id: 'lb-clemenceau', name: 'Clemenceau Medical Center', nameAr: 'مركز كليمنصو الطبي', country: HospitalCountry.lebanon, city: 'Beirut', type: HospitalType.hospital, phone: '+961 1 372 888', emergency: '+961 1 372 888', lat: 33.8960, lng: 35.4850, notes: 'Johns Hopkins affiliate — Multi-specialty'),
  Hospital(id: 'lb-saint-george', name: 'Saint George Hospital University Medical Center', nameAr: 'مستشفى القديس جاورجيوس الجامعي', country: HospitalCountry.lebanon, city: 'Beirut', type: HospitalType.hospital, phone: '+961 1 441 000', emergency: '+961 1 441 000', lat: 33.8950, lng: 35.5230, notes: 'Oldest teaching (1878) — 330 beds'),
  Hospital(id: 'lb-lau-rizk', name: 'LAU Medical Center - Rizk Hospital', nameAr: 'المركز الطبي لجامعة LAU - مستشفى رزق', country: HospitalCountry.lebanon, city: 'Beirut', type: HospitalType.hospital, phone: '+961 1 200 800', emergency: '+961 1 200 800', lat: 33.8900, lng: 35.5220, notes: 'University medical center — LAU affiliated'),
  Hospital(id: 'lb-geitaoui', name: 'Lebanese Hospital Geitaoui', nameAr: 'المستشفى اللبناني الجعيتاوي الجامعي', country: HospitalCountry.lebanon, city: 'Beirut', type: HospitalType.hospital, phone: '+961 1 590 000', emergency: '+961 1 590 000', lat: 33.8940, lng: 35.5309, notes: 'Founded 1927 — 250 beds, 30+ specialties'),
  Hospital(id: 'lb-makassed', name: 'Makassed General Hospital', nameAr: 'مستشفى المقاصد الخيرية الإسلامية العام', country: HospitalCountry.lebanon, city: 'Beirut', type: HospitalType.hospital, phone: '+961 1 636 000', emergency: '+961 1 636 000', lat: 33.8750, lng: 35.5050, notes: 'Islamic charity — 230 beds, 24/7 ER'),
  Hospital(id: 'lb-sahel', name: 'Sahel General Hospital', nameAr: 'مستشفى الساحل العام', country: HospitalCountry.lebanon, city: 'Beirut', type: HospitalType.hospital, phone: '+961 1 858 333', emergency: '+961 1 858 333', lat: 33.8640, lng: 35.4810, notes: 'Govt affiliate — 220 beds, Southern Beirut'),
  Hospital(id: 'lb-haroun', name: 'St. Joseph Hospital (Haroun)', nameAr: 'مستشفى مار يوسف حارون', country: HospitalCountry.lebanon, city: 'Dora', type: HospitalType.hospital, phone: '+961 1 256 256', lat: 33.8980, lng: 35.5760, notes: 'Est. 1973 — 150 beds, Multi-specialty'),
  Hospital(id: 'lb-hammoud', name: 'Hammoud Hospital University Medical Center', nameAr: 'مستشفى حمود', country: HospitalCountry.lebanon, city: 'Sidon', type: HospitalType.hospital, phone: '+961 7 723 111', emergency: '+961 7 723 111', lat: 33.5600, lng: 35.3780, notes: '325 beds — Largest in South Lebanon'),
  Hospital(id: 'lb-tripoli-govt', name: 'Tripoli Governmental Hospital', nameAr: 'مستشفى طرابلس الحكومي', country: HospitalCountry.lebanon, city: 'Tripoli', type: HospitalType.hospital, phone: '+961 6 385 300', emergency: '+961 6 385 300', lat: 34.4450, lng: 35.8300, notes: 'Govt — Trauma, 24/7 ER, North Lebanon'),
  Hospital(id: 'lb-nini', name: 'Nini Hospital', nameAr: 'مستشفى نيني', country: HospitalCountry.lebanon, city: 'Tripoli', type: HospitalType.hospital, phone: '+961 6 444 744', emergency: '+961 6 444 744', lat: 34.4360, lng: 35.8450, notes: 'Private — 200 beds, North Lebanon'),
  Hospital(id: 'lb-haykel', name: 'Haykel Hospital', nameAr: 'مستشفى هيكل', country: HospitalCountry.lebanon, city: 'Tripoli', type: HospitalType.hospital, phone: '+961 6 628 600', lat: 34.4400, lng: 35.8350, notes: 'Private — Multi-specialty, North Lebanon'),
];
