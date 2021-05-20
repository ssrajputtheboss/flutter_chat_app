// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_chat_app/main.dart';

void main() {
  testWidgets('SignUp button click test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    /*await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('SignUp'), findsOneWidget);
    expect(find.text('Name'), findsNothing);

    // Tap SignUp button
    await tester.tap(find.text('SignUp'));
    await tester.pump();

    //verification of movement to next page
    expect(find.text('LogIn'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('SignUp'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
  });
  testWidgets('Login test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // check if Login button , Email , Password are there
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // input email password
    await tester.tap(find.text('Email'));
    await tester.enterText( find.widgetWithText( TextFormField , 'Email') , 'new@gmail.com');
    //await tester.pump();
    await tester.tap(find.text('Password'));
    await tester.enterText( find.widgetWithText( TextFormField , 'Password') , 'newpass');
    await tester.tap(find.widgetWithText( TextButton, 'Login') );

    await tester.pump();

    // checking if homepage appeared
    //expect(find.text('new'), findsOneWidget);*/
  });
}
