class Ayah {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String arabic;
  final String translation;

  Ayah({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.arabic,
    required this.translation,
  });
}

final Map<String, Ayah> quranMap = {
  "1:1": Ayah(
    surahNumber: 1,
    surahName: "Al-Fatiha",
    ayahNumber: 1,
    arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
    translation:
        "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
  ),
  "1:2": Ayah(
    surahNumber: 1,
    surahName: "Al-Fatiha",
    ayahNumber: 2,
    arabic: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
    translation: "All praise is due to Allah, Lord of the worlds.",
  ),
  "2:255": Ayah(
    surahNumber: 2,
    surahName: "Al-Baqarah",
    ayahNumber: 255,
    arabic: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...",
    translation:
        "Allah – there is no deity except Him, the Ever-Living, the Sustainer of existence...",
  ),
};
