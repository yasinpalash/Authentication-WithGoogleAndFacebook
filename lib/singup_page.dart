import 'package:authentication/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  Future<void> _signUpWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled the login

      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to home screen on successful sign-in
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _handleExistingAccount(e);
      } else {
        print('Error signing in with Google: ${e.message}');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

        // Sign in to Firebase with the Facebook credential
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

        // Navigate to HomeScreen on successful sign-in
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
        return userCredential;  // Ensure you return the UserCredential
      } else {
        print('Facebook sign-in failed: ${loginResult.status}');
        throw Exception('Facebook sign-in failed: ${loginResult.message}');  // Throw an exception to handle the error
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _handleExistingAccount(e);  // Handle existing account case
        throw Exception('Account exists with different credential');  // Ensure you throw an exception
      } else {
        print('Error signing in with Facebook: ${e.message}');
        throw Exception('Error signing in with Facebook: ${e.message}');  // Ensure you throw an exception
      }
    } catch (e) {
      print('Error signing in with Facebook: $e');
      throw Exception('Error signing in with Facebook: $e');  // Ensure you throw an exception
    }
  }

  Future<void> _handleExistingAccount(FirebaseAuthException e) async {
    // Fetch sign-in methods for the email
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(e.email!);

    if (signInMethods.isNotEmpty) {
      // User already has an account, sign in using one of the methods
      try {
        if (signInMethods.contains('google.com')) {
          await _signUpWithGoogle();  // Sign-in using the existing Google account
        } else if (signInMethods.contains('facebook.com')) {
          await signInWithFacebook();  // Sign-in using the existing Facebook account
        } else {
          // Additional handling for other providers if implemented
        }
      } catch (exception) {
        print('Error during sign-in with existing account: $exception');
      }
    } else {
      // Inform the user about the conflict
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sign-in Conflict'),
          content: Text(
            'An account already exists with a different sign-in method. Please sign in using one of the following methods:\n\n${signInMethods.join("\n")}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16),
            _buildSocialButton(
              'Sign Up with Google',
              Colors.red,
              Icons.g_mobiledata,
              _signUpWithGoogle,
            ),
            _buildSocialButton(
              'Sign Up with Facebook',
              Colors.blue,
              Icons.facebook,
              signInWithFacebook,
            ),
            // Implement Twitter sign-up if needed
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      String text, Color color, IconData icon, Future<void> Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () async {
          await onPressed();  // Ensure the button calls the async function
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
