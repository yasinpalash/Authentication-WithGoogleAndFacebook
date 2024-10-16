import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Home"),
            SizedBox(height: 50,),
            GestureDetector(
              onTap: (){
               Navigator.pop(context);
              },
                child: Text("Back")),
          ],
        ),
      ),
    );
  }
}
