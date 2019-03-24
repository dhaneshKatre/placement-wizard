// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//  * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following disclaimer
//  in the documentation and/or other materials provided with the
//  distribution.
//  * Neither the name of Google Inc. nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'dart:math' as math;

import 'package:async_loader/async_loader.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pwfinal/model/data.dart';
import 'package:pwfinal/model/state.dart';
import 'package:pwfinal/screens/all_companies_list.dart';
import 'package:pwfinal/screens/company_list.dart';
import 'package:pwfinal/screens/form.dart';
import 'package:pwfinal/state_widget.dart';
import 'package:pwfinal/utils/auth.dart';
import 'package:pwfinal/widgets/shimmer_card.dart';

const double _kFlingVelocity = 2.0;
final GlobalKey<AsyncLoaderState> asyncLoaderState = GlobalKey();

class _BackdropPanel extends StatelessWidget {
  const _BackdropPanel({
    Key key,
    this.onTap,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.title,
    this.child,
  }) : super(key: key);

  final VoidCallback onTap;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final Widget title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: onVerticalDragUpdate,
            onVerticalDragEnd: onVerticalDragEnd,
            onTap: onTap,
            child: Container(
              height: 48.0,
              padding: EdgeInsetsDirectional.only(start: 16.0),
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.subhead,
                child: Center(child: title),
              ),
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _BackdropTitle extends AnimatedWidget {
  final Widget frontTitle;
  final Widget backTitle;

  const _BackdropTitle({
    Key key,
    Listenable listenable,
    this.frontTitle,
    this.backTitle,
  }) : super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.listenable;
    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.title,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: CurvedAnimation(
              parent: ReverseAnimation(animation),
              curve: Interval(0.5, 1.0),
            ).value,
            child: backTitle,
          ),
          Opacity(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Interval(0.5, 1.0),
            ).value,
            child: frontTitle,
          ),
        ],
      ),
    );
  }
}

class Backdrop extends StatefulWidget {
  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  StateModel appState;
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _controller;
  static const platform = const MethodChannel("plawiz");
  static const List outputs = [
    'Front End_H',
    'Front End_M',
    'Front End_L',
    'Back End_H',
    'Back End_M',
    'Back End_L',
    'Full Stack_H',
    'Full Stack_M',
    'Full Stack_L',
    'Cloud_H',
    'Cloud_M',
    'Cloud_L',
    'Data Science_H',
    'Data Science_M',
    'Data Science_L',
    'Database_H',
    'Database_M',
    'Database_L',
    'Machine Learning_H',
    'Machine Learning_M',
    'Machine Learning_L',
    'Security_H',
    'Security_M',
    'Security_L',
    'Marketing',
    'Mobile_H',
    'Mobile_M',
    'Mobile_L'
  ];

  Future<void> _getModelProbabilities() async {
    try {
      if (StateWidget.of(context).state.data != null) {
        List arr = StateWidget.of(context).state.data.asList();
        arr = arr.map((v) => v.toDouble()).toList();
        debugPrint(arr.toString());
        List<dynamic> res =
        await platform.invokeMethod('runModel', {"arr": arr});
        List<double> probs = res.cast<double>();
        List<double> probsCopy = List.from(probs, growable: false);
        probs.sort();
        probs = probs.reversed.toList();
        List<double> top = probs.take(5).toList();
        List<String> eligibleFields = List();
        for (double i in top) eligibleFields.add(outputs[probsCopy.indexOf(i)]);
        navigateToCompaniesList(eligibleFields);
      }
    } on PlatformException catch (e) {
      debugPrint('ERROR!!! - ${e.message.toString()}');
    }
  }

