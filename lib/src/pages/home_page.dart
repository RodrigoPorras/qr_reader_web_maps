import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_reader_app/src/bloc/scans_bloc.dart';
import 'package:qr_reader_app/src/models/scan_model.dart';
import 'package:qr_reader_app/src/pages/direcciones_page.dart';
import 'package:qr_reader_app/src/pages/mapas_page.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:qr_reader_app/src/utils/utils.dart' as utils;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final scansBloc = new ScansBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () {
                scansBloc.borrarScanTODOS();
              })
        ],
      ),
      body: _callPage(currentIndex),
      bottomNavigationBar: _crearBottomNavigationsBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.filter_center_focus),
        onPressed: () => _scanQR(context),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _scanQR(BuildContext context) async {

    ScanResult futureString = new ScanResult();

    try {

      futureString = await BarcodeScanner.scan();

    } catch (e) {

      futureString.rawContent = e.toString();

    }

    if (futureString.rawContent != null) {
      final scan = ScanModel(valor: futureString.rawContent);
      scansBloc.agregarScan(scan);

      if (Platform.isIOS) {
        Future.delayed(Duration(milliseconds: 750), () {
          utils.abrirScan(context, scan);
        });
      } else {
        utils.abrirScan(context, scan);
      }
    }

    print('Scan Result: ${futureString.rawContent}');
  }

  Widget _crearBottomNavigationsBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.map), title: Text('Mapas')),
        BottomNavigationBarItem(
            icon: Icon(Icons.my_location), title: Text('Direcciones')),
      ],
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
    );
  }

  Widget _callPage(int paginaActual) {
    switch (paginaActual) {
      case 0:
        return MapasPage();
        break;
      case 1:
        return DireccionesPage();
        break;

      default:
        return MapasPage();
    }
  }
}
