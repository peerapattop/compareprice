import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController size1Controller = TextEditingController();
  final TextEditingController price1Controller = TextEditingController();
  final TextEditingController size2Controller = TextEditingController();
  final TextEditingController price2Controller = TextEditingController();

  String resultTitle = '';
  String resultDetail = '';
  int cheaperIndex = 0;

  void comparePrices() {
    final size1 = double.tryParse(size1Controller.text);
    final price1 = double.tryParse(price1Controller.text);
    final size2 = double.tryParse(size2Controller.text);
    final price2 = double.tryParse(price2Controller.text);

    if (size1 == null ||
        price1 == null ||
        size2 == null ||
        price2 == null ||
        size1 == 0 ||
        size2 == 0) {
      setState(() {
        resultTitle = 'ข้อมูลไม่ถูกต้อง';
        resultDetail = 'กรุณากรอกขนาดและราคาให้ครบถ้วน';
        cheaperIndex = 0;
      });
      return;
    }

    final unitPrice1 = price1 / size1;
    final unitPrice2 = price2 / size2;

    if (unitPrice1 < unitPrice2) {
      final percent = ((unitPrice2 - unitPrice1) / unitPrice2) * 100;
      final diffPerUnit = unitPrice2 - unitPrice1;
      final savedTotal = diffPerUnit * size1; // ขนาดของสินค้าที่ถูกกว่า

      setState(() {
        cheaperIndex = 1;
        resultTitle = '🎉 รายการที่ 1 คุ้มค่ากว่า';
        resultDetail =
            'ถูกกว่ารายการที่ 2 ทั้งหมด ${percent.toStringAsFixed(2)}%\n'
            'รวมแล้วประหยัด ${savedTotal.toStringAsFixed(2)} บาท';
      });
    } else if (unitPrice2 < unitPrice1) {
      final percent = ((unitPrice1 - unitPrice2) / unitPrice1) * 100;
      final diffPerUnit = unitPrice1 - unitPrice2;
      final savedTotal = diffPerUnit * size2;

      setState(() {
        cheaperIndex = 2;
        resultTitle = '🎉 รายการที่ 2 คุ้มค่ากว่า';
        resultDetail =
            'ถูกกว่ารายการที่ 1 ทั้งหมด ${percent.toStringAsFixed(2)}%\n'
            'รวมแล้วประหยัด ${savedTotal.toStringAsFixed(2)} บาท';
      });
    } else {
      setState(() {
        cheaperIndex = 0;
        resultTitle = '😐 ราคาต่อหน่วยเท่ากัน';
        resultDetail =
            'ทั้งสองรายการมีราคาต่อหน่วยเท่ากัน (${unitPrice1.toStringAsFixed(2)} ต่อหน่วย)';
      });
    }
  }

  void resetFields() {
    setState(() {
      size1Controller.clear();
      price1Controller.clear();
      size2Controller.clear();
      price2Controller.clear();
      resultTitle = '';
      resultDetail = '';
      cheaperIndex = 0;
    });
  }

  Widget buildInputRow({
    required int index,
    required TextEditingController sizeCtrl,
    required TextEditingController priceCtrl,
  }) {
    final isCheapest = cheaperIndex == index;
    final borderColor = isCheapest ? Colors.green : Colors.grey.shade300;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCheapest ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('รายการที่ $index',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: sizeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ขนาด',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isCheapest ? Colors.green : Colors.blueAccent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ราคา',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isCheapest ? Colors.green : Colors.blueAccent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    size1Controller.dispose();
    price1Controller.dispose();
    size2Controller.dispose();
    price2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '🛒 เปรียบเทียบราคาสินค้า',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 143, 184, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            buildInputRow(
              index: 1,
              sizeCtrl: size1Controller,
              priceCtrl: price1Controller,
            ),
            const SizedBox(height: 10),
            buildInputRow(
              index: 2,
              sizeCtrl: size2Controller,
              priceCtrl: price2Controller,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.compare_arrows,
                  size: 24, color: Colors.white),
              label: const Text(
                'เปรียบเทียบราคา',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: comparePrices,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: Colors.blueAccent.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: resetFields,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'รีเซ็ต',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 6,
                shadowColor: Colors.redAccent.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (resultTitle.isNotEmpty)
              Card(
                color: Colors.lightGreen.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resultTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resultDetail,
                        style: const TextStyle(fontSize: 15),
                      ),
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
