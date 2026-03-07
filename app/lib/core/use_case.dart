abstract class UseCase<R, P> {
  R call(P params);
}

abstract class AsyncUseCase<R, P> {
  Future<R> call(P params);
}

class NoParams {
  const NoParams();
}
