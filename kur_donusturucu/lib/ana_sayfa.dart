import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey="2f92e504ece272a893b13d381b31a801";

  final String _baseUrl="http://api.exchangeratesapi.io/v1/latest?access_key=";

  TextEditingController _controller=TextEditingController();

  Map<String,double> _oranlar={};

  String _secilenKur="USD";
  double _sonuc=0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Converter"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (String yeniDeger){
                      _hesapla();
                    },
                  ),
              ),
              SizedBox(width: 15,),
              DropdownButton<String>(
                value: _secilenKur,
                icon: Icon(Icons.arrow_downward),
                underline: SizedBox(),
                items: _oranlar.keys.map((String kur){
                    return DropdownMenuItem<String>(
                      value: kur,
                      child: Text(kur),
                    );
                }).toList(),
                onChanged: (String? yeniDeger){
                  if(yeniDeger!=null){
                    setState(() {
                      _secilenKur=yeniDeger;
                    });
                    _hesapla();
                     }
                   },

              ),
            ],
           ),
            SizedBox(height: 16,),
            Text("${_sonuc.toStringAsFixed(2)} TL",
            style: TextStyle(
              fontSize: 24,
            ),
            ),
            SizedBox(height: 16,),
            Container(
              height: 2,
              color: Colors.black,
            ),
            SizedBox(height: 16,),
            Expanded(
              child: ListView.builder(
                itemCount: _oranlar.keys.length,
                itemBuilder: _buildListItem,
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget? _buildListItem(BuildContext context, int index) {
    return ListTile(
      title: Text(_oranlar.keys.toList()[index]),
      trailing: Text("${_oranlar.values.toList()[index].toStringAsFixed(2)} ₺"),
    );
  }

  void _hesapla(){
    double? deger=double.tryParse(_controller.text);
    double? oran=_oranlar[_secilenKur];

    if(deger!=null && oran!=null){
      setState(() {
        _sonuc=deger*oran;
      });

    }
  }

  void _verileriInternettenCek() async{
    Uri uri=Uri.parse(_baseUrl+_apiKey);
    http.Response response= await http.get(uri);

    Map<String,dynamic> parsedResponse=jsonDecode(response.body);

    Map<String,dynamic> rates=parsedResponse["rates"];
    double? baseTlKuru=rates["TRY"];

    if(baseTlKuru!=null){
      for(String ulkeKuru in rates.keys){
        double? baseKur=double.tryParse(rates[ulkeKuru].toString());
        if(baseKur!=null){
          double tlKuru=baseTlKuru/baseKur;
          _oranlar[ulkeKuru]=tlKuru;
        }
      }
    }
    setState(() {});
  }
}

/*
{
    "success": true,
    "timestamp": 1519296206,
    "base": "EUR",
    "date": "2021-03-17",
    "rates": {
        "AUD": 1.566015,
        "CAD": 1.560132,
        "CHF": 1.154727,
        "CNY": 7.827874,
        "GBP": 0.882047,
        "JPY": 132.360679,
        "USD": 1.23396,
    [...]
    }
}
 */
