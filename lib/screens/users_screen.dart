import 'package:flutter/material.dart';
import '../services/UserService.dart';
import '../interfaces/user/user_interface.dart';

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
  UserList users = [];
  UserList filteredUsers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    print('🚀 Starting to fetch users...');

    try {
      final userData = await UserService.fetchUser();
      
      print('📥 Received userData: $userData');
      print('📥 UserData type: ${userData.runtimeType}');
      
      if (userData != null && userData is UserList) {
        print('✅ Successfully got ${userData.length} users');
        setState(() {
          users = userData as UserList;
          filteredUsers = userData as UserList;
          isLoading = false;
        });
      } else {
        print('❌ No users received or wrong format');
        setState(() {
          users = [];
          filteredUsers = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('💥 Error fetching users: $e');
      setState(() {
        users = [];
        filteredUsers = [];
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredUsers = users;
      } else {
        filteredUsers = users.where((u) => u.email.toLowerCase().contains(query)).toList();
      }
    });
  }

  void _showEditUserDialog(User user) {
    final emailController = TextEditingController(text: user.email);
    final roleController = TextEditingController(text: user.roleId.toString());
    bool isActive = user.isActive;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white, // Formulario blanco
          title: Text('Editar Usuario'),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFFF2F2FE), // Fondo campo #F2F2FE
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                    labelText: 'Rol ID',
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFFF2F2FE), // Fondo campo #F2F2FE
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
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
                      style: TextStyle(color: Color(0xFFFF617F)), // Mensaje de error color #FF617F
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
                backgroundColor: Color(0xFF7710D4), // Botón guardar color #7710D4
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Validación simple
                if (emailController.text.trim().isEmpty) {
                  setDialogState(() {
                    errorMessage = 'El email no puede estar vacío';
                  });
                  return;
                }
                if (roleController.text.trim().isEmpty || int.tryParse(roleController.text) == null) {
                  setDialogState(() {
                    errorMessage = 'Rol ID inválido';
                  });
                  return;
                }
                setDialogState(() {
                  errorMessage = null;
                });
                await _updateUser(
                  user.id,
                  emailController.text,
                  int.tryParse(roleController.text) ?? user.roleId,
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
          SnackBar(content: Text('Usuario actualizado exitosamente')),
        );
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
    final roleController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Crear Usuario'),
          content: Container(
            width: 400,
            child: Column(
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
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                    labelText: 'Rol ID',
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFFF2F2FE),
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
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
              onPressed: () async {
                // Validación simple
                if (emailController.text.trim().isEmpty) {
                  setDialogState(() {
                    errorMessage = 'El email no puede estar vacío';
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
                if (roleController.text.trim().isEmpty || int.tryParse(roleController.text) == null) {
                  setDialogState(() {
                    errorMessage = 'Rol ID inválido';
                  });
                  return;
                }
                setDialogState(() {
                  errorMessage = null;
                });

                final result = await UserService.createUser(
                  email: emailController.text,
                  password: passwordController.text,
                  passwordConfirmation: passwordConfirmController.text,
                  roleId: int.parse(roleController.text),
                );

                if (result != null) {
                  await fetchUsers();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Usuario creado exitosamente')),
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
                                              child: Text(user.roleId.toString()),
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
                                                  onPressed: () => _showEditUserDialog(user),
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
                                                          SnackBar(content: Text('Usuario eliminado correctamente')),
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
