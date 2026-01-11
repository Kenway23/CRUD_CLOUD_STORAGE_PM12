import 'package:cloud_firestore/cloud_firestore.dart';
import 'game.dart';

class GameService {
  final CollectionReference games = FirebaseFirestore.instance.collection(
    'games',
  );

  // CREATE
  Future tambahGame(Game game) async {
    await games.add(game.toMap());
  }

  // READ
  Stream<QuerySnapshot> ambilGame() {
    return games.snapshots();
  }

  // UPDATE
  Future updateGame(String id, Game game) async {
    await games.doc(id).update(game.toMap());
  }

  // DELETE
  Future hapusGame(String id) async {
    await games.doc(id).delete();
  }
}
