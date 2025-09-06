import 'package:flutter_test/flutter_test.dart';
import '../lib/models/models.dart';

void main() {
  group('Product Model Tests', () {
    test('should create Product from Map', () {
      final map = {
        'id': 'prod1',
        'name': 'Test Product',
        'costPrice': 10.0,
        'sellingPrice': 15.0,
        'stock': 100,
        'category': 'Electronics',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      final product = Product.fromMap(map);

      expect(product.id, 'prod1');
      expect(product.name, 'Test Product');
      expect(product.costPrice, 10.0);
      expect(product.sellingPrice, 15.0);
      expect(product.stock, 100);
      expect(product.category, 'Electronics');
    });

    test('should convert Product to Map', () {
      final now = DateTime.now();
      final product = Product(
        id: 'prod1',
        name: 'Test Product',
        costPrice: 10.0,
        sellingPrice: 15.0,
        stock: 100,
        category: 'Electronics',
        createdAt: now,
        updatedAt: now,
      );

      final map = product.toMap();

      expect(map['id'], 'prod1');
      expect(map['name'], 'Test Product');
      expect(map['costPrice'], 10.0);
      expect(map['sellingPrice'], 15.0);
      expect(map['stock'], 100);
      expect(map['category'], 'Electronics');
      expect(map['createdAt'], now.millisecondsSinceEpoch);
      expect(map['updatedAt'], now.millisecondsSinceEpoch);
    });
  });

  group('Transaction Model Tests', () {
    test('should create Transaction from Map', () {
      final map = {
        'id': 'trans1',
        'productId': 'prod1',
        'type': 'in',
        'quantity': 50,
        'date': DateTime.now().millisecondsSinceEpoch,
        'priceAtTime': 15.0,
      };

      final transaction = Transaction.fromMap(map);

      expect(transaction.id, 'trans1');
      expect(transaction.productId, 'prod1');
      expect(transaction.type, 'in');
      expect(transaction.quantity, 50);
      expect(transaction.priceAtTime, 15.0);
      expect(transaction.isStockIn, true);
      expect(transaction.isStockOut, false);
    });

    test('should convert Transaction to Map', () {
      final now = DateTime.now();
      final transaction = Transaction(
        id: 'trans1',
        productId: 'prod1',
        type: 'out',
        quantity: 25,
        date: now,
        priceAtTime: 15.0,
      );

      final map = transaction.toMap();

      expect(map['id'], 'trans1');
      expect(map['productId'], 'prod1');
      expect(map['type'], 'out');
      expect(map['quantity'], 25);
      expect(map['date'], now.millisecondsSinceEpoch);
      expect(map['priceAtTime'], 15.0);
    });

    test('should identify transaction types correctly', () {
      final stockIn = Transaction(
        id: 'trans1',
        productId: 'prod1',
        type: 'in',
        quantity: 50,
        date: DateTime.now(),
        priceAtTime: 15.0,
      );

      final stockOut = Transaction(
        id: 'trans2',
        productId: 'prod1',
        type: 'out',
        quantity: 25,
        date: DateTime.now(),
        priceAtTime: 15.0,
      );

      expect(stockIn.isStockIn, true);
      expect(stockIn.isStockOut, false);
      expect(stockOut.isStockIn, false);
      expect(stockOut.isStockOut, true);
    });
  });
}