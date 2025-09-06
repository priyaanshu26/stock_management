class Transaction {
  final String id;
  final String productId;
  final String type; // 'in' or 'out'
  final int quantity;
  final DateTime date;
  final double priceAtTime;

  Transaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
    required this.priceAtTime,
  });

  // Convert Transaction to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'type': type,
      'quantity': quantity,
      'date': date.millisecondsSinceEpoch,
      'priceAtTime': priceAtTime,
    };
  }

  // Create Transaction from Map (Firestore document)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      type: map['type'] ?? '',
      quantity: map['quantity'] ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      priceAtTime: (map['priceAtTime'] ?? 0).toDouble(),
    );
  }

  // Create a copy of Transaction with updated fields
  Transaction copyWith({
    String? id,
    String? productId,
    String? type,
    int? quantity,
    DateTime? date,
    double? priceAtTime,
  }) {
    return Transaction(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      priceAtTime: priceAtTime ?? this.priceAtTime,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, productId: $productId, type: $type, quantity: $quantity, date: $date, priceAtTime: $priceAtTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods for transaction types
  bool get isStockIn => type == 'in';
  bool get isStockOut => type == 'out';
}