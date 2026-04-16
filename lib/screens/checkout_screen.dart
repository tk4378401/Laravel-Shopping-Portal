import 'package:flutter/material.dart';
import '../utils/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<dynamic> _addresses = [];
  int? _selectedAddressId;
  String _paymentMethod = 'bank_transfer';
  bool _loading = true;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final result = await ApiService.get('addresses.php');
    setState(() {
      _addresses = result['success'] ? (result['addresses'] ?? []) : [];
      _loading = false;
    });
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select a delivery address')),
      );
      return;
    }

    setState(() => _placing = true);

    final result = await ApiService.post('orders.php', {
      'action': 'create',
      'address_id': _selectedAddressId,
      'payment_method': _paymentMethod,
    });

    setState(() => _placing = false);

    if (result['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text('Order Placed!'),
          content: Text('Order #${result['order']['order_number']} has been placed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Failed to place order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery Address', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 12),
                  if (_addresses.isEmpty)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No addresses. Please add one first.'),
                      ),
                    )
                  else
                    ..._addresses.map((addr) => RadioListTile<int>(
                      title: Text(addr['full_name']),
                      subtitle: Text('${addr['address_line1']}, ${addr['city']} - ${addr['pincode']}'),
                      value: addr['id'],
                      groupValue: _selectedAddressId,
                      onChanged: (v) => setState(() => _selectedAddressId = v),
                    )),
                  
                  SizedBox(height: 24),
                  Text('Payment Method', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 12),
                  RadioListTile<String>(
                    title: Text('Bank Transfer'),
                    subtitle: Text('Available on all pincodes'),
                    value: 'bank_transfer',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  RadioListTile<String>(
                    title: Text('Cash on Delivery'),
                    subtitle: Text('Selected pincodes only'),
                    value: 'cod',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  
                  if (_paymentMethod == 'bank_transfer')
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bank Account Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('Account: Shopping Portal'),
                            Text('A/C No: 1234567890'),
                            Text('IFSC: BANK0001'),
                          ],
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _placing ? null : _placeOrder,
                      child: _placing
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Place Order'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
