import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({Key? key}) : super(key: key);

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
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_username != null) Text('Username: $_username'),
          if (_correo != null) Text('Correo: $_correo'),
          if (_rol != null) Text('Rol: $_rol'),
        ],
      ),
    );
  }
}
