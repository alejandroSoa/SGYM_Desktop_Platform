import 'package:flutter/material.dart';
import '../services/UserService.dart';
import '../services/RoleService.dart';
import '../interfaces/user/user_interface.dart';
import '../interfaces/user/role_interface.dart';

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
          users = userData;
          filteredUsers = userData;
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

  Future<void> fetchRoles() async {
    setState(() {
      rolesLoading = true;
    });
    try {
      final fetchedRoles = await RoleService.getRoles();
      print('🟣 Roles obtenidos: $fetchedRoles'); // <-- Consola roles aquí
      setState(() {
        roles = fetchedRoles;
        rolesLoading = false;
      });
    } catch (e) {
      print('💥 Error al obtener roles: $e');
      setState(() {
        roles = [];
        rolesLoading = false;
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
                              content: Text('Usuario no creado'),
                              backgroundColor: Color(0xFFFF617F), // Verde
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

// void _showMockupUserForm(BuildContext context) {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController multilineController = TextEditingController();
//   DateTime? birthDate;
//   TimeOfDay? selectedTime;
//   String? gender;
//   int? selectedRoleId;
//   bool isActive = true;
//   bool checkValue = false;
//   double sliderValue = 50;
//   int radioValue = 1;
//   int stepIndex = 0;

//   showDialog(
//     context: context,
//     builder: (context) => StatefulBuilder(
//       builder: (context, setDialogState) => AlertDialog(
//         title: Text('Mockup Formulario'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Foto de perfil (solo mockup)
//               CircleAvatar(
//                 radius: 32,
//                 backgroundColor: Colors.grey[300],
//                 child: Icon(Icons.person, size: 40, color: Colors.grey[700]),
//               ),
//               SizedBox(height: 16),
//               // TextField simple
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
//               ),
//               SizedBox(height: 16),
//               // TextField multilinea
//               TextField(
//                 controller: multilineController,
//                 decoration: InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
//                 maxLines: 3,
//               ),
//               SizedBox(height: 16),
//               // TextField email
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               SizedBox(height: 16),
//               // TextField password
//               TextField(
//                 controller: passwordController,
//                 decoration: InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
//                 obscureText: true,
//               ),
//               SizedBox(height: 16),
//               // TextField phone
//               TextField(
//                 controller: phoneController,
//                 decoration: InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: 16),
//               // DropdownButtonFormField
//               DropdownButtonFormField<String>(
//                 value: gender,
//                 decoration: InputDecoration(labelText: 'Género', border: OutlineInputBorder()),
//                 items: [
//                   DropdownMenuItem(value: 'M', child: Text('Masculino')),
//                   DropdownMenuItem(value: 'F', child: Text('Femenino')),
//                   DropdownMenuItem(value: 'O', child: Text('Otro')),
//                 ],
//                 onChanged: (value) {
//                   setDialogState(() {
//                     gender = value;
//                   });
//                 },
//               ),
//               SizedBox(height: 16),
//               // Checkbox
//               Row(
//                 children: [
//                   Checkbox(
//                     value: checkValue,
//                     onChanged: (value) {
//                       setDialogState(() {
//                         checkValue = value ?? false;
//                       });
//                     },
//                   ),
//                   Text('Acepto términos y condiciones'),
//                 ],
//               ),
//               SizedBox(height: 16),
//               // Switch
//               Row(
//                 children: [
//                   Text('Estado: '),
//                   Switch(
//                     value: isActive,
//                     onChanged: (value) {
//                       setDialogState(() {
//                         isActive = value;
//                       });
//                     },
//                   ),
//                   Text(isActive ? 'Activo' : 'Inactivo'),
//                 ],
//               ),
//               SizedBox(height: 16),
//               // Radio buttons
//               Row(
//                 children: [
//                   Text('Nivel: '),
//                   Radio<int>(
//                     value: 1,
//                     groupValue: radioValue,
//                     onChanged: (value) {
//                       setDialogState(() {
//                         radioValue = value ?? 1;
//                       });
//                     },
//                   ),
//                   Text('Básico'),
//                   Radio<int>(
//                     value: 2,
//                     groupValue: radioValue,
//                     onChanged: (value) {
//                       setDialogState(() {
//                         radioValue = value ?? 1;
//                       });
//                     },
//                   ),
//                   Text('Avanzado'),
//                 ],
//               ),
//               SizedBox(height: 16),
//               // Slider
//               Row(
//                 children: [
//                   Text('Progreso:'),
//                   Expanded(
//                     child: Slider(
//                       value: sliderValue,
//                       min: 0,
//                       max: 100,
//                       divisions: 10,
//                       label: sliderValue.round().toString(),
//                       onChanged: (value) {
//                         setDialogState(() {
//                           sliderValue = value;
//                         });
//                       },
//                     ),
//                   ),
//                   Text('${sliderValue.round()}%'),
//                 ],
//               ),
//               SizedBox(height: 16),
//               // Date Picker
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(birthDate == null
//                         ? 'Fecha de nacimiento'
//                         : 'Nacimiento: ${birthDate!.toLocal().toString().split(' ')[0]}'),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.calendar_today),
//                     onPressed: () async {
//                       final picked = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime(2000),
//                         firstDate: DateTime(1900),
//                         lastDate: DateTime.now(),
//                       );
//                       if (picked != null) {
//                         setDialogState(() {
//                           birthDate = picked;
//                         });
//                       }
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               // Time Picker
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(selectedTime == null
//                         ? 'Hora preferida'
//                         : 'Hora: ${selectedTime!.format(context)}'),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.access_time),
//                     onPressed: () async {
//                       final picked = await showTimePicker(
//                         context: context,
//                         initialTime: TimeOfDay.now(),
//                       );
//                       if (picked != null) {
//                         setDialogState(() {
//                           selectedTime = picked;
//                         });
//                       }
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               // Stepper simple (solo visual) envuelto en Container con tamaño fijo y centrado
//               Center(
//                 child: Container(
//                   width: 350, // Ajusta el ancho según lo que necesites
//                   height: 220, // Ajusta la altura según lo que necesites
//                   child: Stepper(
//                     currentStep: stepIndex,
//                     onStepTapped: (index) {
//                       setDialogState(() {
//                         stepIndex = index;
//                       });
//                     },
//                     steps: [
//                       Step(title: Text('Paso 1'), content: Text('Contenido del paso 1')),
//                       Step(title: Text('Paso 2'), content: Text('Contenido del paso 2')),
//                       Step(title: Text('Paso 3'), content: Text('Contenido del paso 3')),
//                     ],
//                     controlsBuilder: (context, details) => SizedBox.shrink(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Cerrar'),
//           ),
//         ],
//       ),
//     )
//   );
// }
