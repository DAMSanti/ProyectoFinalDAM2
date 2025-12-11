import 'dart:async' as _i4;
import 'package:dio/dio.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:proyecto_santi/services/api_service.dart' as _i3;
class _FakeDio_0 extends _i1.SmartFake implements _i2.Dio {
  _FakeDio_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}
class _FakeResponse_1<T> extends _i1.SmartFake implements _i2.Response<T> {
  _FakeResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}
class MockApiService extends _i1.Mock implements _i3.ApiService {
  MockApiService() {
    _i1.throwOnMissingStub(this);
  }
  @override
  _i2.Dio get dio => (super.noSuchMethod(
        Invocation.getter(
        returnValue: _FakeDio_0(
          this,
          Invocation.getter(
        ),
      ) as _i2.Dio);
  @override
  void setToken(String? token) => super.noSuchMethod(
        Invocation.method(
          [token],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i4.Future<_i2.Response<dynamic>> getData(String? endpoint) =>
      (super.noSuchMethod(
        Invocation.method(
          [endpoint],
        ),
        returnValue:
            _i4.Future<_i2.Response<dynamic>>.value(_FakeResponse_1<dynamic>(
          this,
          Invocation.method(
            [endpoint],
          ),
        )),
      ) as _i4.Future<_i2.Response<dynamic>>);
  @override
  _i4.Future<_i2.Response<dynamic>> postData(
    String? endpoint,
    Map<String, dynamic>? data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          [
            endpoint,
            data,
          ],
        ),
        returnValue:
            _i4.Future<_i2.Response<dynamic>>.value(_FakeResponse_1<dynamic>(
          this,
          Invocation.method(
            [
              endpoint,
              data,
            ],
          ),
        )),
      ) as _i4.Future<_i2.Response<dynamic>>);
  @override
  _i4.Future<_i2.Response<dynamic>> putData(
    String? endpoint,
    Map<String, dynamic>? data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          [
            endpoint,
            data,
          ],
        ),
        returnValue:
            _i4.Future<_i2.Response<dynamic>>.value(_FakeResponse_1<dynamic>(
          this,
          Invocation.method(
            [
              endpoint,
              data,
            ],
          ),
        )),
      ) as _i4.Future<_i2.Response<dynamic>>);
  @override
  _i4.Future<_i2.Response<dynamic>> put(
    String? endpoint,
    dynamic data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          [
            endpoint,
            data,
          ],
        ),
        returnValue:
            _i4.Future<_i2.Response<dynamic>>.value(_FakeResponse_1<dynamic>(
          this,
          Invocation.method(
            [
              endpoint,
              data,
            ],
          ),
        )),
      ) as _i4.Future<_i2.Response<dynamic>>);
  @override
  _i4.Future<_i2.Response<dynamic>> deleteData(String? endpoint) =>
      (super.noSuchMethod(
        Invocation.method(
          [endpoint],
        ),
        returnValue:
            _i4.Future<_i2.Response<dynamic>>.value(_FakeResponse_1<dynamic>(
          this,
          Invocation.method(
            [endpoint],
          ),
        )),
      ) as _i4.Future<_i2.Response<dynamic>>);
}