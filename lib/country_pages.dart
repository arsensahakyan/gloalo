import 'package:flutter/material.dart';

class CountryPlansPage extends StatelessWidget {
  final String countryName;
  final String flagPath; // Path to the flag image asset
  final List<Map<String, String>> plans; // List of plans with data, validity, and price

  const CountryPlansPage({super.key, 
    required this.countryName,
    required this.flagPath,
    required this.plans,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(countryName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Flag and Name
            Row(
              children: [
                Image.asset(
                  flagPath,
                  width: 50,
                  height: 30,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Text(
                  countryName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // List of Plans
            const Text(
              'Available Top-up Packages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text('${plan['data']} - ${plan['validity']}'),
                      subtitle: Text('Price: ${plan['price']}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Action to buy the plan
                        },
                        child: const Text('BUY'),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom price bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${plans[0]['price']} USD',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Action for buying
                    },
                    child: const Text('BUY'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

