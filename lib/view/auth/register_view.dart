// view/auth/register_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_hive_tdo/main.dart';
import 'package:flutter_hive_tdo/models/user.dart';
import 'package:flutter_hive_tdo/utils/constanst.dart';
import 'package:ftoast/ftoast.dart';

import '../../utils/colors.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          30,
          150,
          30,
          150,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Register',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  labelStyle: TextStyle(color: colorScheme.onBackground),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  labelStyle: TextStyle(color: colorScheme.onBackground),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  if (value.length < 4) {
                    return 'Username must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  labelStyle: TextStyle(color: colorScheme.onBackground),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  labelStyle: TextStyle(color: colorScheme.onBackground),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: colorScheme.primary,
                ),
                onPressed: _register,
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Already have an account? Sign In😊',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final name = _nameController.text;

      final existingUser =
          BaseWidget.of(context).dataStore.getUserByUsername(username);
      if (existingUser != null) {
        FToast.toast(
          context,
          msg: 'Registration Failed',
          subMsg: 'Username already exists',
          corner: 20.0,
          duration: 2000,
          padding: const EdgeInsets.all(20),
        );
        return;
      }

      final user = User.create(
        username: username,
        password: password,
        name: name.isNotEmpty ? name : null,
      );

      await BaseWidget.of(context).dataStore.registerUser(user: user);
      BaseWidget.of(context).currentUser = user;

      FToast.toast(
        context,
        msg: 'Registration Successful',
        subMsg: 'You can now login with your credentials',
        corner: 20.0,
        duration: 2000,
        padding: const EdgeInsets.all(20),
      );

      // Закрываем экран регистрации и возвращаемся к логину
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
