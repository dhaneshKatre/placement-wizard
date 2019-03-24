import 'dart:collection';

class Data {
  double cgpi, ten, twelve;
  int hackathons = 0;
  double softSkillsRating = 5.0, competitiveCodingRating = 5.0;
  List<String> fieldList;
  Map<String, Map<String, int>> fieldMap = Map();

  Data();

  List asList() {
    List dataAsList = List();
    dataAsList.add(this.cgpi);
    dataAsList.add(this.ten);
    dataAsList.add(this.twelve);
    dataAsList.add(this.softSkillsRating);
    dataAsList.add(this.competitiveCodingRating);
    dataAsList.add(this.hackathons);
    for (var i in this.fieldList) {
      dataAsList.add(this.fieldMap[i]["projects"]);
      dataAsList.add(this.fieldMap[i]["internships"]);
      dataAsList.add(this.fieldMap[i]["certificates"]);
    }
    return dataAsList;
  }

  Data.fromMap(LinkedHashMap<dynamic, dynamic> map) {
    this.cgpi = map['cgpi'].toDouble();
    this.ten = map['ten'].toDouble();
    this.twelve = map['twelve'].toDouble();
    this.softSkillsRating = map['soft'].toDouble();
    this.competitiveCodingRating = map['competitive'].toDouble();
    this.hackathons = map['hack'].toInt();
    LinkedHashMap<dynamic, dynamic> fields = map['pic'];
    Map<String, Map<String, int>> fm = Map();
    for (var i in fields.keys) {
      Map<String, int> mapToPut = Map();
      mapToPut["projects"] = fields[i]["projects"];
      mapToPut["internships"] = fields[i]["internships"];
      mapToPut["certificates"] = fields[i]["certificates"];
      fm.putIfAbsent(i, () => mapToPut);
    }
    this.fieldMap = fm;
  }

  Map<String, dynamic> asMap() {
    Map<String, dynamic> dataMap = Map();
    dataMap.putIfAbsent('cgpi', () => this.cgpi);
    dataMap.putIfAbsent('ten', () => this.ten);
    dataMap.putIfAbsent('twelve', () => this.twelve);
    dataMap.putIfAbsent('pic', () => this.fieldMap);
    dataMap.putIfAbsent('soft', () => this.softSkillsRating);
    dataMap.putIfAbsent('competitive', () => this.competitiveCodingRating);
    dataMap.putIfAbsent('hack', () => this.hackathons);
    return dataMap;
  }
}
