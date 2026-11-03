import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.']);
}

class ErrorHandler {
  static Failure handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure('Hết thời gian chờ kết nối. Vui lòng kiểm tra đường truyền.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Đã có lỗi xảy ra từ máy chủ.';
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
        if (status == 401 || status == 403) {
          return AuthFailure(message);
        }
        return ServerFailure(message, statusCode: status);
      case DioExceptionType.cancel:
        return const ServerFailure('Yêu cầu đã bị hủy.');
      default:
        return ServerFailure(error.message ?? 'Đã xảy ra lỗi không xác định.');
    }
  }
}
