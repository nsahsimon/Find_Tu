import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_tu/models/tutor.dart';


class TutorsData extends ChangeNotifier {
  List<Tutor> _myTutors = [];
  bool isFirstTime = true;

  void addTutor(Tutor newTutor, {bool notify = true}) {
    _myTutors.add(newTutor);
    if(notify) notifyListeners();
  }

  void resetFirstTime() {
    isFirstTime = true;
    _myTutors = [];
    notifyListeners();
  }

  void emptyTutorList () {
    _myTutors = [];
  }

  void deleteTutor(Tutor oldTutor, {bool notify = true}) {
    int tutorIndex = _myTutors.indexOf(oldTutor);
    _myTutors.removeAt(tutorIndex);
    if(notify) notifyListeners();
  }

  void loadTutors(List<Map<String, dynamic>> tutorDocs, BuildContext context) {
   emptyTutorList();
    for(Map<String, dynamic> tutorDoc in tutorDocs) {
      Tutor newTutor = Tutor(tutorDoc["tutor_doc"]);
      newTutor.userRating = tutorDoc["rating"];
      _myTutors.add(newTutor);
    }

    isFirstTime ? debugPrint("Is first time") : null;
    isFirstTime ? notifyListeners() : null;
    isFirstTime = isFirstTime ? !isFirstTime : false;
  }

  Tutor getTutorAtIndex(int index) => _myTutors[index];

  int get tutorCount => _myTutors.length;

}