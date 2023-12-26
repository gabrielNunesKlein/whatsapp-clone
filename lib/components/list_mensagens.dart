
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatssap_web/models/conversa.dart';
import 'package:whatssap_web/models/mensagem.dart';
import 'package:whatssap_web/models/usuario.dart';
import 'package:whatssap_web/utils/paleta_cores.dart';

import '../provider/conversa_provider.dart';

class ListMensagens extends StatefulWidget {

  final Usuario usuarioRemetente;
  final Usuario usuarioDestinatario;

  const ListMensagens({
    required this.usuarioRemetente,
    required this.usuarioDestinatario,
    Key? key});

  @override
  State<ListMensagens> createState() => _ListMensagensState();
}

class _ListMensagensState extends State<ListMensagens> {

  ScrollController _scrollController = ScrollController();
  TextEditingController _controllerMensagem = TextEditingController();
  late Usuario _usuarioRemetente;
  late Usuario _usuarioDestinatario;

  StreamController _streamController = StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamMensagem;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  _enviarMensagem(){

    String textoMensagem = _controllerMensagem.text;
    if(textoMensagem.isNotEmpty){

      String idUsuarioRemetente = _usuarioRemetente.idUsuario;
      String idUsuarioDestinatario = _usuarioDestinatario.idUsuario;

      Mensagem mensagem = Mensagem(
        idUsuarioRemetente: idUsuarioRemetente,
        textoMensagem: textoMensagem,
        date: Timestamp.now().toString()
      );

      _salverMensagem(idUsuarioRemetente, idUsuarioDestinatario, mensagem);

      Conversa conversaRemetente = Conversa(
          idUsuarioRemetente,
          idUsuarioDestinatario,
          mensagem.textoMensagem.toString(),
          _usuarioDestinatario.nome,
          _usuarioDestinatario.email,
          _usuarioDestinatario.urlImagem
      );
      _salverConversa(conversaRemetente);

      _salverMensagem(idUsuarioDestinatario, idUsuarioRemetente, mensagem);

      Conversa conversaDestinatario = Conversa(
          idUsuarioDestinatario,
          idUsuarioRemetente,
          mensagem.textoMensagem.toString(),
          _usuarioRemetente.nome,
          _usuarioRemetente.email,
          _usuarioRemetente.urlImagem
      );
      _salverConversa(conversaDestinatario);

      _controllerMensagem.clear();

    }

  }

  _salverMensagem(String idRemetente, String idDestinatario, Mensagem mensagem){

    _firestore.collection('mensagens')
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(mensagem.toMap());

  }

  _salverConversa(Conversa conversa){

    _firestore.collection("conversas")
        .doc(conversa.idRemetente)
        .collection("ultimas-mensagens")
        .doc(conversa.idDestinatario)
        .set(conversa.toMap());

  }

  _getInitiState(){

    _usuarioRemetente = widget.usuarioRemetente;
    _usuarioDestinatario = widget.usuarioDestinatario;

    _addListnerMensagem();

  }

  _addListnerMensagem(){

    final stream = _firestore.collection("mensagens")
        .doc(_usuarioRemetente.idUsuario)
        .collection(_usuarioDestinatario.idUsuario)
        .orderBy("date", descending: false)
        .snapshots();

    _streamMensagem = stream.listen((data) {
      _streamController.add(data);
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });

  }
  _updateListnerMensagem(){
    Usuario? usuarioDestinatario = context.watch<ConversaProvider>().usuario;

    if(usuarioDestinatario != null){
      _usuarioDestinatario = usuarioDestinatario;
    }

    _addListnerMensagem();

  }


  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _streamMensagem.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getInitiState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _updateListnerMensagem();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('./imagens/bg.png'),
          fit: BoxFit.cover
        )
      ),
      child: Column(
        children: [

          StreamBuilder(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Expanded(child: Center(
                      child: Column(
                        children: [
                          Text("Carregando Contatos"),
                          CircularProgressIndicator()
                        ],
                      ),
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
                      List<DocumentSnapshot> listMensagem = querySnapShot.docs.toList();

                      return Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              itemCount: querySnapShot.docs.length,
                              itemBuilder: (context, index){

                                DocumentSnapshot mensagem = listMensagem[index];

                                Alignment alinhamento = Alignment.bottomLeft;
                                Color cor = Colors.white;

                                if( _usuarioRemetente.idUsuario == mensagem["idUsuarioRemetente"] ){
                                  alinhamento = Alignment.bottomRight;
                                  cor = Color(0xffd2ffa5);
                                }

                                Size largura = MediaQuery.of(context).size * 0.8;

                                return Align(
                                  alignment: alinhamento,
                                  child: Container(
                                    constraints: BoxConstraints.loose(largura),
                                    decoration: BoxDecoration(
                                      color: cor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8)
                                      )
                                    ),
                                    padding: EdgeInsets.all(16),
                                    margin: EdgeInsets.all(6),
                                    child: Text(mensagem["textoMensagem"]),
                                  ),
                                );

                              }
                          )
                      );
                    }
                }
              }
          ),

          Container(
            padding: EdgeInsets.all(8),
            color: PaletaCores.corFundoBarra,
            child: Row(
              children: [
                Expanded(child: 
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_emoticon),
                        SizedBox(width: 4,),
                        Expanded(child:
                          TextField(
                            controller: _controllerMensagem,
                            decoration: InputDecoration(
                              hintText: "Digite uma mensagem",
                              border: InputBorder.none
                            ),
                          ),
                        ),
                        Icon(Icons.attach_file),
                        Icon(Icons.camera_alt)
                      ],
                    ),
                  )
                ),
                SizedBox(width: 4,),
                FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)
                  ),
                  onPressed: (){
                    _enviarMensagem();
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  mini: true,
                  backgroundColor: PaletaCores.corPrimaria,)
              ],
            )
          )
        ],
      ),
    );
  }
}
