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
          ? Center(
              child: users.isEmpty
                  ? Text('No users available') // ข้อความแสดงเมื่อไม่มีผู้ใช้
                  : CircularProgressIndicator(), // แสดงการโหลดข้อมูล
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4,
                  child: ListTile(
                    title: Text('Username: ${users[index].username}'),
                    
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteUser(users[index].username),
                    ),
                    onTap: () {
                      // นำทางไปหน้าแสดงรายละเอียดผู้ใช้
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsPage(user: users[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class UserDetailsPage extends StatefulWidget {
  final User user;

  UserDetailsPage({required this.user});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details: ${widget.user.username}'),
      ),
      body: SingleChildScrollView( // Wrap content in SingleChildScrollView
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
                        SizedBox(width: 10),
                        Text(
                          widget.user.username,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildDetailTile(context, Icons.person, 'Full Name', widget.user.fullName),
                    _buildDetailTile(context, Icons.email, 'Email', widget.user.email),
                    _buildDetailTile(context, Icons.phone, 'Phone Number', widget.user.phoneNumber),
                    _buildDetailTile(context, Icons.home, 'Address', widget.user.address),
                    _buildDetailTile(
                      context,
                      Icons.cake,
                      'Birth Date',
                      widget.user.birthDate?.toLocal().toString().split(' ')[0] ?? 'Not provided',
                    ),
                    _buildPasswordTile(context, Icons.lock, 'Password', widget.user.password),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(BuildContext context, IconData icon, String title, String? detail) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
      leading: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        detail ?? 'Not provided',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPasswordTile(BuildContext context, IconData icon, String title, String password) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
      leading: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              _obscurePassword ? '•' * password.length : password,
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ],
      ),
    );
  }
}