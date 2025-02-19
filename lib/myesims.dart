// import 'package:flutter/material.dart';
// import 'package:gloalo/main.dart';
// import 'package:gloalo/purchase.dart';
// import 'profile_page.dart';
// import 'services/notification_service.dart';
// import 'purchase.dart';
// import 'privacy_policy.dart';
// import 'dart:ffi';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class MyESIMs extends StatelessWidget {
//   bool cardsAvailable = false;


//   Future<void> _GetMyCards() async{
//     final prefs = await SharedPreferences.getInstance();
//     final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last;

//      Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'Cookie': 'Authorization=$user_cookie',
//     };

//     final response = await http.post(
//       Uri.parse('https://gloalobackend-f9cfcd5853e4.herokuapp.com/customers/me'),
//       headers: headers
//     );


//       if (response.statusCode == 200) {
//         cardsAvailable = true;

//       } else {
//         print("No Cards Yet" + response.statusCode.toString());
//       }
//   }

//   final List<Map<String, dynamic>> countryPlans = [
//     {
//       "country": "Germany",
//       "flag": "assets/flags/germany.jpg", // Germany flag
//       "price": "\$2.99",
//       "duration": "7 days",
//       "data": "10 GB",
//       "minutes": "200 min",
//       "sms": "150 SMS",
//     },
//     {
//       "country": "France",
//       "flag": "assets/flags/france.png", // France flag
//       "price": "\$3.99",
//       "duration": "7 days",
//       "data": "12 GB",
//       "minutes": "250 min",
//       "sms": "200 SMS",
//     },
//     {
//       "country": "Italy",
//       "flag": "assets/flags/italy.png", // Italy flag
//       "price": "\$4.99",
//       "duration": "10 days",
//       "data": "15 GB",
//       "minutes": "300 min",
//       "sms": "250 SMS",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     if (cardsAvailable) {
//       return Scaffold(
//         appBar: AppBar(title: Text("My eSIMs"), backgroundColor: const Color(0xFFECEFF1)),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Image.asset('assets/visuals/no_card.png', height: 250),
//               SizedBox(height: 30),
//               Text(
//                 'You don\'t have a card yet',
//                 style: TextStyle(fontSize: 14, color: Colors.black),
//               ),
//               SizedBox(height: 30),
//               Center(
//                 child: SizedBox(
//                   width: 150, // Desired width
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => MainPage()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       textStyle: const TextStyle(fontSize: 18, color: Colors.white),
//                       foregroundColor: Colors.white,
//                       backgroundColor: Color(0xFF12BCC6),
//                     ),
//                     child: Text('Packages'),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 60),
//             ],
//           ),
//         ),
//         backgroundColor: const Color(0xFFECEFF1),
//       );
//     } else {
//       return Scaffold(
//         appBar: AppBar(title: Text("My eSIMs"), backgroundColor: const Color(0xFFECEFF1)),
//         body: Center(
//           // padding: const EdgeInsets.all(16.0),
//           child: Column(
//             // mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: 10),
//               Text(
//               'Valid eSIMs',
//               style: TextStyle(
//                 fontSize: 18,
//                 // fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 40),
//               SizedBox(
//                 height: 220, // Adjusted height to fit the design
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: countryPlans.length,
//                   clipBehavior: Clip.none,
//                   itemBuilder: (context, index) {
//                     final plan = countryPlans[index];
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: Stack(
//                         clipBehavior: Clip.none, // Allows the flag to overflow the card
//                         children: [
//                           // Card
//                           Card(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Container(
//                               width: 300, // Fixed width for the card
//                               padding: const EdgeInsets.all(16.0),
//                               decoration: BoxDecoration(
//                                 color: Color(0xFF12BCC6),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   const SizedBox(height: 40), // Space for the flag
//                                   Text(
//                                     plan['country'],
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     plan['price'],
//                                     style: TextStyle(fontSize: 18, color: Colors.white),
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(plan['duration'], style: TextStyle(color: Colors.white)),
//                                   SizedBox(height: 10),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                     children: [
//                                       Text(plan['data'], style: TextStyle(color: Colors.white)),
//                                       Text('|', style: TextStyle(color: Colors.white)),
//                                       Text(plan['minutes'], style: TextStyle(color: Colors.white)),
//                                       Text('|', style: TextStyle(color: Colors.white)),
//                                       Text(plan['sms'], style: TextStyle(color: Colors.white)),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           // Circular Flag
//                           Positioned(
//                             top: -20, // Position above the card
//                             left: 125, // Center the flag horizontally
//                             child: CircleAvatar(
//                               radius: 28, // Adjust size of the flag
//                               backgroundImage: AssetImage(plan['flag']),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_esim/flutter_esim.dart';

class MyESIMs extends StatefulWidget {
  @override
  _MyESIMsState createState() => _MyESIMsState();
}

class _MyESIMsState extends State<MyESIMs> {
  List<dynamic> esims = [];
  List<dynamic> expiredEsims = [];
  bool isLoading = true;
  bool? _supportsEsim;

  @override
  void initState() {
    super.initState();
    // checkEsimSupport();
    _GetMyCards();
  }

  // Future<void> checkEsimSupport() async {
  //   bool isEsimSupported = false;
  //   final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  //   try {
  //     if (Theme.of(context).platform == TargetPlatform.android) {
  //       AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
  //       isEsimSupported = _androidEsimSupportedDevices.contains(androidInfo.model);
  //     } else if (Theme.of(context).platform == TargetPlatform.iOS) {
  //       IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
  //       isEsimSupported = _iosEsimSupportedDevices.contains(iosInfo.utsname.machine);
  //     }
  //   } catch (e) {
  //     print('Failed to get device info: $e');
  //   }

  //   setState(() {
  //     _supportsEsim = isEsimSupported;
  //   });
  // }

  Future<void> _GetMyCards() async {
    final prefs = await SharedPreferences.getInstance();
    final userCookie = prefs.getString('user_cookies')?.split(';').first.split('=').last;

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'Authorization=$userCookie',
    };

    final response = await http.get(
      Uri.parse('https://my-service-435668605472.europe-central2.run.app/customers/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // final data = json.decode(response.body);
      // final customerEsims = data['customer']['esims'] ?? [];
      // final now = DateTime.now();
      // print("ESIM DATA - "+data.toString());
      // setState(() {
      //   esims = customerEsims.where((e) {
      //     final plan = e['plans'][0];
      //     final endTime = DateTime.tryParse(plan['end_time'] ?? '') ?? DateTime(9999);
      //     final isActivated = plan['network_status'] == 'ACTIVE';
      //     final isNotActivated = plan['date_activated'] == "0000-00-00 00:00:00" && plan['end_time'] == "0000-00-00 00:00:00";

      //     print("endTime - "+endTime.toString());
      //     print("is activated - " + isActivated.toString());
      //     print("is not activated - " + isNotActivated.toString());


      //     return e['state'] == 'RELEASED' && (isNotActivated || (isActivated && endTime.isAfter(now)));
      //   }).toList();

      //   expiredEsims = customerEsims.where((e) {
      //     final plan = e['plans'][0];
      //     final endTime = DateTime.tryParse(plan['end_time'] ?? '') ?? DateTime(9999);
      //     final isActivated = plan['network_status'] == 'ACTIVE';
      //     return e['state'] == 'RELEASED' && isActivated && endTime.isBefore(now);
      //   }).toList();

      //   isLoading = false;
      // });
        final data = json.decode(response.body);
  final customerEsims = data['customer']['esims'] ?? [];
  final now = DateTime.now();
  
  print("ESIM DATA - " + data.toString());

  setState(() {
    esims = customerEsims.where((e) {
      final plan = e['plans'][0];
      final endTime = DateTime.tryParse(plan['end_time'] ?? '') ?? DateTime(9999);
      final isNotActivated = plan['date_activated'] == "0000-00-00 00:00:00";
      final isExpired = plan['end_time'] != "0000-00-00 00:00:00" && endTime.isBefore(now);

      print("endTime - " + endTime.toString());
      print("is not activated - " + isNotActivated.toString());
      print("is expired - " + isExpired.toString());

      // Case 1: "state" is "ENABLED" and "end_time" is after the current date
      if (e['state'] == 'ENABLED' && endTime.isAfter(now)) {
        return true;
      }

      // Case 2: "state" is "RELEASED" and "date_activated" is "0000-00-00 00:00:00"
      if (e['state'] == 'RELEASED' && isNotActivated) {
        return true;
      }

      return false;
    }).toList();

    expiredEsims = customerEsims.where((e) {
      final plan = e['plans'][0];
      final endTime = DateTime.tryParse(plan['end_time'] ?? '') ?? DateTime(9999);
      bool active = (e['state'] == 'ENABLED' && endTime.isAfter(now)) || (e['state'] == 'RELEASED' && plan['date_activated'] == "0000-00-00 00:00:00");

      // Case 3: "end_time" has passed (so it's before the current date)
      return !active;
    }).toList();

    isLoading = false;
  });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Error: ${response.statusCode}");
    }
  }

  void _showActivationPopup(BuildContext context, String activationCode) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,  // Change background color of the popup
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners for the dialog
        ),
        title: Text(
          "Activate eSIM",
          style: TextStyle(color: Colors.black87), // Title text color
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Scan the QR code below to activate your eSIM.",
              style: TextStyle(color: Colors.black54), // Text color
            ),
            SizedBox(height: 16),
            Image.network(
              'https://api.qrserver.com/v1/create-qr-code/?data=$activationCode&size=200x200',
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _activateEsimAutomatically(activationCode);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF12BCC6),  // Button background color
                foregroundColor: Colors.white, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded button corners
                ),
              ),
              child: Text("Activate Automatically", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Button text color
            ),
            child: Text("Close"),
          ),
        ],
      );
    },
  );
}


