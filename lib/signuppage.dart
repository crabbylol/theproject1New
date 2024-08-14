import 'package:flutter/material.dart';
import 'package:theproject1/auth_service.dart';
import 'journal.dart';
import 'loginpage.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isTextFieldFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                  image: const AssetImage('assets/signuploading.gif'),
                  width: isTextFieldFocused ? 100 : 300,
                  height: isTextFieldFocused ? 100 : 300,
                ),
              ),
            ),
          ),
          Positioned(
            top: isTextFieldFocused ? MediaQuery.of(context).size.height * 0.123 : MediaQuery.of(context).size.height * 0.47,
            left: isTextFieldFocused ? 0 : (MediaQuery.of(context).size.width - 300) / 2,
            right: isTextFieldFocused ? 0 : (MediaQuery.of(context).size.width - 300) / 2,
            child: Center(
              child: Transform.translate(
                offset: Offset(isTextFieldFocused ? ((MediaQuery.of(context).size.width - 300) / 2) : 0, 0),
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.rubik(
                      fontSize: isTextFieldFocused ? 45 : 55,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFB12B),
                    ),
                  ),
              ),
            ),
          ),
          Positioned(
            bottom: 85,
            left: 40,
            right: 40,
            child: Column(
              children: <Widget>[
                TextField(
                  onChanged: (text) {
                    print('First text field: $text (${text.characters.length})');
                    },
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Username',
                    labelStyle: GoogleFonts.rubik (
                      fontSize: 20,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      isTextFieldFocused = true;
                    });
                    },
                  onSubmitted: (value) {
                    setState(() {
                      isTextFieldFocused = false;
                    });
                    },
                ),
                TextField(
                  onChanged: (text) {
                    print('First text field: $text (${text.characters.length})');
                  },
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
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
                  onSubmitted: (value) {
                    setState(() {
                      isTextFieldFocused = false;
                    });
                  },
                ),
                TextField(
                  onChanged: (text) {
                    print('First text field: $text (${text.characters.length})');
                  },
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Password',
                      labelStyle: GoogleFonts.rubik(
                        fontSize: 20,
                      ),
                  ),
                  onTap: () {
                    setState(() {
                      isTextFieldFocused = true;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      isTextFieldFocused = false;
                    });
                  },
                ),
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
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF482BAD),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.rubik(
                            fontSize: 25,
                            color: const Color(0xFFFFFCF2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]
            )
          ),
        ],
      ),
    );
  }

  goToHome(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const JournalPage())
  );

  _signup() async {
    final user = await _auth.createUserWithEmailAndPassword(_emailController.text, _passwordController.text);
    if (user != null) {
      print("User created successfully");
      goToHome(context);
    }
  }
}
