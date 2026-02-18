import 'package:quran/quran.dart' as quran;

void main() {
  print('--- Debugging Bismillah ---');
  // Surah 3 Verse 1
  String alImranVerse1 = quran.getVerse(3, 1);
  print('Surah 3 Verse 1: "$alImranVerse1"');

  // Print each character code to be sure
  print('Character codes: ${alImranVerse1.codeUnits}');

  String basmala = quran.basmala;
  print('Package Basmala: "$basmala"');
  print('Package Basmala codes: ${basmala.codeUnits}');

  // Compare
  bool startsWith = alImranVerse1.startsWith(basmala);
  print('StartsWith package basmala: $startsWith');
}
