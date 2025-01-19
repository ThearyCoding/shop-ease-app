import 'package:flutter/material.dart';

import '../../services/apis/auth_api.dart';
import '../../utils/show_snackbar_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback isLogin;
  const SignUpScreen({super.key, required this.isLogin});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final _txtname = TextEditingController();
  final _txtemail = TextEditingController();
  final _txtpassword = TextEditingController();
  final _txtconfirmPassword = TextEditingController();
  final AuthApi _authApi = AuthApi();
  Future<void> _signUp() async {
    final isLogining = await _authApi.register(
        _txtname.text, _txtemail.text, _txtpassword.text);
    if (isLogining) {
      if (!mounted) return;
      ShowSnackbarUtils.showSnackbar(context, "Login success");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
    } else {
      if (!mounted) return;
      ShowSnackbarUtils.showSnackbar(context, "Login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              Text(
                'Welcome to ShopEase',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Create Account to Start Shopping',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              CustomTextField(
                hint: 'Full Name',
                controller: _txtname,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                hint: 'Email',
                controller: _txtemail,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                hint: 'Password',
                controller: _txtpassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                isPasswordField: true,
                isPasswordVisible: _isPasswordVisible,
                togglePasswordVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                hint: 'Confirm Password',
                controller: _txtconfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _txtpassword.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                isPasswordField: true,
                isPasswordVisible: _isPasswordVisible,
                togglePasswordVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _signUp();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?',
                      style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: () {
                      widget.isLogin();
                    },
                    child: Text('Log In', style: TextStyle(color: Colors.teal)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
