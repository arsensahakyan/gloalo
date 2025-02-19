import 'package:flutter/material.dart';
import 'package:gloalo/purchase.dart';
import 'package:gloalo/splash_screen.dart';
import 'profile_page.dart';
import 'services/notification_service.dart';
import 'purchase.dart';
import 'privacy_policy.dart';
import 'myesims.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

bool isLoggedIn = true;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GloAlo',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFECEFF1),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF5C5C5C)),
          bodyMedium: TextStyle(color: Color(0xFF5C5C5C)),
          bodySmall: TextStyle(color: Color(0xFF5C5C5C)),
          titleLarge: TextStyle(color: Color(0xFF5C5C5C)),
          titleMedium: TextStyle(color: Color(0xFF5C5C5C)),
          titleSmall: TextStyle(color: Color(0xFF5C5C5C)),
          headlineLarge: TextStyle(color: Color(0xFF5C5C5C)),
          headlineMedium: TextStyle(color: Color(0xFF5C5C5C)),
          headlineSmall: TextStyle(color: Color(0xFF5C5C5C)),
        ),
      ),
      // home: isLoggedIn ? MainPage() : HomeNotLoggedIn(),
      home: SplashScreen(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    MyESIMs(),
    SettingsPage(),
    ProfilePage(), // Add ProfilePage to the list
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Center(
      //     child: Image.asset('assets/logo.png', height: 40,), // Logo at the top
      //   ),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      // ),
      body: _pages[_selectedIndex],
      // bottomNavigationBar: Container(decoration: BoxDecoration(
      //     color: Colors.white, // Background color of BottomNavigationBar
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(90),
      //       topRight: Radius.circular(90),
      //     ),
      //   ),
      //   child: BottomNavigationBar(
      //     currentIndex: _selectedIndex,
      //     onTap: _onItemTapped,
      //     items: <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart),
      //       label: 'My eSIMs',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      // ),

      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue, // Background color of the bottom bar
          ),
          child: BottomNavigationBar(
            backgroundColor: Color(0xFF12BCC6),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.white,
            unselectedItemColor: const Color.fromARGB(255, 219, 219, 219),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sim_card_outlined),
                label: 'My eSIMs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                label: 'Profile',
              ),
            ],
          ),
        ),
    
    ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  {

  final List<String> countries = const ['brazil', 'france', 'japan', 'usa'];
  late Future<List<Map<String, String>>> _countryData;
    @override
    void initState() {
      super.initState();
      _countryData = fetchCountryData();
    }

  final List<String> images = const [
    'assets/visuals/slides/italy_slide.png',
    'assets/visuals/slides/germany_slide.png',
  ];

  // const HomePage({super.key});


  Future<List<Map<String, String>>> fetchCountryData() async {
    final prefs = await SharedPreferences.getInstance();
    final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last; // Replace with your actual cookie
    // const String country = 'global'; // Replace with your specific country or logic

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'Authorization=$user_cookie',
    };

    final response = await http.get(
      Uri.parse('https://my-service-435668605472.europe-central2.run.app/alfacodes'),
      headers: headers,
    );
    // print(response.body);
    if (response.statusCode == 200) {
     // Parse the response JSON
    final Map<String, dynamic> responseData = json.decode(response.body);

    // Extract the countries array
    final List<dynamic> countries = responseData['countries'];

    // Map the countries data to a list of maps with `country` and `flagAsset`
    return countries.map<Map<String, String>>((item) {
      return {
        'country': item['alfa2_code'],
        'flagAsset': 'assets/flags/${item['alfa2_code'].toLowerCase()}.png', // Generate flag asset path dynamically
      };
    }).toList();
    } else {
      throw Exception('Failed to load country data');
    }
  }

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Country"),
        backgroundColor: const Color(0xFFECEFF1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     const Text("Welcome to GloAlo "), // Logo at top left
            //     TextButton(
            //       onPressed: () {
            //         Navigator.push(
            //               context,
            //               MaterialPageRoute(builder: (context) => ProfilePage()),
            //             );
            //       },
            //       child: const Text('Log In'),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
            const Text(
              'Most Popular',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 10),

            // DEFINE IMAGES AT THE TOP, SHOULD COME FROM DB

            Center(
              child: Container(
                height: 230, // Set a fixed height for the carousel
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Define the action you want to perform on tap
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Image.asset(
                          images[index],
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width *
                              0.8, // Set image width
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 30),

            // DropdownButtonFormField<String>(
            //   decoration: const InputDecoration(
            //     filled: true, // Makes the background white
            //     fillColor: Colors.white, // Sets the background color to white
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.all(Radius.circular(90)),
            //     ),
            //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   ),
            //   items: countries.map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Row(
            //         children: [
            //           Image.asset("assets/flags/"+value+".png", width: 30,), // Example icon, replace with your preferred one
            //           SizedBox(width: 8),
            //           Text(value),
            //         ],
            //       ),
            //     );
            //   }).toList(),
            //   onChanged: (String? newValue) {},
            //   hint: const Text('Select a country'),
            // ),

            // DropdownSearch<String>(
            //   items: countries, // Your list of countries
            //   dropdownDecoratorProps: DropDownDecoratorProps(
            //     dropdownSearchDecoration: InputDecoration(
            //       filled: true,
            //       fillColor: Colors.white,
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.all(Radius.circular(90)),
            //         borderSide: BorderSide(
            //             color: Colors.white), // Invisible white border
            //       ),
            //       enabledBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.all(Radius.circular(90)),
            //         borderSide: BorderSide(
            //             color: Colors.white), // Invisible white border
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.all(Radius.circular(90)),
            //         borderSide: BorderSide(
            //             color: Colors.white), // Invisible white border
            //       ),
            //       contentPadding:
            //           EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //       hintText: 'Select a country',
            //       suffixIcon: null, // Removed the dropdown arrow icon
            //     ),
            //   ),
            //   popupProps: PopupProps.menu(
            //     showSearchBox: true, // Enables search functionality
            //     fit: FlexFit.loose,
            //     constraints: BoxConstraints.tightFor(width: double.infinity),
            //     containerBuilder: (ctx, popupWidget) {
            //       // Background becomes grey when search is active
            //       return Container(
            //         color: Colors
            //             .grey[200], // Grey background for the active dropdown
            //         child: popupWidget,
            //       );
            //     },
            //     searchFieldProps: TextFieldProps(
            //       decoration: InputDecoration(
            //         filled: true,
            //         fillColor: Colors.white,
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(90)),
            //           borderSide: BorderSide(
            //               color: Colors.white), // Invisible white border
            //         ),
            //         enabledBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(90)),
            //           borderSide: BorderSide(
            //               color: Colors.white), // Invisible white border
            //         ),
            //         focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(90)),
            //           borderSide: BorderSide(
            //               color: Colors.white), // Invisible white border
            //         ),
            //         contentPadding:
            //             EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //         hintText: 'Search for a country',
            //         prefixIcon: Icon(Icons
            //             .search), // Optional search icon inside the search box
            //       ),
            //     ),
            //     itemBuilder: (context, item, isSelected) {
            //       // Each item in a white box with rounded corners
            //       return Padding(
            //         padding:
            //             const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            //         child: Container(
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             borderRadius:
            //                 BorderRadius.circular(12), // Rounded corners
            //             boxShadow: [
            //               BoxShadow(
            //                 color: Colors.grey.withOpacity(0.2),
            //                 spreadRadius: 1,
            //                 blurRadius: 5,
            //                 offset: Offset(0, 2), // Adds a subtle shadow
            //               ),
            //             ],
            //           ),
            //           child: ListTile(
            //             leading: ClipOval(
            //               child: Image.asset(
            //                 "assets/flags/$item.png", // Add your flag images here
            //                 width: 30,
            //                 height: 30,
            //                 fit: BoxFit.cover,
            //               ),
            //             ),
            //             title: Text(item),
            //             selected: isSelected,
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            //   dropdownBuilder: (context, selectedItem) {
            //     return Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //       child: Row(
            //         children: [
            //           if (selectedItem != null)
            //             ClipOval(
            //               child: Image.asset(
            //                 "assets/flags/$selectedItem.png", // Add your flag images here
            //                 width: 30,
            //                 height: 30,
            //                 fit: BoxFit.cover,
            //               ),
            //             ),
            //           const SizedBox(width: 8),
            //           selectedItem == null
            //               ? Text(
            //                   'Select a country',
            //                   style: TextStyle(color: Colors.grey),
            //                 )
            //               : Text(selectedItem),
            //         ],
            //       ),
            //     );
            //   },
            //   onChanged: (String? newValue) {
            //     // Handle the selected value
            //     //  print("Selected country: $newValue");
            //   },
            // ),

            const SizedBox(height: 30),
            const Text(
              'All',
              style: TextStyle(
                fontSize: 18,
                // fontWeight: FontWeight.bold,
              ),
            ),
            // Popular Plans section
            // Container(
            //   // padding: const EdgeInsets.all(16),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const SizedBox(height: 10),
            //       Column(
            //         children: [
            //           PlanCard(
            //             country: 'jp',
            //             flagAsset: 'assets/flags/japan.png',
            //             // data: '5 GB',
            //             // validity: '7 Days',
            //             // price: '\$1200',
            //           ),
            //           PlanCard(
            //             country: 'France',
            //             flagAsset: 'assets/flags/france.png',
            //             // data: '10 GB',
            //             // validity: '10 Days',
            //             // price: '\$1500',
            //           ),
            //           PlanCard(
            //             country: 'Brazil',
            //             flagAsset: 'assets/flags/brazil.png',
            //             // data: '7 GB',
            //             // validity: '7 Days',
            //             // price: '\$1000',
            //           ),
            //           PlanCard(
            //             country: 'Australia',
            //             flagAsset: 'assets/flags/australia.jpg',
            //             // data: '15 GB',
            //             // validity: '2 Weeks',
            //             // price: '\$1700',
            //           ),
            //           PlanCard(
            //             country: 'United States',
            //             flagAsset: 'assets/flags/usa.png',
            //             // data: '20 GB',
            //             // validity: '10 Days',
            //             // price: '\$2000',
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),







  Container(
            height: MediaQuery.of(context).size.height - 300, // Constrain height to fit within the page
            child: FutureBuilder<List<Map<String, String>>>(
              future: _countryData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final countries = snapshot.data!;
                  return ListView.builder(
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      final country = countries[index];
                      return PlanCard(
                        country: country['country'] ?? 'Unknown',
                        flagAsset: country['flagAsset'].toString(), 
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),








          ],
        ),
      ),
      backgroundColor: const Color(0xFFECEFF1),
    );
  }
}

class HomeNotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("My eSIMs"), backgroundColor: const Color(0xFFECEFF1),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome',
                style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 58, 56, 56),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Image.asset('assets/visuals/notLoggedInHome.png', height: 300),
              SizedBox(height: 40),
              Center(
                  child: Text(
                'Your Global Connection\nWherever You Are',
                style: TextStyle(fontSize: 14, color: Colors.black),
                textAlign: TextAlign.center,
              )),
              SizedBox(height: 40),
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150, // Desired width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle:
                            const TextStyle(fontSize: 18, color: Colors.white),
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF404041),
                      ),
                      child: Text('Sign Up'),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 150, // Desired width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                        );
                      },
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
                ],
              )),
              SizedBox(height: 20),
              Column(
                children: [
                  Text("Or Sign In via"),

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
      ),
      backgroundColor: const Color(0xFFECEFF1),
    );
  }
}

// PlanCard Widget
class PlanCard extends StatelessWidget {
  final String country;

  // Map<String, dynamic> jsonData;
  final String flagAsset;
  // final String data;
  // final String validity;
  // final String price;

  const PlanCard({
    super.key,
    required this.country,
    required this.flagAsset,
    // required this.data,
    // required this.validity,
    // required this.price,
  });

  Future<List<dynamic>> GetCountryPlans() async {
    //  print(country);
    final prefs = await SharedPreferences.getInstance();
    final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last;
      // Define headers with the authentication cookie
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Cookie':
            'Authorization=$user_cookie', // Replace `authCookie` with your cookie's key
      };
    final response = await http.get(Uri.parse(
        'https://my-service-435668605472.europe-central2.run.app/matchcountries/$country'),headers: headers);


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print(data);
      return data['products'];
    } else {
      throw Exception('Failed to load country plans');
    }
  }

