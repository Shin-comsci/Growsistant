import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreService {
  final FirebaseFirestore db;

  const CloudFirestoreService(this.db);

  Future<void> add(String collectionName, String docId, Map<String, dynamic> data) async {
    // Add a new document with a generated ID
    try {
      await db.collection(collectionName).doc(docId).set(data);
    } catch (error) {
      print("Failed to add document: $error");
    }
  }

  Future<Map<String, dynamic>?> get(String collection, String docId) async {
    try {
      DocumentSnapshot snapshot = await db.collection(collection).doc(docId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        print('No such document!');
        return null;
      }
    } catch (error) {
      print("Failed to fetch document: $error");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAll(String collection) {
    CollectionReference obj = FirebaseFirestore.instance.collection(collection);
    return obj.get().then((QuerySnapshot snapshot) {
      List<Map<String, dynamic>> documents = [];
      for (var doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        // add the document ID under a key, e.g. "id"
        documents.add({
          'id': doc.id,
          ...userData, // spread the rest of the fields
        });
      }
      return documents;
    }).catchError((error) {
      print("Failed to fetch documents: $error");
      return <Map<String, dynamic>>[];
    });
  }



  Future<void> update(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await db.collection(collection).doc(docId).update(data);
    } catch (error) {
      print("Failed to update document: $error");
    }
  }

  Future<bool> addContribution(String collectionName, String docId, Map<String, dynamic> contribution) async {
    try {
      await db.collection(collectionName).doc(docId).update({
        'contributions': FieldValue.arrayUnion([contribution]),
      });
      return true;
    } catch (error) {
      print("Failed to add contribution: $error");
      return false;
    }
  }

  Future<bool> editProfile(String userEmail, String key, dynamic value) async {
    try {
      final userDoc = db.collection('users').doc(userEmail);
      await userDoc.set({
        'profile': {
          key: value,
        }
      }, SetOptions(merge: true)); // merge true to preserve existing fields
      return true;
    } catch (e) {
      print('Error editing profile: $e');
      return false;
    }
  }
}