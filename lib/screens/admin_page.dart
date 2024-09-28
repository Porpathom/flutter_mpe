import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'login_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AuthService _authService = AuthService();
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // โหลดรายชื่อผู้ใช้ทั้งหมดจาก AuthService
  void _loadUsers() async {
    List<User> loadedUsers = await _authService.getAllUsers();
    setState(() {
      users = loadedUsers;
    });
  }

  // ลบผู้ใช้
  void _deleteUser(String username) async {
    bool success = await _authService.deleteAccount(username);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User $username deleted successfully')),
      );
      _loadUsers(); // โหลดรายชื่อผู้ใช้ใหม่
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user $username')),
      );
    }
  }

  // ออกจากระบบ
  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // นำทางไปหน้า LoginPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout, // เรียกใช้งานฟังก์ชัน logout
          ),
        ],
      ),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator()) // แสดงการโหลดข้อมูล
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4,
                  child: ListTile(
                    title: Text('Username: ${users[index].username}'),
                    subtitle: Text('Password: ${users[index].password}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteUser(users[index].username),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
