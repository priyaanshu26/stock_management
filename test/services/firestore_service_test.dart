import 'package:flutter_test/flutter_test.dart';
import 'package:stock_management/services/firestore_service.dart';
import 'package:stock_management/models/product.dart';
import 'package:stock_management/models/transaction.dart' as models;

void main() {
  group('FirestoreService', () {
    late FirestoreService firestoreService;

    setUp(() {
      firestoreService = FirestoreService();
    });

    test('should be a singleton', () {
      final instance1 = FirestoreService();
      final instance2 = FirestoreService();
      expect(instance1, equals(instance2));
    });

    test('should have all required methods', () {
      // User management methods
      expect(firestoreService.getUserData, isA<Function>());
      expect(firestoreService.createUser, isA<Function>());
      expect(firestoreService.isFirstUser, isA<Function>());

      // Product management methods
      expect(firestoreService.getProducts, isA<Function>());
      expect(firestoreService.addProduct, isA<Function>());
      expect(firestoreService.updateProduct, isA<Function>());
      expect(firestoreService.deleteProduct, isA<Function>());
      expect(firestoreService.getProduct, isA<Function>());

      // Transaction management methods
      expect(firestoreService.getTransactions, isA<Function>());
      expect(firestoreService.addTransaction, isA<Function>());
      expect(firestoreService.processStockTransaction, isA<Function>());
      expect(firestoreService.updateProductStock, isA<Function>());

      // Analytics and utility methods
      expect(firestoreService.getDashboardMetrics, isA<Function>());
      expect(firestoreService.searchProducts, isA<Function>());
      expect(firestoreService.getProductsByCategory, isA<Function>());
      expect(firestoreService.getLowStockProducts, isA<Function>());
      expect(firestoreService.getCategories, isA<Function>());
    });

    test('should return streams for real-time data', () {
      expect(firestoreService.getProducts(), isA<Stream<List<Product>>>());
      expect(firestoreService.getTransactions(), isA<Stream<List<models.Transaction>>>());
      expect(firestoreService.getLowStockProducts(), isA<Stream<List<Product>>>());
    });
  });
}