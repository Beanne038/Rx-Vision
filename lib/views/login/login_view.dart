import 'package:flutter/material.dart';
import 'package:rx_vision/views/forgot_password/forgotpassword_view.dart';
import '../../../models/user_model.dart';
import 'package:rx_vision/services/auth_service.dart';
import 'package:rx_vision/views/dashboard/dashboard_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isValidEmail(String email) {
    return RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(email);
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(email: _emailController.text, password: _passwordController.text, context: context);

      debugPrint('Login Response: $result'); // Add this for debugging

      if (result['success'] == true) {
        // Handle different response structures
        dynamic userData = result['user'] ?? result; // Try both 'user' key and root level

        if (userData['id'] == null) {
          // If ID is still missing, try alternative keys
          userData['id'] = userData['_id'] ?? userData['userId'] ?? '0';
        }

        final user = User.fromJson({'id': userData['id']?.toString() ?? '0', 'name': userData['name'] ?? 'Guest', 'email': userData['email'] ?? _emailController.text});

        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardView(user: user)));
        }
      } else {
        throw Exception(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Failed: ${e.toString().replaceAll('Exception: ', '')}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60.0),
                const Text(
                  'Rx-Vision',
                  style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40.0),

                // Email Field
                const Text('Email:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter your email', prefixIcon: Icon(Icons.email)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!_isValidEmail(value)) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),

                // Password Field
                const Text('Password:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 8.0),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordView())),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Text('Login'),
                ),
                const SizedBox(height: 20.0),

                // Back Button
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
