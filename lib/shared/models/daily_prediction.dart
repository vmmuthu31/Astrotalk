class DailyPrediction {
  final String id;
  final String userId;
  final String date;
  final String luckyColor;
  final String luckyColorHex;
  final int luckyNumber;
  final String luckyDirection;
  final String luckyTime;
  final String? mantra;

  const DailyPrediction({
    required this.id,
    required this.userId,
    required this.date,
    required this.luckyColor,
    required this.luckyColorHex,
    required this.luckyNumber,
    required this.luckyDirection,
    required this.luckyTime,
    this.mantra,
  });

  factory DailyPrediction.fromJson(Map<String, dynamic> json) => DailyPrediction(
        id: json['id'] as String,
        userId: json['userId'] as String,
        date: json['date'] as String,
        luckyColor: json['luckyColor'] as String,
        luckyColorHex: json['luckyColorHex'] as String,
        luckyNumber: json['luckyNumber'] as int,
        luckyDirection: json['luckyDirection'] as String,
        luckyTime: json['luckyTime'] as String,
        mantra: json['mantra'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'date': date,
        'luckyColor': luckyColor,
        'luckyColorHex': luckyColorHex,
        'luckyNumber': luckyNumber,
        'luckyDirection': luckyDirection,
        'luckyTime': luckyTime,
        'mantra': mantra,
      };

  static DailyPrediction mock() => const DailyPrediction(
        id: '1',
        userId: '1',
        date: '2024-12-24',
        luckyColor: 'Saffron',
        luckyColorHex: '#FF6F00',
        luckyNumber: 7,
        luckyDirection: 'North-East',
        luckyTime: '6:00 AM - 8:00 AM',
        mantra: 'ॐ गं गणपतये नमः',
      );
}
