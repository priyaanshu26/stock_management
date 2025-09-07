import 'package:flutter/material.dart';
import '../models/product_category.dart';
import '../services/firestore_service.dart';

class CategoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<ProductCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider() {
    _loadCategories();
  }

  // Load categories with real-time updates
  void _loadCategories() {
    _setLoading(true);
    _error = null;

    try {
      _firestoreService.getCategories().listen(
        (categories) {
          _categories = categories;
          _setLoading(false);
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _setLoading(false);
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Add category
  Future<bool> addCategory(ProductCategory category) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.addCategory(category);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Update category
  Future<bool> updateCategory(ProductCategory category) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.updateCategory(category);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Delete category
  Future<bool> deleteCategory(String categoryId) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.deleteCategory(categoryId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Check if category name already exists
  bool categoryExists(String name, {String? excludeId}) {
    return _categories.any((category) => 
        category.name.toLowerCase() == name.toLowerCase() && 
        category.id != excludeId);
  }

  // Get category by ID
  ProductCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh data manually
  void refreshData() {
    _loadCategories();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

}