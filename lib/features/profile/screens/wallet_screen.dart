
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_service.dart';
import '../../../core/utils/error_handler.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ApiService _apiService = ApiService();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  bool _isLoading = true;
  bool _isDepositing = false;
  double _balance = 0;
  List<dynamic> _transactions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getWalletBalance(),
        _apiService.getWalletTransactions(),
      ]);

      setState(() {
        _balance = results[0] as double;
        _transactions = results[1] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = ErrorHandler.getFriendlyErrorMessage(e);
      });
    }
  }

  Future<void> _showMockDepositSheet() async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giả lập nạp tiền',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Số tiền (VND)',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.replaceAll(',', '') ?? '');
                    if (amount == null || amount <= 0) {
                      return 'Vui lòng nhập số tiền hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isDepositing
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final amount = double.parse(
                                controller.text.replaceAll(',', ''));
                            await _mockDeposit(amount);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: _isDepositing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _mockDeposit(double amount) async {
    setState(() {
      _isDepositing = true;
    });
    try {
      await _apiService.mockWalletDeposit(amount);
      await _loadWallet();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã nạp ${_currencyFormat.format(amount)} vào ví.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: () => _mockDeposit(amount),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDepositing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ví của tôi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadWallet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _showMockDepositSheet,
        icon: const Icon(Icons.add),
        label: const Text('Nạp tiền'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _WalletError(message: _error!, onRetry: _loadWallet)
              : RefreshIndicator(
                  onRefresh: _loadWallet,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildBalanceCard(context),
                      _buildMomoActionCard(context),
                      _buildTransactionHistory(context),
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
            "Số dư hiện tại",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(_balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomoActionCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/images/momo_logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.account_balance_wallet,
                size: 40,
                color: Color(0xFFAE1076),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Nạp tiền nhanh chóng qua Momo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Chức năng giả lập giúp bạn thử nghiệm nạp tiền ngay trong ứng dụng.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _showMockDepositSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAE1076),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Giả lập nạp tiền"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lịch sử giao dịch",
            style:
                Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Chưa có giao dịch nào.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final double amount =
                    double.tryParse(tx['amount']?.toString() ?? '') ?? 0;
                final isCredit = amount >= 0;
                final description = tx['description'] ?? '';
                final createdAt = tx['created_at']?.toString();
                DateTime? dateTime;
                if (createdAt != null) {
                  dateTime = DateTime.tryParse(createdAt);
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                    child: Icon(
                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isCredit ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(description.isEmpty
                      ? (isCredit ? 'Nạp tiền' : 'Thanh toán')
                      : description),
                  subtitle: Text(
                    dateTime != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime)
                        : 'Không xác định',
                  ),
                  trailing: Text(
                    (isCredit ? '+ ' : '- ') +
                        _currencyFormat.format(amount.abs()),
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

class _WalletError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _WalletError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}