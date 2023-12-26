import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';

class ListContact extends StatefulWidget {
  const ListContact({Key? key});

  @override
  State<ListContact> createState() => _ListContactState();
}

class _ListContactState extends State<ListContact> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userId;

  Future<List<Usuario>> _getUsers() async {

    final userRfe = _firestore.collection("usuarios");
    QuerySnapshot querySnapshot = await userRfe.get();
    List<Usuario> userList = [];

    for( DocumentSnapshot item in querySnapshot.docs ){

      String idUsuario = item['idUsuario'];
      String nome = item['nome'];
      String email = item['email'];
      String urlImagem = item['urlImagem'];

      if(_userId == idUsuario) continue;

      Usuario usuario = Usuario(idUsuario, nome, email, urlImagem: urlImagem);

      userList.add(usuario);

    }

    return userList;

  }

  _getUser() async {
    User? userLogado = await _auth.currentUser;

    if(userLogado != null){
      _userId = userLogado.uid;
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUsers();
    _getUser();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
        future: _getUsers(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
              //
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text("Carregando Contatos"),
                    CircularProgressIndicator()
                  ],
                ),
              );
            case ConnectionState.active:
              //
            case ConnectionState.done:

              if(snapshot.hasError){
                return Flexible(
                  flex: 1,
                  child: Center(
                    child: Column(
                      children: [
                        Text("Erro ao buscar contatos.")
                      ],
                    ),
                  ),
                );
              } else {

                List<Usuario>? listUser = snapshot.data;

                if(listUser != null){

                  return ListView.separated(
                      separatorBuilder: (context, index){
                        return Divider(
                          color: Colors.grey,
                          thickness: 0.2,
                        );
                      },
                      itemBuilder: (context, index) {

                        Usuario usuario = listUser[index];

                        return ListTile(
                          onTap: (){
                            Navigator.pushNamed(context, '/mensagens', arguments: usuario);
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
                          contentPadding: EdgeInsets.all(8),
                        );
                      },
                      itemCount: listUser.length
                  );

                } else {
                  return Flexible(
                    flex: 1,
                    child: Center(
                      child: Column(
                        children: [
                          Text("Nenhum contato encontrado.")
                        ],
                      ),
                    ),
                  );
                }

              }
          }
        }
    );
  }
}
