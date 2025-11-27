
import 'package:flutter/material.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý Thu nhập"),
        ),
        body: Column(
          children: [
            _buildBalanceCard(context),
            const SizedBox(height: 24),
            
            const TabBar(
              tabs: [
                Tab(text: "Tiền đã nhận"),
                Tab(text: "Tiền đã rút"),
              ],
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  _buildTransactionList(isReceived: true),
                  _buildTransactionList(isReceived: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        children: [
          const Text(
            "Số dư Khả dụng",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "5,200,000 VND", 
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Số tiền đang chờ: 1,200,000 VND", 
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {  },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Yêu cầu Rút tiền"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList({required bool isReceived}) {
    final items = isReceived
        ? [
            {'title': 'Thanh toán buổi học (Học viên: Lê Văn A)', 'amount': '+ 300,000'},
            {'title': 'Thanh toán buổi học (Học viên: Trần Thị B)', 'amount': '+ 250,000'},
          ]
        : [
            {'title': 'Rút tiền về Vietcombank', 'amount': '- 4,000,000'},
          ];

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(
            isReceived ? Icons.arrow_downward : Icons.arrow_upward,
            color: isReceived ? Colors.green : Colors.red,
          ),
          title: Text(item['title']!),
          subtitle: const Text("10:30, 07/11/2025"), 
          trailing: Text(
            item['amount']!,
            style: TextStyle(
              color: isReceived ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}