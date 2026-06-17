import 'package:qcf_quran_plus/qcf_quran_plus.dart';

void main() {
  print('--- Debugging QCF Quran Plus ---');
  final norm = normalise('ٱلْحَمْدُ');
  print('Normalised: "$norm"');
  
  final result = searchWords(norm);
  print('Result keys: ${result.keys}');
  print('Result: $result');
}
