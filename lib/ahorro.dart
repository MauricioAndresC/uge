import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AhorroScreen extends StatefulWidget {
  const AhorroScreen({super.key});

  @override
  _AhorroScreenState createState() => _AhorroScreenState();
}

class _AhorroScreenState extends State<AhorroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chartKey = GlobalKey();

  final _potenciaController = TextEditingController();
  final _horasController = TextEditingController();
  final _costoKwhController = TextEditingController();

  double? _costoActualAnual;
  double? _costoFuturoAnual;
  double? _ahorroAnual;
  double? _porcentajeAhorro;
  double? _emisionesActualTon;
  double? _emisionesFuturoTon;
  double? _ahorroCO2_15y;
  double? _paybackAnios;
  double? _inversion;

  List<Map<String, double>> _tcoTable = [];

  final Map<String, double> preciosBombas = {
    "0-5 Hp": 6500000 * 2.5,
    "5-10 Hp": 8800000 * 2.5,
    "10-15 Hp": 10600000 * 2.5,
    "15-20 Hp": 12500000 * 2.5,
    "20-30 Hp": 15320000 * 2.5,
    "30-40 Hp": 22750000 * 2.5,
    "40-50 Hp": 25000000 * 2.5,
    "50-75 Hp": 32000000 * 2.5,
  };

  static const double factorCO2 = 0.000180;
  final _fmt = NumberFormat('#,##0', 'es_CO');
  final _fmt2 = NumberFormat('#,##0.00', 'es_CO');

  double _getCostoInversion(double hp) {
    if (hp <= 5) return preciosBombas["0-5 Hp"]!;
    if (hp <= 10) return preciosBombas["5-10 Hp"]!;
    if (hp <= 15) return preciosBombas["10-15 Hp"]!;
    if (hp <= 20) return preciosBombas["15-20 Hp"]!;
    if (hp <= 30) return preciosBombas["20-30 Hp"]!;
    if (hp <= 40) return preciosBombas["30-40 Hp"]!;
    if (hp <= 50) return preciosBombas["40-50 Hp"]!;
    return preciosBombas["50-75 Hp"]!;
  }

  void _calculateAll() {
    if (!_formKey.currentState!.validate()) return;

    final hp = double.parse(_potenciaController.text);
    final horas = double.parse(_horasController.text);
    final costoKwh = double.parse(_costoKwhController.text);

    const double efActual = 0.50;
    const double efNueva = 0.70;

    final inversion = _getCostoInversion(hp);

    final potenciaMotorKw = hp * 0.746;
    final potenciaHidraulica = potenciaMotorKw * 0.67;

    final potenciaEntradaActual = potenciaHidraulica / efActual;
    final potenciaEntradaFuturo = potenciaHidraulica / efNueva;

    final costoActualAnual = potenciaEntradaActual * horas * costoKwh;
    final costoFuturoAnual = potenciaEntradaFuturo * horas * costoKwh;

    final ahorroAnual = costoActualAnual - costoFuturoAnual;
    final porcentajeAhorro =
        costoActualAnual > 0 ? (ahorroAnual / costoActualAnual * 100.0) : 0.0;

    final emisionesActual = potenciaEntradaActual * horas * factorCO2;
    final emisionesFuturo = potenciaEntradaFuturo * horas * factorCO2;
    final ahorroCO2_15y = (emisionesActual - emisionesFuturo) * 15.0;

    final payback = ahorroAnual > 0 ? inversion / ahorroAnual : double.infinity;

    List<Map<String, double>> tabla = [];
    for (int year = 0; year <= 5; year++) {
      final tcoActual = costoActualAnual * year;
      final tcoNuevo = costoFuturoAnual * year + inversion;
      tabla.add({
        "anio": year.toDouble(),
        "tco_actual": tcoActual,
        "tco_nuevo": tcoNuevo,
      });
    }

    setState(() {
      _costoActualAnual = costoActualAnual;
      _costoFuturoAnual = costoFuturoAnual;
      _ahorroAnual = ahorroAnual;
      _porcentajeAhorro = porcentajeAhorro;
      _emisionesActualTon = emisionesActual;
      _emisionesFuturoTon = emisionesFuturo;
      _ahorroCO2_15y = ahorroCO2_15y;
      _paybackAnios = payback;
      _inversion = inversion;
      _tcoTable = tabla;
    });
  }

  Future<void> _generatePdf() async {
    try {
      final boundary = _chartKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List chartBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Text("Reporte de Ahorro Energético",
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),

            // Tabla resumen
            pw.Table.fromTextArray(
              headers: ["Concepto", "Valor"],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              data: [
                ["Costo anual actual", "${_fmt.format(_costoActualAnual)} COP"],
                ["Costo anual optimizado", "${_fmt.format(_costoFuturoAnual)} COP"],
                ["Ahorro anual", "${_fmt.format(_ahorroAnual)} COP"],
                ["Ahorro [%]", "${_fmt2.format(_porcentajeAhorro)} %"],
                ["Inversión estimada", "${_fmt.format(_inversion)} COP"],
                [
                  "Payback",
                  _paybackAnios != null && _paybackAnios!.isFinite
                      ? "${_paybackAnios!.toStringAsFixed(2)} años"
                      : "N/A"
                ],
                ["Emisiones actuales", "${_emisionesActualTon!.toStringAsFixed(2)} ton"],
                ["Emisiones optimizadas", "${_emisionesFuturoTon!.toStringAsFixed(2)} ton"],
                ["Ahorro CO₂ en 15 años", "${_ahorroCO2_15y!.toStringAsFixed(2)} ton"],
              ],
            ),
            pw.SizedBox(height: 20),

            // Tabla TCO + Gráfico
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Table.fromTextArray(
                    headers: ["Año", "Actual", "Nuevo + Inversión"],
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                    data: _tcoTable.map((r) => [
                      r["anio"]!.toInt().toString(),
                      _fmt.format(r["tco_actual"]),
                      _fmt.format(r["tco_nuevo"]),
                    ]).toList(),
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(children: [
                    pw.Text("Gráfico TCO (5 años)",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Image(pw.MemoryImage(chartBytes), height: 200),
                  ]),
                ),
              ],
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint("Error al generar PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al generar el PDF")),
      );
    }
  }

  Widget _buildTcoChart() {
    if (_tcoTable.isEmpty) return const SizedBox.shrink();
    final spotsActual = _tcoTable
        .map((r) => FlSpot(r["anio"]!, r["tco_actual"]!))
        .toList();
    final spotsNuevo = _tcoTable
        .map((r) => FlSpot(r["anio"]!, r["tco_nuevo"]!))
        .toList();

    double maxVal = _tcoTable
            .map((r) => r["tco_actual"]! > r["tco_nuevo"]!
                ? r["tco_actual"]!
                : r["tco_nuevo"]!)
            .reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal * 1.1);

    // determinar intervalo dinámico
    double interval = maxY / 5;

    String formatNumber(double value) {
      if (value >= 1e6) {
        return "${(value / 1e6).toStringAsFixed(0)} M";
      } else if (value >= 1e3) {
        return "${(value / 1e3).toStringAsFixed(0)} K";
      } else {
        return value.toStringAsFixed(0);
      }
    }

    return RepaintBoundary(
      key: _chartKey,
      child: SizedBox(
        height: 260,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 5,
            minY: 0,
            maxY: maxY,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: interval,
                  getTitlesWidget: (value, meta) {
                    return Text(formatNumber(value));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text("${value.toInt()}");
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                  spots: spotsActual, isCurved: true, color: Colors.red, barWidth: 3),
              LineChartBarData(
                  spots: spotsNuevo, isCurved: true, color: Colors.green, barWidth: 3),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estudio Ahorro Energía & CO₂"),
        actions: [
          if (_costoActualAnual != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePdf,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _buildTextField(_potenciaController, "Potencia bomba (HP)"),
            _buildTextField(_horasController, "Horas de operación al año"),
            _buildTextField(_costoKwhController, "Costo kWh (COP)"),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _calculateAll, child: const Text("Calcular")),
            const SizedBox(height: 14),
            if (_costoActualAnual != null) ...[
              _buildResultsCard(),
              const SizedBox(height: 14),
              _buildTcoChart(),
            ]
          ]),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Resultados", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _resultRow("Costo anual actual", "${_fmt.format(_costoActualAnual!)} COP"),
              _resultRow("Costo anual optimizado", "${_fmt.format(_costoFuturoAnual!)} COP"),
              _resultRow("Ahorro anual", "${_fmt.format(_ahorroAnual!)} COP"),
              _resultRow("Ahorro [%]", "${_fmt2.format(_porcentajeAhorro!)} %"),
              _resultRow("Inversión estimada", "${_fmt.format(_inversion!)} COP"),
              _resultRow("Payback",
                  _paybackAnios != null && _paybackAnios!.isFinite
                      ? "${_paybackAnios!.toStringAsFixed(2)} años"
                      : "N/A"),
              _resultRow("Emisiones actuales", "${_emisionesActualTon!.toStringAsFixed(2)} ton"),
              _resultRow("Emisiones optimizadas", "${_emisionesFuturoTon!.toStringAsFixed(2)} ton"),
              _resultRow("Ahorro CO₂ en 15 años", "${_ahorroCO2_15y!.toStringAsFixed(2)} ton"),
            ]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return "Ingrese un valor";
          if (double.tryParse(v.replaceAll(',', '.')) == null) {
            return "Número inválido";
          }
          return null;
        },
      ),
    );
  }

  Widget _resultRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(children: [
        Expanded(child: Text(title)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
