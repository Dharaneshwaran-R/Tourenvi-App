import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _selectedFilter = 'All';

  // Simulated users
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Priya Sharma',
      'email': 'priya@gmail.com',
      'role': 'end_user',
      'trips': 12,
      'joined': 'Jan 2026',
      'status': 'active',
    },
    {
      'name': 'Rahul Kumar',
      'email': 'rahul.k@gmail.com',
      'role': 'end_user',
      'trips': 5,
      'joined': 'Feb 2026',
      'status': 'active',
    },
    {
      'name': 'Meena K',
      'email': 'meena.guide@gmail.com',
      'role': 'local_guide',
      'trips': 0,
      'joined': 'Mar 2026',
      'status': 'active',
    },
    {
      'name': 'Arun Patel',
      'email': 'arun.p@gmail.com',
      'role': 'end_user',
      'trips': 28,
      'joined': 'Dec 2025',
      'status': 'active',
    },
    {
      'name': 'SpamBot123',
      'email': 'spam@fake.com',
      'role': 'end_user',
      'trips': 0,
      'joined': 'Mar 2026',
      'status': 'banned',
    },
    {
      'name': 'Deepa Nair',
      'email': 'deepa.n@gmail.com',
      'role': 'support_team',
      'trips': 0,
      'joined': 'Jan 2026',
      'status': 'active',
    },
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    if (_selectedFilter == 'All') return _users;
    if (_selectedFilter == 'Banned') {
      return _users.where((u) => u['status'] == 'banned').toList();
    }
    final roleMap = {
      'Users': 'end_user',
      'Guides': 'local_guide',
      'Support': 'support_team',
    };
    return _users.where((u) => u['role'] == roleMap[_selectedFilter]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Users',
          style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Search users...',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Users', 'Guides', 'Support', 'Banned']
                  .map((f) => _buildFilterChip(f))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Users list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return _UserCard(
                  data: user,
                  onRoleChange: (newRole) {
                    setState(() {
                      final idx = _users.indexOf(user);
                      if (idx != -1) _users[idx]['role'] = newRole;
                    });
                  },
                  onToggleBan: () {
                    setState(() {
                      final idx = _users.indexOf(user);
                      if (idx != -1) {
                        _users[idx]['status'] =
                            _users[idx]['status'] == 'banned' ? 'active' : 'banned';
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipActive : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen.withValues(alpha: 0.5)
                : AppColors.borderGreen.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(String) onRoleChange;
  final VoidCallback onToggleBan;

  const _UserCard({
    required this.data,
    required this.onRoleChange,
    required this.onToggleBan,
  });

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.orange;
      case 'local_guide':
        return const Color(0xFF60A5FA);
      case 'support_team':
        return const Color(0xFFA78BFA);
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'local_guide':
        return 'Guide';
      case 'support_team':
        return 'Support';
      default:
        return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBanned = data['status'] == 'banned';
    final roleColor = _getRoleColor(data['role']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBanned ? AppColors.danger.withValues(alpha: 0.05) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBanned
              ? AppColors.danger.withValues(alpha: 0.2)
              : AppColors.borderGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: roleColor.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                data['name'][0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: roleColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data['name'],
                      style: TextStyle(
                        color: isBanned ? AppColors.textSecondary : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: isBanned ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isBanned
                            ? AppColors.danger.withValues(alpha: 0.15)
                            : roleColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBanned ? 'Banned' : _getRoleLabel(data['role']),
                        style: TextStyle(
                          color: isBanned ? AppColors.danger : roleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${data['email']} · ${data['trips']} trips · ${data['joined']}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'role_user',
                child: _popupItem(Icons.person_rounded, 'Set as User'),
              ),
              PopupMenuItem(
                value: 'role_guide',
                child: _popupItem(Icons.tour_rounded, 'Set as Guide'),
              ),
              PopupMenuItem(
                value: 'role_support',
                child: _popupItem(Icons.support_agent_rounded, 'Set as Support'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'ban',
                child: _popupItem(
                  isBanned ? Icons.check_circle_rounded : Icons.block_rounded,
                  isBanned ? 'Unban User' : 'Ban User',
                  color: isBanned ? AppColors.primaryGreen : AppColors.danger,
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'ban') {
                onToggleBan();
              } else if (value == 'role_user') {
                onRoleChange('end_user');
              } else if (value == 'role_guide') {
                onRoleChange('local_guide');
              } else if (value == 'role_support') {
                onRoleChange('support_team');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _popupItem(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color ?? Colors.white, fontSize: 13)),
      ],
    );
  }
}
