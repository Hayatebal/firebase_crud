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
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Edit Item' : 'Add item',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30343B),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Name',
                    labelStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Quantity',
                    labelStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF666E78),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = _nameController.text.trim();
                          final quantity = int.tryParse(
                            _quantityController.text.trim(),
                          );

                          if (name.isEmpty || quantity == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid name and quantity.',
                                ),
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

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: isEditing
                              ? const Color(0xFFFFA000)
                              : const Color(0xFF00A99D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(isEditing ? 'Update' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteItem(String id) async {
    await _crudService.deleteItem(id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item deleted')));
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

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30343B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: $quantity',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF8A929B)),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              size: 16,
              color: isFavorite
                  ? const Color(0xFFFFA000)
                  : const Color(0xFF8A929B),
            ),
            onPressed: () => _toggleFavorite(document),
            tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit, size: 16, color: Color(0xFFFFA000)),
            onPressed: () => _showItemDialog(document: document),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete, size: 16, color: Color(0xFFE53935)),
            onPressed: () => _deleteItem(document.id),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4E8EA),
      appBar: AppBar(
        toolbarHeight: 44,
        centerTitle: true,
        backgroundColor: const Color(0xFF00A99D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Firebase Balila-on',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(_showFavoritesOnly ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
            tooltip: _showFavoritesOnly
                ? 'Show all items'
                : 'Show favorites only',
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
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

              if (!context.mounted) return;
              if (confirmed == true) {
                final navigator = Navigator.of(context);
                await _authService.signOut();
                if (!mounted) return;
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
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
            return Center(child: Text('Error: ${snapshot.error}'));
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
              child: Text(
                _showFavoritesOnly
                    ? 'No favorite items yet. Tap a star to favorite an item.'
                    : 'No items yet. Add one using the + button.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: filteredDocs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildItemTile(filteredDocs[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        elevation: 2,
        backgroundColor: const Color(0xFF00A99D),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
