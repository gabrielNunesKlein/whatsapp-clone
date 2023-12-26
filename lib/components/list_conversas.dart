import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatssap_web/models/usuario.dart';
import 'package:whatssap_web/provider/conversa_provider.dart';

import '../utils/responsive.dart';

class ListConversas extends StatefulWidget {
  const ListConversas({Key? key});

  @override
  State<ListConversas> createState() => _ListConversasState();
}

class _ListConversasState extends State<ListConversas> {

  StreamController _streamController = StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamConversas;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  late Usuario _usuarioRemetente;

  _dataInitial(){

    User? user = _auth.currentUser;
    if(user != null) {
      String? idUser = user?.uid;
      String? nome = user?.displayName ?? "";
      String? email = user?.email ?? "";
      String? imageUrl = user?.photoURL ?? "";

      _usuarioRemetente = Usuario(idUser!, nome, email, urlImagem: imageUrl);

      _getMensagens();
    }
  }
  
  _getMensagens(){

    final stream = _firestore.collection("conversas")
        .doc(_usuarioRemetente.idUsuario)
        .collection("ultimas-mensagens")
        .snapshots();

    _streamConversas = stream.listen((data) {
      _streamController.add(data);
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _streamConversas.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _dataInitial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final isMobile = Responsive.isMobile(context);

    return StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text("Carregando Conversas"),
                    CircularProgressIndicator()
                  ],
                )
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar os dados'),
                );
              } else {

                QuerySnapshot querySnapShot = snapshot.data as QuerySnapshot;
                List<DocumentSnapshot> listConversas = querySnapShot.docs.toList();


                return ListView.separated(
                        separatorBuilder: (context, index){
                          return Divider(
                            color: Colors.grey,
                            thickness: 0.2,
                          );
                        },
                        itemBuilder: (context, index) {

                          DocumentSnapshot conversas = listConversas[index];

                          String emailDestinatario = conversas["emailDestinatario"];
                          String urlImagemDestinatario = conversas["urlImagemDestinatario"];
                          String nomeDestinatario = conversas["nomeDestinatario"];
                          String ultimaMensagem = conversas["ultimaMensagem"];
                          String idDestinatario = conversas["idDestinatario"];

                          Usuario usuario = Usuario(idDestinatario, nomeDestinatario, emailDestinatario, urlImagem: urlImagemDestinatario);

                          return ListTile(
                            onTap: (){

                              if(isMobile){
                                Navigator.pushNamed(context, '/mensagens', arguments: usuario);
                              } else {
                                context.read<ConversaProvider>().usuario = usuario;
                              }

                            },
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey,
                              backgroundImage:  CachedNetworkImageProvider(usuario.urlImagem),
                            ),
                            title: Text(usuario.nome, style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            )),
                            subtitle: Text(ultimaMensagem, style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey
                            )),
                            contentPadding: EdgeInsets.all(8),
                          );
                        },
                        itemCount: listConversas.length
                );
              }
          }
        }
    );
  }
}
