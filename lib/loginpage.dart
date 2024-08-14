import 'package:flutter/material.dart';
import 'loginpagewithemail.dart';
import 'signuppage.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( 
        child: Stack(
          fit: StackFit.expand,
          children: [
             Center(
               child: Container (
                 decoration: const BoxDecoration(
                   image: DecorationImage(
                     image: AssetImage('assets/login page.png'),
                     fit: BoxFit.cover,
                     alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            Positioned(
                top: 500,
                left: 106,
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.rubik(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFB12B),
                  ),
                ),
              ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 350), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPageWithEmail(),
                            ),
                          );
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFFFFFCF0),
                        ),
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return const Color(0xFF472bad);
                            }
                            return const Color(0xFFFFFCF2);
                          },
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: const BorderSide(
                              color: Color(0xFF472bad),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 24.0,
                        ),
                        child: Text(
                          'LOGIN WITH EMAIL',
                          style: GoogleFonts.rubik(
                            fontSize: 18,
                            color: const Color(0xFF472bad),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Don’t have an account?',
                          style: GoogleFonts.rubik(
                              fontSize:16
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupPage(),
                              ),
                            );
                          },
                          child: Text (
                            'Click here!',
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
