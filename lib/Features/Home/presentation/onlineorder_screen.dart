import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class OnlineorderScreen extends StatefulWidget {
  const OnlineorderScreen({super.key});

  @override
  State<OnlineorderScreen> createState() => _OnlineorderScreenState();
}

class _OnlineorderScreenState extends State<OnlineorderScreen> {
  @override
  Widget build(BuildContext context) {
    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(20),
      child:Column(
        children: [
          Center(
            child: Lottie.asset('Assets/Icons/Delivery Service-Delivery man.json',
            height: height*0.8,
            width: width*1
            ),
          ),
        ],
      ) ,
      ),
    );
  }
}