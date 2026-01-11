class Game {
  String id;
  String title;
  String genre;

  Game({required this.id, required this.title, required this.genre});

  Map<String, dynamic> toMap() {
    return {'title': title, 'genre': genre};
  }
}
 