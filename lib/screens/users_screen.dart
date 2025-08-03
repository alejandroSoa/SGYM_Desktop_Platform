import 'package:flutter/material.dart';
import '../services/UserService.dart';
import '../services/RoleService.dart';
import '../interfaces/user/user_interface.dart';
import '../interfaces/user/profile_interface.dart';
import '../interfaces/user/role_interface.dart';
import '../services/ProfileService.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usuarios',
      debugShowCheckedModeBanner: false,
      home: const UsersScreen(),
    );
  }
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Valida el formato de email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    return emailRegex.hasMatch(email);
  }
  UserList users = [];
  UserList filteredUsers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> roles = [];
  bool rolesLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(_onSearchChanged);
    fetchRoles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        return user.email.toLowerCase().contains(query) ||
            user.id.toString().contains(query);
      }).toList();
    });
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedUsers = await UserService.fetchUser();
      setState(() {
        users = fetchedUsers as UserList;
        filteredUsers = fetchedUsers as UserList;
      });
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRoles() async {
    setState(() {
      rolesLoading = true;
    });
    try {
      final fetchedRoles = await RoleService.getRoles();
      setState(() {
        roles = fetchedRoles;
      });
    } catch (e) {
      print('Error fetching roles: $e');
    } finally {
      setState(() {
        rolesLoading = false;
      });
    }
  }

  void _showEditUserDialog(user) {
    final emailController = TextEditingController(text: user.email);
    int selectedRoleId = user.roleId;
    bool isActive = user.isActive;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Editar Usuario'),
          content: Container(
            width: 400,
            child: rolesLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFF2F2FE),
                          filled: true,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: roles.any((role) => role['id'] == selectedRoleId)
                            ? selectedRoleId
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFF2F2FE),
                          filled: true,
                        ),
                        items: roles.map((role) {
                          return DropdownMenuItem<int>(
                            value: role['id'],
                            child: Text(role['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedRoleId = value ?? user.roleId;
                          });
                        },
                        hint: roles.isEmpty
                            ? Text('No hay roles disponibles')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Estado: '),
                          Switch(
                            value: isActive,
                            onChanged: (value) {
                              setDialogState(() {
                                isActive = value;
                              });
                            },
                          ),
                          Text(isActive ? 'Activo' : 'Inactivo'),
                        ],
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Color(0xFFFF617F)),
                          ),
                        ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7710D4),
                foregroundColor: Colors.white,
              ),
              onPressed: rolesLoading
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty) {
                        setDialogState(() {
                          errorMessage = 'El email no puede estar vacío';
                        });
                        return;
                      }
                      if (!_isValidEmail(email)) {
                        setDialogState(() {
                          errorMessage = 'El email no es válido';
                        });
                        return;
                      }
                      if (selectedRoleId == 0) {
                        setDialogState(() {
                          errorMessage = 'Rol inválido';
                        });
                        return;
                      }
                      setDialogState(() {
                        errorMessage = null;
                      });
                      await _updateUser(
                        user.id,
                        email,
                        selectedRoleId,
                        isActive,
                      );
                      Navigator.of(context).pop();
                    },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

