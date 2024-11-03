import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:sms_auth_firebase/src/aurh_service.dart';
// import 'package:sms_auth_firebase/src/auth_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      authService = AuthService();
    });
    Uri sendUri = Uri.parse('https://direct.i-dgtl.ru/api/v1/verifier/send');
    Uri verifyUri = Uri.parse('https://direct.i-dgtl.ru/api/v1/verifier/check');

    test('sendPhoneNumber returns uuid on success', () async {
      when(mockHttpClient.post(sendUri, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"uuid": "test-uuid"}', 200));

      final uuid = await authService.sendPhoneNumber('79653210567');

      expect(uuid, 'test-uuid');
    });

    test('sendPhoneNumber throws exception on failure', () async {
      when(mockHttpClient.post(sendUri, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Error', 400));

      expect(() => authService.sendPhoneNumber('79653210567'), throwsException);
    });

    test('verifyCode returns true on success', () async {
      when(mockHttpClient.post(verifyUri, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"status": "CONFIRMED"}', 200));

      final isVerified = await authService.verifyCode('test-uuid', '1234');

      expect(isVerified, true);
    });

    test('verifyCode returns false on failure', () async {
      when(mockHttpClient.post(verifyUri, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"status": "FAILED"}', 200));

      final isVerified = await authService.verifyCode('test-uuid', '1234');

      expect(isVerified, false);
    });

    test('registerUser saves user data on successful verification', () async {
      when(mockHttpClient.post(verifyUri, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"status": "CONFIRMED"}', 200));

      await authService.registerUser('79653210567', 'test-uuid', '1234');

      // Add assertions to verify that user data is saved correctly
    });

    test('registerUser throws exception on failed verification', () async {
      when(mockHttpClient.post(verifyUri, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"status": "FAILED"}', 200));

      expect(() => authService.registerUser('79653210567', 'test-uuid', '1234'), throwsException);
    });
  });
}