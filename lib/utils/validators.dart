 String? validateIpAddress(String? value) {
    final ipAddressRegExp = RegExp(
      r'^(\d{1,3}\.){3}\d{1,3}$',
    );
    if (!ipAddressRegExp.hasMatch(value!)) {
      return 'Enter a valid IP address';
    }

    final segments = value.split('.');
    for (final segment in segments) {
      final intValue = int.tryParse(segment);
      if (intValue == null || intValue < 0 || intValue > 255) {
        return 'Enter a valid IP address';
      }
    }
    return null; // Valid IP address
  }

  String? validatePort(String? value) {
    final port = int.tryParse(value!);
    if (port == null || port < 1 || port > 65535) {
      return 'Enter a valid port number (1-65535)';
    }
    return null; // Valid port number
  }
