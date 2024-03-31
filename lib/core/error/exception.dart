class ServerExceptions implements Exception {
  final String excMessage;
  const ServerExceptions([this.excMessage = 'Server exception!']);
}