Future<void> _activateEsimAutomatically(String activationCode) async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 29) {  // Ensure Android 10+
        const platform = MethodChannel('esim_activation');
        final bool result = await platform.invokeMethod('activateEsim', {'activationCode': activationCode});
        if (result) {
          print("eSIM activated successfully on Android.");
        } else {
          print("Failed to activate eSIM on Android.");
        }
      } else {
        print("eSIM activation is not supported on this Android version.");
      }
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      const platform = MethodChannel('esim_activation');
      final bool result = await platform.invokeMethod('installEsim', {'activationCode': activationCode});
      if (result) {
        print("eSIM activated successfully on iOS.");
      } else {
        print("Failed to activate eSIM on iOS.");
      }
    } else {
      print("Unsupported platform for eSIM activation.");
    }
  } on PlatformException catch (e) {
    print("Error during eSIM activation: ${e.message}");
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("My eSIMs"), backgroundColor: const Color(0xFFECEFF1)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("My eSIMs"),
          backgroundColor: const Color(0xFFECEFF1),
          surfaceTintColor: Color(0xFF12BCC6),
          bottom: TabBar(
            tabs: [
              Tab(text: "Valid eSIMs"),
              Tab(text: "Expired eSIMs"),
            ],
            indicatorColor: Color(0xFF12BCC6),
            labelColor: Color(0xFF12BCC6),
          ),
        ),
        body: TabBarView(
          children: [
            _buildEsimList(esims, false),
            _buildExpiredEsimList(expiredEsims, true),
          ],
        ),
      ),
    );
  }

  Widget _buildEsimList(List<dynamic> esimList, bool isExpired) {
    if (esimList.isEmpty) {
      return Center(
        child: Text(isExpired ? "No expired eSIMs" : "No valid eSIMs"),
      );
    }

    return ListView.builder(
      itemCount: esimList.length,
      itemBuilder: (context, index) {
        final esim = esimList[index];
        final plan = esim['plans'][0];
        final isActivated = plan['network_status'] == 'ACTIVE';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(plan['plan_type']['plan_name'] ?? "Unknown Plan"),
            subtitle: isActivated ? Text("Data: ${plan['data_quota_mb']}+MB \nStatus: Activated\nEnd date: ${plan['end_time']}") : Text("Activate the eSIM"),
            trailing: isExpired
                ? null
                : isActivated
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                        onPressed: () => _showActivationPopup(context, esim['activation_code']),
                        child: Text("Activate", style: TextStyle(fontWeight: FontWeight.bold),),
                        style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF12BCC6), // Change button color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                      ),
          ),
          color: Colors.white,
        );
      },
    );
  }

  Widget _buildExpiredEsimList(List<dynamic> esimList, bool isExpired) {
    if (esimList.isEmpty) {
      return Center(
        child: Text(isExpired ? "No expired eSIMs" : "No valid eSIMs"),
      );
    }

    return ListView.builder(
      itemCount: esimList.length,
      itemBuilder: (context, index) {
        final esim = esimList[index];
        final plan = esim['plans'][0];
        // final isActivated = plan['network_status'] == 'ACTIVE';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(plan['plan_type']['plan_name'] ?? "Unknown Plan"),
            subtitle: Text("eSIM Expired"),
            // trailing: isExpired
            //     ? null
            //     : isActivated
            //         ? Icon(Icons.check_circle, color: Colors.green)
            //         : ElevatedButton(
            //             onPressed: () => _showActivationPopup(context, esim['activation_code']),
            //             child: Text("Activate", style: TextStyle(fontWeight: FontWeight.bold),),
            //             style: ElevatedButton.styleFrom(
            //       backgroundColor: Color(0xFF12BCC6), // Change button color
            //       foregroundColor: Colors.white, // Text color
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8), // Rounded corners
            //       ),
            //     ),
            //           ),
          ),
          color: Colors.white,
        );
      },
    );
  }
}
