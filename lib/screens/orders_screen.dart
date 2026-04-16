import 'package:flutter/material.dart';
import '../utils/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final url = 'orders.php?page=1&limit=20' + (_filter != 'all' ? '&status=$_filter' : '');
    final result = await ApiService.get(url);
    setState(() {
      _orders = result['success'] ? (result['orders'] ?? []) : [];
      _loading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.indigo;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['all', 'pending', 'processing', 'shipped', 'delivered']
                  .map((f) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f.toUpperCase()),
                          selected: _filter == f,
                          onSelected: (_) {
                            setState(() {
                              _filter = f;
                              _loading = true;
                            });
                            _loadOrders();
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('No orders found'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (_, i) {
                    final order = _orders[i];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '#${order['order_number']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(order['order_status']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    order['order_status'].toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(order['order_status']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(order['city'] + ', ' + order['state']),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  new DateTime.parse(order['created_at'])
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '₹${order['final_amount']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
