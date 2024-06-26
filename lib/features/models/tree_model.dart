import 'package:latlong2/latlong.dart';

class Tree {
  final String name;
  final String idTree;
  final String id_user;
  final LatLng position;
  final String nomor;
  final String baris;
  final String ancak;
  final String blok;
  final String estate;
  final String afd;
  final String keterangan;
  final String qty;
  final String date;

  Tree(
      {required this.name,
      this.id_user = '',
      required this.idTree,
      required this.position,
      this.nomor = '',
      this.baris = '',
      this.ancak = '',
      this.blok = '',
      this.estate = '',
      this.afd = '',
      this.keterangan = '',
      this.qty = '0',
      this.date = ''});

  factory Tree.fromJson(data) {
    return Tree(
        name: data['name'].toString(),
        id_user: (data['id_user'] == null) ? '' : data['id_user'],
        idTree: data['id_tree'].toString(),
        qty: data['qty'].toString(),
        date: (data['date'] == null) ? '' : data['date'],
        nomor: (data['nomor'] == null) ? '' : data['nomor'],
        baris: (data['baris'] == null) ? '' : data['baris'],
        ancak: (data['ancak'] == null) ? '' : data['ancak'],
        blok: (data['blok'] == null) ? '' : data['blok'],
        afd: (data['afd'] == null) ? '' : data['afd'],
        estate: (data['estate'] == null) ? '' : data['estate'],
        keterangan: (data['keterangan'] == null) ? '' : data['keterangan'],
        position:
            LatLng(double.parse(data['lat']), double.parse(data['long'])));
  }
}

class User {
  final String id_user;
  final String name;
  final String username;

  User({
    required this.id_user,
    required this.name,
    required this.username,
  });

  factory User.fromJson(data) {
    return User(
      id_user: data['id_user'].toString(),
      name: data['name'].toString(),
      username: data['username'].toString(),
    );
  }
}

class Routes {
  final LatLng position;

  Routes({required this.position});

  factory Routes.fromJson(data) {
    return Routes(
        position:
            LatLng(double.parse(data['lat']), double.parse(data['long'])));
  }
}
