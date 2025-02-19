import 'package:flutter/material.dart';
import 'package:gloalo/main.dart';
import 'forgot_password.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class TransactionHistoryPage extends StatelessWidget {
  final List<Map<String, String>> transactions = const [
    {'date': 'Oct 1', 'item': '10GB eSIM', 'price': '\$20'},
    {'date': 'Sept 15', 'item': '5GB eSIM', 'price': '\$10'},
    // Add more transactions
  ];

  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(transaction['item']!),
            subtitle: Text(transaction['date']!),
            trailing: Text(transaction['price']!),
          );
        },
      ),
      backgroundColor: const Color(0xFFECEFF1),
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> validateUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last;
      print(user_cookie);
      // Define headers with the authentication cookie
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Cookie':
            'Authorization=$user_cookie', // Replace `authCookie` with your cookie's key
      };

      // Send the HTTP GET request
      final response = await http.get(Uri.parse('https://my-service-435668605472.europe-central2.run.app/validate'), headers: headers);
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Successfully validated user
        print('User validation successful: ${response.body}');
        print(response.body);
        prefs.setString('user_name', jsonData['name']);
        prefs.setString('user_email', jsonData['email']);
        print("USER DATA +"+prefs.getStringList('user_name').toString()+prefs.getStringList('user_email').toString());
     
      } else {
        // Handle errors
        print('User validation failed. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
       
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> _logIn() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final url =
        Uri.parse('https://my-service-435668605472.europe-central2.run.app/login');

    final Map<String, String> body = {
      'email': email,
      'password': password,
    };
    try {
      final response = await http
          .post(
        Uri.parse('https://my-service-435668605472.europe-central2.run.app/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(const Duration(seconds: 1000), onTimeout: () {
        throw Exception('Connection timed out');
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged In Successfully!')),
        );

        // Handling cookies here
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          await saveCookies(cookies);
          print('Login successful, cookies saved!');
          await validateUser();
        }

        // print(getCookies());

        //Navigating to HomePage afetr Logging In
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
          (route) => false
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Log In Failed: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> saveCookies(String cookies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_cookies', cookies);
  }

  Future<String?> getCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_cookies');
  }

  bool _isObscureLogIn = true;
  bool _isObscureSignUp = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log In"),
        backgroundColor: const Color(0xFFECEFF1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset("assets/visuals/Group.png", height: 200),
            const SizedBox(height: 50),
            // Email Input Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
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

                // prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),

            // Password Input Field
            // TextField(
            //   controller: _passwordController,
            //   decoration: InputDecoration(
            //     hintText: 'Password',
            //     fillColor: Colors.white,
            //     filled: true,
            //     focusedBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(90.0), // Rounded corners
            //       borderSide: const BorderSide(color: Colors.white, width: 2),
            //     ),
            //     enabledBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(90.0), // Rounded corners
            //       borderSide: const BorderSide(color: Colors.white, width: 2),
            //     ),
            //   ),

            //   obscureText: true, // Hides the password
            // ),
            TextField(
  controller: _passwordController,
  obscureText: _isObscureLogIn, // Controls password visibility
  decoration: InputDecoration(
    hintText: 'Password',
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
    suffixIcon: IconButton(
      icon: Icon(
        _isObscureLogIn ? Icons.visibility_off : Icons.visibility,
        color: Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _isObscureLogIn = !_isObscureLogIn; // Toggle password visibility
        });
      },
    ),
  ),
),

            const SizedBox(height: 10),

            // Forgot Password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to Forgot Password page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            // Log In Button
            const SizedBox(height: 20),

            // ElevatedButton(
            //   onPressed: () {
            //     // Handle login logic with email/password
            //   },
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(vertical: 16),
            //     textStyle: const TextStyle(fontSize: 18),
            //   ),
            //   child: Text('Log In'),
            // ),

            Center(
              child: SizedBox(
                width: 150, // Desired width
                child: ElevatedButton(
                  onPressed: _logIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle:
                        const TextStyle(fontSize: 18, color: Colors.white),
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF12BCC6),
                  ),
                  child: Text('Log In'),
                ),
              ),
            ),

            // OR separator
            const SizedBox(height: 30),
            Column(
              children: [
                Text("Or Log In Via"),

                const SizedBox(height: 10),

                // Google and Apple Buttons in One Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle Google login
                      },
                      style: ElevatedButton.styleFrom(
                        shape:
                            const CircleBorder(), // Makes the button a circle
                        padding: const EdgeInsets.all(
                            16), // Adjust padding for icon size
                        backgroundColor: Colors.white, // White background
                        elevation: 0, // No shadow
                      ),
                      child: Image.asset('assets/google.png',
                          height: 24), // Google icon
                    ),
                    const SizedBox(width: 5), // Space between buttons

                    // Apple Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle Apple login
                      },
                      style: ElevatedButton.styleFrom(
                        shape:
                            const CircleBorder(), // Makes the button a circle
                        padding: const EdgeInsets.all(
                            16), // Adjust padding for icon size
                        backgroundColor: Colors.white, // White background
                        elevation: 0, // No shadow
                      ),
                      child: const Icon(Icons.apple,
                          size: 24, color: Colors.black), // Apple icon
                    ),
                  ],
                ),

                // OR separator again before Sign Up
                const SizedBox(height: 30),
                Text("Or"),
                const SizedBox(height: 10),
              ],
            ),

            // Sign Up Button
            // const SizedBox(height: 20),
            // OutlinedButton(
            //   onPressed: () {
            //     // Navigate to Sign Up page
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => SignUpPage()),
            //     );
            //   },
            //   style: OutlinedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(vertical: 16),
            //     textStyle: const TextStyle(fontSize: 18),
            //   ),
            //   child: Text('Sign Up'),
            // ),

            // Center(
            //   child: SizedBox(
            //     width: 150, // Desired width
            //     child: ElevatedButton(
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (context) => SignUpPage()),
            //         );
            //       },
            //       style: ElevatedButton.styleFrom(
            //         padding: const EdgeInsets.symmetric(vertical: 16),
            //         textStyle: const TextStyle(fontSize: 18, color: Colors.white),
            //         foregroundColor: Colors.white,
            //         backgroundColor: Color(0xFF12BCC6),
            //       ),
            //       child: Text('Sign Up'),
            //     ),
            //   ),
            // ),
            Center(
                child: GestureDetector(
              onTap: () {
                // Handle the onTap action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: RichText(
                text: TextSpan(
                  text: "Don’t have an account? ",
                  style: TextStyle(
                      color: Colors.grey, fontSize: 14), // Default text style
                  children: [
                    TextSpan(
                      text: "SING UP FOR FREE",
                      style: TextStyle(
                          color: Color(0xFF12BCC6),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFECEFF1),
    );
  }
}

// Dummy Forgot Password Page
// class ForgotPasswordPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Forgot Password'),
//       ),
//       body: Center(
//         child: Text('Forgot Password Page'),
//       ),
//     );
//   }
// }

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

// Dummy Sign Up Page
class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
// Initialize the error string
  bool isPasswordValid = true;
  bool isEmailValid = true;
  bool isNameValid = true;
  bool isSubmitEnabled = false;
  bool showVerificationField = false;
  String verificationCode = '';
  bool _isObscure = true;

  void validateInputs() {
    final isValidName = _nameController.text.isNotEmpty;
    final isValidEmail = _isValidEmail(_emailController.text);
    final isValidPassword = _validatePassword(_passwordController.text);

    setState(() {
      isSubmitEnabled = isValidName && isValidEmail && isValidPassword;
    });
  }

  // Password validation function
  bool _validatePassword(String password) {
    if (password.isEmpty ||
        password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return false;
    } else {
      return true;
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  bool _isNameValid(String name) {
    return !name.isEmpty;
  }
  // const SignUpPage({super.key});

  Future<void> _signUp() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final url =
        Uri.parse('https://my-service-435668605472.europe-central2.run.app/signup');

    final Map<String, String> body = {
      'name': name,
      'email': email,
      'password': password,
    };
    try {
      final response = await http
          .post(
        Uri.parse('https://my-service-435668605472.europe-central2.run.app/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(const Duration(seconds: 1000), onTimeout: () {
        throw Exception('Connection timed out');
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up Successful!')),
        );
        setState(() {
          showVerificationField = true; // Show the verification code field
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up Faile: ${jsonDecode(response.body)['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> submitVerificationCode() async {
    final String email = _emailController.text;
    final String verificationCode = _verificationCodeController.text;
    final response = await http.post(
      Uri.parse(
          'https://my-service-435668605472.europe-central2.run.app/verify-email'), // Replace with your backend verification URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': _verificationCodeController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid verification code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color(0xFFECEFF1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset("assets/visuals/Group-1.png", height: 200),
            const SizedBox(height: 50),

            if (!showVerificationField) ...[
              // Name Input Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                    borderSide: BorderSide(
                      color: isNameValid ? Colors.white : Colors.red,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                    borderSide: BorderSide(
                      color: isNameValid ? Colors.white : Colors.red,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    isNameValid = _isNameValid(_nameController.text);
                  });
                  validateInputs();
                },
              ),
              const SizedBox(height: 20),
              // Email Input Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                    borderSide: BorderSide(
                      color: isEmailValid ? Colors.white : Colors.red,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                    borderSide: BorderSide(
                      color: isEmailValid ? Colors.white : Colors.red,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    isEmailValid = _isValidEmail(
                        _emailController.text); // Update error message
                  });
                  validateInputs();
                },
              ),

              const SizedBox(height: 20),

//             TextField(
//   controller: _passwordController,
//   obscureText: _isObscureLogIn, // Controls password visibility
//   decoration: InputDecoration(
//     hintText: 'Password',
//     fillColor: Colors.white,
//     filled: true,
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(90.0), // Rounded corners
//       borderSide: const BorderSide(color: Colors.white, width: 2),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(90.0), // Rounded corners
//       borderSide: const BorderSide(color: Colors.white, width: 2),
//     ),
//     suffixIcon: IconButton(
//       icon: Icon(
//         _isObscureLogIn ? Icons.visibility_off : Icons.visibility,
//         color: Colors.grey,
//       ),
//       onPressed: () {
//         setState(() {
//           _isObscureLogIn = !_isObscureLogIn; // Toggle password visibility
//         });
//       },
//     ),
//   ),
// ),

              // Password Input Field
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: 'Password',
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                    borderSide: BorderSide(
                      color: isPasswordValid
                          ? Colors.white
                          : Colors.red, // Red border if invalid
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                    borderSide: BorderSide(
                      color: isPasswordValid
                          ? Colors.white
                          : Colors.red, // Red border if invalid
                      width: 2,
                    ),
                  ),
                                      suffixIcon: IconButton(
      icon: Icon(
        _isObscure ? Icons.visibility_off : Icons.visibility,
        color: Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _isObscure = !_isObscure; // Toggle password visibility
        });
      },
    ),
                  errorText: null, // No error text directly, handled manually
                ),
                onChanged: (value) {
                  setState(() {
                    isPasswordValid =
                        _validatePassword(value); // Update error message
                  });
                  validateInputs();
                },

              ),

              const SizedBox(height: 10),

              // Forgot Password link
              Center(
                child: Text(
                  "Password must be min 8 characters with at least 1 uppercase, 1 numeric and 1 special character.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isPasswordValid
                        ? Colors.grey
                        : Colors.red, // Red text if invalid
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
              ),

              // Log In Button
              const SizedBox(height: 20),

              Center(
                child: SizedBox(
                  width: 150, // Desired width
                  child: ElevatedButton(
                    onPressed: isSubmitEnabled ? _signUp : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle:
                          const TextStyle(fontSize: 18, color: Colors.white),
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF12BCC6),
                    ),
                    child: Text('Sign Up'),
                  ),
                ),
              ),
            ],

            if (showVerificationField) ...[
              SizedBox(height: 20),
              TextFormField(
                controller: _verificationCodeController,
                decoration: InputDecoration(
                  hintText: 'Verification Code',
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  errorText: null, // No error text directly, handled manually
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  verificationCode = value;
                },
              ),
              ElevatedButton(
                onPressed: submitVerificationCode,
                child: Text('Verify Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF12BCC6),
                ),
              ),
            ],

            // OR separator
            const SizedBox(height: 30),
            Column(
              children: [
                Text("Or Sign Up Via"),

                const SizedBox(height: 10),

                // Google and Apple Buttons in One Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle Google login
                      },
                      style: ElevatedButton.styleFrom(
                        shape:
                            const CircleBorder(), // Makes the button a circle
                        padding: const EdgeInsets.all(
                            16), // Adjust padding for icon size
                        backgroundColor: Colors.white, // White background
                        elevation: 0, // No shadow
                      ),
                      child: Image.asset('assets/google.png',
                          height: 24), // Google icon
                    ),
                    const SizedBox(width: 5), // Space between buttons

                    // Apple Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle Apple login
                      },
                      style: ElevatedButton.styleFrom(
                        shape:
                            const CircleBorder(), // Makes the button a circle
                        padding: const EdgeInsets.all(
                            16), // Adjust padding for icon size
                        backgroundColor: Colors.white, // White background
                        elevation: 0, // No shadow
                      ),
                      child: const Icon(Icons.apple,
                          size: 24, color: Colors.black), // Apple icon
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFECEFF1),
    );
  }
}

