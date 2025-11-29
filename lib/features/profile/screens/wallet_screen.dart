import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/utils/error_handler.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ApiService _apiService = ApiService();
  double _balance = 0.0;
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  bool _isLoadingTransactions = false;
  bool _hasLinkedAccount = false;
  bool _isCheckingAccount = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _checkLinkedAccount(),
      _loadBalance(),
      _loadTransactions(),
    ]);
  }

  Future<void> _checkLinkedAccount() async {
    setState(() {
      _isCheckingAccount = true;
    });

    try {
      final accounts = await _apiService.getWalletAccounts();
      if (mounted) {
        setState(() {
          _hasLinkedAccount = accounts.isNotEmpty;
          _isCheckingAccount = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [Wallet] Error checking linked account: $e');
      if (mounted) {
        setState(() {
          _hasLinkedAccount = false;
          _isCheckingAccount = false;
        });
      }
    }
  }

  Future<void> _loadBalance() async {
    try {
      final data = await _apiService.getWalletBalance();
      if (mounted) {
        setState(() {
          _balance = double.tryParse(data['balance']?.toString() ?? '0') ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint('❌ [Wallet] Error loading balance: $e');
      if (mounted) {
        setState(() {
          _balance = 0.0;
        });
      }
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final data = await _apiService.getWalletTransactions();
      if (mounted) {
        setState(() {
          _transactions = data
              .map((json) => TransactionModel.fromJson(json))
              .toList();
          _transactions.sort((a, b) => b.date.compareTo(a.date));
          _isLoading = false;
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [Wallet] Error loading transactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingTransactions = false;
        });
      }
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VND';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k VND';
    }
    return '${amount.toStringAsFixed(0)} VND';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _showLinkWalletDialog() async {
    final accountNumberController = TextEditingController();
    final accountNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLinking = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Liên kết ví Momo'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAE1076).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Color(0xFFAE1076)),
                        const SizedBox(width: 8),
                        const Text(
                          'Ví điện tử Momo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: accountNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại Momo',
                      hintText: '',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập số điện thoại Momo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: accountNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên chủ tài khoản',
                      hintText: 'Nguyễn Văn A',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên chủ tài khoản';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLinking
                  ? null
                  : () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isLinking
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setDialogState(() {
                        isLinking = true;
                      });

                      try {
                        await _apiService.linkWallet(
                          accountType: 'momo',
                          accountNumber: accountNumberController.text.trim(),
                          accountName: accountNameController.text.trim(),
                        );

                        if (!context.mounted) return;

                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Liên kết ví thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        setDialogState(() {
                          isLinking = false;
                        });

                        ErrorHandler.showErrorDialogFromException(
                          context,
                          e,
                        );
                      }
                    },
              child: isLinking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Liên kết'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await _checkLinkedAccount();
      await _loadBalance();
    }
  }

  Future<void> _showDepositDialog() async {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isDepositing = false;

    final List<int> quickAmounts = [50000, 100000, 200000, 500000, 1000000];

    String formatCurrency(int amount) {
      if (amount >= 1000000) {
        return '${(amount / 1000000).toStringAsFixed(1)}M VND';
      } else if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(0)}k VND';
      }
      return '$amount VND';
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nạp tiền qua Momo'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAE1076).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Color(0xFFAE1076)),
                        const SizedBox(width: 8),
                        const Text(
                          'Ví điện tử Momo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền nạp',
                      hintText: '500000',
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: 'VND',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập số tiền';
                      }
                      final amount = int.tryParse(value.trim());
                      if (amount == null || amount <= 0) {
                        return 'Số tiền phải lớn hơn 0';
                      }
                      if (amount < 10000) {
                        return 'Số tiền tối thiểu là 10,000 VND';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chọn nhanh',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: quickAmounts.map((amount) {
                      return FilterChip(
                        label: Text(formatCurrency(amount)),
                        selected: amountController.text == amount.toString(),
                        onSelected: (selected) {
                          amountController.text = amount.toString();
                          setDialogState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDepositing
                  ? null
                  : () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isDepositing
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      final amount = int.tryParse(amountController.text.trim());
                      if (amount == null || amount <= 0) return;

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận nạp tiền'),
                          content: Text('Bạn có chắc chắn muốn nạp ${formatCurrency(amount)}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Xác nhận'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      setDialogState(() {
                        isDepositing = true;
                      });

                      try {
                        await _apiService.depositWallet(
                          amount: amount,
                          source: 'momo_mock',
                        );

                        if (!context.mounted) return;

                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Nạp tiền thành công! ${formatCurrency(amount)}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        setDialogState(() {
                          isDepositing = false;
                        });

                        ErrorHandler.showErrorDialogFromException(
                          context,
                          e,
                        );
                      }
                    },
              child: isDepositing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Nạp tiền'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await _loadData();
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
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildBalanceCard(context),
                    _buildMomoActionCard(context),
                    _buildTransactionHistory(context),
                  ],
                ),
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
            "Số dư Hiện tại",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(_balance),
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
            Text(
              _hasLinkedAccount
                  ? "Nạp tiền nhanh chóng qua Momo"
                  : "Liên kết ví Momo để bắt đầu",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _hasLinkedAccount
                  ? "Nạp tiền vào ví và thanh toán các buổi học an toàn, tiện lợi."
                  : "Liên kết ví Momo của bạn để nạp tiền và thanh toán các buổi học an toàn, tiện lợi.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_isCheckingAccount)
              const CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasLinkedAccount ? _showDepositDialog : _showLinkWalletDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE1076),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _hasLinkedAccount ? "Nạp tiền" : "Liên kết Momo ngay",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lịch sử Giao dịch",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_isLoadingTransactions)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Chưa có giao dịch nào',
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
                final isCredit = tx.isCredit;
                final icon = isCredit
                    ? Icons.arrow_downward
                    : Icons.arrow_upward;
                final color = isCredit ? Colors.green : Colors.red;

                return ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(tx.description),
                  subtitle: Text(_formatDate(tx.date)),
                  trailing: Text(
                    '${isCredit ? '+' : ''}${_formatCurrency(tx.amount)}',
                    style: TextStyle(
                      color: color,
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