@override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(90), // Rounded corners
      ),
      child: FutureBuilder<List<dynamic>>(
        future: GetCountryPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            final plan = snapshot.data;
            print("PLAN - $plan");
            return ListTile(
              leading: ClipOval(
                child: Image.asset(
                  flagAsset,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                country,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text("Loading..."), // Placeholder while loading
              trailing: const CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return ListTile(
              leading: ClipOval(
                child: Image.asset(
                  flagAsset,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                country,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final plan = snapshot.data![0]; // Access the first plan
            return ListTile(
              leading: ClipOval(
                child: Image.asset(
                  flagAsset,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                plan['name'].toString().split(" ")[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // subtitle: Text(("\$") + plan['name'].split("").toString()), // Use plan data
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlanDetailsPage(
                      country: country,
                      flagAsset: flagAsset,
                      // data: plan['data'].toString(),
                      // validity: plan['validity'].toString(),
                      // price: plan['price'].toString(),
                    ),
                  ),
                );
              },
            );
          } else {
            return ListTile(
              leading: ClipOval(
                child: Image.asset(
                  flagAsset,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                country,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text("No plans available"),
            );
          }
        },
      ),
    );
  }
}

class PlanDetailsPage extends StatefulWidget {
  final String country;
  final String flagAsset;

  const PlanDetailsPage({
    Key? key,
    required this.country,
    required this.flagAsset,
  }) : super(key: key);

  @override
  _PlanDetailsPageState createState() => _PlanDetailsPageState();
}


class _PlanDetailsPageState extends State<PlanDetailsPage> {
  String? selectedPlanId; // To store the selected plan's ID
  
  Future<List<dynamic>> GetCountryPlans() async {
   final prefs = await SharedPreferences.getInstance();
    final user_cookie = prefs.getString('user_cookies').toString().split(';').first.split('=').last;
      // Define headers with the authentication cookie
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Cookie':
            'Authorization=$user_cookie', // Replace `authCookie` with your cookie's key
      };
    final response = await http.get(Uri.parse(
        'https://my-service-435668605472.europe-central2.run.app/matchcountries/${widget.country}'),headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['products'];
    } else {
      throw Exception('Failed to load country plans');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Plan",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
        ),
        backgroundColor: const Color(0xFFECEFF1),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: GetCountryPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No plans available"),
            );
          } else {
            final plans = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Top image section
                  ClipOval(
                    child: Image.asset(widget.flagAsset,
                        width: 60, height: 60, fit: BoxFit.cover),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.country, // Access `country` through `widget.country`
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // Display plans with selectable options
                  ...plans.map((plan) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPlanId = plan['uid']; // Set the selected plan ID
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: selectedPlanId == plan['uid']
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.white,
                          border: Border.all(
                              color: selectedPlanId == plan['uid']
                                  ? Colors.blue
                                  : Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${plan['data_quota_gb']} GB",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${plan['validity_days']} Days",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              "\$${plan['price_usd']}",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),

                  // Checkout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16),
                    child: ElevatedButton(
                      onPressed: selectedPlanId == null
                          ? null // Disable button if no plan is selected
                          : () {
                              if (isLoggedIn) {
                                // If logged in, navigate to payment process page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                      country: widget.country, // Access country here
                                      price: plans.firstWhere((plan) =>
                                              plan['uid'] == selectedPlanId)[
                                          'price_usd'],
                                      uid: selectedPlanId.toString(), // Pass selected plan price
                                    ),
                                  ),
                                );
                              } else {
                                // If not logged in, navigate to login page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        textStyle: const TextStyle(
                            fontSize: 18, color: Colors.white),
                        foregroundColor: Colors.white,
                        backgroundColor: selectedPlanId == null
                            ? Colors.grey
                            : const Color(0xFF12BCC6),
                      ),
                      child: const Text('Checkout'),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}





// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text(
//         "Select Plan",
//         style: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.normal,
//         ),
//       ),
//       backgroundColor: const Color(0xFFECEFF1),
//     ),
//     body: FutureBuilder<List<dynamic>>(
//       future: GetCountryPlans(), // Fetch the country plans
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text("Error: ${snapshot.error}"),
//           );
//         } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
//           return const Center(
//             child: Text("No plans available"),
//           );
//         } else {
//           final plans = snapshot.data!; // List of plans
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 10),

//                 // Top image section
//                 ClipOval(
//                   child: Image.asset(flagAsset,
//                       width: 60, height: 60, fit: BoxFit.cover),
//                 ),

//                 const SizedBox(height: 10),

//                 Text(
//                   plans[0]['name'].toString().split(' ')[0],
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 20),

