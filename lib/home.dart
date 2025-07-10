import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TextEditingController> sizeControllers = [];
  final List<TextEditingController> priceControllers = [];

  String resultTitle = '';
  String resultDetail = '';
  int cheaperIndex = -1;

  @override
  void initState() {
    super.initState();
    addInputRow();
    addInputRow();
  }

  void addInputRow() {
    setState(() {
      sizeControllers.add(TextEditingController());
      priceControllers.add(TextEditingController());
    });
  }

  void removeInputRow(int index) {
    if (sizeControllers.length <= 1) return;
    setState(() {
      sizeControllers[index].dispose();
      priceControllers[index].dispose();
      sizeControllers.removeAt(index);
      priceControllers.removeAt(index);
      cheaperIndex = -1;
      resultTitle = '';
      resultDetail = '';
    });
  }

  void resetFields() {
    setState(() {
      for (var c in sizeControllers) c.dispose();
      for (var c in priceControllers) c.dispose();
      sizeControllers.clear();
      priceControllers.clear();
      resultTitle = '';
      resultDetail = '';
      cheaperIndex = -1;
      addInputRow();
      addInputRow();
    });
  }

  void comparePrices() {
    final unitPrices = <double>[];
    final sizes = <double>[];
    final prices = <double>[];

    for (int i = 0; i < sizeControllers.length; i++) {
      final size = double.tryParse(sizeControllers[i].text);
      final price = double.tryParse(priceControllers[i].text);

      if (size == null || price == null || size == 0) {
        setState(() {
          resultTitle = 'ข้อมูลไม่ถูกต้อง';
          resultDetail = 'กรุณากรอกขนาดและราคาให้ครบถ้วน';
          cheaperIndex = -1;
        });
        return;
      }

      unitPrices.add(price / size);
      sizes.add(size);
      prices.add(price);
    }

    final minUnitPrice = unitPrices.reduce((a, b) => a < b ? a : b);
    final minIndex = unitPrices.indexOf(minUnitPrice);

    // คำนวณความแตกต่าง
    double maxSaving = 0;
    double maxPercent = 0;
    int comparedIndex = -1;

    for (int i = 0; i < unitPrices.length; i++) {
      if (i == minIndex) continue;

      final diffPerUnit = unitPrices[i] - minUnitPrice;
      final savedTotal = diffPerUnit * sizes[minIndex];
      final percent = (diffPerUnit / unitPrices[i]) * 100;

      if (savedTotal > maxSaving) {
        maxSaving = savedTotal;
        maxPercent = percent;
        comparedIndex = i;
      }
    }

    setState(() {
      cheaperIndex = minIndex;
      resultTitle = '🎉 รายการที่ ${minIndex + 1} คุ้มค่ากว่า';

      if (comparedIndex != -1) {
        resultDetail = 'ราคาต่อหน่วย ${minUnitPrice.toStringAsFixed(2)} บาท\n'
            'ถูกกว่ารายการที่ ${comparedIndex + 1} ประมาณ ${maxPercent.toStringAsFixed(2)}%\n'
            'รวมแล้วประหยัด ${maxSaving.toStringAsFixed(2)} บาท';
      } else {
        resultDetail = 'ราคาต่อหน่วย ${minUnitPrice.toStringAsFixed(2)} บาท';
      }
    });
  }

  Widget buildInputRow({
    required int index,
    required TextEditingController sizeCtrl,
    required TextEditingController priceCtrl,
  }) {
    final isCheapest = cheaperIndex == index;

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
          children: [
            Row(
              children: [
                Text('รายการที่ ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (sizeControllers.length > 1)
                  IconButton(
                    onPressed: () => removeInputRow(index),
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: sizeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ขนาด',
                      border: OutlineInputBorder(
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
                      border: OutlineInputBorder(
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
    for (var c in sizeControllers) c.dispose();
    for (var c in priceControllers) c.dispose();
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
            ...List.generate(
              sizeControllers.length,
              (index) => buildInputRow(
                index: index,
                sizeCtrl: sizeControllers[index],
                priceCtrl: priceControllers[index],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: addInputRow,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'เพิ่มรายการ',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
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
