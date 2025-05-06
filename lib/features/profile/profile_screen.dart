import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // Если null - текущий пользователь

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
  }

  class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCurrentUser = widget.userId == null || widget.userId == currentUserId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.goNamed('edit_profile'),
              tooltip: 'Редактировать профиль',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                context.go('/login'); // Adjust the route as needed
              },
              tooltip: 'Выйти',
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId ?? currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Профиль не найден'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return _ProfileView(userData: userData, isCurrentUser: isCurrentUser);
        },
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool isCurrentUser;

  const _ProfileView({required this.userData, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final birthday = (userData['birthday'] as Timestamp).toDate();
    final createdAt = (userData['created_at'] as Timestamp).toDate();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватар
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: userData['photoUrl'] != null
                  ? NetworkImage(userData['photoUrl'] as String)
                  : null,
              child: userData['photoUrl'] == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          // Основная информация
          _ProfileInfoItem(
            icon: Icons.person,
            title: 'Имя',
            value: '${userData['name']} ${userData['surname']}',
          ),
          _ProfileInfoItem(
            icon: Icons.phone,
            title: 'Телефон',
            value: _formatPhone(userData['phone'] as String),
          ),
          _ProfileInfoItem(
            icon: Icons.email,
            title: 'Email',
            value: userData['email_address'] as String,
          ),
          _ProfileInfoItem(
            icon: Icons.cake,
            title: 'Дата рождения',
            value: DateFormat('dd.MM.yyyy').format(birthday),
          ),
          _ProfileInfoItem(
            icon: Icons.work,
            title: 'Роль',
            value: userData['role'] as String,
          ),

          // Статистика
          const SizedBox(height: 24),
          const Text(
            'Статистика',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _ProfileInfoItem(
            icon: Icons.help_outline,
            title: 'Помощи оказано',
            value: userData['help_count'].toString(),
          ),
          _ProfileInfoItem(
            icon: Icons.help,
            title: 'Помощи получено',
            value: userData['received_help_count'].toString(),
          ),

          // Мета-информация
          if (isCurrentUser) ...[
            const SizedBox(height: 24),
            const Text(
              'Аккаунт',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ElevatedButton.icon(
              onPressed: () {
                context.goNamed('medical_data');
              },
              icon: const Icon(Icons.medical_information),
              label: const Text('Медицинские данные'),
            ),
            const SizedBox(height: 16),
            _ProfileInfoItem(
              icon: Icons.date_range,
              title: 'Дата регистрации',
              value: DateFormat('dd.MM.yyyy').format(createdAt),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPhone(String phone) {
    if (phone.length == 11) {
      return '+${phone[0]} (${phone.substring(1, 4)}) ${phone.substring(4, 7)}-${phone.substring(7, 9)}-${phone.substring(9)}';
    }
    return phone;
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}