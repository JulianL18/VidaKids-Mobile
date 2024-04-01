import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vida_kids/main.dart';
import 'package:vida_kids/services/serviceapi.dart';

class Donacion {
  final int idDonacion;
  final int idDonante;
  final String tipoDonacion;
  final int cantidad;
  final String tipo;
  final String gramaje;
  final String fechaDonado;
  final String fechaRegistroDonacion;

  Donacion({
    required this.idDonacion,
    required this.idDonante,
    required this.tipoDonacion,
    required this.cantidad,
    required this.tipo,
    required this.gramaje,
    required this.fechaDonado,
    required this.fechaRegistroDonacion,
  });

  factory Donacion.fromJson(Map<String, dynamic> json) {
    return Donacion(
      idDonacion: json['idDonacion'],
      idDonante: json['idDonante'],
      tipoDonacion: json['tipoDonacion'],
      cantidad: json['cantidad'],
      tipo: json['tipo'],
      gramaje: json['gramaje'],
      fechaDonado: json['fechaDonado'],
      fechaRegistroDonacion: json['fechaRegistroDonacion'],
    );
  }
}

Future<List<Donacion>> fetchPosts() async {
  final response = await http
      .get(Uri.parse('https://api-donaciones.onrender.com/donaciones'));

  if (response.statusCode == 200) {
    Map<String, dynamic> responseData = json.decode(response.body);
    List<dynamic> donacionList = responseData['msg'];
    List<Donacion> donacion =
        donacionList.map((json) => Donacion.fromJson(json)).toList();

    return donacion;
  } else {
    throw Exception('Falló la carga de las donaciones.');
  }
}

class ListarScreen extends StatefulWidget {
  const ListarScreen({Key? key}) : super(key: key);

  @override
  State<ListarScreen> createState() => _ListarScreenState();
}

class _ListarScreenState extends State<ListarScreen> {
  late Future<List<Donacion>> futureExports;

