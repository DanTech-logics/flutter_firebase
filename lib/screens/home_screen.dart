import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final User? user;

  const HomeScreen({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? email = user?.email ?? "Guest";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Home'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.home, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              'Hello, $email!',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            const Text(
              'You are now logged in successfully.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
