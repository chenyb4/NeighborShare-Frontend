import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class Home extends StatefulWidget{
  @override
  _HomeState createState()=>_HomeState();
}

class _HomeState extends State<Home>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("NeighborShare"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Center(

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed( context, '/addParty');
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ),
    );
  }
}