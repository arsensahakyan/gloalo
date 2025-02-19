import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'myesims.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  final String country;
  final String price;
  final String uid;

  const PaymentPage({super.key, required this.country, required this.price, required this.uid});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  String _expiryDate = '';
  String? _nameSurname;
  String? _cardNumber, _cvv;
  final bool _isLoading = false;
  bool _saveCard = false;

  void _submitPayment(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final userCookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last; // Replace with your actual cookie
    // const String country = 'global'; // Replace with your specific country or logic

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'Authorization=$userCookie',
    };

    final Map<String, String> body = {
      'plan_type_id': uid,
    };




    final response = await http.post(
      Uri.parse('https://my-service-435668605472.europe-central2.run.app/esims'),
      headers: headers,
      body: json.encode(body)
    );


      if (response.statusCode == 201) {
        print('bought');
        _showSuccessDialog(context);

      } else {
        print("FAIL${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase Failed: ${response.reasonPhrase}')),
        );
      }
  
  }
    
  

  // Future<void> makePurchase() async {
  //  final prefs = await SharedPreferences.getInstance();
  //   final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last;
  //     // Define headers with the authentication cookie
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Cookie':
  //           'Authorization=$user_cookie', // Replace `authCookie` with your cookie's key
  //     };
  //   final response = await http.get(Uri.parse(
  //       'https://gloalobackend-f9cfcd5853e4.herokuapp.com/matchcountries/${widget.country}'),headers: headers);

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body)['products'];
  //   } else {
  //     throw Exception('Failed to load country plans');
  //   }
  // }

  // Function to show the success popup
  void _showSuccessDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow custom height
      backgroundColor: Colors.white, // Background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), // Rounded top corners
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30,),
              const Text(
                'Woohoo!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order has been placed',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.check_circle, // Blue checkmark icon
                size: 60,
                color: Color(0xFF12BCC6),
              ),
              SizedBox(height: 30,),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Back button, close the modal
                    },
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyESIMs()),
                        //  
                      );
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(
                          0xFF12BCC6),
                    ),
                    child: const Text('Go To my eSIMs', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
              SizedBox(height: 30,),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment for ${widget.country} - ${widget.price}'), backgroundColor: const Color(0xFFECEFF1),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Number Field
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Card Number',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text.replaceAll(' ', '');
                    final formatted = text
                        .replaceAllMapped(
                          RegExp(r'.{1,4}'),
                          (match) => '${match.group(0)} ',
                        )
                        .trim();
                    return TextEditingValue(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Your Card Number';
                  }
                  final sanitized = value.replaceAll(' ', '');
                  final cardNumberRegEx = RegExp(r'^\d{16}$');
                  if (!cardNumberRegEx.hasMatch(sanitized)) {
                    return 'Invalid Card Number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cardNumber = value?.replaceAll(' ', '');
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Expiry Date Field
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365 * 10)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _expiryDate =
                                '${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year % 100}';
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: _expiryDate.isEmpty
                                ? 'Expiry Date (MM/YY)'
                                : _expiryDate,
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          validator: (value) {
                            if (_expiryDate.isEmpty) {
                              return 'Please Select an Expiry Date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // CVV Field
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'CVV',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVV';
                        }
                        final cvvRegEx = RegExp(r'^\d{3,4}$');
                        if (!cvvRegEx.hasMatch(value)) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _cvv = value;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Name Surname',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z ]')), // Only allow letters and spaces
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Convert input to uppercase
                    return newValue.copyWith(text: newValue.text.toUpperCase());
                  }),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Your Name and Surname';
                  }
                  return null;
                },
                onSaved: (value) {
                  // Save the name if needed
                  _nameSurname = value?.toUpperCase();
                },
              ),
              const SizedBox(height: 32),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centers horizontally
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Ensures vertical centering
                children: [
                  Checkbox(
                    value: _saveCard,
                    onChanged: (bool? value) {
                      setState(() {
                        _saveCard = value ?? false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), // Circular shape
                    ),
                    side: BorderSide(
                      color: Color(0xFF12BCC6), // Border color for the checkbox
                      width: 2, // Border width
                    ),
                    activeColor: Color(0xFF12BCC6), // Active color
                    checkColor: Colors.white, // Checkmark color
                  ),
                  const SizedBox(width: 8), // Space between checkbox and text
                  const Text(
                    'Save this card for future payments',
                    style: TextStyle(fontSize: 16), // Customize text style
                  ),
                ],
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 70.0, vertical: 16),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // Perform payment submission

                            _submitPayment(widget.uid);

                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    textStyle:
                        const TextStyle(fontSize: 18, color: Colors.white),
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF12BCC6),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Confirm Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