class EditProfile extends StatefulWidget {
  @override
  _EditProfile createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  bool _notificationsEnabled = false;
  String name = 'Loading...';
  String email = 'Loading...';

  
Future<void> removeCookie() async {
  final prefs = await SharedPreferences.getInstance();

  // Attempt to remove the 'user-cookie' and check if it was successful
  bool isRemoved = await prefs.remove('user_cookies') && await prefs.remove('user_name') && await prefs.remove('user_email');

  if (isRemoved) {
    print('Cookies removed successfully.');
  } else {
    print('No cookies found or could not remove cookies.');
  }
}


  void _logout(BuildContext context) async {
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              removeCookie();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeNotLoggedIn()),
                 (route) => false,
              );
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // Future<Map> getUserData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final name = await prefs.getString('user_name');
  //   final email = await prefs.getString('user_email');

  //   Map<String, String> data = {
  //     'name': name.toString(),
  //     'email':email.toString()
  //   };

  //   return data;
  // }

  @override
  void initState() {
    super.initState();
    _loadNameFromSharedPreferences();
  }

  // Function to load name from SharedPreferences
  void _loadNameFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('user_name') ?? "No Name Found";
    String? savedEmail = prefs.getString('user_email') ?? "No Email Found";

    setState(() {
      name = savedName;
      email = savedEmail; 
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadNameFromSharedPreferences();
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: const Color(0xFFECEFF1),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          Icon(
            Icons.person_pin,
            color: Color(0xFF12BCC6),
            size: 100,
          ),
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text('$name', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.edit),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditFieldPage(fieldName: 'Name Surname')),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('$email'),
            trailing: Icon(Icons.edit),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditFieldPage(fieldName: 'Email')),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Change Password'),
            trailing: Icon(Icons.edit),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditFieldPage(fieldName: 'Change Password')),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Card Details'),
            trailing: Icon(Icons.edit),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditFieldPage(fieldName: 'Card Details')),
              );
            },
          ),
          Divider(),
          SwitchListTile(
            title: Text('Notifications'),
            value: _notificationsEnabled,
            activeColor: Colors.white,
            activeTrackColor: Color(0xFF12BCC6),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Color(0xFFC8C6C6),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          Divider(),
          ListTile(
            title: Center(
              child: Text(
                'Log Out',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class EditFieldPage extends StatefulWidget {
  final String fieldName;

  EditFieldPage({required this.fieldName});

  @override
  _EditFieldPageState createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
final TextEditingController _newEmailVerificationCodeController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _existingPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _verifyPasswordController =
      TextEditingController();
  String _verificationCode = '';
  String _userEnteredCode = '';
  String _currentEmail = 'user@example.com'; // Example current email

  bool _isPasswordVisible = false;
  bool _isEmailVerification = false;

  bool isPasswordValid = true;
  bool isEmailValid = true;
  // Password validation function
  bool _validatePassword(String password) {
    if (password.isEmpty ||
        password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return false;
    } else {
      return true;
    }
  }

    void _loadNameFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('user_email') ?? "No Email Found";

    setState(() {
      _currentEmail = savedEmail; 
    });
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // Simulate sending a verification code
  String generateVerificationCode() {
    return Random().nextInt(999999).toString().padLeft(6, '0');
  }

  void _changeName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last; // Replace with your actual cookie
    // const String country = 'global'; // Replace with your specific country or logic

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'Authorization=$user_cookie',
    };

    final Map<String, String> body = {
      'new_name': name,
    };


    final response = await http.patch(
      Uri.parse('https://my-service-435668605472.europe-central2.run.app/change-name'),
      headers: headers,
      body: json.encode(body)
    );


      if (response.statusCode == 200) {
        print('name changed ' + response.body);
        prefs.setString('user_name', name);

      } else {
        print("FAIL" + response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Change Failed: ${response.reasonPhrase}')),
        );
      }
  
  }

  void _changePassword(String currentPassword, String newPassowrd) async {
    final prefs = await SharedPreferences.getInstance();
    final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last; // Replace with your actual cookie
    // const String country = 'global'; // Replace with your specific country or logic

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'Authorization=$user_cookie',
    };

    final Map<String, String> body = {
      'current_password': currentPassword,
      'new_password':newPassowrd
    };


    final response = await http.patch(
      Uri.parse('https://my-service-435668605472.europe-central2.run.app/change-password'),
      headers: headers,
      body: json.encode(body)
    );


      if (response.statusCode == 200) {
        print('Password has been changed ' + response.body);
                            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Password has been changed')));

      } else {
        print("FAIL" + response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Change Failed: ${response.reasonPhrase}')),
        );
      }
  
  }

    void _changeEmailRequest(String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last; // Replace with your actual cookie
    // const String country = 'global'; // Replace with your specific country or logic

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'Authorization=$user_cookie',
    };

    print(newEmail);
    final Map<String, String> body = {
      'new_email': newEmail,
    };


    final response = await http.post( 
      Uri.parse('https://my-service-435668605472.europe-central2.run.app/change-email-request'),
      headers: headers,
      body: json.encode(body)
    );


      if (response.statusCode == 200) {
        print('Code sent ' + response.body);
        setState(() {
          _isEmailVerification = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Verification code sent')));

      } else {
        print("FAaaaIL" + response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Change Failed: ${response.reasonPhrase}')),
        );
      }
  
  }

  void _confirmEmailChange(String newEmail, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last; // Replace with your actual cookie
    // const String country = 'global'; // Replace with your specific country or logic

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'Authorization=$user_cookie',
    };

    final Map<String, String> body = {
      'new_email': newEmail,
      'code': code
    };


    final response = await http.post(
      Uri.parse('https://my-service-435668605472.europe-central2.run.app/confirm-email-change'),
      headers: headers,
      body: json.encode(body)
    );


      if (response.statusCode == 200) {
        print('Email Changed' + response.body);
        _isEmailVerification = false;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user_email', newEmail);
        
        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Email has been changed')));
                                        Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile()),
                                );

      } else {
        print("FAIL" + response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Change Failed: ${response.reasonPhrase}')),
        );
      }
  
  }

  @override
  void dispose() {
    _controller.dispose();
    _newEmailController.dispose();
    _existingPasswordController.dispose();
    _newPasswordController.dispose();
    _verifyPasswordController.dispose();
    _newEmailVerificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loadNameFromSharedPreferences();
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.fieldName}"),
        backgroundColor: const Color(0xFFECEFF1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.fieldName == 'Name Surname') ...[
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter new name and surname',
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(90.0), // Rounded corners
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(90.0), // Rounded corners
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name and surname';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save the name and surname (for example, update a database)
                      _changeName(_controller.text);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Name saved')));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile()),
                                );
                    }
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 30),
                    textStyle:
                        const TextStyle(fontSize: 18, color: Colors.white),
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF12BCC6),
                  ),
                ),
              ] else if (widget.fieldName == 'Email') ...[
                Text('Current email: $_currentEmail'),
                SizedBox(height: 16),
                TextFormField(
                    controller: _newEmailController,
                    decoration: InputDecoration(
                      hintText: 'Enter new email',
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(90.0), // Rounded corners
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(90.0), // Rounded corners
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        isEmailValid = _isValidEmail(
                            _newEmailController.text); // Update error message
                      });
                    }),
                SizedBox(height: 16),
                if (_isEmailVerification) ...[
                  TextFormField(
                    controller: _newEmailVerificationCodeController,
                    decoration: InputDecoration(
                      hintText: 'Enter Verification Code',
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(90.0), // Rounded corners
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(90.0), // Rounded corners
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      _userEnteredCode = value;
                    },
                    validator: (value) {
                      if (value != _verificationCode) {
                        return 'Incorrect code';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                        _confirmEmailChange(_newEmailController.text, _newEmailVerificationCodeController.text);
                    },
                    // () {
                    //   if (_formKey.currentState!.validate()) {
                    //     setState(() {
                    //       _currentEmail = _newEmailController.text;
                    //       _isEmailVerification = false;
                    //     });
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(content: Text('Email updated')));
                    //   }
                    // },
                    child: Text('Verify and Save'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 30),
                      textStyle:
                          const TextStyle(fontSize: 18, color: Colors.white),
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF12BCC6),
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _verificationCode = generateVerificationCode();
                        // _isEmailVerification = true;
                      });

                      _changeEmailRequest(_newEmailController.text);
                      // Simulate sending an email with the verification code
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(content: Text('Verification code sent')));
                    },
                    child: Text('Send Verification Code'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 30),
                      textStyle:
                          const TextStyle(fontSize: 18, color: Colors.white),
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF12BCC6),
                    ),
                  ),
                ],
              ] else if (widget.fieldName == 'Change Password') ...[
                TextFormField(
                  controller: _existingPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration:
                      InputDecoration(
                    hintText: 'Enter the current password',
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(90.0), // Rounded corners
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(90.0), // Rounded corners
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the existing password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter the new password',
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(90.0), // Rounded corners
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(90.0), // Rounded corners
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _verifyPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Verify the new password',
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(90.0), // Rounded corners
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(90.0), // Rounded corners
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Simulate password change process
                      _changePassword(_existingPasswordController.text, _newPasswordController.text);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(content: Text('Password changed')));
                    }
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 30),
                      textStyle:
                          const TextStyle(fontSize: 18, color: Colors.white),
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF12BCC6),
                    )
                ),
              ] else if (widget.fieldName == 'Card Details') ...<Widget>[

                Center(
                  child: Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CARD TYPE",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "BANK NAME",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 40,
                                color: Colors.grey[300],
                              ),
                              SizedBox(width: 10),
                              Text(
                                "••••  ••••  ••••  3456",
                                style: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "1234",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "CARDHOLDER NAME",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "VALID THRU\n06/30",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