//                 // Iterate over plans and display each plan
//                 ...plans.map((plan) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10.0),
//                     child: Container(
//                       padding:
//                           const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius:
//                             BorderRadius.circular(90), // Circular corners
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Circular Checkmark Icon
//                           Container(
//                             padding: const EdgeInsets.all(5),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.grey, width: 1),
//                             ),
//                             child: const Icon(
//                               Icons.circle,
//                               color: Colors.blue,
//                               size: 15,
//                             ),
//                           ),
//                           const SizedBox(width: 30),

//                           // Plan Data
//                           Text(
//                             "${plan['data_quota_gb']} GB",
//                             style: const TextStyle(
//                                 fontSize: 16, color: Colors.black),
//                           ),
//                           const SizedBox(width: 30),

//                           // Plan Validity
//                           Text(
//                             "${plan['validity_days']} Days",
//                             style: const TextStyle(
//                                 fontSize: 16, color: Colors.black),
//                           ),
//                           const SizedBox(width: 30),

//                           // Plan Price
//                           Text(
//                             "\$${plan['price_usd']}",
//                             style: const TextStyle(
//                                 fontSize: 16, color: Colors.black),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),

//                 const SizedBox(height: 20),

//                 // Buy button
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0, vertical: 16),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (isLoggedIn) {
//                         // If logged in, navigate to payment process page
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => PaymentPage(
//                                   country: country,
//                                   price: plans[0]['price_usd'].toString())),
//                         );
//                       } else {
//                         // If not logged in, navigate to login page
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => ProfilePage()),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 16, horizontal: 32),
//                       textStyle: const TextStyle(
//                           fontSize: 18, color: Colors.white),
//                       foregroundColor: Colors.white,
//                       backgroundColor: const Color(0xFF12BCC6),
//                     ),
//                     child: const Text('Checkout'),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     ),
//   );
// }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Select Plan",
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.normal,
//           ),
//         ),
//         backgroundColor: const Color(0xFFECEFF1),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 10),

