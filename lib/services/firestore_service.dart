import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/user_model.dart';
import '../models/product_category.dart';
import '../models/transaction.dart' as models;

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _productsCollection => _firestore.collection('products');
  CollectionReference get _categoriesCollection => _firestore.collection('categories');
  CollectionReference get _transactionsCollection => _firestore.collection('transactions');

  // User Management
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      // In production, use proper logging instead of print
      // print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap());
    } catch (e) {
      // print('Error creating user: $e');
      rethrow;
    }
  }

  // Product Management
  Stream<List<Product>> getProducts() {
    return _productsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure the document ID is included
        return Product.fromMap(data);
      }).toList();
    });
  }

  Future<void> addProduct(Product product) async {
    try {
      // Generate a new document reference to get the ID
      DocumentReference docRef = _productsCollection.doc();
      
      // Create product with the generated ID
      Product productWithId = product.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await docRef.set(productWithId.toMap());
    } catch (e) {
      // print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      Product updatedProduct = product.copyWith(updatedAt: DateTime.now());
      await _productsCollection.doc(product.id).update(updatedProduct.toMap());
    } catch (e) {
      // print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      // print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }
      return null;
    } catch (e) {
      // print('Error getting product: $e');
      return null;
    }
  }

  // Transaction Management
  Stream<List<models.Transaction>> getTransactions() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return models.Transaction.fromMap(data);
      }).toList();
    });
  }

  Future<void> addTransaction(models.Transaction transaction) async {
    try {
      // Generate a new document reference to get the ID
      DocumentReference docRef = _transactionsCollection.doc();
      
      // Create transaction with the generated ID
      models.Transaction transactionWithId = transaction.copyWith(
        id: docRef.id,
        date: DateTime.now(),
      );
      
      await docRef.set(transactionWithId.toMap());
    } catch (e) {
      // print('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _productsCollection.doc(productId).update({
        'stock': newStock,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // print('Error updating product stock: $e');
      rethrow;
    }
  }

  // Stock Transaction with automatic stock update
  Future<void> processStockTransaction({
    required String productId,
    required String type, // 'in' or 'out'
    required int quantity,
    required double priceAtTime,
  }) async {
    try {
      // Start a batch write for atomic operation
      WriteBatch batch = _firestore.batch();
      
      // Get current product
      Product? product = await getProduct(productId);
      if (product == null) {
        throw Exception('Product not found');
      }
      
      // Calculate new stock
      int newStock;
      if (type == 'in') {
        newStock = product.stock + quantity;
      } else if (type == 'out') {
        if (product.stock < quantity) {
          throw Exception('Insufficient stock. Available: ${product.stock}, Requested: $quantity');
        }
        newStock = product.stock - quantity;
      } else {
        throw Exception('Invalid transaction type. Must be "in" or "out"');
      }
      
      // Create transaction
      DocumentReference transactionRef = _transactionsCollection.doc();
      models.Transaction transaction = models.Transaction(
        id: transactionRef.id,
        productId: productId,
        type: type,
        quantity: quantity,
        date: DateTime.now(),
        priceAtTime: priceAtTime,
      );
      
      // Update product stock
      DocumentReference productRef = _productsCollection.doc(productId);
      
      // Add to batch
      batch.set(transactionRef, transaction.toMap());
      batch.update(productRef, {
        'stock': newStock,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Commit batch
      await batch.commit();
    } catch (e) {
      // print('Error processing stock transaction: $e');
      rethrow;
    }
  }

  // Get transactions for a specific product
  Stream<List<models.Transaction>> getProductTransactions(String productId) {
    return _transactionsCollection
        .where('productId', isEqualTo: productId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return models.Transaction.fromMap(data);
      }).toList();
    });
  }

  // Get transactions within date range
  Stream<List<models.Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) {
    return _transactionsCollection
        .where('date', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .where('date', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return models.Transaction.fromMap(data);
      }).toList();
    });
  }

  // Dashboard Analytics
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      // Get all products
      QuerySnapshot productsSnapshot = await _productsCollection.get();
      List<Product> products = productsSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();

      // Calculate metrics
      int totalProducts = products.length;
      double totalStockValue = products.fold(0.0, (total, product) => 
          total + (product.stock * product.sellingPrice));
      
      List<Product> lowStockProducts = products.where((product) => 
          product.stock < 5).toList();

      return {
        'totalProducts': totalProducts,
        'totalStockValue': totalStockValue,
        'lowStockCount': lowStockProducts.length,
        'lowStockProducts': lowStockProducts,
      };
    } catch (e) {
      // print('Error getting dashboard metrics: $e');
      return {
        'totalProducts': 0,
        'totalStockValue': 0.0,
        'lowStockCount': 0,
        'lowStockProducts': <Product>[],
      };
    }
  }

  // Search products by name
  Stream<List<Product>> searchProducts(String searchTerm) {
    return _productsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Product.fromMap(data);
          })
          .where((product) => 
              product.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  // Filter products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _productsCollection
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
    });
  }

  // Get low stock products (stock < 5) as a stream
  Stream<List<Product>> getLowStockProducts() {
    return _productsCollection
        .where('stock', isLessThan: 5)
        .orderBy('stock')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
    });
  }

  // Category Management
  Stream<List<ProductCategory>> getCategories() {
    return _categoriesCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure the document ID is included
        return ProductCategory.fromMap(data);
      }).toList();
    });
  }

  Future<void> addCategory(ProductCategory category) async {
    try {
      // Generate a new document reference to get the ID
      DocumentReference docRef = _categoriesCollection.doc();
      
      // Create category with the generated ID
      ProductCategory categoryWithId = category.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await docRef.set(categoryWithId.toMap());
    } catch (e) {
      // print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(ProductCategory category) async {
    try {
      ProductCategory updatedCategory = category.copyWith(updatedAt: DateTime.now());
      await _categoriesCollection.doc(category.id).update(updatedCategory.toMap());
    } catch (e) {
      // print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      // print('Error deleting category: $e');
      rethrow;
    }
  }

  Future<ProductCategory?> getCategory(String categoryId) async {
    try {
      DocumentSnapshot doc = await _categoriesCollection.doc(categoryId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductCategory.fromMap(data);
      }
      return null;
    } catch (e) {
      // print('Error getting category: $e');
      return null;
    }
  }

  // Get unique categories from products (legacy method for backward compatibility)
  Future<List<String>> getProductCategories() async {
    try {
      QuerySnapshot snapshot = await _productsCollection.get();
      Set<String> categories = {};
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String category = data['category'] ?? '';
        if (category.isNotEmpty) {
          categories.add(category);
        }
      }
      
      List<String> categoryList = categories.toList();
      categoryList.sort();
      return categoryList;
    } catch (e) {
      // print('Error getting categories: $e');
      return [];
    }
  }

  // Check if user is first user (for admin role assignment)
  Future<bool> isFirstUser() async {
    try {
      QuerySnapshot snapshot = await _usersCollection.limit(1).get();
      return snapshot.docs.isEmpty;
    } catch (e) {
      // print('Error checking first user: $e');
      return false;
    }
  }

  // Update user role
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _usersCollection.doc(uid).update({'role': role});
    } catch (e) {
      // print('Error updating user role: $e');
      rethrow;
    }
  }

  // Make user admin by email
  Future<bool> makeUserAdmin(String email) async {
    try {
      QuerySnapshot users = await _usersCollection
          .where('email', isEqualTo: email)
          .get();
      
      if (users.docs.isNotEmpty) {
        String uid = users.docs.first.id;
        await updateUserRole(uid, 'admin');
        return true;
      }
      return false;
    } catch (e) {
      // print('Error making user admin: $e');
      return false;
    }
  }
}