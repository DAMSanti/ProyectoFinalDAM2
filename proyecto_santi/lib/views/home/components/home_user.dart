import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _username;
  String? _correo;
  String? _rol;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final username = await _storage.read(key: 'username');
    final correo = await _storage.read(key: 'correo');
    final rol = await _storage.read(key: 'rol');

    setState(() {
      _username = username;
      _correo = correo;
      _rol = rol;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_username != null) Text('$_username', style: Theme.of(context).textTheme.titleMedium?.copyWith(inherit: true)),
            if (_correo != null)  Text('$_correo', style: Theme.of(context).textTheme.bodyMedium?.copyWith(inherit: true)),
            if (_rol != null) Text('$_rol', style: Theme.of(context).textTheme.bodySmall?.copyWith(inherit: true)),
          ],
        ),
      ),
    );
  }
}