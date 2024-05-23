import 'package:flutter/material.dart';


class AppWidget{
  static TextStyle boldTextFieldStyle(){
     return TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins'
    );
  }

  static TextStyle semiboldTextFieldStyle(){
     return TextStyle(
      color: Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins'
    );
  }

  static TextStyle PHP(){
     return TextStyle(
      color: Colors.black,
      fontSize: 23,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle HeadlineTextFieldStyle(){
     return TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins'
    );
  }

  static TextStyle SoftTextFieldStyle(){
     return TextStyle(
      color: Colors.black38,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins'
    );
  }

}