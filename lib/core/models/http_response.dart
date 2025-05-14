
class HttpResponse<T> {
  final T? data;
  final int? statusCode;
  final Map<String, String>? headers;

  HttpResponse({
    this.data,
    this.statusCode,
    this.headers,
  });
}
