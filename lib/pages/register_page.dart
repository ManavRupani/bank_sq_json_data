import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user_model.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    User newUser = User(username: username, password: password, balance: 300.0);
    await DatabaseHelper.instance.insertUser(newUser);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration Successful')));
    Navigator.pop(context);
  }
}
