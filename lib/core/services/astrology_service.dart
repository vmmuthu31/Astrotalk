import 'dart:math';

class AstrologyService {
  static const List<String> _nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni',
    'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
    'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana',
    'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static const List<Map<String, dynamic>> _rashiData = [
    {'name': 'Mesha', 'english': 'Aries', 'startMonth': 4, 'startDay': 14, 'endMonth': 5, 'endDay': 14},
    {'name': 'Vrishabha', 'english': 'Taurus', 'startMonth': 5, 'startDay': 15, 'endMonth': 6, 'endDay': 14},
    {'name': 'Mithuna', 'english': 'Gemini', 'startMonth': 6, 'startDay': 15, 'endMonth': 7, 'endDay': 14},
    {'name': 'Karka', 'english': 'Cancer', 'startMonth': 7, 'startDay': 15, 'endMonth': 8, 'endDay': 14},
    {'name': 'Simha', 'english': 'Leo', 'startMonth': 8, 'startDay': 15, 'endMonth': 9, 'endDay': 15},
    {'name': 'Kanya', 'english': 'Virgo', 'startMonth': 9, 'startDay': 16, 'endMonth': 10, 'endDay': 15},
    {'name': 'Tula', 'english': 'Libra', 'startMonth': 10, 'startDay': 16, 'endMonth': 11, 'endDay': 14},
    {'name': 'Vrishchika', 'english': 'Scorpio', 'startMonth': 11, 'startDay': 15, 'endMonth': 12, 'endDay': 14},
    {'name': 'Dhanu', 'english': 'Sagittarius', 'startMonth': 12, 'startDay': 15, 'endMonth': 1, 'endDay': 13},
    {'name': 'Makara', 'english': 'Capricorn', 'startMonth': 1, 'startDay': 14, 'endMonth': 2, 'endDay': 11},
    {'name': 'Kumbha', 'english': 'Aquarius', 'startMonth': 2, 'startDay': 12, 'endMonth': 3, 'endDay': 13},
    {'name': 'Meena', 'english': 'Pisces', 'startMonth': 3, 'startDay': 14, 'endMonth': 4, 'endDay': 13},
  ];

  static const Map<String, Map<String, dynamic>> _rashiPredictionData = {
    'Mesha': {
      'colors': ['Red', 'Coral', 'Crimson', 'Maroon', 'Scarlet'],
      'colorHexes': ['#FF0000', '#FF7F50', '#DC143C', '#800000', '#FF2400'],
      'numbers': [1, 9, 8],
      'directions': ['East', 'North-East'],
      'mantras': ['ॐ श्री गणेशाय नमः', 'ॐ नमो भगवते वासुदेवाय'],
    },
    'Vrishabha': {
      'colors': ['White', 'Green', 'Pink', 'Cream', 'Aquamarine'],
      'colorHexes': ['#FFFFFF', '#228B22', '#FFC0CB', '#FFFDD0', '#7FFFD4'],
      'numbers': [2, 6, 9],
      'directions': ['South-East', 'South'],
      'mantras': ['ॐ शुक्राय नमः', 'ॐ लक्ष्मी नारायणाय नमः'],
    },
    'Mithuna': {
      'colors': ['Green', 'Yellow', 'Light Blue', 'White', 'Lime'],
      'colorHexes': ['#228B22', '#FFFF00', '#ADD8E6', '#FFFFFF', '#32CD32'],
      'numbers': [3, 5, 6],
      'directions': ['West', 'North-West'],
      'mantras': ['ॐ बुधाय नमः', 'ॐ श्री सरस्वत्यै नमः'],
    },
    'Karka': {
      'colors': ['White', 'Silver', 'Pearl', 'Cream', 'Orange'],
      'colorHexes': ['#FFFFFF', '#C0C0C0', '#FDEEF4', '#FFFDD0', '#FFA500'],
      'numbers': [2, 4, 7],
      'directions': ['North', 'North-West'],
      'mantras': ['ॐ चंद्राय नमः', 'ॐ श्री दुर्गायै नमः'],
    },
    'Simha': {
      'colors': ['Gold', 'Orange', 'Saffron', 'Yellow', 'Ruby Red'],
      'colorHexes': ['#FFD700', '#FFA500', '#FF6F00', '#FFFF00', '#E0115F'],
      'numbers': [1, 4, 5],
      'directions': ['East', 'South-East'],
      'mantras': ['ॐ सूर्याय नमः', 'ॐ श्री रामाय नमः'],
    },
    'Kanya': {
      'colors': ['Green', 'Yellow', 'White', 'Gray', 'Emerald'],
      'colorHexes': ['#228B22', '#FFFF00', '#FFFFFF', '#808080', '#50C878'],
      'numbers': [3, 5, 6],
      'directions': ['South', 'South-West'],
      'mantras': ['ॐ बुधाय नमः', 'ॐ श्री विष्णवे नमः'],
    },
    'Tula': {
      'colors': ['White', 'Blue', 'Pink', 'Turquoise', 'Light Green'],
      'colorHexes': ['#FFFFFF', '#0000FF', '#FFC0CB', '#40E0D0', '#90EE90'],
      'numbers': [2, 6, 9],
      'directions': ['West', 'North-West'],
      'mantras': ['ॐ शुक्राय नमः', 'ॐ श्री कृष्णाय नमः'],
    },
    'Vrishchika': {
      'colors': ['Red', 'Maroon', 'Crimson', 'Black', 'Chocolate'],
      'colorHexes': ['#FF0000', '#800000', '#DC143C', '#000000', '#D2691E'],
      'numbers': [1, 4, 9],
      'directions': ['North', 'North-East'],
      'mantras': ['ॐ मंगलाय नमः', 'ॐ नमः शिवाय'],
    },
    'Dhanu': {
      'colors': ['Yellow', 'Gold', 'Saffron', 'Orange', 'Beige'],
      'colorHexes': ['#FFFF00', '#FFD700', '#FF6F00', '#FFA500', '#F5F5DC'],
      'numbers': [3, 5, 8],
      'directions': ['East', 'North-East'],
      'mantras': ['ॐ बृहस्पतये नमः', 'ॐ श्री हनुमते नमः'],
    },
    'Makara': {
      'colors': ['Black', 'Navy Blue', 'Brown', 'Dark Green', 'Gray'],
      'colorHexes': ['#000000', '#000080', '#8B4513', '#006400', '#808080'],
      'numbers': [4, 8, 6],
      'directions': ['South', 'South-West'],
      'mantras': ['ॐ शनैश्चराय नमः', 'ॐ श्री शनि देवाय नमः'],
    },
    'Kumbha': {
      'colors': ['Blue', 'Black', 'Electric Blue', 'Violet', 'Gray'],
      'colorHexes': ['#0000FF', '#000000', '#7DF9FF', '#8F00FF', '#808080'],
      'numbers': [4, 8, 7],
      'directions': ['West', 'South-West'],
      'mantras': ['ॐ शनैश्चराय नमः', 'ॐ श्री राधा कृष्णाय नमः'],
    },
    'Meena': {
      'colors': ['Yellow', 'Sea Green', 'White', 'Orange', 'Pink'],
      'colorHexes': ['#FFFF00', '#2E8B57', '#FFFFFF', '#FFA500', '#FFC0CB'],
      'numbers': [3, 7, 9],
      'directions': ['North', 'North-East'],
      'mantras': ['ॐ बृहस्पतये नमः', 'ॐ श्री विष्णवे नमः'],
    },
  };

  static String getRashiFromDate(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    for (final rashi in _rashiData) {
      final startMonth = rashi['startMonth'] as int;
      final startDay = rashi['startDay'] as int;
      final endMonth = rashi['endMonth'] as int;
      final endDay = rashi['endDay'] as int;

      if (startMonth <= endMonth) {
        if ((month == startMonth && day >= startDay) ||
            (month == endMonth && day <= endDay) ||
            (month > startMonth && month < endMonth)) {
          return rashi['name'] as String;
        }
      } else {
        if ((month == startMonth && day >= startDay) ||
            (month == endMonth && day <= endDay) ||
            (month > startMonth) ||
            (month < endMonth)) {
          return rashi['name'] as String;
        }
      }
    }

    return 'Mesha';
  }

  static String getRashiEnglish(String rashiName) {
    for (final rashi in _rashiData) {
      if (rashi['name'] == rashiName) {
        return rashi['english'] as String;
      }
    }
    return rashiName;
  }

  static String getNakshatraFromDate(DateTime birthDate, String birthTimeStr) {
    final parts = birthTimeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final dayOfYear = _getDayOfYear(birthDate);
    final timeValue = hour * 60 + minute;

    final lunarDay = (dayOfYear * 27.3 / 365.25).floor();
    final timeOffset = (timeValue / (24 * 60) * 27 / 27.3).floor();

    final nakshatraIndex = ((lunarDay + timeOffset + birthDate.year) % 27).abs();

    return _nakshatras[nakshatraIndex];
  }

  static int _getDayOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    return date.difference(firstDayOfYear).inDays + 1;
  }

  static Map<String, dynamic> generateDailyPrediction({
    required String rashi,
    required DateTime date,
  }) {
    final rashiData = _rashiPredictionData[rashi] ?? _rashiPredictionData['Mesha']!;
    final random = Random(date.year * 1000 + date.month * 100 + date.day + rashi.hashCode);

    final colors = rashiData['colors'] as List<String>;
    final colorHexes = rashiData['colorHexes'] as List<String>;
    final numbers = rashiData['numbers'] as List<int>;
    final directions = rashiData['directions'] as List<String>;
    final mantras = rashiData['mantras'] as List<String>;

    final colorIndex = random.nextInt(colors.length);

    final hour = 5 + random.nextInt(6);
    final endHour = hour + 2 + random.nextInt(2);

    return {
      'luckyColor': colors[colorIndex],
      'luckyColorHex': colorHexes[colorIndex],
      'luckyNumber': numbers[random.nextInt(numbers.length)],
      'luckyDirection': directions[random.nextInt(directions.length)],
      'luckyTime': '${hour}:00 AM - ${endHour > 12 ? endHour - 12 : endHour}:00 ${endHour >= 12 ? 'PM' : 'AM'}',
      'mantra': mantras[random.nextInt(mantras.length)],
    };
  }

  static List<String> get allNakshatras => _nakshatras;

  static List<String> get allRashis => _rashiData.map((r) => r['name'] as String).toList();

  static List<String> get allRashisEnglish => _rashiData.map((r) => r['english'] as String).toList();
}
