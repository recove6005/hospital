import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/toekn_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:glucocare/services/fcm_service.dart';
import 'package:logger/logger.dart';

class TokenRepository {
  static final Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertToken(_isAdmin, _isMaster) async {
    String? token = '';
    String? uid = '';

    if(await AuthService.userLoginedFa()) {
      uid = AuthService.getCurUserUid();
    } else {
      uid = await AuthService.getCurUserId();
    }

    token = await FCMService.getToken();

    TokenModel model = TokenModel(uid: uid!, token: token!, isAdmin: _isAdmin, isMaster: _isMaster);

    await _store.collection('tokens').doc(uid).set(model.toJson());
  }

  static Future<List<String>> selectAdminTokens() async {
    List<String> admins = [];
    var snapshot = await _store.collection('tokens').where('is_admin', isEqualTo: true).get();
    for(var doc in snapshot.docs) {
      String token = doc.data()['token'];
      admins.add(token);
    }

    return admins;
  }

  static Future<List<String>> selectMasterTokens() async {
    List<String> masters = [];
    var snapshot = await _store.collection('tokens').where('is_master', isEqualTo: true).get();
    for(var doc in snapshot.docs) {
      String token = doc.data()['token'];
      masters.add(token);
    }

    return masters;
  }
}