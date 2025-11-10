import 'package:cloud_firestore/cloud_firestore.dart';

class Analytics {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Increment an integer field on a document (fieldName = 'views' or 'sales')
  static Future<void> incrementProductCounter({
    required String productId,
    required String fieldName,
    int by = 1,
  }) async {
    final docRef = _firestore.collection('products').doc(productId);
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) {
        // If product doc doesn't exist, create with the counter
        tx.set(docRef, {fieldName: by}, SetOptions(merge: true));
        return;
      }
      final current = (snapshot.data()?[fieldName] ?? 0) as int;
      tx.update(docRef, {fieldName: current + by});
    });
  }

  // Optionally: increment multiple counters atomically
  static Future<void> incrementProductCountersBatch({
    required String productId,
    required Map<String, int> increments,
  }) async {
    final docRef = _firestore.collection('products').doc(productId);
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      final data = snapshot.exists
          ? Map<String, dynamic>.from(snapshot.data()!)
          : {};
      final updates = <String, dynamic>{};
      increments.forEach((key, value) {
        final current = (data[key] ?? 0) as int;
        updates[key] = current + value;
      });
      tx.set(docRef, updates, SetOptions(merge: true));
    });
  }
}
