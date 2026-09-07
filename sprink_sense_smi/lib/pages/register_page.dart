import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sprink_sense_smi/components/constant.dart';
import 'package:sprink_sense_smi/components/mybutton.dart';
import 'package:sprink_sense_smi/components/mytextfield.dart';

class RegisterPage extends StatefulWidget {
  //final VoidCallback showRegisterPage;
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

//try sing up user
  void signUserUp() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog manually
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      //check if password  is confirm
      if (passwordController.text == confirmpasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        //show error message "password do not match"
        showErrorMessage("Password don't Match");
      }

      // Pop loading dialog after successful login
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Pop loading dialog before showing error message
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(
            message,
            style: TextStyle(color: KTetxt),
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [KBackground, KBackgroundShade],
          stops: [0.5, 1.0],
        )),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10),

                  // Logo
                  Image.asset(
                    'lib/images/Logo.png',
                    height: 120,
                  ),
                  SizedBox(height: 30),

                  // Subtitle
                  Text(
                    'Let\'s create an acccount for you',
                    style: TextStyle(
                      color: KTetxt,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 30),

                  // email TextField
                  MyTextfield(
                    controller: emailController,
                    hintText: 'Email address/id',
                    obscureText: false,
                  ),
                  SizedBox(height: 20),

                  // Password TextField
                  MyTextfield(
                    controller: passwordController,
                    hintText: 'Enter your Password',
                    obscureText: true,
                    isPassword: true, // Enable show/hide feature
                  ),

                  SizedBox(height: 10),
                  // Password TextField
                  MyTextfield(
                    controller: confirmpasswordController,
                    hintText: 'confirm Password',
                    obscureText: true,
                    isPassword: true, // Enable show/hide feature
                  ),

                  SizedBox(height: 25),

                  /*    // Forgot Password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forget password?',
                          style: TextStyle(
                            color: KAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),*/

                  // Login Button
                  MyButton(
                    onTap: signUserUp,
                    text: 'Register Now',
                  ),
                  SizedBox(height: 20),

                  // OR Login with
                  Text(
                    "Or continue  with",
                    style: TextStyle(
                      color: KTetxt,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),

                  // Google & Apple Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                        ),
                        onPressed: () {},
                        icon: Image.asset('lib/images/Google.png', height: 30),
                        label: Text("Google",
                            style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(width: 10),

                      // Apple Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                        ),
                        onPressed: () {},
                        icon: Image.asset('lib/images/Apple.png', height: 30),
                        label: Text("Apple",
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),

                  // Register Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: KTetxt),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Login Now",
                          style: TextStyle(
                            color: KAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