//             // Top image section
//             ClipOval(
//                 child: Image.asset(flagAsset,
//                     width: 60, height: 60, fit: BoxFit.cover)),

//             const SizedBox(height: 10),

//             Text(country,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

//             const SizedBox(height: 20),

//             Center(
//               child: // ),
//                   Container(
//                 padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(90), // Circular corners
//                 ),
//                 child: Row(
//                   mainAxisAlignment:
//                       MainAxisAlignment.spaceBetween, // Equal spacing
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min, // Vertically center items
//                   children: [
//                     // Circular Checkmark Icon
//                     Container(
//                       padding:
//                           EdgeInsets.all(5), // Space between icon and border
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle, // Circular border
//                         border: Border.all(
//                             color: Colors.grey,
//                             width: 1), // Border color and width
//                       ),
//                       child: Icon(
//                         Icons.circle,
//                         color: Colors.blue,
//                         size: 15,
//                       ),
//                     ),

//                     SizedBox(
//                       width: 30,
//                     ),
//                     // Short Text 1
//                     Text(
//                       data,
//                       style: TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                     SizedBox(
//                       width: 30,
//                     ),
//                     // Short Text 2
//                     Text(
//                       validity,
//                       style: TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                     SizedBox(
//                       width: 30,
//                     ),
//                     // Short Text 3
//                     Text(
//                       price,
//                       style: TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             Text(price,
//                 style: TextStyle(
//                   color: Color(0xFF12BCC6),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 28,
//                 )),

//             Text(data + " \/ " + validity,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w200,
//                 )),

//             const SizedBox(height: 10),
//             // Buy button
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (isLoggedIn) {
//                     // If logged in, navigate to payment process page
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) =>
//                               PaymentPage(country: country, price: price)),
//                     );
//                   } else {
//                     // If not logged in, navigate to login page
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => ProfilePage()),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//                   textStyle: const TextStyle(fontSize: 18, color: Colors.white),
//                   foregroundColor: Colors.white,
//                   backgroundColor: Color(0xFF12BCC6),
//                 ),
//                 child: Text('Ckechout'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }



class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Your Purchases will appear here',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<String> validateUser() async {
    final prefs = await SharedPreferences.getInstance();
    // print(prefs.getString('user_cookies'));
    if(prefs.getString('user_cookies') != null){
      return "Validated";
    }else{
      return "Invalid";
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: const Color(0xFFECEFF1),
      ),
      body: ListView(
      // padding: const EdgeInsets.right(16.0),
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          onTap: () {


            validateUser().then((result) {
                          if (result == "Validated"){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
              );
            }else if(result == "Invalid"){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            }
            });
          
          },
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Security Settings'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicy(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_center_outlined),
          title: const Text('Help Center'),
          onTap: () {
            openWebsite('https://www.gloalo.com');
          },
        ),
      ],
    ),
      
  );  
  }

  Future<void> openWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

}
