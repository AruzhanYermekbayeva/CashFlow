import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationScreen extends StatefulWidget {
  final User user;

  const EmailVerificationScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _isEmailSent = false;

  Future<void> _sendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      await widget.user.sendEmailVerification();
      setState(() => _isEmailSent = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'A verification email has been sent to ${widget.user.email}',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _isEmailSent
                ? Text(
              'Verification email sent!',
              style: TextStyle(color: Colors.green),
            )
                : SizedBox(),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _sendVerificationEmail,
              child: Text('Resend Verification Email'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}