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

  // 전체 프로젝트 가져오기
  static Future<List<ProjectModel>> selectAllProjects() async {
    List<ProjectModel> models = [];
    try {
      var snapshot = await _store.collection('projects').orderBy('date', descending: true).get();
      for(var doc in snapshot.docs) {
        ProjectModel model = ProjectModel.fromFirestore(doc.data());
        model.docId = doc.id;
        models.add(model);
      }
    } catch(e) {
      logger.e('aligo-log Failed to select all project. $e');
    }

    return models;
  }

  // 현재 로그인된 사용자 프로젝트 가져오기
  static Future<List<ProjectModel>> selectMyProjects() async {
    String uid = await AuthService.getCurrentUserUid();
    List<ProjectModel> models = [];
    try {
      var snapshot = await _store.collection('projects').where('uid', isEqualTo: uid).orderBy('date', descending: true).get();
      for(var doc in snapshot.docs) {
        ProjectModel model = ProjectModel.fromFirestore(doc.data());
        model.docId = doc.id;
        models.add(model);
      }
    } catch(e) {
      logger.e('aligo-log Failed to select MyProject list. $e');
    }

    return models;
  }

  // DocId로 특정 프로젝트 가져오기
  static Future<ProjectModel?> getProjectByDocId(String docId) async {
    ProjectModel? model;
    try {
      var docRef = await _store.collection('projects').doc(docId).get();
      model = ProjectModel.fromFirestore(docRef.data()!);
    } catch(e) {
      logger.e('aligo-log Failed to get a project with docId. $e');
    }
    return model;
  }

  // 프로젝트 진행현황 업데이트
  static Future<void> updateProgressTo(String docId, String progress) async {
    try {
      await _store.collection('projects').doc(docId).update({
        'progress': progress,
      });
    } catch(e) {
      logger.e('aligo-log Failed to update progress to 11. $e');
    }
  }

  // 프로젝트 삭제
  static Future<void> deleteProject(String docId) async {
    try {
      await _store.collection('projects').doc(docId).delete();
    } catch(e) {
      logger.e('aligo-log Failed to delete project ${docId}. $e');
    }
  }
}
