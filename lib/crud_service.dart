import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  final CollectionReference<Map<String, dynamic>> _items =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(String name, int quantity) {
    return _items.add({
      'name': name,
      'quantity': quantity,
      'favorite': false,
      'createdat': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getItems() {
    return _items.orderBy('createdat', descending: true).snapshots();
  }

  Future<void> toggleFavorite(String id, bool favorite) {
    return _items.doc(id).update({
      'favorite': favorite,
    });
  }

  Future<void> updateItem(
    String id, {
    required String name,
    required int quantity,
  }) {
    return _items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  Future<void> deleteItem(String id) {
    return _items.doc(id).delete();
  }
}


