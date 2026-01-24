import 'dart:math';

class VedicAstrologyService {
  static const List<String> _rashis = [
    'Mesha',      // Aries
    'Vrishabha',  // Taurus
    'Mithuna',    // Gemini
    'Karka',      // Cancer
    'Simha',      // Leo
    'Kanya',      // Virgo
    'Tula',       // Libra
    'Vrishchika', // Scorpio
    'Dhanu',      // Sagittarius
    'Makara',     // Capricorn
    'Kumbha',     // Aquarius
    'Meena',      // Pisces
  ];

  static const List<String> _rashisEnglish = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
  ];

  static const List<String> _nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni',
    'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
    'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana',
    'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static double getLahiriAyanamsha(DateTime date) {
    final year = date.year + (date.month - 1) / 12.0 + (date.day - 1) / 365.25;
    
    const referenceYear = 2000.0;
    const referenceAyanamsha = 23.856;
    const annualPrecession = 50.29 / 3600.0;
    
    return referenceAyanamsha + (year - referenceYear) * annualPrecession;
  }

  static double _dateToJulianDay(DateTime dateUtc) {
    int y = dateUtc.year;
    int m = dateUtc.month;
    double d = dateUtc.day + dateUtc.hour / 24.0 + dateUtc.minute / 1440.0 + dateUtc.second / 86400.0;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  static double _getMoonLongitude(DateTime birthDateTimeUtc) {
    final jd = _dateToJulianDay(birthDateTimeUtc);
    final t = (jd - 2451545.0) / 36525.0;
    
    double lp = 218.3164477 + 481267.88123421 * t -
        0.0015786 * t * t +
        t * t * t / 538841.0 -
        t * t * t * t / 65194000.0;
    
    double d = 297.8501921 + 445267.1114034 * t -
        0.0018819 * t * t +
        t * t * t / 545868.0 -
        t * t * t * t / 113065000.0;
    
    double m = 357.5291092 + 35999.0502909 * t -
        0.0001536 * t * t +
        t * t * t / 24490000.0;
    
    double mp = 134.9633964 + 477198.8675055 * t +
        0.0087414 * t * t +
        t * t * t / 69699.0 -
        t * t * t * t / 14712000.0;
    
    double f = 93.2720950 + 483202.0175233 * t -
        0.0036539 * t * t -
        t * t * t / 3526000.0 +
        t * t * t * t / 863310000.0;
    
    double om = 125.0445479 - 1934.1362891 * t +
        0.0020754 * t * t +
        t * t * t / 467441.0 -
        t * t * t * t / 60616000.0;
    
    d = d * pi / 180.0;
    m = m * pi / 180.0;
    mp = mp * pi / 180.0;
    f = f * pi / 180.0;
    om = om * pi / 180.0;
    
    double e = 1.0 - 0.002516 * t - 0.0000074 * t * t;
    
    double sl = 0.0;
    sl += 6.288774 * sin(mp);
    sl += 1.274027 * sin(2 * d - mp);
    sl += 0.658314 * sin(2 * d);
    sl += 0.213618 * sin(2 * mp);
    sl -= 0.185116 * e * sin(m);
    sl -= 0.114332 * sin(2 * f);
    sl += 0.058793 * sin(2 * d - 2 * mp);
    sl += 0.057066 * e * sin(2 * d - m - mp);
    sl += 0.053322 * sin(2 * d + mp);
    sl += 0.045758 * e * sin(2 * d - m);
    sl -= 0.040923 * e * sin(m - mp);
    sl -= 0.034720 * sin(d);
    sl -= 0.030383 * e * sin(m + mp);
    sl += 0.015327 * sin(2 * d - 2 * f);
    sl -= 0.012528 * sin(mp + 2 * f);
    sl += 0.010980 * sin(mp - 2 * f);
    sl += 0.010675 * sin(4 * d - mp);
    sl += 0.010034 * sin(3 * mp);
    sl += 0.008548 * sin(4 * d - 2 * mp);
    sl -= 0.007888 * e * sin(2 * d + m - mp);
    sl -= 0.006766 * e * sin(2 * d + m);
    sl -= 0.005163 * sin(d - mp);
    sl += 0.004987 * e * sin(d + m);
    sl += 0.004036 * e * sin(2 * d - m + mp);
    
    double moonLongitude = lp + sl;
    
    moonLongitude = moonLongitude % 360.0;
    if (moonLongitude < 0) moonLongitude += 360.0;
    
    return moonLongitude;
  }

  static DateTime _convertIstToUtc(DateTime istDateTime) {
    return istDateTime.subtract(const Duration(hours: 5, minutes: 30));
  }

  static String calculateRashi(DateTime birthDate, String birthTime) {
    final timeParts = birthTime.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
    
    final birthDateTimeIst = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      hour,
      minute,
    );
    
    final birthDateTimeUtc = _convertIstToUtc(birthDateTimeIst);
    
    double moonLongitude = _getMoonLongitude(birthDateTimeUtc);
    
    final ayanamsha = getLahiriAyanamsha(birthDateTimeUtc);
    double siderealMoonLongitude = moonLongitude - ayanamsha;
    
    if (siderealMoonLongitude < 0) siderealMoonLongitude += 360.0;
    
    final rashiIndex = (siderealMoonLongitude / 30.0).floor() % 12;
    
    return _rashis[rashiIndex];
  }

  static String calculateNakshatra(DateTime birthDate, String birthTime) {
    final timeParts = birthTime.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
    
    final birthDateTimeIst = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      hour,
      minute,
    );
    
    final birthDateTimeUtc = _convertIstToUtc(birthDateTimeIst);
    
    double moonLongitude = _getMoonLongitude(birthDateTimeUtc);
    
    final ayanamsha = getLahiriAyanamsha(birthDateTimeUtc);
    double siderealMoonLongitude = moonLongitude - ayanamsha;
    
    if (siderealMoonLongitude < 0) siderealMoonLongitude += 360.0;
    
    const nakshatraSpan = 360.0 / 27.0;
    final nakshatraIndex = (siderealMoonLongitude / nakshatraSpan).floor() % 27;
    
    return _nakshatras[nakshatraIndex];
  }

  static String getRashiEnglish(String rashiName) {
    final index = _rashis.indexOf(rashiName);
    if (index >= 0 && index < _rashisEnglish.length) {
      return _rashisEnglish[index];
    }
    return rashiName;
  }

  static List<String> get allRashis => _rashis;
  static List<String> get allRashisEnglish => _rashisEnglish;
  static List<String> get allNakshatras => _nakshatras;
}

