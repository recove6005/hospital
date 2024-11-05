import 'package:flutter/material.dart';
import 'package:glucocare/register.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white),),
      ),
      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _idInputController = TextEditingController();
  final TextEditingController _passwordInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('GLUCOCARE', style: TextStyle(fontSize: 40),),
            const SizedBox(height: 80,),
            Container(
              width: 400,
              height: 50,
              child: TextField(
                controller: _idInputController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  labelStyle: const TextStyle(fontSize: 15, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.red,
                      )
                  ),
                ),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              width: 400,
              height: 50,
              child: TextField(
                controller: _passwordInputController,
                decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: const TextStyle(fontSize: 15, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                        )
                    )
                ),
                style: const TextStyle(fontSize: 20),
                obscureText: true,
              ),
            ),
            SizedBox(height: 30,),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                      onPressed: () => {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
                      ),
                      child: const Text('SIGN IN', style: TextStyle(fontSize: 15, color: Colors.white),),
                    ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()))
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
                    ),
                    child: const Text('SIGN UP', style: TextStyle(fontSize: 15, color: Colors.white),),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40,),
            Row(
              children: [
                Expanded(
                    child: GestureDetector(
                      onTap: () => {},
                      child: Image.asset(
                        'lib/assets/images/login/kakao_login_medium_wide.png',
                      ),
                    )
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text('비밀번호 찾기', style: TextStyle(
              fontSize: 14,
              color: Colors.grey
            ),)
          ],
        ),
      );
  }
}
