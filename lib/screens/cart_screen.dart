import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _items = [];
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final result = await ApiService.get('cart.php');
    setState(() {
      _items = result['success'] ? (result['items'] ?? []) : [];
      _summary = result['summary'];
      _loading = false;
    });
  }

  Future<void> _updateQuantity(int cartId, int qty) async {
    if (qty < 1) return;
    await ApiService.post('cart.php', {
      'action': 'update',
      'cart_id': cartId,
      'quantity': qty,
    });
    _loadCart();
  }

  Future<void> _removeItem(int cartId) async {
    await ApiService.post('cart.php', {
      'action': 'remove',
      'cart_id': cartId,
    });
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator());
    
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Your cart is empty', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Shopping Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: Center(child: Icon(Icons.image)),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['product_name'], 
                                style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('₹${item['unit_price']}', 
                                style: TextStyle(color: Colors.indigo)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => _updateQuantity(item['cart_id'], item['quantity'] - 1),
                            ),
                            Text('${item['quantity']}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _updateQuantity(item['cart_id'], item['quantity'] + 1),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(item['cart_id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:', style: TextStyle(fontSize: 18)),
                    Text(
                      '₹${_summary?['total_amount'] ?? 0}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CheckoutScreen()),
                    ),
                    child: Text('Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
