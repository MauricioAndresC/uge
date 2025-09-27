import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class IneficienteScreen extends StatefulWidget {
  @override
  _IneficienteScreenState createState() => _IneficienteScreenState();
}

class _IneficienteScreenState extends State<IneficienteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _potenciaPromedioController = TextEditingController();
  final _eficienciaPromedioController = TextEditingController();
  final _nuevaEficienciaController = TextEditingController();
  final _horasOperacionController = TextEditingController();
  final _costoKwhController = TextEditingController();

  String _resultText = '';

  // Tabla de precios de bombas
  final Map<String, double> preciosBombas = {
    "0-5 Hp": 6500000,
    "5-10 Hp": 8800000,
    "10-15 Hp": 10600000,
    "15-20 Hp": 12500000,
    "20-30 Hp": 15320000,
    "30-40 Hp": 22750000,
    "40-50 Hp": 25000000,
    "50-75 Hp": 32000000,
  };

  String? _bombaSeleccionada;

  double? _costoInversion;
  double? _ahorroAnual;
  double? _roiAnios;

  List<Map<String, dynamic>> _tablaResultados = [];

  void _calculate() {
    if (_formKey.currentState!.validate() && _bombaSeleccionada != null) {
      try {
        double potenciaPromedio = double.parse(_potenciaPromedioController.text);
        double eficienciaPromedio = double.parse(_eficienciaPromedioController.text);
        double nuevaEficiencia = double.parse(_nuevaEficienciaController.text);
        double horasOperacion = double.parse(_horasOperacionController.text);
        double costoKwh = double.parse(_costoKwhController.text);

        // Costo de inversión según bomba seleccionada
        double costoInversion = preciosBombas[_bombaSeleccionada]!;

        // Cálculos
        double baseCalculoK = potenciaPromedio * 0.746 * 0.6666666667;
        double calculoP2 = (baseCalculoK * eficienciaPromedio) / nuevaEficiencia;
        double ahorroAnual = (baseCalculoK - calculoP2) * horasOperacion * costoKwh;

        // ROI
        double roiAnios = costoInversion / ahorroAnual;

        final formatter = NumberFormat('#,##0', 'es_CO');

        // Generar tabla para 5 años
        List<Map<String, dynamic>> tabla = [];
        for (int i = 1; i <= 5; i++) {
          tabla.add({
            "anio": i,
            "ahorro": ahorroAnual * i,
            "inversion": costoInversion,
          });
        }

        setState(() {
          _costoInversion = costoInversion;
          _ahorroAnual = ahorroAnual;
          _roiAnios = roiAnios;
          _tablaResultados = tabla;

          _resultText = """
💡 Estudio para una bomba de $_bombaSeleccionada
----------------------------------------
🔹 Costo de inversión: ${formatter.format(costoInversion)} COP
🔹 Ahorro anual estimado: ${formatter.format(ahorroAnual)} COP
🔹 ROI (Retorno de inversión): ${roiAnios.toStringAsFixed(1)} años
🔹 Ahorro acumulado en 5 años: ${formatter.format(ahorroAnual * 5)} COP
""";
        });
      } catch (e) {
        setState(() {
          _resultText = "❌ Error en los cálculos. Verifique los datos.";
        });
      }
    } else {
      setState(() {
        _resultText = "⚠️ Seleccione la bomba e ingrese todos los datos.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'es_CO');

    return Scaffold(
      appBar: AppBar(
        title: Text("Estudio de Motobombas"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown selección de bomba
              DropdownButtonFormField<String>(
                value: _bombaSeleccionada,
                items: preciosBombas.keys
                    .map((hp) => DropdownMenuItem(
                          child: Text("Motobomba $hp"),
                          value: hp,
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: "Seleccione potencia de la bomba (Hp)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _bombaSeleccionada = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Seleccione una bomba" : null,
              ),
              SizedBox(height: 12),
              _buildTextField(_potenciaPromedioController, "Potencia promedio (Hp)", TextInputType.number),
              _buildTextField(_eficienciaPromedioController, "Eficiencia promedio (%)", TextInputType.number),
              _buildTextField(_nuevaEficienciaController, "Nueva eficiencia (%)", TextInputType.number),
              _buildTextField(_horasOperacionController, "Horas de operación", TextInputType.number),
              _buildTextField(_costoKwhController, "Costo kWh (COP)", TextInputType.number),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                ),
                child: Text("Calcular", style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 20),
              Text(
                _resultText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Tabla con resultados de 5 años
              if (_tablaResultados.isNotEmpty)
                DataTable(
                  border: TableBorder.all(),
                  columns: const [
                    DataColumn(label: Text("Año")),
                    DataColumn(label: Text("Ahorro Acumulado (COP)")),
                    DataColumn(label: Text("Inversión (COP)")),
                  ],
                  rows: _tablaResultados.map((fila) {
                    return DataRow(cells: [
                      DataCell(Text(fila["anio"].toString())),
                      DataCell(Text(formatter.format(fila["ahorro"]))),
                      DataCell(Text(formatter.format(fila["inversion"]))),
                    ]);
                  }).toList(),
                ),

              SizedBox(height: 20),

              // Gráfica a 5 años
              if (_costoInversion != null && _ahorroAnual != null)
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value >= 1 && value <= 5) {
                                return Text("${value.toInt()} año");
                              }
                              return Text("");
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        // Línea de ahorro acumulado
                        LineChartBarData(
                          spots: List.generate(
                            5,
                            (i) => FlSpot(
                              (i + 1).toDouble(),
                              _ahorroAnual! * (i + 1),
                            ),
                          ),
                          isCurved: false,
                          color: Colors.green,
                          barWidth: 3,
                        ),
                        // Línea inversión
                        LineChartBarData(
                          spots: List.generate(
                            5,
                            (i) => FlSpot(
                              (i + 1).toDouble(),
                              _costoInversion!,
                            ),
                          ),
                          isCurved: false,
                          color: Colors.red,
                          barWidth: 3,
                          dashArray: [5, 5],
                        ),
                      ],
                    ),
                  ),
                ),
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
        ),
        keyboardType: inputType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Por favor, complete este campo";
          }
          return null;
        },
      ),
    );
  }
}
