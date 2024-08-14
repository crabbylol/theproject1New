import 'package:flutter/material.dart';
import 'package:theproject1/auth_service.dart';
import 'journal.dart';
import 'loginpage.dart';

import 'package:google_fonts/google_fonts.dart';

class LoginPageWithEmail extends StatefulWidget {

  const LoginPageWithEmail({super.key});

  @override
  State<LoginPageWithEmail> createState() => _LoginPageWithEmailState();
}

class _LoginPageWithEmailState extends State<LoginPageWithEmail> {
  final _auth = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isTextFieldFocused = false;

  void _printLatestEmailValue() {
    final text = _emailController.text;
    print('Email Field: $text');
  }

  void _printLatestPasswordValue() {
    final text = _passwordController.text;
    print('Password Field: $text');
  }

  void initState() {
    super.initState();

    _emailController.addListener(_printLatestEmailValue);
    _passwordController.addListener(_printLatestPasswordValue);
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color(0xFFFFFCF2),
          ),
          Positioned(
            top: isTextFieldFocused ? MediaQuery.of(context).size.height * 0.1 : MediaQuery.of(context).size.height * 0.10,
            left: isTextFieldFocused ? 0 : (MediaQuery.of(context).size.width - 300) / 2,
            child: Center(
              child: Transform.translate(
                offset: Offset(isTextFieldFocused ? ((MediaQuery.of(context).size.width - 300) / 2) : 0, 0),
                child: Image(
                  image: const AssetImage('assets/loading.gif'),
                  width: isTextFieldFocused ? 110 : 310,
                  height: isTextFieldFocused ? 110 : 310,
                ),
              ),
            ),
          ),
          Positioned(
            top: isTextFieldFocused ? MediaQuery.of(context).size.height * 0.153 : MediaQuery.of(context).size.height * 0.52,
            left: isTextFieldFocused ? 0 : (MediaQuery.of(context).size.width - 380) / 2,
            right: isTextFieldFocused ? 0 : (MediaQuery.of(context).size.width - 380) / 2,
            child: Center(
              child: Transform.translate(
                offset: Offset(isTextFieldFocused ? ((MediaQuery .of(context).size.width - 300) / 2) : 0, 0),
                child: Text(
                  'Login with Email',
                  style: GoogleFonts.rubik(
                    fontSize: isTextFieldFocused ? 25 : 40,
                    // Adjusted font size based on focus
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFB12B),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 40,
            right: 40,
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Email',
                      labelStyle: GoogleFonts.rubik(
                      fontSize: 20,
                      )
                  ),
                  onTap: () {
                    setState(() {
                      isTextFieldFocused = true;
                    });
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    setState(() {
                      isTextFieldFocused = false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Password',
                      labelStyle: GoogleFonts.rubik(
                        fontSize: 20,
                      )
                  ),
                  onTap: () {
                    setState(() {
                      isTextFieldFocused = true;
                    });
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    setState(() {
                      isTextFieldFocused = false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB12B),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.rubik(
                            fontSize: 25,
                            color: Color(0xFFFFFCF2),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF482BAD),
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.rubik(
                            fontSize: 25,
                            color: const Color(0xFFFFFCF2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  goToHome(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JournalPage())
  );

  _login() async {
    final user = await _auth.loginUserWithEmailAndPassword(_emailController.text, _passwordController.text);

    if (user != null) {
      print("User logged in successfully");
      goToHome(context);
    }
  }
}
