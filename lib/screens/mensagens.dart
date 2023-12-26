import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatssap_web/components/list_mensagens.dart';

import '../models/usuario.dart';

class Mensagens extends StatefulWidget {

  final Usuario usuarioDestinatario;

  const Mensagens(this.usuarioDestinatario, {Key? key});

  @override
  State<Mensagens> createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {

  late Usuario _usuarioRemetente;
  late Usuario _usuarioDestinatario;
  FirebaseAuth _auth = FirebaseAuth.instance;

  _getInitialData(){


    _usuarioDestinatario = widget.usuarioDestinatario;

    User? user = _auth.currentUser;
    if(user != null){
      String? idUser = user?.uid;
      String? nome = user?.displayName ?? "";
      String? email = user?.email ?? "";
      String? imageUrl = user?.photoURL ?? "";

      _usuarioRemetente = Usuario(idUser!, nome, email, urlImagem: imageUrl);

    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              backgroundImage:  CachedNetworkImageProvider(_usuarioDestinatario.urlImagem),
            ),
            SizedBox(width: 8,),
            Text(
              _usuarioDestinatario.nome,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white
              ),
            )
          ],
        ),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.more_vert), color: Colors.white,)
        ],
      ),
      body: ListMensagens(usuarioDestinatario: _usuarioDestinatario, usuarioRemetente: _usuarioRemetente),
    );
  }
}
