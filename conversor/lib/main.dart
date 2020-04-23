import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "http://api.hgbrasil.com/finance?format=json&key=918d3d48";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getDados() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar, euro;

  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  void _realMudou(String texto) {
    verificarSeOTextoNaoEstaVazio(texto);
    double valor = double.parse(texto);
    dolarController.text = (valor / dolar).toStringAsFixed(2);
    euroController.text = (valor / euro).toStringAsFixed(2);
  }

  void _dolarMudou(String texto) {
    verificarSeOTextoNaoEstaVazio(texto);
    double valor = double.parse(texto);
    realController.text = (valor * dolar).toStringAsFixed(2);
    euroController.text = ((valor * euro) / euro).toStringAsFixed(2);
  }

  void _euroMudou(String texto) {
    verificarSeOTextoNaoEstaVazio(texto);
    double valor = double.parse(texto);
    dolarController.text = ((valor * dolar) / dolar).toStringAsFixed(2);
    realController.text = (valor * euro).toStringAsFixed(2);
  }

  void verificarSeOTextoNaoEstaVazio(String texto){

    if(texto == "")
        _clearAll();
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          '\$ Conversor \$',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getDados(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case (ConnectionState.none):
              case (ConnectionState.waiting):
                return Center(
                  child: Text(
                    "Carregando...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro :(",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 150.0,
                        ),
                        Divider(),
                        buildTextField(
                            'R\$', 'Reais', realController, _realMudou),
                        Divider(),
                        buildTextField(
                            'US\$', 'Dólares', dolarController, _dolarMudou),
                        Divider(),
                        buildTextField(
                            '€', 'Euros', euroController, _euroMudou),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }

  Widget buildTextField(String prefixText, String labelText,
      TextEditingController controller, Function function) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          prefixText: prefixText,
          prefixStyle: TextStyle(color: Colors.amber),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.amber)),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      onChanged: function,
    );
  }
}
