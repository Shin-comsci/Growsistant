import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {},
              ),

              const SizedBox(height: 10),

              // Title
              Center(
                child: Column(
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Welcome Back You've Been Missed!",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: Colors.blueGrey
                      ),
                      // style: GoogleFonts.poppins(
                      //   fontSize: 13,
                      //   color: Colors.grey[600],
                      // ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Email
              Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
                // style: GoogleFonts.poppins(
                //   fontSize: 14,
                //   fontWeight: FontWeight.w500,
                //   color: Colors.grey[800],
                // ),
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFDFDE9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password
              Text(
                'Password',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFDFDE9),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Recovery Password",
                    style: TextStyle(
                      fontSize: 13
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Sign In button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9CAC74),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/on_boarding');
                  },
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Google Sign-in button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDFDE9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/icons/google.png',
                    height: 20,
                  ),
                  label: Text(
                    "Sign in with Google",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Footer
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text.rich(
                    TextSpan(
                      text: "Don't Have An Account? ",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey
                      ),
                      children: [
                        TextSpan(
                          text: "Sign Up For Free",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
