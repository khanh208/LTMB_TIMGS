// lib/features/wallet/screens/wallet_screen.dart

import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ví của tôi"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Thẻ Số dư
            _buildBalanceCard(context),
            
            // 2. Thẻ Liên kết Momo (Như bạn yêu cầu)
            _buildMomoActionCard(context),
            
            // 3. Lịch sử Giao dịch
            _buildTransactionHistory(context),
          ],
        ),
      ),
    );
  }

  // --- Widget Thẻ Số dư ---
  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Số dư Hiện tại",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            "0 VND", // (Dữ liệu giả)
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Liên kết Momo ---
  Widget _buildMomoActionCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // (Bạn sẽ cần thêm logo Momo vào assets/images)
            // 
            Image.asset(
              'assets/images/momo_logo.png', // Đảm bảo bạn có ảnh này
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance_wallet, size: 40, color: Color(0xFFAE1076)), // Màu Momo (thay thế)
            ),
            const SizedBox(height: 12),
            const Text(
              "Nạp tiền nhanh chóng qua Momo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Liên kết ví Momo của bạn để nạp tiền và thanh toán các buổi học an toàn, tiện lợi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // (Xử lý logic liên kết hoặc nạp tiền Momo SDK)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAE1076), // Màu chính của Momo
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Liên kết / Nạp tiền ngay"),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Lịch sử Giao dịch ---
  Widget _buildTransactionHistory(BuildContext context) {
    // (Dữ liệu giả)
    final List<Map<String, String>> transactions = [
      {'title': 'Thanh toán cho Gia sư Nguyễn Văn A', 'amount': '- 300,000', 'date': '06/11/2025'},
      {'title': 'Nạp tiền từ Momo', 'amount': '+ 500,000', 'date': '05/11/2025'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lịch sử Giao dịch",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // (Hiển thị nếu rỗng - Giả lập)
          // const Center(child: Text("Chưa có giao dịch nào.")),

          // Hiển thị danh sách
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final bool isCredit = tx['amount']!.startsWith('+');
              return ListTile(
                leading: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green : Colors.red,
                ),
                title: Text(tx['title']!),
                subtitle: Text(tx['date']!),
                trailing: Text(
                  "${tx['amount']} VND",
                  style: TextStyle(
                    color: isCredit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}