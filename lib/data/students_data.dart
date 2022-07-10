import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:find_tu/models/student.dart';
import 'package:flutter/material.dart';

class StudentsData extends ChangeNotifier {
  List<Student> _myStudents = [];
  bool isFirstTime = true;

  void addStudent(Student newStudent, {bool notify = true}) {
    _myStudents.add(newStudent);
    if(notify) notifyListeners();
  }

  void empty({bool notify = false}){
    _myStudents = [];
    notify ? notifyListeners() : null;
  }

  void resetFirstTime() {
    isFirstTime = true;
    _myStudents = [];
    notifyListeners();
  }

  void deleteStudent(Student oldStudent,  {bool notify = true}) {
    int studIndex = _myStudents.indexOf(oldStudent);
    _myStudents.removeAt(studIndex);
    if(notify) notifyListeners();
  }

  void loadStudents(List studentDocs, BuildContext context) {
    empty();
    for(DocumentSnapshot studentDoc in studentDocs) {
      Student newStudent = Student(studentDoc);
      _myStudents.add(newStudent);
    }

    isFirstTime ? notifyListeners() : null;
    isFirstTime = isFirstTime ? !isFirstTime : false;
  }

  Student getStudentAtIndex (int index) => _myStudents[index];

  int get studentCount => _myStudents.length;

}