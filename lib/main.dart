import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:theproject1/wrapper.dart';
import 'loginpage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyD_f3srn8rPlM9v1bsVWlaoAUx2ZrYZV0Q",
            authDomain: "theproject1-e7869.firebaseapp.com",
            projectId: "theproject1-e7869",
            storageBucket: "theproject1-e7869.appspot.com",
            messagingSenderId: "819941299504",
            appId: "1:819941299504:web:7939a961960d1ba7d3a4f5",
            measurementId: "G-GKL14CYFLP"
        )
    ) ;
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey:
        "AIzaSyD2DO7pPZLT0otndA2XnXj6nC7ryvVfm98",
        appId:
        "1:819941299504:android:818ae67d2af4adc3d3a4f5",
        messagingSenderId: "819941299504",
        projectId: "theproject1-e7869",
      ),
    );
  }

  runApp(MaterialApp(
    home: Wrapper(),
  ));
}

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeInButton();
  }

  void _fadeInButton() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/splash screen.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Positioned(
            bottom: 175,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 2),
                child: ElevatedButton(
                  onPressed: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFF472bad),
                    ),
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return const Color(0xFFFFB12B);
                        }
                        return const Color(0xFF472bad);
                      },
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
