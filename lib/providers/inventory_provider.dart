import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class InventoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dashboard metrics
  int get totalProducts => _products.length;
  
  double get totalStockValue {
    return _products.fold(0.0, (total, product) => 
        total + (product.stock * product.sellingPrice));
  }
  
  List<Product> get lowStockProducts {
    return _products.where((product) => product.stock < 5).toList();
  }
  
  int get lowStockCount => lowStockProducts.length;

  InventoryProvider() {
    _loadProducts();
  }

  // Load products with real-time updates
  void _loadProducts() {
    _setLoading(true);
    _error = null;

    try {
      _firestoreService.getProducts().listen(
        (products) {
          _products = products;
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

  // Add product
  Future<bool> addProduct(Product product) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.addProduct(product);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(Product product) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.updateProduct(product);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.deleteProduct(productId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Process stock transaction (in/out)
  Future<bool> processStockTransaction({
    required String productId,
    required String type,
    required int quantity,
    required double priceAtTime,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.processStockTransaction(
        productId: productId,
        type: type,
        quantity: quantity,
        priceAtTime: priceAtTime,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Refresh data manually
  void refreshData() {
    _loadProducts();
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