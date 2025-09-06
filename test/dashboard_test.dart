import 'package:flutter_test/flutter_test.dart';
import 'package:stock_management/models/product.dart';

// Mock class to test dashboard metrics without Firebase dependency
class MockInventoryProvider {
  List<Product> products = [];

  int get totalProducts => products.length;
  
  double get totalStockValue {
    return products.fold(0.0, (total, product) => 
        total + (product.stock * product.sellingPrice));
  }
  
  List<Product> get lowStockProducts {
    return products.where((product) => product.stock < 5).toList();
  }
  
  int get lowStockCount => lowStockProducts.length;
}

void main() {
  group('Dashboard Metrics Tests', () {
    test('should calculate total products correctly', () {
      final provider = MockInventoryProvider();
      
      // Mock products data
      final products = [
        Product(
          id: '1',
          name: 'Product 1',
          costPrice: 10.0,
          sellingPrice: 15.0,
          stock: 100,
          category: 'Electronics',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Product 2',
          costPrice: 20.0,
          sellingPrice: 30.0,
          stock: 50,
          category: 'Clothing',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Simulate products being loaded
      provider.products.addAll(products);
      
      expect(provider.totalProducts, 2);
    });

    test('should calculate total stock value correctly', () {
      final provider = MockInventoryProvider();
      
      final products = [
        Product(
          id: '1',
          name: 'Product 1',
          costPrice: 10.0,
          sellingPrice: 15.0,
          stock: 100, // 100 * 15.0 = 1500.0
          category: 'Electronics',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Product 2',
          costPrice: 20.0,
          sellingPrice: 30.0,
          stock: 50, // 50 * 30.0 = 1500.0
          category: 'Clothing',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      provider.products.addAll(products);
      
      expect(provider.totalStockValue, 3000.0); // 1500.0 + 1500.0
    });

    test('should identify low stock products correctly', () {
      final provider = MockInventoryProvider();
      
      final products = [
        Product(
          id: '1',
          name: 'High Stock Product',
          costPrice: 10.0,
          sellingPrice: 15.0,
          stock: 100, // Above threshold
          category: 'Electronics',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Low Stock Product 1',
          costPrice: 20.0,
          sellingPrice: 30.0,
          stock: 3, // Below threshold (< 5)
          category: 'Clothing',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '3',
          name: 'Low Stock Product 2',
          costPrice: 15.0,
          sellingPrice: 25.0,
          stock: 1, // Below threshold (< 5)
          category: 'Books',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      provider.products.addAll(products);
      
      expect(provider.lowStockCount, 2);
      expect(provider.lowStockProducts.length, 2);
      expect(provider.lowStockProducts[0].name, 'Low Stock Product 1');
      expect(provider.lowStockProducts[1].name, 'Low Stock Product 2');
    });

    test('should handle empty products list', () {
      final provider = MockInventoryProvider();
      
      expect(provider.totalProducts, 0);
      expect(provider.totalStockValue, 0.0);
      expect(provider.lowStockCount, 0);
      expect(provider.lowStockProducts.isEmpty, true);
    });
  });
}