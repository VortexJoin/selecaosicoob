import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _collection;

  FirestoreService(String collectionName)
      : _collection = FirebaseFirestore.instance.collection(collectionName);

  Future<void> setdata(
      {required Map<String, dynamic> item, required String id}) async {
    await _collection.doc(id).set(item);
  }

  Stream<QuerySnapshot> getItemsAsStream() {
    return _collection.snapshots();
  }

  Future<List<DocumentSnapshot>> getItems() async {
    final QuerySnapshot snapshot = await _collection.get();
    final List<DocumentSnapshot> documents = snapshot.docs;
    return documents;
  }

  Future<void> updateItem(Map<String, dynamic> item, String id) async {
    await _collection.doc(id).set(item);
  }

  Future<void> deleteItem(String id) async {
    await _collection.doc(id).delete();
  }
}
