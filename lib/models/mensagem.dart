
class Mensagem {

  String? idUsuarioRemetente;
  String? textoMensagem;
  String? date;

  Mensagem({ this.idUsuarioRemetente, this.textoMensagem, this.date}){
  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "idUsuarioRemetente": this.idUsuarioRemetente,
      "textoMensagem": this.textoMensagem,
      "date": this.date,
    };

    return map;

  }


}