void _showEditProfileDialog(Profile profile, int userId) {
  final nameController = TextEditingController(text: profile.fullName);
  final phoneController = TextEditingController(text: profile.phone);
  final birthDateController = TextEditingController(text: profile.birthDate);
  String gender = profile.gender ?? 'Otro';
  String? errorMessage;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Editar perfil'),
        content: Container(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFFF2F2FE),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFFF2F2FE),
                    filled: true,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de nacimiento (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFFF2F2FE),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Masculino')),
                    DropdownMenuItem(value: 'F', child: Text('Femenino')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      gender = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Género',
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFFF2F2FE),
                    filled: true,
                  ),
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Color(0xFFFF617F)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final fullName = nameController.text.trim();
              final phone = phoneController.text.trim();
              final birthDate = birthDateController.text.trim();

              if (fullName.isEmpty || phone.isEmpty || birthDate.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Todos los campos son obligatorios.';
                });
                return;
              }

              setDialogState(() {
                errorMessage = null;
              });

              try {
                final updatedProfile = await ProfileService.updateProfile(
                  profile,
                  fullName: fullName,
                  phone: phone,
                  birthDate: birthDate,
                  gender: gender,
                  userId: userId,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Perfil actualizado correctamente'),
                    backgroundColor: Color.fromARGB(255, 16, 212, 58),
                  ),
                );
                Navigator.of(context).pop();
              } catch (e) {
                print('Error actualizando el perfil: $e');
                setDialogState(() {
                  errorMessage = 'Error al actualizar perfil';
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7710D4),
              foregroundColor: Colors.white,
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}




  Future<void> _updateUser(int userId, String email, int roleId, bool isActive) async {
    try {
      final result = await UserService.updateUser(
        userId: userId,
        email: email,
        roleId: roleId,
        isActive: isActive,
      );

      if (result != null) {
        print('✅ User updated successfully');
        // Refresh the users list
        await fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario actualizado exitosamente'),
          backgroundColor: Color.fromARGB(255, 16, 212, 58)
        ));
      } else {
        print('❌ Failed to update user');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFFFF617F), // Fondo rojito
            content: Text(
              'Error al actualizar usuario',
              style: TextStyle(color: Colors.black), // Texto negro
            ),
          ),
        );
      }
    } catch (e) {
      print('💥 Error updating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFFFF617F), // Fondo rojito
          content: Text(
            'Error: $e',
            style: TextStyle(color: Colors.black), // Texto negro
          ),
        ),
      );
    }
  }

  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final passwordConfirmController = TextEditingController();
    int? selectedRoleId = roles.isNotEmpty ? roles.first['id'] : null;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Crear Usuario'),
          content: Container(
            width: 400,
            child: rolesLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFF2F2FE),
                          filled: true,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFF2F2FE),
                          filled: true,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordConfirmController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFF2F2FE),
                          filled: true,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedRoleId,
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFF2F2FE),
                          filled: true,
                        ),
                        items: roles.map((role) {
                          return DropdownMenuItem<int>(
                            value: role['id'],
                            child: Text(role['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedRoleId = value;
                          });
                        },
                        hint: roles.isEmpty
                            ? Text('No hay roles disponibles')
                            : null,
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Color(0xFFFF617F)),
                          ),
                        ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7710D4),
                foregroundColor: Colors.white,
              ),
              onPressed: rolesLoading
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty) {
                        setDialogState(() {
                          errorMessage = 'El email no puede estar vacío';
                        });
                        return;
                      }
                      if (!_isValidEmail(email)) {
                        setDialogState(() {
                          errorMessage = 'El email no es válido';
                        });
                        return;
                      }
                      if (passwordController.text.trim().isEmpty) {
                        setDialogState(() {
                          errorMessage = 'La contraseña no puede estar vacía';
                        });
                        return;
                      }
                      if (passwordController.text != passwordConfirmController.text) {
                        setDialogState(() {
                          errorMessage = 'Las contraseñas no coinciden';
                        });
                        return;
                      }
                      if (selectedRoleId == null || selectedRoleId == 0) {
                        setDialogState(() {
                          errorMessage = 'Rol inválido';
                        });
                        return;
                      }
                      setDialogState(() {
                        errorMessage = null;
                      });

                      final result = await UserService.createUser(
                        email: email,
                        password: passwordController.text,
                        passwordConfirmation: passwordConfirmController.text,
                        roleId: selectedRoleId!,
                      );

                      if (result != null) {
                        await fetchUsers();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Usuario creado correctamente'),
                            backgroundColor: Color.fromARGB(255, 16, 212, 58),
                          ),
                        );
                      } else {
                        setDialogState(() {
                          errorMessage = 'Error al crear usuario';
                        });
                      }
                    },
              child: Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Barra de búsqueda y botón Añadir en la misma fila, estilo ejercicios
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar',
                        prefixIcon: Icon(Icons.search),
                        // Sin borde exterior, estilo ejercicios
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Añadir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7710D4),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showCreateUserDialog(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  border: Border.all(color: Color(0xFF7A5AF8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Encabezado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: const [
                          Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          Expanded(child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          Expanded(child: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          Expanded(child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          Expanded(child: Text('Fecha Creación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          SizedBox(width: 100), // espacio para botones
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.deepPurpleAccent),
                    // Lista
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredUsers.isEmpty
                              ? const Center(child: Text('No hay usuarios disponibles'))
                              : ListView.builder(
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = filteredUsers[index];
                                    // Buscar el nombre del rol por id
                                    final roleName = roles.firstWhere(
                                      (role) => role['id'] == user.roleId,
                                      orElse: () => {'name': user.roleId.toString()},
                                    )['name'] ?? user.roleId.toString();
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(user.id.toString()),
                                            )),
                                            Expanded(child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(user.email),
                                            )),
                                            Expanded(child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(roleName),
                                            )),
                                            Expanded(child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(user.isActive ? 'Activo' : 'Inactivo'),
                                            )),
                                            Expanded(child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(user.lastAccess?.substring(0, 10) ?? 'N/A'),
                                            )),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit),
                                                  onPressed: () {
                                                    try {
                                                      _showEditUserDialog(user);
                                                    } catch (e) {
                                                      print('💥 Error al mostrar mockup: $e');
                                                    }
                                                  },
                                                ),
                                               IconButton(
                                                icon: const Icon(Icons.account_circle, color: Colors.deepPurple),
                                                tooltip: 'Editar perfil',
                                                onPressed: () async {
                                                  final profile = await ProfileService.fetchProfileByUserId(user.id);
                                                  if (profile == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('No se pudo cargar el perfil de este usuario'),
                                                              backgroundColor: Color(0xFFFF617F)),
                                                    );
                                                    return;
                                                  }

                                                  _showEditProfileDialog(profile, user.id);
                                                },
                                              ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete),
                                                  onPressed: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: Text('Eliminar usuario'),
                                                        content: Text('¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(false),
                                                            child: Text('Cancelar'),
                                                          ),
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Color(0xFF7710D4),
                                                              foregroundColor: Colors.white,
                                                            ),
                                                            onPressed: () => Navigator.of(context).pop(true),
                                                            child: Text('Eliminar'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      final success = await UserService.deleteUser(user.id);
                                                      if (success) {
                                                        await fetchUsers();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Usuario eliminado correctamente'),
                                                                  backgroundColor: Color.fromARGB(255, 16, 212, 58)
),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            backgroundColor: Color(0xFFFF617F),
                                                            content: Text(
                                                              'Error al eliminar usuario',
                                                              style: TextStyle(color: Colors.black),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 1, color: Colors.deepPurpleAccent),
                                      ],
                                    );
                                  },
                                ),
                    ),
                    // Footer paginación
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text('1-${users.length} of ${users.length}', style: TextStyle(color: Colors.deepPurple)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.first_page, color: Colors.deepPurple),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.deepPurple),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.deepPurple),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page, color: Colors.deepPurple),
                            onPressed: () {},
                          ),                         
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.deepPurple),
                            onPressed: () {}, 
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page, color: Colors.deepPurple),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}