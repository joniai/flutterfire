// Copyright 2020, the Chromium project messagingors.  Please see the MESSAGINGORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import './test_utils.dart';

bool SKIP_MANUAL_TESTS = false;

void runInstanceTests() {
  group('$FirebaseMessaging.instance', () {
    FirebaseApp app;
    FirebaseApp secondaryApp;
    FirebaseMessaging messaging;

    setUpAll(() async {
      app = await Firebase.initializeApp();
      secondaryApp = await testInitializeSecondaryApp();
      messaging = FirebaseMessaging.instance;
    });

    tearDownAll(() {});

    test('instance', () {
      expect(messaging, isA<FirebaseMessaging>());
      expect(messaging.app, isA<FirebaseApp>());
      expect(messaging.app.name, defaultFirebaseAppName);
    });

    test('instanceFor', () {
      FirebaseMessaging secondaryMessaging =
          FirebaseMessaging.instanceFor(app: secondaryApp);
      expect(messaging.app, isA<FirebaseApp>());
      expect(secondaryMessaging, isA<FirebaseMessaging>());
      expect(secondaryMessaging.app.name, secondaryApp.name);
    });

    group('app', () {
      test('accessible from firebase.app()', () {
        expect(messaging.app, isA<FirebaseApp>());
        expect(messaging.app.name, app.name);
      });
    });

    // group('configure', () {});

    group('setAutoInitEnabled()', () {
      test('sets the value', () async {
        expect(messaging.isAutoInitEnabled, isFalse);
        await messaging.setAutoInitEnabled(true);
        expect(messaging.isAutoInitEnabled, isTrue);
      });
    });

    group('requestPermission', () {
      test('resolves 1 on android', () async {
        final result = await messaging.requestPermission();
        expect(result, isA<NotificationSettings>());
        expect(result.authorizationStatus, AuthorizationStatus.authorized);
      }, skip: !Platform.isAndroid);
    });

    group('getAPNSToken', () {
      test('resolves null on android', () async {
        expect(await messaging.getAPNSToken(), null);
      }, skip: !Platform.isAndroid);

      test('resolves null on ios if using simulator', () async {
        expect(await messaging.getAPNSToken(), null);
      }, skip: !Platform.isIOS);
    });

    group('getInitialMessage', () {
      test('returns null when no initial message', () async {
        expect(await messaging.getInitialMessage(), null);
      });
    });

    group('getToken()', () {
      test('returns a token', () async {
        final result = await messaging.getToken();
        expect(result, isA<String>());
      });
    }, skip: SKIP_MANUAL_TESTS); // only run for manual testing

    group('deleteToken()', () {
      test('generate a new token after deleting', () async {
        final token1 = await messaging.getToken();

        await messaging.deleteToken();

        final token2 = await messaging.getToken();

        expect(token1, isA<String>());
        expect(token2, isA<String>());
        expect(token1, isNot(token2));
      }, skip: SKIP_MANUAL_TESTS); // only run for manual testing
    });

    group('subscribeToTopic()', () {
      test('successfully subscribes from topic', () async {
        final topic = 'test-topic';

        await messaging.subscribeToTopic(topic);
      });
    });

    group('unsubscribeFromTopic()', () {
      test('successfully unsubscribes from topic', () async {
        final topic = 'test-topic';

        await messaging.unsubscribeFromTopic(topic);
      });
    });

    // deprecated methods
    group('FirebaseMessaging (deprecated)', () {
      test('returns an instance with the current [FirebaseApp]', () async {
        // ignore: deprecated_member_use
        final testInstance = FirebaseMessaging();
        expect(testInstance, isA<FirebaseMessaging>());
        expect(testInstance.app, isA<FirebaseApp>());
        expect(testInstance.app.name, defaultFirebaseAppName);
      });
    });

    group('requestNotificationPermissions', () {});

    group('autoInitEnabled (deprecated)', () {
      test('returns correct value', () async {
        expect(messaging.isAutoInitEnabled, isFalse);
        // ignore: deprecated_member_use
        expect(await messaging.autoInitEnabled(), messaging.isAutoInitEnabled);

        await messaging.setAutoInitEnabled(true);

        expect(messaging.isAutoInitEnabled, isTrue);
        // ignore: deprecated_member_use
        expect(await messaging.autoInitEnabled(), messaging.isAutoInitEnabled);
      });
    });
  });
}
