import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String categoryId;
  String name;
  bool disabled;

  CategoryModel({
    required this.categoryId,
    required this.name,
    required this.disabled,
  });

  // Factory method to create a CategoryModel from Firestore document
  factory CategoryModel.fromDocument(DocumentSnapshot doc) {
    return CategoryModel(
      categoryId: doc.id,
      name: doc['name'],
      disabled: doc['disabled'] ?? false,
    );
  }

  // Method to convert CategoryModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'disabled': disabled,
    };
  }

  // Method to add a new category to Firestore
  Future<void> createCategory() async {
    await FirebaseFirestore.instance.collection('categories').add({
      'name': name,
      'disabled': disabled,
    });
  }

  // Method to update an existing category in Firestore
  Future<void> updateCategory() async {
    await FirebaseFirestore.instance.collection('categories').doc(categoryId).update({
      'name': name,
      'disabled': disabled,
    });
  }

  // Method to disable a category
  Future<void> disableCategory() async {
    await FirebaseFirestore.instance.collection('categories').doc(categoryId).update({
      'disabled': true,
    });
  }

  // Method to enable a category
  Future<void> enableCategory() async {
    await FirebaseFirestore.instance.collection('categories').doc(categoryId).update({
      'disabled': false,
    });
  }
}
