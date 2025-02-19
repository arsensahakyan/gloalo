import 'package:flutter/material.dart';
import 'package:gloalo/profile_page.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String? _verificationCode;
  bool _isCodeSent = false;
  bool _isCodeVerified = false;

  // Simulate sending a verification code
  Future<void> _sendVerificationCode() async {
   
    final String email = _emailController.text;

    final url =
        Uri.parse('https://my-service-435668605472.europe-central2.run.app/forgot-password');

    final Map<String, String> body = {
      'email': email,
    };

    try {
      final response = await http
      .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(const Duration(seconds: 1000), onTimeout: () {
        throw Exception('Connection timed out');
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Code has been sent')),
        );
        setState(() {
          _isCodeSent = true;
        });
        

      } else {
        print(response.statusCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

  }

  // Verify if the code entered matches the one sent
  Future<void> _verifyCode() async {

       
    final String email = _emailController.text;
    final String code = _codeController.text;
    final String newPassword = _newPasswordController.text;

    final url =
        Uri.parse('https://my-service-435668605472.europe-central2.run.app/reset-password');

    final Map<String, String> body = {
      'email': email,
      'code': code,
      'new_password':newPassword
    };

    try {
      final response = await http
      .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(const Duration(seconds: 1000), onTimeout: () {
        throw Exception('Connection timed out');
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password Successfully Changed!')),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
          (route) => false
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }


    // if (_verificationCode == _codeController.text) {
    //   setState(() {
    //     _isCodeVerified = true;
    //   });
    // } else {
    //   // Show error if code does not match
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //     content: Text("Verification code is incorrect"),
    //     backgroundColor: Colors.red,
    //   ));
    // }
  }

  // Simulate updating the password in the database
  void _updatePassword() {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      // Normally you would update the password in the database here.
      print("Password updated successfully");
      
      // Show success message and navigate to the login page
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password updated successfully"),
        backgroundColor: Colors.green,
      ));

      // Navigate to the login page
      Navigator.pop(context); // Go back to the previous page (which is login page)
    } else {
      // Show error if passwords do not match
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Passwords do not match"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Color(0xFFECEFF1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step 1: Enter Email
            if (!_isCodeSent) ...[
              TextField(
                controller: _emailController,
                  decoration: InputDecoration(
    hintText: 'Enter Your Email',
    fillColor: Colors.white,
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(90.0), // Rounded corners
      borderSide: const BorderSide(color: Colors.white, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(90.0), // Rounded corners
      borderSide: const BorderSide(color: Colors.white, width: 2),
    ),
  ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _sendVerificationCode();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle:
                        const TextStyle(fontSize: 18, color: Colors.white),
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF12BCC6),
                  ),
                child: const Text("Send Verification Code"),
              ),
            ],

            // Step 2: Enter Verification Code (only show if code is sent)
            if (_isCodeSent && !_isCodeVerified) ...[
              TextField(
                controller: _codeController,
                  decoration: InputDecoration(
    hintText: 'Enter Verification Code',
    fillColor: Colors.white,
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(90.0), // Rounded corners
      borderSide: const BorderSide(color: Colors.white, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(90.0), // Rounded corners
      borderSide: const BorderSide(color: Colors.white, width: 2),
    ),

  ),
              ),
              const SizedBox(height: 20),
                            TextField(
                controller: _newPasswordController,
                  decoration: InputDecoration(
    hintText: 'Enter the New Password',
    fillColor: Colors.white,
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(90.0), // Rounded corners
      borderSide: const BorderSide(color: Colors.white, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(90.0), // Rounded corners
      borderSide: const BorderSide(color: Colors.white, width: 2),
    ),

  ),
                obscureText: true, // For hiding password input
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _verifyCode();
                },
                                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle:
                        const TextStyle(fontSize: 18, color: Colors.white),
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF12BCC6),
                  ),
                child: const Text("Verify Code and reset Password"),
              ),
            ],

            // Step 3: Reset Password (only show if code is verified)
            if (_isCodeVerified) ...[

              const SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true, // For hiding password input
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _updatePassword();
                },
                child: const Text("Update Password"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
