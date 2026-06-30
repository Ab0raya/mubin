class Reciter {
  final String name;
  final String arabicName;
  final String serverUrl;

  const Reciter({
    required this.name,
    required this.arabicName,
    required this.serverUrl,
  });

  String get imagePath {
    switch (name) {
      case "Yasser Al-Dosari":
        return "assets/images/reciters/icfe-الدوسري.png";
      case "Mohamed Siddiq El-Minshawi (Mujawwad)":
        return "assets/images/reciters/icfe-المنشاوي.png";
      case "Abdul Basit Abdul Samad":
        return "assets/images/reciters/icfe-عبدالباسط.png";
      case "Mohammad Mahmoud Al-Tablawi":
        return "assets/images/reciters/icfe-الطبلاوي.png";
      case "Saad Al-Ghamdi":
        return "assets/images/reciters/icfe-الغامدي.png";
      case "Mahmoud Khalil Al-Hussary":
        return "assets/images/reciters/icfe-الحصري.png";
      case "Abdul Rahman Al-Sudais":
        return "assets/images/reciters/icfe-السديس.png";
      case "Mishary Rashid Alafasy":
        return "assets/images/reciters/icfe-العفاسي.png";
      case "Maher Al-Muaiqly":
        return "assets/images/reciters/icfe-المعيقلي.png";
      case "Mustafa Ismail":
        return "assets/images/reciters/icfe-مصطفي إسماعيل.png";
      case "Ahmed Al-Ajmi":
        return "assets/images/reciters/icfe-العجمي.png";
      case "Saud Al-Shuraim":
        return "assets/images/reciters/icfe-الشريم.png";
      case "Rashid Al-Soufi (Hafs)":
        return "assets/images/reciters/icfe-راشد الصوفي.png";
      case "Khalid Al-Jalil":
        return "assets/images/reciters/icfe-خالد جليل.png";
      case "Nasser Al-Qatami":
        return "assets/images/reciters/icfe-القطامي.png";
      case "Fares Abbad":
        return "assets/images/reciters/icfe-فارس عباد.png";
      case "Mohamed Al-Luhaidan":
        return "assets/images/reciters/icfe-اللحيدان.png";
      case "Islam Sobhi":
        return "assets/images/reciters/icfe-إسلام صبحي.png";
      case "Bandar Baleila":
        return "assets/images/reciters/icfe-بدر بليله.png";
      case "Muhammad Ayyub":
        return "assets/images/reciters/icfe-محمد ايوب.png";
      case "Bader Al-Turki":
        return "assets/images/reciters/icfe-بدر التركي.png";
      default:
        return "assets/images/quran_cover.png";
    }
  }

  String get narration {
    if (name.contains("Qalon") || arabicName.contains("قالون")) {
      return "رواية قالون عن نافع";
    }
    return "رواية حفص عن عاصم";
  }

  static const List<Reciter> reciters = [
    Reciter(
      name: "Yasser Al-Dosari",
      arabicName: "ياسر الدوسري",
      serverUrl: "https://server11.mp3quran.net/yasser/",
    ),
    Reciter(
      name: "Mohamed Siddiq El-Minshawi (Mujawwad)",
      arabicName: "محمد صديق المنشاوي (مجود)",
      serverUrl: "https://server10.mp3quran.net/minsh/minh-old-with-echo/",
    ),
    Reciter(
      name: "Abdul Basit Abdul Samad",
      arabicName: "عبد الباسط عبد الصمد",
      serverUrl: "https://server7.mp3quran.net/basit/",
    ),
    Reciter(
      name: "Mohammad Mahmoud Al-Tablawi",
      arabicName: "محمد محمود الطبلاوي",
      serverUrl: "https://server12.mp3quran.net/tblawi/",
    ),
    Reciter(
      name: "Saad Al-Ghamdi",
      arabicName: "سعد الغامدي",
      serverUrl: "https://server7.mp3quran.net/s_gmd/",
    ),
    Reciter(
      name: "Mahmoud Khalil Al-Hussary",
      arabicName: "محمود خليل الحصري ",
      serverUrl: "https://server13.mp3quran.net/husr/Rewayat-Qalon-A-n-Nafi/",
    ),
    Reciter(
      name: "Abdul Rahman Al-Sudais",
      arabicName: "عبد الرحمن السديس",
      serverUrl: "https://server11.mp3quran.net/sds/",
    ),
    Reciter(
      name: "Mishary Rashid Alafasy",
      arabicName: "مشاري راشد العفاسي",
      serverUrl: "https://server8.mp3quran.net/afs/",
    ),
    Reciter(
      name: "Maher Al-Muaiqly",
      arabicName: "ماهر المعيقلي",
      serverUrl: "https://server12.mp3quran.net/maher/",
    ),
    Reciter(
      name: "Mustafa Ismail",
      arabicName: "مصطفى إسماعيل",
      serverUrl: "https://server8.mp3quran.net/mustafa/",
    ),
    Reciter(
      name: "Ahmed Al-Ajmi",
      arabicName: "أحمد العجمي",
      serverUrl: "https://server10.mp3quran.net/ajm/",
    ),
    Reciter(
      name: "Saud Al-Shuraim",
      arabicName: "سعود الشريم",
      serverUrl: "https://server7.mp3quran.net/shur/",
    ),
    Reciter(
      name: "Rashid Al-Soufi (Hafs)",
      arabicName: "راشد الصوفي (حفص)",
      serverUrl: "https://server16.mp3quran.net/soufi/Rewayat-Hafs-A-n-Assem/",
    ),
    Reciter(
      name: "Khalid Al-Jalil",
      arabicName: "خالد الجليل",
      serverUrl: "https://server10.mp3quran.net/jleel/",
    ),
    Reciter(
      name: "Nasser Al-Qatami",
      arabicName: "ناصر القطامي",
      serverUrl: "https://server6.mp3quran.net/qtm/",
    ),
    Reciter(
      name: "Fares Abbad",
      arabicName: "فارس عباد",
      serverUrl: "https://server8.mp3quran.net/frs_a/",
    ),
    Reciter(
      name: "Mohamed Al-Luhaidan",
      arabicName: "محمد اللحيدان",
      serverUrl: "https://server8.mp3quran.net/lhdan/",
    ),
    Reciter(
      name: "Islam Sobhi",
      arabicName: "إسلام صبحي",
      serverUrl: "https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem/",
    ),
    Reciter(
      name: "Bandar Baleila",
      arabicName: "بندر بليلة",
      serverUrl: "https://server8.mp3quran.net/bna/",
    ),
    Reciter(
      name: "Muhammad Ayyub",
      arabicName: "محمد أيوب",
      serverUrl: "https://server8.mp3quran.net/ayyub/",
    ),
    Reciter(
      name: "Bader Al-Turki",
      arabicName: "بدر التركي",
      serverUrl: "https://server10.mp3quran.net/bader/Rewayat-Hafs-A-n-Assem/",
    ),
  ];
}
