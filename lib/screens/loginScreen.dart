import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase/screens/passwordField.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'horizontalLine.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isValidEmail = true;

  bool _isLogin = true;
  String _errorMessage = '';
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centering content vertically
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'Welcome Back!' : 'Create an Account',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    _buildSocialButtons(),
                    SizedBox(height: 20),
                    HorizontalLineWithText(),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.black), // Black border when focused
                        ),
                        // Highlight with red when invalid
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: _isValidEmail ? Colors.grey : Colors.red, // Red for invalid email
                          ),
                        ),
                        errorText: !_isValidEmail ? 'Please enter a valid email' : null, // Error message
                      ),
                      onChanged: (text) {
                        setState(() {
                          _isValidEmail = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(text);
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    PasswordField(controller: _passwordController),
                    SizedBox(height: 20),
                    if (_isLogin)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe, // Your boolean state variable
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _rememberMe = newValue ?? false;
                                  });
                                },
                              ),
                              Text('Remember Me'),
                            ],
                          ),
                          TextButton(
                            onPressed: _resetPassword, // Handle password reset
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity, // Ensures the button fills the full width
                      child: ElevatedButton(
                        onPressed: _handleEmailPasswordAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Black background
                          padding: EdgeInsets.symmetric(vertical: 15), // Vertical padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                        ),
                        child: Text(
                          _isLogin ? 'Login' : 'Register',
                          style: TextStyle(
                            color: Colors.white, // White text
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.grey), // Default style (grey for other text)
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? 'Don\'t have an account? '
                                  : 'Already have an account? ',
                            ),
                            TextSpan(
                              text: _isLogin ? 'Register' : 'Login', // Bold and black text
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              if (_isLoading) // Show loading indicator when authentication is in progress
                CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(user: FirebaseAuth.instance.currentUser),),
    );
  }
  // Handle Email/Password Login or Registration
  Future<void> _handleEmailPasswordAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential userCredential;
      if (_isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'email': _emailController.text.trim(),
          'createdAt': DateTime.now(),
        });
      }

      if (userCredential.user != null) {
        _login(context);
      }else{
        _errorMessage = 'Enter valid email and passwords.';
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle Password Reset
  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address to reset your password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        _errorMessage = 'Password reset email sent! Check your inbox.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send password reset email. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Map FirebaseAuthException to user-friendly error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The email is already in use by another account.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An unknown error occurred.';
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.black),
      ),
      contentPadding: EdgeInsets.all(15),
    );
  }

  // Build Social Media Sign-In Buttons
  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: FaIcon(FontAwesomeIcons.google,color: Colors.black,),
            //Icon(Icons.login_sharp, size: 24), // Google icon
          ),
        ),
        SizedBox(width: 10),
        if (Theme.of(context).platform == TargetPlatform.iOS)
          Expanded(
            child: OutlinedButton(
              onPressed: _handleAppleSignIn,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(Icons.apple, size: 24,color: Colors.black,), // Apple icon
            ),
          ),
      ],
    );
  }

  // Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Save user data in Firestore for Google Sign-In
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'lastSignIn': DateTime.now(),
      }, SetOptions(merge: true));

      _login(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Google';//: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle Apple Sign-In
  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final appleProvider = OAuthProvider("apple.com");
      UserCredential userCredential = await _auth.signInWithProvider(appleProvider);
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'lastSignIn': DateTime.now(),
      }, SetOptions(merge: true));
      _login(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Apple';//: ${e.toString()}';
        print('Failed to sign in with Apple: ${e.toString()}');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}










