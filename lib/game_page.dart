import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final titleController = TextEditingController();
  final genreController = TextEditingController();
  final platformController = TextEditingController();

  final gameCollection = FirebaseFirestore.instance.collection('game');

  void addGame() {
    if (titleController.text.isEmpty ||
        genreController.text.isEmpty ||
        platformController.text.isEmpty)
      return;

    gameCollection.add({
      'title': titleController.text,
      'genre': genreController.text,
      'platform': platformController.text,
    });

    titleController.clear();
    genreController.clear();
    platformController.clear();
  }

  void editGame(String id, String title, String genre, String platform) {
    final editTitle = TextEditingController(text: title);
    final editGenre = TextEditingController(text: genre);
    final editPlatform = TextEditingController(text: platform);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('EDIT GAME', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            gameField(
              controller: editTitle,
              label: 'Game Title',
              icon: Icons.videogame_asset,
            ),
            const SizedBox(height: 8),
            gameField(
              controller: editGenre,
              label: 'Genre',
              icon: Icons.category,
            ),
            const SizedBox(height: 8),
            gameField(
              controller: editPlatform,
              label: 'Platform',
              icon: Icons.gamepad,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              gameCollection.doc(id).update({
                'title': editTitle.text,
                'genre': editGenre.text,
                'platform': editPlatform.text,
              });
              Navigator.pop(context);
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  void deleteGame(String id) {
    gameCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎮 GAME HUB',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// INPUT AREA
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                gameField(
                  controller: titleController,
                  label: 'Game Title',
                  icon: Icons.videogame_asset,
                ),
                const SizedBox(height: 8),
                gameField(
                  controller: genreController,
                  label: 'Genre',
                  icon: Icons.category,
                ),
                const SizedBox(height: 8),
                gameField(
                  controller: platformController,
                  label: 'Platform',
                  icon: Icons.gamepad,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: addGame,
                    icon: const Icon(Icons.add),
                    label: const Text('ADD GAME'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// LIST GAME
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: gameCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'NO GAME DATA',
                      style: TextStyle(color: Colors.white54, letterSpacing: 2),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: snapshot.data!.docs.map((doc) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.videogame_asset,
                          color: Colors.white,
                          size: 30,
                        ),
                        title: Text(
                          doc['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${doc['genre']} • ${doc['platform']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.yellowAccent,
                              ),
                              onPressed: () => editGame(
                                doc.id,
                                doc['title'],
                                doc['genre'],
                                doc['platform'],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => deleteGame(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget gameField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true,
        fillColor: const Color(0xFF0F3460),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
