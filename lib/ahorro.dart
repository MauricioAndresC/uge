import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar el paquete intl

class IneficienteScreen extends StatefulWidget {
  @override
  _IneficienteScreenState createState() => _IneficienteScreenState();
}

class _IneficienteScreenState extends State<IneficienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroBombasController = TextEditingController();
  final _potenciaPromedioController = TextEditingController();
  final _eficienciaPromedioController = TextEditingController();
  final _nuevaEficienciaController = TextEditingController();
  final _horasOperacionController = TextEditingController();
  final _costoKwhController = TextEditingController();
  String _resultText = '';

  void _calculate() {
    // Oculta el teclado
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      try {
        // Obtiene los valores del formulario
        int numeroBombas = int.parse(_numeroBombasController.text);
        double potenciaPromedio = double.parse(_potenciaPromedioController.text);
        double eficienciaPromedio = double.parse(_eficienciaPromedioController.text);
        double nuevaEficiencia = double.parse(_nuevaEficienciaController.text);
        double horasOperacion = double.parse(_horasOperacionController.text);
        double costoKwh = double.parse(_costoKwhController.text);

        // Debugging print statements
        print('Número de bombas: $numeroBombas');
        print('Potencia promedio: $potenciaPromedio');
        print('Eficiencia promedio: $eficienciaPromedio');
        print('Nueva eficiencia: $nuevaEficiencia');
        print('Horas de operación: $horasOperacion');
        print('Costo KWh: $costoKwh');

        // Realiza los cálculos
        double baseCalculoK = numeroBombas * potenciaPromedio * 0.746 * 0.6666666667;
        double calculoP2 = (baseCalculoK * eficienciaPromedio) / nuevaEficiencia;
        double resultadoFinal = (baseCalculoK - calculoP2) * horasOperacion * costoKwh;

        String resultadoFinalFormateado = NumberFormat('#,##0.00', 'es_CO').format(resultadoFinal);

        // Actualiza el estado con el resultado
        setState(() {
          _resultText = "El ahorro anual estimado es: ${resultadoFinalFormateado} COP";
        });
      } catch (e) {
        print("Error: $e");
        setState(() {
          _resultText = "Hubo un error al calcular. Verifique los valores ingresados.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Motobombas Ineficientes'),
        backgroundColor: const Color.fromARGB(255, 113, 177, 230),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Imagen en el encabezado
              Container(
                width: double.infinity,
                child: Image.asset('images/ahorro.png', fit: BoxFit.cover),
              ),
              SizedBox(height: 16.0),
              _buildTextField(_numeroBombasController, 'Número de bombas en planta', TextInputType.number),
              _buildTextField(_potenciaPromedioController, 'Potencia promedio (Hp)', TextInputType.number),
              _buildTextField(_eficienciaPromedioController, 'Eficiencia promedio (%)', TextInputType.number),
              _buildTextField(_nuevaEficienciaController, 'Nueva eficiencia (%)', TextInputType.number),
              _buildTextField(_horasOperacionController, 'Horas de operación', TextInputType.number),
              _buildTextField(_costoKwhController, 'Costo Kw-h', TextInputType.number),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: _calculate,
                  child: Text('Calcular', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 54, 244, 139),
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                _resultText,
                style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType inputType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          labelStyle: TextStyle(fontSize: 16.0),
        ),
        keyboardType: inputType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, complete este campo';
          }
          return null;
        },
      ),
    );
  }
}
