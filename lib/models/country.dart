class Country {
  final String name;
  final String capital;

  const Country({
    required this.name,
    required this.capital,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      capital: json['capital'] as String,
    );
  }
}
