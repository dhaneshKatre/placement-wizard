import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pwfinal/model/data.dart';
import 'package:pwfinal/state_widget.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:pwfinal/widgets/table_generator.dart';

final GlobalKey<FormState> _personalForm = GlobalKey();
final GlobalKey<FormState> _projectsForm = GlobalKey();
final GlobalKey<FormState> _skillsForm = GlobalKey();

final GlobalKey<ScaffoldState> _scaffold = GlobalKey();

final TextEditingController projectController = TextEditingController();
final TextEditingController internshipController = TextEditingController();
final TextEditingController certificateController = TextEditingController();
final TextEditingController hackathonController = TextEditingController();

enum ConfirmAction { CANCEL, ACCEPT }

class StepwiseFormScreen extends StatefulWidget {
  final Data data;
  StepwiseFormScreen(this.data);
  State createState() => new _StepwiseFormState();
}

class _StepwiseFormState extends State<StepwiseFormScreen> {
  Data data;
  int currentStep = 0;
  GlobalKey<FormState> _formKey = new GlobalKey();
  static bool isLoading = false, isSubmitting = false;
  double sSR, cCR;

  Map<String, Map<String, int>> fieldMap;
  List<String> fieldList;
  String _currentSelectedField;

  List<bool> stepList = [true, false, false];

  @override
  void initState() {
    super.initState();
    populateFields();
    this.data = widget.data ?? Data();
    this.fieldMap = widget.data != null ? widget.data.fieldMap : Map();
    this.sSR = widget.data != null ? widget.data.softSkillsRating : 5.0;
    this.cCR = widget.data != null ? widget.data.competitiveCodingRating : 5.0;
    hackathonController.text = (widget.data == null) ? "" : data.hackathons.toString();
  }

  Future<void> populateFields() async {
    this.fieldList = List<String>();
    setState(() {
      isLoading = true;
    });
    await FirebaseDatabase.instance
        .reference()
        .child('Fields')
        .once()
        .then((DataSnapshot snapshot) {
      List<dynamic> list = snapshot.value;
      setState(() {
        Map<String, Map<String, int>> map = Map();
        list.forEach((v) {
          this.fieldList.add(v.toString());
          Map<String, int> temp = Map();
          temp["projects"] = 0;
          temp["internships"] = 0;
          temp["certificates"] = 0;
          map.putIfAbsent(v.toString(), () => temp);
        });
        this.fieldMap = map;
        this._currentSelectedField = list.elementAt(0).toString();
        data.fieldList = list.map((t) => t.toString()).toList();
        isLoading = false;
      });
    }).catchError((e) => debugPrint('Error: ${e.toString()}'));
  }

