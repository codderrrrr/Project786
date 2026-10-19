class AppError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  AppError(this.code, this.message, [this.details]);
}

class ApiError extends AppError {
  ApiError(super.code, super.message, [super.details]);
}

class BusinessError extends AppError {
  BusinessError(super.code, super.message, [super.details]);
}
