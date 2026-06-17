import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import '../data/models/prayer_timings_model.dart';
import '../services/api_service.dart';

import 'dart:math';
import '../data/models/quran_data.dart';

class HomeController extends GetxController {
  var currentTime = DateTime.now().obs;
  var currentLanguage = 'en'.obs;
  var nextPrayerName = ''.obs;
  var nextPrayerTime = DateTime.now().obs;
  var timeUntilNextPrayer = ''.obs;
  var prayedCount = 0.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // User & Date info
  var userName = 'Mubin'.obs;
  var hijriDateString = ''.obs;

  // Verse of the Day
  final verseOfTheDay = Rx<Ayah?>(null);

  final prayers = <Map<String, dynamic>>[].obs;
  // Final ApiService
  final ApiService _apiService = Get.find<ApiService>();
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    updateVerseOfTheDay();
    updateHijriDate();

    // Start fetching data immediately
    fetchPrayerTimes();

    // Handle permissions separately (don't await them for data)
    _initializePermissions();

    // Update time and countdown every second
    Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()).listen((
      time,
    ) {
      currentTime.value = time;
      updateCountdown();
    });
  }

  Future<void> _initializePermissions() async {
    // 1. Request Notification Permission
    bool isNotificationAllowed = await AwesomeNotifications()
        .isNotificationAllowed();
    if (!isNotificationAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // 2. Request Location Permission (sequential)
    await _checkLocationPermission();
  }

  void updateVerseOfTheDay() {
    // Select a random verse for now.
    // In production, this could be seeded by the date (DateTime.now().day) to be consistent for the whole day.
    int randomIndex = Random().nextInt(quranMap.length);
    verseOfTheDay.value = quranMap.values.elementAt(randomIndex);
  }

  Future<void> fetchPrayerTimes() async {
    isLoading.value = true;
    errorMessage.value = '';

    DateTime now = DateTime.now();
    String formattedDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    String cacheKey = 'prayers_$formattedDate';

    // 1. Try to load from cache first for instant UI
    if (box.hasData(cacheKey)) {
      try {
        debugPrint("Loading from cache: $cacheKey");
        var cachedData = box.read(cacheKey);
        if (cachedData != null) {
          PrayerTimingsModel timings = PrayerTimingsModel.fromJson(
            Map<String, dynamic>.from(cachedData),
          );
          processPrayerTimes(timings, now);
          isLoading.value = false; // Show cached data immediately
        }
      } catch (e) {
        debugPrint("Cache error: $e");
      }
    }

    try {
      debugPrint("Fetching prayer times for $formattedDate");
      // 2. Fetch fresh data from API
      final response = await _apiService.getPrayerTimes(formattedDate);
      debugPrint("API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        debugPrint("API Success: ${response.data}");
        // Save to cache
        box.write(cacheKey, response.data);

        PrayerTimingsModel timings = PrayerTimingsModel.fromJson(response.data);
        processPrayerTimes(timings, now);
      } else {
        debugPrint("API Failed with status ${response.statusCode}");
        if (!box.hasData(cacheKey)) {
          errorMessage.value = 'Failed to load prayer times';
        }
      }
    } catch (e, stackTrace) {
      debugPrint("API Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      if (!box.hasData(cacheKey)) {
        errorMessage.value =
            'No internet connection and no cached data for today.';
      }
    } finally {
      isLoading.value = false;
      debugPrint("fetchPrayerTimes finished. isLoading: ${isLoading.value}");
    }
  }

  void processPrayerTimes(PrayerTimingsModel timings, DateTime now) {
    // Helper to parse "HH:MM" to DateTime
    DateTime parseTime(String timeStr) {
      try {
        final parts = timeStr.split(' ')[0].split(':');
        int h = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        return DateTime(now.year, now.month, now.day, h, m);
      } catch (e) {
        return now;
      }
    }

    Map<String, DateTime> times = {
      'Fajr': parseTime(timings.fajr),
      'Dhuhr': parseTime(timings.dhuhr),
      'Asr': parseTime(timings.asr),
      'Maghrib': parseTime(timings.maghrib),
      'Isha': parseTime(timings.isha),
    };

    // Determine Next Prayer
    String? closestNextName;
    DateTime? closestNextTime;

    for (var entry in times.entries) {
      if (entry.value.isAfter(now)) {
        if (closestNextTime == null || entry.value.isBefore(closestNextTime)) {
          closestNextTime = entry.value;
          closestNextName = entry.key;
        }
      }
    }

    // If no next prayer (all passed), next is Fajr tomorrow
    if (closestNextTime == null) {
      closestNextName = 'Fajr';
      closestNextTime = times['Fajr']!.add(const Duration(days: 1));
    }

    nextPrayerName.value = closestNextName!;
    nextPrayerTime.value = closestNextTime;

    updateCountdown();

    // Schedule Notifications for Future Prayers Today
    schedulePrayerNotifications(times, now);

    var newPrayers = <Map<String, dynamic>>[];
    int doneCounter = 0;

    // Ordered list for UI
    List<String> order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var name in order) {
      DateTime? time = times[name];
      if (time != null) {
        bool isNext = name == closestNextName && time.day == now.day;
        // If next is tomorrow's Fajr, today's Fajr isn't next.
        if (closestNextTime.day != now.day && name == 'Fajr') {
          isNext = false;
        }

        bool isDone = time.isBefore(now);
        if (isDone) doneCounter++;

        newPrayers.add({
          'name': name.toLowerCase(),
          'time':
              "${time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour)}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}",
          'isNext': isNext,
          'done': isDone,
        });
      }
    }

    prayers.assignAll(newPrayers);
    prayedCount.value = doneCounter;

    prayedCount.value = doneCounter;

    // API-based Hijri logic removed in favor of local calculation
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return;
    }
  }

  void updateHijriDate([String? langCode]) {
    var _today = HijriCalendar.now();
    String currentCode = langCode ?? Get.locale?.languageCode ?? 'en';
    HijriCalendar.setLocal(currentCode);

    // Format: "Weekday, Day Month" (e.g. Monday, 14 Ramadhan)
    // DD = Day Name (Friday), dd = Day (14), MMMM = Month Name (Ramadan)
    hijriDateString.value = _today.toFormat("DD, dd MMMM");
  }

  void schedulePrayerNotifications(
    Map<String, DateTime> times,
    DateTime now,
  ) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      debugPrint("Notifications not allowed. Skipping scheduling.");
      return;
    }

    final String todayStr = "${now.year}-${now.month}-${now.day}";
    final String? lastScheduledDate = box.read('last_notification_schedule_date');
    if (lastScheduledDate == todayStr) {
      debugPrint("Notifications already scheduled for today ($todayStr). Skipping rescheduling.");
      return;
    }

    // Cancel all schedules first to ensure a clean slate
    await AwesomeNotifications().cancelAllSchedules();

    // IDs: Fajr=1, Dhuhr=2, Asr=3, Maghrib=4, Isha=5
    Map<String, int> ids = {
      'Fajr': 1,
      'Dhuhr': 2,
      'Asr': 3,
      'Maghrib': 4,
      'Isha': 5,
    };

    for (var entry in times.entries) {
      if (entry.value.isAfter(now)) {
        try {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: ids[entry.key] ?? 100,
              channelKey: 'prayer_channel',
              title: '${entry.key} Prayer',
              body: 'It is time for ${entry.key} prayer.',
              notificationLayout: NotificationLayout.Default,
              wakeUpScreen: true,
              category: NotificationCategory.Reminder,
            ),
            schedule: NotificationCalendar.fromDate(date: entry.value),
          );
          debugPrint("Scheduled ${entry.key} at ${entry.value}");
        } catch (e) {
          debugPrint("Failed to schedule notification: $e");
        }
      }
    }

    // Save scheduled date to prevent redundant scheduling today
    await box.write('last_notification_schedule_date', todayStr);
  }

  void updateCountdown() {
    try {
      // Don't update countdown if loading or no data
      if (isLoading.value || prayers.isEmpty) return;

      DateTime now = DateTime.now();
      DateTime nextTime = nextPrayerTime.value;

      // Re-load logic if we passed the prayer time
      if (nextTime.isBefore(now)) {
        // Avoid spamming API
        if (!isLoading.value && now.difference(nextTime).inSeconds > 5) {
          fetchPrayerTimes();
        }
        return;
      }

      Duration diff = nextTime.difference(now);

      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(diff.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(diff.inSeconds.remainder(60));
      timeUntilNextPrayer.value =
          "${twoDigits(diff.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } catch (e) {
      timeUntilNextPrayer.value = "00:00:00";
    }
  }

  void changeLanguage() async {
    if (Get.locale?.languageCode == 'en') {
      var locale = const Locale('ar', 'SA');
      await Get.updateLocale(locale);
      currentLanguage.value = 'ar';
      updateHijriDate('ar');
    } else {
      var locale = const Locale('en', 'US');
      await Get.updateLocale(locale);
      currentLanguage.value = 'en';
      updateHijriDate('en');
    }
  }
}
