import 'package:intl/intl.dart';

class Users {
  String id_user;
  String username;
  String name;
  String rnc_panen_kg;
  String rnc_panen_janjang;
  String rnc_penghasilan;

  Users({
    required this.id_user,
    required this.username,
    required this.name,
    required this.rnc_panen_kg,
    required this.rnc_panen_janjang,
    required this.rnc_penghasilan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_user': id_user,
      'username': username,
      'name': name,
      'rnc_panen_kg': rnc_panen_kg,
      'rnc_panen_janjang': rnc_panen_janjang,
      'rnc_penghasilan': rnc_penghasilan,
    };
  }
}

class sendTree {
  String id_tree;
  String lat;
  String long;
  String name;
  String nomor;
  String baris;
  String ancak;
  String blok;
  String afd;
  String estate;
  String keterangan;

  sendTree({
    required this.id_tree,
    required this.lat,
    required this.long,
    required this.name,
    required this.nomor,
    required this.baris,
    required this.ancak,
    required this.blok,
    required this.estate,
    required this.afd,
    required this.keterangan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_tree': id_tree,
      'lat': lat,
      'long': long,
      'name': name,
      'nomor': nomor,
      'baris': baris,
      'ancak': ancak,
      'blok': blok,
      'estate': estate,
      'afd': afd,
      'keterangan': keterangan,
    };
  }
}

class sendRoute {
  String lat;
  String long;
  String id_user;
  String tipe;
  String date;

  sendRoute({
    required this.lat,
    required this.long,
    required this.id_user,
    this.tipe = '2',
    this.date = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'long': long,
      'id_user': id_user,
      'tipe': tipe,
      'date': date
    };
  }
}

class sendSchedule {
  String id_tree;
  String id_user;
  String lat;
  String long;
  String name;
  String nomor;
  String baris;
  String ancak;
  String blok;
  String afd;
  String estate;
  String keterangan;

  sendSchedule({
    required this.id_tree,
    required this.id_user,
    required this.lat,
    required this.long,
    required this.name,
    required this.nomor,
    required this.baris,
    required this.ancak,
    required this.blok,
    required this.estate,
    required this.afd,
    required this.keterangan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_tree': id_tree,
      'lat': lat,
      'long': long,
      'id_user': id_user,
      'name': name,
      'nomor': nomor,
      'baris': baris,
      'ancak': ancak,
      'blok': blok,
      'estate': estate,
      'afd': afd,
      'keterangan': keterangan,
    };
  }
}

class sendHistoryQty {
  String id_tree;
  String id_user;
  String lat;
  String long;
  String name;
  double qty;
  String tipe;
  String id_harvest;
  String date;

  sendHistoryQty(
      {required this.id_tree,
      required this.id_user,
      required this.name,
      required this.lat,
      required this.long,
      required this.qty,
      required this.tipe,
      required this.id_harvest,
      this.date = ''});

  Map<String, dynamic> toMap() {
    return {
      'id_tree': id_tree,
      'id_user': id_user,
      'name': name,
      'lat': lat,
      'long': long,
      'qty': qty,
      'tipe': tipe,
      'id_harvest': id_harvest,
      'date': getCurrentDateTime(),
    };
  }
}

String getCurrentDateTime() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  String formattedDate = formatter.format(now);
  return formattedDate.toString();
}
