import 'package:authentication/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signUpWithEmail() {
    if (_formKey.currentState!.validate()) {
      // Perform sign-up with email logic
      String email = _emailController.text;
      String password = _passwordController.text;
      print('Email: $email, Password: $password');
    }
  }

  void _signUpWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(userCredential.user?.displayName);
    if(userCredential.user!=null){
     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomeScreen()));
    }
  }

  void _signUpWithFacebook() {

  }

  void _signUpWithTwitter() {
    // Perform Twitter sign-up logic
    print('Sign up with Twitter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _signUpWithEmail,
                child: Text('Sign Up with Email'),
              ),
              SizedBox(height: 16),
              Divider(),
              Text(
                'Or sign up with',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
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
                _signUpWithFacebook,
              ),
              _buildSocialButton(
                'Sign Up with Twitter',
                Colors.lightBlue,
                Icons.alternate_email,
                _signUpWithTwitter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      String text, Color color, IconData icon, VoidCallback onPressed) {
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
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
