class Game {
  final String id;
  final String name;
  final String windowsUrl;
  final String image;
  final String? exeFileName;

  Game({
    required this.id,
    required this.name,
    required this.windowsUrl,
    required this.image,
    this.exeFileName,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'],
      windowsUrl: json['windows_url'],
      image: json['image'],
      exeFileName: json['exe_file_name'],
    );
  }
}
