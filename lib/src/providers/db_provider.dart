import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:qr_reader_app/src/models/scan_model.dart';
export 'package:qr_reader_app/src/models/scan_model.dart';

class DBProvider {
  static Database _database;

  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join( documentsDirectory.path,'ScansDB.db' );

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {

      },
      onCreate: ( Database db, int version) async {
        await db.execute(
          'CREATE TABLE Scans ('
          ' id INTEGER PRIMARY KEY, '
          ' tipo TEXT,'
          ' valor TEXT'
          ')'
          );
      }
    );
  }

  //Crear registros
  nuevoScanRaw(ScanModel nuevoScan) async {

    final db = await database;

    final res = await db.rawInsert(
      "INSERT INTO Scans (id, tipo, valor) "
      "VALUES ( ${nuevoScan.id } , '${nuevoScan.tipo}', '${nuevoScan.valor}' )"
    );

    return res;
  }


  nuevoScan(ScanModel nuevoScan) async {

    final db = await database;

    final res = await db.insert('Scans', nuevoScan.toJson());

    return res;
  }

  // Obtener Registros

  Future<ScanModel> getScanId( int id ) async {

    final db = await database;

    final res = await db.query('Scans', where: 'id = ?',whereArgs: [id]);

    return res.isNotEmpty ? ScanModel.fromJson( res.first ) : null;

  }

  Future<List<ScanModel>> getTodosScans() async{
    
    final db = await database;
    
    final res = await db.query('Scans');

    List<ScanModel> list = res.isNotEmpty 
                            ? res.map((s) => ScanModel.fromJson(s)).toList() 
                            : [];

    return list;  
  }

 Future<List<ScanModel>> getScansPorTipo(String tipo) async{
    
    final db = await database;
    
    final res = await db.rawQuery("SELECT * FROM Scans WHERE tipo ='$tipo");

    List<ScanModel> list = res.isNotEmpty 
                            ? res.map((s) => ScanModel.fromJson(s)).toList() 
                            : [];

    return list;  

  }
  

  //actualziar registros 

  Future<int> updateScan(ScanModel nuevoScan) async {
    final db  = await database;
    
    final res = await db.update('Scans', nuevoScan.toJson(), where: 'id = ?',whereArgs: [nuevoScan.id]);

    return res;
  }

  //borrar registros

  Future<int> deleteScan( int id ) async {
    
    final db  = await database;

    final res = await db.delete('Scans',where: 'id = ?',whereArgs: [id]);

    return res;
  }

  Future<int> deleteAllScan() async {
    
    final db  = await database;

    final res = await db.rawDelete('DELETE FROM Scans');

    return res;
  }


}
