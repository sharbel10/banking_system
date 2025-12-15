sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  });
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) =>
      success(data);
}

final class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) =>
      failure(message);
}
