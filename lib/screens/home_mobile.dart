import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatssap_web/components/list_contact.dart';
import 'package:whatssap_web/components/list_conversas.dart';
import 'package:whatssap_web/models/usuario.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({Key? key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("WhatsApp"),
            actions: [
              IconButton(onPressed: (){}, icon: Icon(Icons.search, color: Colors.white)),
              SizedBox(width: 3.0,),
              IconButton(onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, "/");
              }, icon: Icon(Icons.logout, color: Colors.white,)),
            ],
            bottom: TabBar(
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.white,
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
              tabs: [
                Tab(text: "Conversas"),
                Tab(text: "Contatos",)
              ],
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              children: [
                ListConversas(),
                ListContact()
              ],
            ),
          ),
        )
    );
  }
}
