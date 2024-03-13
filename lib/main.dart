//import 'dart:js';

import 'package:aad_hybrid/screens/add_item.dart';
import 'package:aad_hybrid/screens/home.dart';
import 'package:flutter/material.dart';


void main() {

  runApp(MaterialApp(

    routes: {
      '/':(context)=>Home(),
      '/addItem':(context)=>AddItem(),
    },
  ));
}
