abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super("Jaringan bermasalah Silakan periksa koneksi internet Anda.");
}

class ServerFailure extends Failure {
  const ServerFailure() : super("Server sedang mengalami masalah. Silakan coba lagi nanti.");
}

class NotFoundFailure extends Failure {
  const NotFoundFailure() : super("Kota tidak ditemukan.");
}

class ParsingFailure extends Failure {
  const ParsingFailure() : super("Terjadi kesalahan saat memproses data.");
}