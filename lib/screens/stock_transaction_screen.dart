import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../providers/inventory_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class StockTransactionScreen extends StatefulWidget {
  const StockTransactionScreen({super.key});

  @override
  State<StockTransactionScreen> createState() => _StockTransactionScreenState();
}

class _StockTransactionScreenState extends State<StockTransactionScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  Product? _selectedProduct;
  String _transactionType = 'in'; // 'in' or 'out'
  bool _isLoading = false;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize with 1 tab, will be updated in build method
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _processTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    // Check if user is admin
    if (authProvider.userData?.role != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only admins can perform stock transactions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quantity = int.parse(_quantityController.text);
      
      await inventoryProvider.processStockTransaction(
        productId: _selectedProduct!.id,
        type: _transactionType,
        quantity: quantity,
        priceAtTime: _transactionType == 'in' 
            ? _selectedProduct!.costPrice 
            : _selectedProduct!.sellingPrice,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock ${_transactionType == 'in' ? 'added' : 'removed'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          _selectedProduct = null;
          _transactionType = 'in';
          _quantityController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<InventoryProvider, AuthProvider>(
      builder: (context, inventoryProvider, authProvider, child) {
        final products = inventoryProvider.products;
        final isAdmin = authProvider.userData?.role == 'admin';

        // Update tab controller length based on admin status
        final tabCount = isAdmin ? 2 : 1;
        if (_tabController.length != tabCount) {
          _tabController.dispose();
          _tabController = TabController(length: tabCount, vsync: this);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Stock Management',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                if (isAdmin) 
                  const Tab(
                    icon: Icon(Icons.add_circle_outline),
                    text: 'Add Transaction',
                  ),
                const Tab(
                  icon: Icon(Icons.history),
                  text: 'Transaction History',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              if (isAdmin) _buildAddTransactionTab(products, isAdmin),
              _buildTransactionHistoryTab(products),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddTransactionTab(List<Product> products, bool isAdmin) {

    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Products Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add products first to perform stock transactions',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                  // Transaction Type Toggle
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _transactionType = 'in';
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _transactionType == 'in'
                                          ? Colors.green.shade50
                                          : Colors.grey.shade50,
                                      border: Border.all(
                                        color: _transactionType == 'in'
                                            ? Colors.green
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.add_circle,
                                          color: _transactionType == 'in'
                                              ? Colors.green
                                              : Colors.grey,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Stock In',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _transactionType == 'in'
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'Add inventory',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _transactionType == 'in'
                                                ? Colors.green.shade700
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _transactionType = 'out';
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _transactionType == 'out'
                                          ? Colors.red.shade50
                                          : Colors.grey.shade50,
                                      border: Border.all(
                                        color: _transactionType == 'out'
                                            ? Colors.red
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.remove_circle,
                                          color: _transactionType == 'out'
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Stock Out',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _transactionType == 'out'
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'Remove inventory',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _transactionType == 'out'
                                                ? Colors.red.shade700
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Product Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<Product>(
                            value: _selectedProduct,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Choose a product',
                              prefixIcon: Icon(Icons.inventory_2),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a product';
                              }
                              return null;
                            },
                            items: products.map((product) {
                              return DropdownMenuItem<Product>(
                                value: product,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    '${product.name} (Stock: ${product.stock})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (product) {
                              setState(() {
                                _selectedProduct = product;
                              });
                            },
                          ),
                          
                          // Show selected product details
                          if (_selectedProduct != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory,
                                        size: 16,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Current Stock: ${_selectedProduct!.stock} units',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Cost Price',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '₹${_selectedProduct!.costPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Selling Price',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '₹${_selectedProduct!.sellingPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quantity Input
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter quantity',
                              prefixIcon: Icon(
                                _transactionType == 'in' 
                                    ? Icons.add_circle_outline 
                                    : Icons.remove_circle_outline,
                                color: _transactionType == 'in' 
                                    ? Colors.green 
                                    : Colors.red,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              final quantity = int.tryParse(value);
                              if (quantity == null || quantity <= 0) {
                                return 'Please enter a valid positive number';
                              }
                              
                              // Check stock availability for stock out
                              if (_transactionType == 'out' && 
                                  _selectedProduct != null && 
                                  quantity > _selectedProduct!.stock) {
                                return 'Insufficient stock. Available: ${_selectedProduct!.stock}';
                              }
                              
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _transactionType == 'in' 
                            ? Colors.green 
                            : Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _transactionType == 'in' 
                                      ? Icons.add_circle 
                                      : Icons.remove_circle,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _transactionType == 'in' 
                                      ? 'Add Stock' 
                                      : 'Remove Stock',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistoryTab(List<Product> products) {
    return StreamBuilder<List<Transaction>>(
      stream: _firestoreService.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Transaction History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Stock transactions will appear here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final product = products.firstWhere(
              (p) => p.id == transaction.productId,
              orElse: () => Product(
                id: transaction.productId,
                name: 'Unknown Product',
                category: '',
                stock: 0,
                costPrice: 0,
                sellingPrice: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaction.isStockIn 
                      ? Colors.green[100] 
                      : Colors.red[100],
                  child: Icon(
                    transaction.isStockIn 
                        ? Icons.add_circle 
                        : Icons.remove_circle,
                    color: transaction.isStockIn 
                        ? Colors.green[700] 
                        : Colors.red[700],
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${transaction.isStockIn ? '+' : '-'}${transaction.quantity} units',
                      style: TextStyle(
                        color: transaction.isStockIn 
                            ? Colors.green[700] 
                            : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Price: ₹${transaction.priceAtTime.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _formatTime(transaction.date),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}