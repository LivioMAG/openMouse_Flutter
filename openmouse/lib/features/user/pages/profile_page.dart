import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/user_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserController>();
    return Card(
      child: ListTile(
        title: const Text('Profil'),
        subtitle: Text(
          'Abo aktiv: ${user.hasSubscription ? 'Ja' : 'Nein'}',
        ),
      ),
    );
  }
}
