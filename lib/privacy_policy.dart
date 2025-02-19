import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'main.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Privacy & Policy"), backgroundColor: const Color(0xFFECEFF1),),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width*0.85,
          child: FutureBuilder(
            future: rootBundle.loadString('assets/privacy_policy.md'),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return MarkdownWidget(
                  data: snapshot.data!,
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
      
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart),
      //       label: 'Purchases',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      
      //   selectedItemColor: Colors.blue,
     
      // ),
    );
    
  }
}