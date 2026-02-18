class TafseerModel {
  final String number;
  final String aya;
  final String text;

  TafseerModel({required this.number, required this.aya, required this.text});

  factory TafseerModel.fromJson(Map<String, dynamic> json) {
    return TafseerModel(
      number: json['number'] as String,
      aya: json['aya'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'number': number, 'aya': aya, 'text': text};
  }
}
