import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'crud_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final CrudService _crudService = CrudService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _showItemDialog({
    QueryDocumentSnapshot<Map<String, dynamic>>? document,
  }) async {
    final isEditing = document != null;

    if (isEditing) {
      _nameController.text = document.data()['name']?.toString() ?? '';
      _quantityController.text = document.data()['quantity']?.toString() ?? '';
    } else {
      _nameController.clear();
      _quantityController.clear();
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Item' : 'Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final quantity = int.tryParse(_quantityController.text.trim());

                if (name.isEmpty || quantity == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid name and quantity.'),
                    ),
                  );
                  return;
                }

                if (isEditing) {
                  await _crudService.updateItem(
                    document.id,
                    name: name,
                    quantity: quantity,
                  );
                } else {
                  await _crudService.addItem(name, quantity);
                }

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(String id) async {
    await _crudService.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted')),
    );
  }

  Future<void> _toggleFavorite(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final favorite = document.data()['favorite'] == true;
    await _crudService.toggleFavorite(document.id, !favorite);
  }

  Widget _buildItemTile(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    final name = data['name']?.toString() ?? 'Unnamed';
    final quantity = data['quantity']?.toString() ?? '0';
    final isFavorite = data['favorite'] == true;

    return ListTile(
      leading: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.amber : null,
        ),
        onPressed: () => _toggleFavorite(document),
        tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
      ),
      title: Text(name),
      subtitle: Text('Quantity: $quantity'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showItemDialog(document: document),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteItem(document.id),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FirebaseCRUD (Balila-on)'),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.star : Icons.star_border,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
            tooltip: _showFavoritesOnly ? 'Show all items' : 'Show favorites only',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                await _authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _crudService.getItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final filteredDocs = _showFavoritesOnly
              ? docs.where((doc) => doc.data()['favorite'] == true).toList()
              : docs;

          if (filteredDocs.isEmpty) {
            return Center(
              child: Text(_showFavoritesOnly
                  ? 'No favorite items yet. Tap a star to favorite an item.'
                  : 'No items yet. Add one using the + button.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocs.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              return _buildItemTile(filteredDocs[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
