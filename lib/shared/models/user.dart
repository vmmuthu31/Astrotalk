class User {
  final String id;
  final String name;
  final String? birthDate;
  final String? birthTime;
  final String? birthPlace;
  final String? nakshatra;
  final String? rashi;
  final bool isSubscribed;
  final bool notificationsEnabled;
  final String notificationTime;

  const User({
    required this.id,
    required this.name,
    this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.nakshatra,
    this.rashi,
    this.isSubscribed = false,
    this.notificationsEnabled = true,
    this.notificationTime = "08:00",
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate,
        'birthTime': birthTime,
        'birthPlace': birthPlace,
        'nakshatra': nakshatra,
        'rashi': rashi,
        'isSubscribed': isSubscribed,
        'notificationsEnabled': notificationsEnabled,
        'notificationTime': notificationTime,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        birthDate: json['birthDate'] as String?,
        birthTime: json['birthTime'] as String?,
        birthPlace: json['birthPlace'] as String?,
        nakshatra: json['nakshatra'] as String?,
        rashi: json['rashi'] as String?,
        isSubscribed: json['isSubscribed'] as bool? ?? false,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        notificationTime: json['notificationTime'] as String? ?? "08:00",
      );

  User copyWith({
    String? id,
    String? name,
    String? birthDate,
    String? birthTime,
    String? birthPlace,
    String? nakshatra,
    String? rashi,
    bool? isSubscribed,
    bool? notificationsEnabled,
    String? notificationTime,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      nakshatra: nakshatra ?? this.nakshatra,
      rashi: rashi ?? this.rashi,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }
}
