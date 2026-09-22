abstract final class ApiConstants {
  static const baseUrl = 'https://backup.ssd4me.cloud';
  static const notes = '/api/notes';
  static String noteById(String id) => '/api/notes/$id';

  static const timeout = Duration(seconds: 15);

  static const headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
