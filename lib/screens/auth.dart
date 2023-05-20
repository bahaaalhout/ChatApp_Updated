import 'dart:io';

import 'package:app_no9_chat/widgets/button.dart';
import 'package:app_no9_chat/widgets/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../widgets/input_field.dart';

final _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _keyState = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredPass = '';
  String _enteredUsername = '';
  bool isLogin = true;
  File? _pickedImage;
  bool isLoading = false;
  // This method to signin button
  // It will check if validate then with save the value in the controller
  void _signIn() async {
    FocusScope.of(context).unfocus();
    final isValid = _keyState.currentState!.validate();

    if (!isValid || !isLogin && _pickedImage == null) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _keyState.currentState!.save();
    try {
      if (isLogin) {
        _auth.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPass);
      } else {
        final userCredentials = await _auth.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPass,
        );
        final userStorage = FirebaseStorage.instance
            .ref()
            .child('Image_Picker')
            .child('${userCredentials.user!.uid}.jpg');
        await userStorage.putFile(_pickedImage!);
        final imageUrl = await userStorage.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Unvalid authntication'),
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _keyState,
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (!isLogin)
                          ImagePickerWidget(
                            pickedPic: (image) {
                              _pickedImage = image;
                            },
                          ),
                        if (!isLogin)
                          InputField(
                            hinttext: 'Username',
                            textInputType: TextInputType.text,
                            borderColor: Colors.blue,
                            focusedColor: Colors.orange,
                            isPass: false,
                            validation: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 4) {
                                return 'Must be at least 4 character ';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredUsername = value!;
                            },
                          ),
                        InputField(
                          hinttext: 'Enter Your Email',
                          textInputType: TextInputType.emailAddress,
                          borderColor: isLogin ? Colors.orange : Colors.blue,
                          focusedColor: isLogin ? Colors.blue : Colors.orange,
                          isPass: false,
                          validation: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'This field must contain an email';
                            }

                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredEmail = newValue!;
                          },
                        ),
                        InputField(
                          hinttext: 'Password',
                          textInputType: TextInputType.text,
                          borderColor: isLogin ? Colors.orange : Colors.blue,
                          focusedColor: isLogin ? Colors.blue : Colors.orange,
                          isPass: true,
                          validation: (value) {
                            if (value == null || value.trim().length <= 6) {
                              return isLogin
                                  ? 'Enter a stronger password'
                                  : 'Wrong Password';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredPass = newValue!;
                          },
                        ),
                        ButtonWidget(
                          title: isLogin ? 'Sign In' : 'Sign Up',
                          onpressed: _signIn,
                          buttonColor:
                              isLogin ? Colors.yellow[900]! : Colors.blue[900]!,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? 'You dont have one?' : 'Do you have an account',
                    style:
                        const TextStyle(color: Color.fromARGB(255, 96, 94, 94)),
                  ),
                  TextButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _keyState.currentState!.reset();
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin ? 'Create an account' : 'Sign In',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 96, 94, 94)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
