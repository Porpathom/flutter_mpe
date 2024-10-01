import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  User? currentUser;
  bool isEditing = false;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  DateTime? selectedDate;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      List<User> users = await _authService.getAllUsers();
      if (users.isNotEmpty) {
        currentUser = users.first;
        
        usernameController.text = currentUser?.username ?? '';
        emailController.text = currentUser?.email ?? '';
        fullNameController.text = currentUser?.fullName ?? '';
        phoneController.text = currentUser?.phoneNumber ?? '';
        addressController.text = currentUser?.address ?? '';
        selectedDate = currentUser?.birthDate;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                if (_formKey.currentState?.validate() ?? false) {
                  _saveProfile();
                }
              }
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : currentUser == null
                  ? Text('ไม่พบข้อมูลผู้ใช้')
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Icon(Icons.person, size: 80, color: Theme.of(context).primaryColor),
                              SizedBox(height: 30),
                              Text(
                                'Profile Information',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 30),
                              _buildProfileField(
                                'Username',
                                usernameController,
                                Icons.person,
                                enabled: false,
                              ),
                              SizedBox(height: 15),
                              _buildProfileField(
                                'Email',
                                emailController,
                                Icons.email,
                                enabled: isEditing,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return null;
                                  if (!value!.contains('@')) return 'อีเมลไม่ถูกต้อง';
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              _buildProfileField(
                                'Full Name',
                                fullNameController,
                                Icons.person,
                                enabled: isEditing,
                              ),
                              SizedBox(height: 15),
                              _buildProfileField(
                                'Phone Number',
                                phoneController,
                                Icons.phone,
                                enabled: isEditing,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return null;
                                  if (value!.length < 10) return 'เบอร์โทรศัพท์ไม่ถูกต้อง';
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              _buildProfileField(
                                'Address',
                                addressController,
                                Icons.home,
                                enabled: isEditing,
                                maxLines: 3,
                              ),
                              SizedBox(height: 15),
                              _buildDatePicker(context),
                              SizedBox(height: 25),
                              isEditing
                                  ? ElevatedButton(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16.0),
                                        child: Text('Save Changes', style: TextStyle(fontSize: 18)),
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          _saveProfile();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
  
  Widget _buildProfileField(String label, TextEditingController controller, IconData icon, {bool enabled = true, String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enabled: isEditing,
      onTap: isEditing ? () => _selectBirthDate(context) : null,
      decoration: InputDecoration(
        labelText: selectedDate == null ? 'Birth Date' : DateFormat('dd/MM/yyyy').format(selectedDate!),
        prefixIcon: Icon(Icons.cake),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) => selectedDate == null ? 'Select your birth date' : null,
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveProfile() async {
    if (currentUser == null) return;

    User updatedUser = User(
      username: currentUser!.username,
      password: currentUser!.password,
      email: emailController.text.isEmpty ? null : emailController.text,
      fullName: fullNameController.text.isEmpty ? null : fullNameController.text,
      phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
      address: addressController.text.isEmpty ? null : addressController.text,
      birthDate: selectedDate,
    );
    
    try {
      bool success = await _authService.register(
        updatedUser.username,
        updatedUser.password,
        email: updatedUser.email,
        fullName: updatedUser.fullName,
        phoneNumber: updatedUser.phoneNumber,
        address: updatedUser.address,
        birthDate: updatedUser.birthDate,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
        );
        setState(() {
          currentUser = updatedUser;
          isEditing = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
      );
    }
  }
}