  Widget getPersonalForm() {
    return Form(
      key: _personalForm,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
                initialValue: (data.cgpi == null) ? "" : data.cgpi.toString(),
                decoration: InputDecoration(
                  hintText: 'Enter current CGPI',
                  labelText: 'CGPI',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => data.cgpi = double.parse(val),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  double value = double.tryParse(val);
                  if (value != null) {
                    if (value > 10.0 || value < 0.0) return "Enter proper value";
                  } else
                    return "Enter proper value!";
                }),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
                initialValue: (data.ten == null) ? "" : data.ten.toString(),
                onSaved: (val) => data.ten = double.parse(val),
                decoration: InputDecoration(
                  hintText: 'Enter 10th percentage',
                  labelText: '10th %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  double value = double.tryParse(val);
                  if (value != null) {
                    if (value > 100.0 || value < 35.0)
                      return "Enter proper value";
                  } else
                    return "Enter proper value!";
                }),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
                initialValue:
                    (data.twelve == null) ? "" : data.twelve.toString(),
                onSaved: (val) => data.twelve = double.parse(val),
                decoration: InputDecoration(
                  hintText: 'Enter 12th percentage',
                  labelText: '12th %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  double value = double.tryParse(val);
                  if (value != null) {
                    if (value > 100.0 || value < 35.0)
                      return "Enter proper value";
                  } else
                    return "Enter proper value!";
                }),
          ),
        ],
      ),
    );
  }

  Widget getProjectsForm() {
    return Form(
      key: _projectsForm,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _getDropdown(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: projectController,
              decoration: InputDecoration(
                labelText: '#Projects done',
                hintText: 'Enter number of projects',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (t) {
                debugPrint(t);
              },
              validator: (val) {
                if (projectController.text.isNotEmpty &&
                    int.tryParse(val) == null) return 'Enter proper value!';
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: internshipController,
              decoration: InputDecoration(
                labelText: '#Internships done',
                hintText: 'Enter number of internships',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (internshipController.text.isNotEmpty &&
                    int.tryParse(val) == null) return 'Enter proper value!';
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: certificateController,
              decoration: InputDecoration(
                labelText: '#Certificates aquired',
                hintText: 'Enter number of certificates',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (certificateController.text.isNotEmpty &&
                    int.tryParse(val) == null) return 'Enter proper value!';
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                color: Theme.of(context).primaryColor,
                child: Text(
                  'ADD',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    if (_projectsForm.currentState.validate()) {
                      this.fieldMap.update(this._currentSelectedField, (t) {
                        Map<String, int> temp = Map();
                        temp["projects"] =
                            int.tryParse(projectController.text) ?? 0;
                        temp["internships"] =
                            int.tryParse(internshipController.text) ?? 0;
                        temp["certificates"] =
                            int.tryParse(certificateController.text) ?? 0;
                        return temp;
                      });
                      _scaffold.currentState.showSnackBar(
                        SnackBar(
                          content: Text('Value updated successfully!'),
                          duration: Duration(milliseconds: 1000),
                        ),
                      );
                    }
                  });
                },
              ),
              FlatButton(
                child: Text('CLEAR'),
                onPressed: () {
                  projectController.text = '';
                  internshipController.text = '';
                  certificateController.text = '';
                },
              ),
            ],
          ),
          Divider(),
          TableGenerator(this.fieldMap),
        ],
      ),
    );
  }

  Widget _getDropdown() {
    _refillTextBoxes(String t) {
      if (_currentSelectedField != t) {
        Map<String, int> t3 = this.fieldMap[t];
        projectController.text =
            (t3["projects"] != 0) ? t3["projects"].toString() : '';
        internshipController.text =
            (t3["internships"] != 0) ? t3["internships"].toString() : '';
        certificateController.text =
            (t3["certificates"] != 0) ? t3["certificates"].toString() : '';
      }
    }

    return Card(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            items: this
                .fieldList
                .map((t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(t),
                    ))
                .toList(),
            elevation: 8,
            value: this._currentSelectedField,
            onChanged: (t) {
              setState(() {
                _refillTextBoxes(t);
                this._currentSelectedField = t;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget getSkillsForm() {
    return Form(
      key: _skillsForm,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Rate your soft skills',
                  textAlign: TextAlign.left,
                ),
                StarRating(
                  size: 31.2,
                  starCount: 10,
                  rating: this.sSR,
                  borderColor: Colors.black87,
                  color: Theme.of(context).accentColor,
                  onRatingChanged: (t) {
                    setState(() {
                      this.sSR = t;
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Rate your competitive coding skills',
                  textAlign: TextAlign.left,
                ),
                StarRating(
                  size: 31.2,
                  starCount: 10,
                  rating: this.cCR,
                  borderColor: Colors.black87,
                  color: Theme.of(context).accentColor,
                  onRatingChanged: (t) {
                    setState(() {
                      this.cCR = t;
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              controller: hackathonController,
              decoration: InputDecoration(
                labelText: '#Hackathons participated',
                hintText: 'Enter number of hackathons',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (hackathonController.text.isNotEmpty &&
                    int.tryParse(val) == null) return 'Enter proper value!';
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Step> formSteps() {
    List<Step> steps = [
      Step(
        title: Text('Personal'),
        isActive: stepList[0],
        content: getPersonalForm(),
        state: stepList[0] ? StepState.indexed : StepState.disabled,
      ),
      Step(
          title: Text('Projects'),
          isActive: stepList[1],
          content: (isLoading)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : getProjectsForm(),
          state: stepList[1] ? StepState.indexed : StepState.disabled),
      Step(
          title: Text('Skills'),
          isActive: stepList[2],
          content: getSkillsForm(),
          state: stepList[2] ? StepState.indexed : StepState.disabled),
    ];
    return steps;
  }

  Future<bool> _showProjectConfirmation() async {
    bool flag = true;
    for (Map<String, int> t3 in this.fieldMap.values)
      if (t3["projects"] != 0 ||
          t3["internships"] != 0 ||
          t3["certificates"] != 0) {
        flag = false;
        break;
      }
    if (flag)
      return await _asyncConfirmDialog(context, 'No projects eh !',
              'You haven\'t entered any projects, internships or certificates in any domain. Proceed anyway ?') ==
          ConfirmAction.ACCEPT;
    else
      return true;
  }

  Future<ConfirmAction> _asyncConfirmDialog(
      BuildContext context, String title, String message) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                color: Theme.of(context).primaryColor,
                child: Text(
                  'NO',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop(ConfirmAction.CANCEL);
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(ConfirmAction.ACCEPT);
                },
              )
            ],
          ),
    );
  }

  Widget getForm() {
    if ((isSubmitting)) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Form(
        key: _formKey,
        child: Stepper(
          steps: formSteps(),
          currentStep: currentStep,
          type: StepperType.horizontal,
          onStepContinue: () {
            if (currentStep == 0) {
              if (_personalForm.currentState.validate()) {
                _personalForm.currentState.save();
                setState(() {
                  currentStep += 1;
                  stepList[1] = true;
                });
              }
            } else if (currentStep == 1) {
              _showProjectConfirmation().then((b) {
                if (b) {
                  setState(() {
                    currentStep += 1;
                    stepList[2] = true;
                  });
                  data.fieldMap = this.fieldMap;
                } else
                  return;
              });
            }
          },
          onStepTapped: (step) {
            setState(() {
              this.currentStep = step;
            });
          },
          onStepCancel: (currentStep == 0)
              ? null
              : () {
                  setState(() {
                    if (currentStep > 0)
                      currentStep -= 1;
                    else
                      currentStep = 0;
                  });
                },
          onFinished: () async {
            if (_skillsForm.currentState.validate()) {
              int hacks = int.tryParse(hackathonController.text) ?? 0;
              data.hackathons = hacks.toInt();
              data.softSkillsRating = this.sSR;
              data.competitiveCodingRating = this.cCR;
              await _asyncConfirmDialog(context, 'Sure to submit ?',
                      'Are you sure want to finish fillling the form and submit it ?')
                  .then((b) {
                if (b == ConfirmAction.ACCEPT)
                  _handleFormSubmission();
                else
                  return;
              });
            }
          },
        ),
      );
    }
  }

  _handleFormSubmission() async {
    setState(() {
      isSubmitting = true;
    });
    await FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(StateWidget.of(context).state.user.uid)
        .child('form')
        .set(data.asMap())
        .then((r) {
      setState(() {
        isSubmitting = false;
        StateWidget.of(context).handleData(this.data);
        Navigator.of(context).pop(true);
      });
    }).catchError((e) {
      setState(() {
        isSubmitting = false;
      });
      _scaffold.currentState
          .showSnackBar(SnackBar(content: Text(e.toString())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          await _asyncConfirmDialog(context, 'Sure to exit ?',
              'Form isn\'t submitted yet. Do you want to leave page ?') ==
          ConfirmAction.ACCEPT,
      child: Scaffold(
        key: _scaffold,
        appBar: AppBar(
          elevation: 0.0,
          title: Text('Fill Details'),
        ),
        body: Builder(builder: (context) => getForm()),
      ),
    );
  }
}
