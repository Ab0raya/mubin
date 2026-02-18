class PrayerTimingsModel {
  final Map<String, String> timings;
  final String date;
  final String hijriDate;
  final String hijriMonthEnglish;
  final String hijriMonthArabic;
  final String hijriDay;
  final String hijriYear;
  final String hijriWeekdayEnglish;
  final String hijriWeekdayArabic;

  PrayerTimingsModel({
    required this.timings,
    required this.date,
    required this.hijriDate,
    required this.hijriMonthEnglish,
    required this.hijriMonthArabic,
    required this.hijriDay,
    required this.hijriYear,
    required this.hijriWeekdayEnglish,
    required this.hijriWeekdayArabic,
  });

  factory PrayerTimingsModel.fromJson(Map<String, dynamic> json) {
    final hijri = json['data']['date']['hijri'];
    final weekday = hijri['weekday'];
    final month = hijri['month'];

    return PrayerTimingsModel(
      timings: Map<String, String>.from(json['data']['timings']),
      date: json['data']['date']['gregorian']['date'],
      hijriDate: hijri['date'],
      hijriDay: hijri['day'],
      hijriYear: hijri['year'],
      hijriMonthEnglish: month['en'],
      hijriMonthArabic: month['ar'],
      hijriWeekdayEnglish: weekday['en'],
      hijriWeekdayArabic: weekday['ar'],
    );
  }

  String get fajr => timings['Fajr'] ?? '';
  String get dhuhr => timings['Dhuhr'] ?? '';
  String get asr => timings['Asr'] ?? '';
  String get maghrib => timings['Maghrib'] ?? '';
  String get isha => timings['Isha'] ?? '';
}
