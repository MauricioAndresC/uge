import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar el paquete intl

class FriccionActivity extends StatefulWidget {
  @override
  _FriccionActivityState createState() => _FriccionActivityState();
}

class _FriccionActivityState extends State<FriccionActivity> {
  final _formKey = GlobalKey<FormState>();
  final _caudalController = TextEditingController();
  final _presionP1Controller = TextEditingController();
  final _presionP2Controller = TextEditingController();
  final _alturaEntrePuntosController = TextEditingController();
  final _eficienciaBombaController = TextEditingController();
  final _horasOperacionController = TextEditingController();
  final _costoKwhController = TextEditingController();
  String _resultText = '';

  void _calculate() {
    // Oculta el teclado
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      try {
        double caudal = double.parse(_caudalController.text);
        double presionP1 = double.parse(_presionP1Controller.text);
        double presionP2 = double.parse(_presionP2Controller.text);
        double alturaEntrePuntos = double.parse(_alturaEntrePuntosController.text);
        double eficienciaBomba = double.parse(_eficienciaBombaController.text);
        double horasOperacion = double.parse(_horasOperacionController.text);
        double costoKwh = double.parse(_costoKwhController.text);

        // Debugging print statements
        print('Caudal: $caudal');
        print('Presión P1: $presionP1');
        print('Presión P2: $presionP2');
        print('Altura Entre Puntos: $alturaEntrePuntos');
        print('Eficiencia Bomba: $eficienciaBomba');
        print('Horas Operación: $horasOperacion');
        print('Costo KWh: $costoKwh');

        double presionIdeal = (presionP2 * 1.2) + ((alturaEntrePuntos / 0.704) * 1.2);
        double perdidasPorFriccion = presionP1 - presionIdeal;
        double potenciaDisipada = (caudal * perdidasPorFriccion * 0.7 * 3.28) / (3960 * (eficienciaBomba / 100));
        double resultadoFinal = potenciaDisipada * horasOperacion * costoKwh;

        String resultadoFinalFormateado = NumberFormat('#,##0.00', 'es_CO').format(resultadoFinal);

        setState(() {
          _resultText = "El ahorro anual estimado es: $resultadoFinalFormateado COP";
        });
      } catch (e) {
        print('Error en el cálculo: $e');
        setState(() {
          _resultText = 'Hubo un error en el cálculo. Verifica las entradas.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pérdidas Por Fricción'),
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
                child: Image.asset('images/friccion.png', fit: BoxFit.cover),
              ),
              SizedBox(height: 16.0),
              _buildTextField(_caudalController, 'Caudal (USgpm)', TextInputType.number),
              _buildTextField(_presionP1Controller, 'Presión descarga bomba P2 (PSI)', TextInputType.number),
              _buildTextField(_presionP2Controller, 'Presión aguas abajo P1 (PSI)', TextInputType.number),
              _buildTextField(_alturaEntrePuntosController, 'Altura entre los dos puntos (m.c.a.)', TextInputType.number),
              _buildTextField(_eficienciaBombaController, 'Eficiencia de la bomba (%)', TextInputType.number),
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
