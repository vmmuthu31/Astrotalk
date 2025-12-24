class NakshatraData {
  static const Map<String, Map<String, String>> info = {
    'Ashwini': {'ruler': 'Ketu', 'deity': 'Ashwini Kumaras', 'element': 'Earth', 'symbol': 'Horse Head'},
    'Bharani': {'ruler': 'Venus', 'deity': 'Yama', 'element': 'Earth', 'symbol': 'Yoni'},
    'Krittika': {'ruler': 'Sun', 'deity': 'Agni', 'element': 'Earth', 'symbol': 'Razor'},
    'Rohini': {'ruler': 'Moon', 'deity': 'Brahma', 'element': 'Earth', 'symbol': 'Cart'},
    'Mrigashira': {'ruler': 'Mars', 'deity': 'Soma', 'element': 'Earth', 'symbol': 'Deer Head'},
    'Ardra': {'ruler': 'Rahu', 'deity': 'Rudra', 'element': 'Water', 'symbol': 'Teardrop'},
    'Punarvasu': {'ruler': 'Jupiter', 'deity': 'Aditi', 'element': 'Water', 'symbol': 'Bow'},
    'Pushya': {'ruler': 'Saturn', 'deity': 'Brihaspati', 'element': 'Water', 'symbol': 'Flower'},
    'Ashlesha': {'ruler': 'Mercury', 'deity': 'Nagas', 'element': 'Water', 'symbol': 'Serpent'},
    'Magha': {'ruler': 'Ketu', 'deity': 'Pitris', 'element': 'Water', 'symbol': 'Throne'},
    'Purva Phalguni': {'ruler': 'Venus', 'deity': 'Bhaga', 'element': 'Water', 'symbol': 'Hammock'},
    'Uttara Phalguni': {'ruler': 'Sun', 'deity': 'Aryaman', 'element': 'Fire', 'symbol': 'Bed'},
    'Hasta': {'ruler': 'Moon', 'deity': 'Savitar', 'element': 'Fire', 'symbol': 'Hand'},
    'Chitra': {'ruler': 'Mars', 'deity': 'Tvashtar', 'element': 'Fire', 'symbol': 'Pearl'},
    'Swati': {'ruler': 'Rahu', 'deity': 'Vayu', 'element': 'Fire', 'symbol': 'Coral'},
    'Vishakha': {'ruler': 'Jupiter', 'deity': 'Indragni', 'element': 'Fire', 'symbol': 'Archway'},
    'Anuradha': {'ruler': 'Saturn', 'deity': 'Mitra', 'element': 'Fire', 'symbol': 'Lotus'},
    'Jyeshtha': {'ruler': 'Mercury', 'deity': 'Indra', 'element': 'Air', 'symbol': 'Earring'},
    'Mula': {'ruler': 'Ketu', 'deity': 'Nirrti', 'element': 'Air', 'symbol': 'Root'},
    'Purva Ashadha': {'ruler': 'Venus', 'deity': 'Apas', 'element': 'Air', 'symbol': 'Fan'},
    'Uttara Ashadha': {'ruler': 'Sun', 'deity': 'Vishvadevas', 'element': 'Air', 'symbol': 'Tusk'},
    'Shravana': {'ruler': 'Moon', 'deity': 'Vishnu', 'element': 'Air', 'symbol': 'Ear'},
    'Dhanishta': {'ruler': 'Mars', 'deity': 'Vasus', 'element': 'Ether', 'symbol': 'Drum'},
    'Shatabhisha': {'ruler': 'Rahu', 'deity': 'Varuna', 'element': 'Ether', 'symbol': 'Circle'},
    'Purva Bhadrapada': {'ruler': 'Jupiter', 'deity': 'Ajaikapada', 'element': 'Ether', 'symbol': 'Sword'},
    'Uttara Bhadrapada': {'ruler': 'Saturn', 'deity': 'Ahirbudhnya', 'element': 'Ether', 'symbol': 'Twins'},
    'Revati': {'ruler': 'Mercury', 'deity': 'Pushan', 'element': 'Ether', 'symbol': 'Fish'},
  };

  static const List<String> names = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni',
    'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
    'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana',
    'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static const List<String> rashis = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  static const Map<String, IconInfo> luckyDirectionIcons = {
    'North': IconInfo(name: 'arrow_upward'),
    'South': IconInfo(name: 'arrow_downward'),
    'East': IconInfo(name: 'arrow_forward'),
    'West': IconInfo(name: 'arrow_back'),
    'North-East': IconInfo(name: 'north_east'),
    'North-West': IconInfo(name: 'north_west'),
    'South-East': IconInfo(name: 'south_east'),
    'South-West': IconInfo(name: 'south_west'),
  };
}

class IconInfo {
  final String name;
  const IconInfo({required this.name});
}
