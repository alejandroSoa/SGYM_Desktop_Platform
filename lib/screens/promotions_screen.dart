import 'package:flutter/material.dart';
import '../services/PromotionService.dart';
import '../interfaces/bussiness/promotion_interface.dart';

class PromotionsScreen extends StatefulWidget {
  @override
  _PromotionsScreenState createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  String _search = '';
  PromotionList? _promotions;
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _discount = 0.0;
  int _membershipId = 0;
  int? _editingId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    setState(() => _loading = true);
    _promotions = await PromotionService.fetchPromotions();
    setState(() => _loading = false);
  }

  void _showForm({Promotion? promotion}) {
    if (promotion != null) {
      _editingId = promotion.id;
      _name = promotion.name;
      _discount = promotion.discount;
      _membershipId = promotion.membershipId;
    } else {
      _editingId = null;
      _name = '';
      _discount = 0.0;
      _membershipId = 0;
    }
    _errorMessage = null;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(_editingId == null ? 'Crear Promoción' : 'Editar Promoción'),
            content: Container(
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                        fillColor: Color(0xFFF2F2FE),
                        filled: true,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => _name = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _discount == 0.0 ? '' : _discount.toString(),
                      decoration: InputDecoration(
                        labelText: 'Descuento (%)',
                        border: OutlineInputBorder(),
                        fillColor: Color(0xFFF2F2FE),
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || double.tryParse(v) == null ? 'Número requerido' : null,
                      onSaved: (v) => _discount = double.tryParse(v ?? '0') ?? 0,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _membershipId == 0 ? '' : _membershipId.toString(),
                      decoration: InputDecoration(
                        labelText: 'ID Membresía',
                        border: OutlineInputBorder(),
                        fillColor: Color(0xFFF2F2FE),
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || int.tryParse(v) == null ? 'Número requerido' : null,
                      onSaved: (v) => _membershipId = int.tryParse(v ?? '0') ?? 0,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7710D4),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();
                  setDialogState(() => _errorMessage = null);
                  Navigator.pop(context);
                  setState(() => _loading = true);
                  try {
                    if (_editingId == null) {
                      final result = await PromotionService.createPromotion(
                        name: _name,
                        discount: _discount,
                        membershipId: _membershipId,
                      );
                      if (result == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al crear promoción'), backgroundColor: Colors.red),
                        );
                      }
                    } else {
                      final result = await PromotionService.updatePromotion(
                        id: _editingId!,
                        name: _name,
                        discount: _discount,
                        membershipId: _membershipId,
                      );
                      if (result == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar promoción'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                  await _fetchPromotions();
                },
                child: Text(_editingId == null ? 'Crear' : 'Actualizar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeletePromotion(Promotion promo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Promoción'),
        content: Text('¿Estás seguro de eliminar la promoción "${promo.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7710D4),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _loading = true);
      final ok = await PromotionService.deletePromotion(promo.id);
      await _fetchPromotions();
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promoción eliminada correctamente'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar promoción'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = (_promotions == null)
        ? []
        : _promotions!.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Barra de búsqueda y botón Añadir
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Buscar',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (val) => setState(() => _search = val),
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
                    onPressed: () => _showForm(),
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
                child: _loading
                    ? Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? Center(child: Text('No hay promociones disponibles'))
                        : Column(
                            children: [
                              // Encabezado
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                child: Row(
                                  children: const [
                                    Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    Expanded(child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    Expanded(child: Text('Descuento (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    Expanded(child: Text('ID Membresía', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    SizedBox(width: 100), // espacio para botones
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Colors.deepPurpleAccent),
                              // Lista
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final promo = filtered[index];
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(promo.id.toString()),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(promo.name),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(promo.discount.toString()),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(promo.membershipId.toString()),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Color(0xFF7710D4)),
                                                  onPressed: () => _showForm(promotion: promo),
                                                  tooltip: 'Editar',
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete),
                                                  onPressed: () => _confirmDeletePromotion(promo),
                                                  tooltip: 'Eliminar',
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
                              // Footer paginación (dummy)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text('1-${filtered.length} de ${filtered.length}', style: TextStyle(color: Colors.deepPurple)),
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
            ),
          ],
        ),
      ),
    );
  }
}
