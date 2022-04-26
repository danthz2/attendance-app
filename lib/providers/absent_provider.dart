import 'package:attendance/models/absent.dart';
import 'package:attendance/providers/user_provider.dart';
import 'package:attendance/services/enums.dart';
import 'package:attendance/services/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:attendance/services/utils.dart';

class AbsentProvider extends ChangeNotifier {
  Absent? _absent;
  Absent? get absent => _absent;
  set absent(Absent? value) {
    _absent = value;
    notifyListeners();
  }

  List<Absent>? _absents;
  List<Absent>? get absents => _absents;

  void resetState() {
    _absents = null;
    _absent = null;
    notifyListeners();
  }

  Future<void> getAbsent(String id) async {
    try {
      final response = await FirebaseService.get<DocumentSnapshot>(
          collection: Collection.Absent, id: id);
      final snapshot = response.value;
      if (snapshot!.exists) {
        _absent = Absent.fromSnapshot(snapshot);
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> getAbsents({int? limit, String? id}) async {
    try {
      final response = await FirebaseService.get<List<DocumentSnapshot>>(
          collection: Collection.Absent, limit: limit!, query: id);
      final snapshots = response.value ?? [];
      if (snapshots.isNotEmpty) {
        _absents = snapshots.map((e) => Absent.fromSnapshot(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> sendReason(
    BuildContext context,
    String reason,
  ) async {
    final prov = Provider.of<UserProvider>(context, listen: false);
    try {
      final currentDate = DateTime.now();
      final userName = prov.user?.name;
      final id = '${userName}_${currentDate.formatddMMy()}';
      final response = await FirebaseService.set<Absent>(
        id: id,
        collection: Collection.Absent,
        data: Absent(
          id: id,
          name: userName,
          nign: prov.user?.id,
          reason: reason,
          date: currentDate,
        ),
      );
      _absent = response;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
