class _PipelineException implements Exception {
  final String message;
  const _PipelineException(this.message);
}

void main() {
  try {
    throw const _PipelineException('test message');
  } catch (error) {
    final String message = switch (error) {
      _PipelineException(message: final String msg) => msg,
      _ => 'unknown error',
    };
    print('Result: $message');
  }
}