  navigateToCompaniesList(List<String> eligibleFields) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CompaniesListScreen(eligibleFields)));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      value: 1.0,
      vsync: this,
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _backdropPanelVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropPanelVisibility() {
    FocusScope.of(context).requestFocus(FocusNode());
    _controller.fling(
        velocity: _backdropPanelVisible ? -_kFlingVelocity : _kFlingVelocity);
  }

  double get _backdropHeight {
    final RenderBox renderBox = _backdropKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    _controller.value -= details.primaryDelta / _backdropHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(_kFlingVelocity, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-_kFlingVelocity, -flingVelocity));
    else
      _controller.fling(
          velocity:
              _controller.value < 0.5 ? -_kFlingVelocity : _kFlingVelocity);
  }

  Widget _errorWidget() {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(
            Icons.signal_wifi_off,
            color: Colors.white,
          ),
        ),
        title: Text('No Internet!'),
        subtitle: Text('Please check your connectivity!'),
        onTap: () => asyncLoaderState.currentState.reloadState(),
      ),
    );
  }

  Widget _successWidget(data) {
    List<Widget> cards = List();
    if (data == 'null') {
      cards.add(
        Card(
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.error,
                color: Colors.white,
              ),
            ),
            title: Text('Form not filled!'),
            subtitle: Text('Fill form to get predicted companies list.'),
            onTap: () => _navigateToForm(appState.data, context),
          ),
        ),
      );
    } else
      cards.add(Card(
        elevation: 2.0,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.greenAccent,
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
          title: Text('Form filled!'),
          subtitle: Text('Press here to get predicted companies list'),
          onTap: () => _getModelProbabilities(),
        ),
      ));
    cards
      ..add(SizedBox(height: 20.0))
      ..add(
        Card(
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.yellow,
              child: Icon(
                Icons.info,
                color: Colors.white,
              ),
            ),
            title: Text('View all companies'),
            subtitle: Text('Press here to view all companies'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AllCompanies())),
          ),
        ),
      );
    return Column(children: cards);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double panelTitleHeight = 48.0;
    final Size panelSize = constraints.biggest;
    final double panelTop = panelSize.height - panelTitleHeight;

    Animation<RelativeRect> panelAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, panelTop, 0.0, panelTop - panelSize.height),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_controller.view);

    return Container(
      color: Theme.of(context).primaryColor,
      key: _backdropKey,
      child: Stack(
        children: <Widget>[
          Center(
            child: Builder(
              builder: (context) => Drawer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _getDrawerMenuItems(context),
                ),
              ),
            ),
          ),
          PositionedTransition(
            rect: panelAnimation,
            child: _BackdropPanel(
              onTap: _toggleBackdropPanelVisibility,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              title: Text(
                  "Welcome, ${StateWidget.of(context).state.user.displayName}",
                  style: TextStyle(color: Theme.of(context).accentColor)),
              child: Center(
                child: Builder(
                  builder: (context) => Container(
                    child: ListView(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(8.0),
                          child: SizedBox(
                            child: AsyncLoader(
                                key: asyncLoaderState,
                                initState: () async => await _checkIfFormFilled(),
                                renderLoad: () => ShimmerCard(),
                                renderError: ([error]) => _errorWidget(),
                                renderSuccess: ({data}) =>
                                    _successWidget(data.value.toString())),
                            width: 80.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<DataSnapshot> _checkIfFormFilled() {
    Future<DataSnapshot> ds = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(appState.user.uid)
        .child('form')
        .once()
        .timeout(Duration(seconds: 20));
    ds.then((d) {
      if (d.value != null) {
        Data datagram = Data.fromMap(d.value);
        datagram.fieldList = StateWidget.of(context).state.fields;
        StateWidget.of(context).handleData(datagram);
      }
    });
    return ds;
  }

  List<Widget> _getDrawerMenuItems(BuildContext context) {
    StateModel appState = StateWidget.of(context).state;
    List<Widget> menuItems = List();
    menuItems
      ..add(
        SizedBox(
          width: double.infinity,
          height: 200.0,
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 72.0,
                  height: 72.0,
                  child: CircleAvatar(
                    backgroundColor:
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Colors.blue
                        : Colors.white,
                    child: Image.network(appState.user.photoUrl,
                        fit: BoxFit.cover),
                  ),
                ),
                Text(appState.user.displayName),
                Text(appState.user.email),
              ],
            ),
          ),
        ),
      );
    if (appState.data != null)
      menuItems.add(ListTile(
        title: Text("Edit Form"),
        leading: Icon(Icons.edit),
        onTap: () {
          _toggleBackdropPanelVisibility();
          _navigateToForm(appState.data, context);
        },
      ));
    menuItems
      ..add(ListTile(
        title: Text("Logout"),
        leading: Icon(Icons.exit_to_app),
        onTap: () {
            _toggleBackdropPanelVisibility();
          StateWidget.of(context).signOut();
        },
      ))
      ..add(ListTile(
          title: Text("Invert app theme"),
          leading: DynamicTheme.of(context).brightness == Brightness.light
              ? Icon(Icons.invert_colors)
              : Icon(Icons.invert_colors_off),
          onTap: () {
            DynamicTheme.of(context).setBrightness(
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark);
              _toggleBackdropPanelVisibility();
          }));
    return menuItems;
  }

  _navigateToForm(Data data, context) async {
    bool res = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => StepwiseFormScreen(data)));
    if (res) {
      await showIt(context);
      asyncLoaderState.currentState.reloadState();
    }
  }


  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          onPressed: _toggleBackdropPanelVisibility,
          icon: AnimatedIcon(
            icon: AnimatedIcons.close_menu,
            progress: _controller.view,
          ),
        ),
        title: _BackdropTitle(
          listenable: _controller.view,
          frontTitle: Text("Home"),
          backTitle: Text("Menu"),
        ),
      ),
      body: LayoutBuilder(
        builder: _buildStack,
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}
