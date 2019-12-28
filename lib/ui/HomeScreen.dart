import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myturn/bloc/auth/auth_bloc.dart';
import 'package:myturn/injection/AuthModule.dart';
import 'package:myturn/injection/MainModule.dart';
import 'package:myturn/Routes.dart';
import 'package:myturn/core/theme/AppTheme.dart';
import 'package:myturn/injection/RepoModule.dart';
import 'package:myturn/ui/GroupOptionsScreen.dart';
import 'package:myturn/ui/PhoneAuthScreen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen() : super();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MainModule mainModule = MainModule();
  FirebaseUser _firebaseUser;

  final AuthBloc _authBloc = MainModule().get<AuthBloc>();

  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _firebaseUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      currentTheme: this.mainModule.get<ContemporaryTheme>(),
      child: Builder(
        builder: (context) => Container(
            color: Theme.of(context).backgroundColor,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(5, 55, 5, 10), //provide extra padding on all 4 sides
              child: _screen(context),
            )),
      ),
    );
  } //build

  Widget _screen(BuildContext context) {
    ///to set common media query attributes in current theme
    ThemeProvider.of(context).currentTheme.mediaQueryData(MediaQuery.of(context));

    return Scaffold(
      drawerScrimColor: Theme.of(context).backgroundColor,
      appBar: _appBar(context),
      body: BlocBuilder(
          bloc: _authBloc,
          builder: (BuildContext context, AuthState authState) {
            return _body(context, authState);
          }),
      // show this only when the user is authenticated
      //bottomNavigationBar: _bottomNav(context),
    );
  } //_screen

  /// build body
  Widget _initialLandingScreen(BuildContext context) {
    return Wrap(runSpacing: 40.0, alignment: WrapAlignment.spaceAround, children: <Widget>[_header(), PhoneAuthScreen()]);
  }

  /// Method
  Widget _body(BuildContext context, AuthState authState) {
    Widget widget;

    /*if (_firebaseUser != null) {
      widget = GroupOptionsScreen().groupOptions(context);
    } else {
      widget = _initialLandingScreen(context);
    }*/
    switch (authState.name()) {
      case AuthStates.UninitializedState:
        // Check if the user is authenticated or not
        this._authBloc.add(AuthModule().get<AppStart>()); // this event will either send back Authenticated or UnAuthenticated
        widget = Center(
            child: CircularProgressIndicator(
          value: null, // drawing of the circle does not depend on any value
          strokeWidth: 5.0, // line width
        ));
        break;
      case AuthStates.CodeSentState:
        break;
      case AuthStates.UnAuthenticatedState:
        // If user is not authenticated, then display the screen to enter phone number to authenticate the user.
        widget = _initialLandingScreen(context);
        break;
      case AuthStates.AuthenticatedState:
        // Check if the user is in group, if not show screen that will display Group Options
        // IF the user is already in a group, show the screen that displays booked slots and ability to add new slot
        widget = GroupOptionsScreen().groupOptions(context);
        break;
    }
    return widget;
  }

  Widget _header() {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
        alignment: Alignment.center,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: <Widget>[
          Text(
            "Hello! Welcome to MyTurn!",
            textScaleFactor: 2.0,
          ),
          Text(""),
          Text(
            "Lets get you started!",
            textScaleFactor: 1.5,
          ),
        ]));
  }

  ///Using PreferredSize instead of directly using an AppBar to provide box decoration and other styling
  ///PreferredSize needs 'preferredSize' attribute
  PreferredSize _appBar(BuildContext context) {
    return PreferredSize(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          border: Border.all(color: ThemeProvider.of(context).currentTheme.appBarBorder()),
          borderRadius: BorderRadius.circular(6),
        ),
        child: AppBar(
          automaticallyImplyLeading: false,
          //leading: _drawerIcon(state),
          centerTitle: false,
          title: Text('MyTurn'),
          // actions: _appBarActions(context, state),
        ),
      ),
      preferredSize: Size.fromHeight(50),
    );
  }

  /// ***** start: bottom navbar *****
  BottomAppBar _bottomNav(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: ThemeProvider.of(context).currentTheme.bottomBarBorder()))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              tooltip: "Search",
              onPressed: () => debugPrint("on create"),
            ),
            IconButton(
              icon: Icon(Icons.schedule),
              onPressed: () => Navigator.pushNamed(context, Routes.bookSlot),
            ),
            IconButton(
              icon: Icon(Icons.create),
              onPressed: () => Navigator.pushNamed(context, Routes.createGroup),
            )
          ],
        ),
      ),
    );
  }
}
