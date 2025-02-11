import 'package:aligo_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../model/project_model.dart';

class ProjectRepo {
  static final _store = FirebaseFirestore.instance;
  static final Logger logger = Logger();
  
  // 프로젝트 문의 접수
  static Future<void> insertProject(ProjectModel model) async {
    try {
      await _store.collection('projects').add(model.toFirestore());
    } catch(e) {
      logger.e('aligo-log Failed to insert project. $e');
    }
  }

  static Future<List<ProjectModel>> selectMyProjects() async {
    String uid = await AuthService.getCurrentUserUid();
    List<ProjectModel> models = [];
    try {
      var snapshot = await _store.collection('projects').where('uid', isEqualTo: uid).get();
      for(var doc in snapshot.docs) {
        ProjectModel model = ProjectModel.fromFirestore(doc.data());
        models.add(model);
      }
    } catch(e) {
      logger.e('aligo-log Failed to select MyProject list. $e');
    }

    return models;
  }
}