  @override
  void initState() {
    super.initState();
    futureExports = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vida Kids',
          style: TextStyle(color: Colors.black, fontSize: 30),
        ),
        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
        leading: Image.asset(
          'assets/images/vidakids-logo.png',
          width: 40,
          height: 40,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Donacion>>(
        future: futureExports,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Donacion> donacion = snapshot.data!;
            return ListView.builder(
              itemCount: donacion.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Registrar(donacion: donacion[index]),
                        ),
                      ).then((value) {
                        setState(() {
                          futureExports = fetchPosts();
                        });
                      });
                    },
                    onLongPress: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Eliminar donación'),
                        content: const Text(
                            '¿Está seguro que desea eliminar esta donación?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancelar'),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final response = await ServiceAPI().delete(
                                  'donaciones/${donacion[index].idDonacion}');
                              Navigator.pop(context, 'Eliminar');
                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Donación eliminada'),
                                  ),
                                );
                                setState(() {
                                  futureExports = fetchPosts();
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error al eliminar'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                        'Id Donación: ${donacion[index].idDonacion.toString()}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Id donante: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${donacion[index].idDonante}\n',
                          ),
                          const TextSpan(
                            text: 'Tipo de donación: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${donacion[index].tipoDonacion}\n',
                          ),
                          const TextSpan(
                            text: 'Cantidad: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (donacion[index].tipoDonacion == 'Dinero')
                            const TextSpan(
                              text: ' \$',
                            ),
                          TextSpan(
                            text: '${donacion[index].cantidad}',
                          ),
                          const TextSpan(
                            text: '\nFecha de donación: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: donacion[index].fechaDonado,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color.fromRGBO(143, 148, 251, 1),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Registrar()),
          ).then((value) {
            setState(() {
              futureExports = fetchPosts();
            });
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.grey,
        child: const Center(
          child: Text(
            'Autor: Julián Lopera',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class Registrar extends StatefulWidget {
  final Donacion? donacion;

  const Registrar({Key? key, this.donacion}) : super(key: key);

  @override
  State<Registrar> createState() => RegistrarState();
}

class RegistrarState extends State<Registrar> {
  TextEditingController idDonacion = TextEditingController();
  TextEditingController idDonante = TextEditingController();
  TextEditingController tipoDonacion = TextEditingController();
  TextEditingController cantidad = TextEditingController();
  TextEditingController tipo = TextEditingController();
  TextEditingController gramaje = TextEditingController();
  TextEditingController fechaDonado =
      TextEditingController(text: DateTime.now().toString().substring(0, 10));
  TextEditingController fechaRegistroDonacion =
      TextEditingController(text: DateTime.now().toString().substring(0, 10));
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> tiposSeleccionados = [
    'Dinero',
    'Alimentos',
    'Viaje',
    'Tratamiento',
    'Medicamentos',
  ];

  Map<String, List<String>> opcionesTipo = {
    'Dinero': ['Efectivo', 'Debito/Credito', 'Transferencia'],
    'Alimentos': ['No perecederos', 'Perecederos'],
    'Viaje': ['Boleto', 'Reserva de hotel', 'Paquete turístico'],
    'Tratamiento': ['Medicamentos', 'Terapias'],
    'Medicamentos': ['Genéricos', 'Marcas']
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.donacion != null) {
      idDonacion.text = widget.donacion!.idDonacion.toString();
      idDonante.text = widget.donacion!.idDonante.toString();
      tipoDonacion.text = widget.donacion!.tipoDonacion;
      cantidad.text = widget.donacion!.cantidad.toString();
      tipo.text = widget.donacion!.tipo;
      gramaje.text = widget.donacion!.gramaje;
      fechaDonado.text = widget.donacion!.fechaDonado;
      fechaRegistroDonacion.text = widget.donacion!.fechaRegistroDonacion;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
            widget.donacion != null ? 'Editar donación' : 'Registrar donación'),
        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
        leading: Image.asset(
          'assets/images/vidakids-logo.png',
          width: 40,
          height: 40,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                controller: idDonacion,
                decoration: const InputDecoration(labelText: 'Id Donación'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el id de la donación';
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                controller: idDonante,
                decoration: const InputDecoration(labelText: 'Id Donante'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el id del donante';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: tipoDonacion.text.isNotEmpty ? tipoDonacion.text : null,
                decoration:
                    const InputDecoration(labelText: 'Tipo de Donación'),
                items: tiposSeleccionados.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    tipoDonacion.text = value!;
                    tipo.text = '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione el tipo de donación';
                  }
                  return null;
                },
              ),
              if (tipoDonacion.text.isNotEmpty &&
                  opcionesTipo.containsKey(tipoDonacion.text))
                DropdownButtonFormField<String>(
                  value: tipo.text.isNotEmpty ? tipo.text : null,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: opcionesTipo[tipoDonacion.text]!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      tipo.text = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione el tipo';
                    }
                    return null;
                  },
                ),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                controller: cantidad,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la cantidad';
                  }
                  return null;
                },
              ),
              if (tipoDonacion.text == 'Alimentos' ||
                  tipoDonacion.text == 'Medicamentos')
                TextFormField(
                  controller: gramaje,
                  decoration: const InputDecoration(labelText: 'Gramaje'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la cantidad';
                    }
                    return null;
                  },
                ),
              if (tipoDonacion.text != 'Alimentos' ||
                  tipoDonacion.text != 'Medicamentos')
                const SizedBox(height: 0), // SizedBox con altura cero
              TextFormField(
                controller: fechaDonado,
                decoration:
                    const InputDecoration(labelText: 'Fecha de donación'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la fecha de la donación';
                  }
                  return null;
                },
                enabled: false,
              ),
              TextFormField(
                controller: fechaRegistroDonacion,
                decoration: const InputDecoration(
                    labelText: 'Fecha de registro de donación'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la fecha del registro de la donación';
                  }
                  return null;
                },
                enabled: false,
              ),
              const SizedBox(height: 20),
              if (widget.donacion == null)
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      var donacion = {
                        "idDonacion": int.parse(idDonacion.text),
                        "idDonante": int.parse(idDonante.text),
                        "tipoDonacion": tipoDonacion.text,
                        "cantidad": int.parse(cantidad.text),
                        "tipo": tipo.text,
                        "gramaje": gramaje.text,
                        "fechaDonado": fechaDonado.text,
                        "fechaRegistroDonacion": fechaRegistroDonacion.text,
                      };
                      ServiceAPI api = ServiceAPI();
                      final response = await api.post('donaciones', donacion);
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Donación registrada')),
                        );
                        Navigator.pop(context); // Close the dialog after adding
                      } else {
                        print('Error al registrar la donación');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromRGBO(143, 148, 251, 1),
                    onPrimary: Colors.black,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Registrar'),
                ),
              if (widget.donacion != null)
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      var updatedDonacion = {
                        "idDonacion": int.parse(idDonacion.text),
                        "idDonante": int.parse(idDonante.text),
                        "tipoDonacion": tipoDonacion.text,
                        "cantidad": int.parse(cantidad.text),
                        "tipo": tipo.text,
                        "gramaje": gramaje.text,
                        "fechaDonado": fechaDonado.text,
                        "fechaRegistroDonacion": fechaRegistroDonacion.text,
                      };
                      ServiceAPI api = ServiceAPI();
                      final response = await api.put(
                          'donaciones/${widget.donacion!.idDonacion}',
                          updatedDonacion);
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Donación actualizada')),
                        );
                        Navigator.pop(context);
                      } else {
                        print('Error al actualizar la donación');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromRGBO(143, 148, 251, 1),
                    onPrimary: Colors.black,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Actualizar'),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.grey,
        child: const Center(
          child: Text(
            'Autor: Julián Lopera',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}