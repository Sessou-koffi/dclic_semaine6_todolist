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
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.readAllNotes();
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note supprimée avec succès'),
        backgroundColor: Colors.orange,
      ),
    );
    _refreshNotes();
  }

  // Affiche la boîte de dialogue pour créer OU modifier une note
  void _showFormDialog(Note? note) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Si on édite une note existante, on pré-remplit les champs
    if (note != null) {
      titleController.text = note.title;
      contentController.text = note.content;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // L'utilisateur doit cliquer sur un bouton pour fermer
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          note == null ? 'Ajouter une note' : 'Modifier la note',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Le titre est obligatoire' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Contenu',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Le contenu est obligatoire' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Bouton d'annulation (Directive Ergonomie)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          // Bouton de sauvegarde (Directive Ergonomie)
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final inputTitle = titleController.text.trim();
                final inputContent = contentController.text.trim();

                if (note == null) {
                  // Mode création
                  await DatabaseHelper.instance.createNote(
                    Note(title: inputTitle, content: inputContent),
                  );
                } else {
                  // Mode édition
                  await DatabaseHelper.instance.updateNote(
                    Note(id: note.id, title: inputTitle, content: inputContent),
                  );
                }

                if (mounted) {
                  Navigator.pop(context); // Ferme la boîte de dialogue
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(note == null ? 'Note ajoutée !' : 'Note mise à jour !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _refreshNotes(); // Rafraîchit l'affichage en arrière-plan
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
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
                      elevation: 2,
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
                          // Action au clic sur une note existante : Édition
                          _showFormDialog(note);
                        },
                      ),
                    );
                  },
                ),
      // Bouton d'ajout facilement identifiable
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action au clic sur le bouton + : Ajout
          _showFormDialog(null);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
