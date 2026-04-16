import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _showOtp = false;
  bool _loading = false;
  String? _error;

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      _showOtp = true;
      _loading = false;
      _otpController.text = '123456'; // Dummy OTP
    });
  }

  Future<void> _verifyOtp() async {
    setState(() => _loading = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.login(_phoneController.text, _otpController.text);
    
    setState(() => _loading = false);
    
    if (result['success'] == true) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = result['error'] ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 8),
            Text('Login with your phone number', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 32),
            if (_error != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              ),
            if (!_showOtp) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+91 ',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _sendOtp,
                  child: _loading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Send OTP'),
                ),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verifyOtp,
                  child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Verify & Login'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showOtp = false),
                child: Text('Change Phone'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
