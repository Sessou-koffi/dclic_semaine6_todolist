import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/note_model.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshNotes(); // Charge les notes au démarrage de l'écran
  }

  // Fonction pour rafraîchir la liste depuis SQLite
  Future<void> _refreshNotes() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.readAllNotes();
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  // Fonction de suppression (Étape 4 de votre énoncé)
  Future<void> _deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note supprimée avec succès'),
        backgroundColor: Colors.orange,
      ),
    );
    _refreshNotes(); // Met à jour l'affichage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Retour à la page de connexion
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune note pour le moment',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          note.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            // Dialogue de confirmation de suppression
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer la note ?'),
                                content: const Text('Cette action est irréversible.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      if (note.id != null) _deleteNote(note.id!);
                                    },
                                    child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          // Nous lierons l'édition ici à l'étape suivante
                        },
                      ),
                    );
                  },
                ),
      // Bouton d'ajout facilement identifiable (Flottant)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Nous lierons l'ajout ici à l'étape suivante
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
