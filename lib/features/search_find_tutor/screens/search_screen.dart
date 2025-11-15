// lib/features/search_find_tutor/screens/search_screen.dart

import 'package:flutter/material.dart';
import '../../profile/screens/tutor_profile_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  
  const SearchScreen({super.key, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // --- STATE CHO BỘ LỌC ---
  final Set<String> _selectedQuickFilters = {};
  
  // 1. State mới: Bộ lọc nâng cao có đang được áp dụng không?
  bool _isAdvancedFilterActive = false;
  // (Bạn có thể dùng state này để hiển thị các chip lọc nâng cao đã chọn)
  // Map<String, Set<String>> _advancedFilters = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _searchController.text = _getCategoryName(widget.initialCategory!);
      // (Tải dữ liệu ban đầu theo category)
    }
  }

  String _getCategoryName(String key) {
    if (key == 'tin_hoc') return "Tin học";
    if (key == 'ngoai_ngu') return "Ngoại ngữ";
    return key;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- HÀM MỞ POPUP LỌC NÂNG CAO (ĐÃ CẬP NHẬT) ---
  void _showAdvancedFilter(BuildContext context) async {
    // Chờ kết quả trả về (true) từ popup
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Không truyền categoryKey nữa, popup sẽ tự hiển thị tất cả
        return _AdvancedFilterContent();
      },
    );

    // 2. Nếu người dùng bấm "Áp dụng" (popup trả về true)
    if (result == true) {
      setState(() {
        _isAdvancedFilterActive = true; // Kích hoạt bộ lọc nâng cao
        _selectedQuickFilters.clear(); // Xóa các lựa chọn ở lọc nhanh
        // (Bạn sẽ gọi API lọc lại danh sách với các filter nâng cao)
      });
    }
  }

  // --- HÀM BUILD THANH LỌC NHANH (ĐÃ CẬP NHẬT) ---
  Widget _buildQuickFilterBar() {
    final Map<String, String> quickFilters = {
      'gan_toi': 'Gần tôi',
      'danh_gia_cao': 'Đánh giá cao',
      'gia_thap': 'Giá thấp',
      'online': 'Dạy Online',
    };

    // 3. Vô hiệu hóa và làm mờ nếu Lọc Nâng cao đang active
    return IgnorePointer(
      ignoring: _isAdvancedFilterActive, // Vô hiệu hóa (disable)
      child: Opacity(
        opacity: _isAdvancedFilterActive ? 0.4 : 1.0, // Làm mờ
        child: Container(
          height: 50, 
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!))
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: quickFilters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              String key = quickFilters.keys.elementAt(index);
              String label = quickFilters.values.elementAt(index);
              bool isSelected = _selectedQuickFilters.contains(key);

              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedQuickFilters.add(key);
                    } else {
                      _selectedQuickFilters.remove(key);
                    }
                    // (Gọi API lọc lại danh sách)
                  });
                },
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                ),
                side: BorderSide(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialCategory == null,
          decoration: InputDecoration(
            hintText: "Tìm kiếm...",
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () { /* Xử lý tìm kiếm */ },
            ),
          ),
          onSubmitted: (value) { /* Xử lý tìm kiếm */ },
        ),
        actions: [
          // 4. Thêm nút "Reset" nếu lọc nâng cao đang bật
          if (_isAdvancedFilterActive)
            TextButton(
              onPressed: () {
                setState(() {
                  _isAdvancedFilterActive = false; // Tắt lọc nâng cao
                  // (Gọi API tải lại danh sách gốc)
                });
              },
              child: const Text("Reset", style: TextStyle(color: Colors.red)),
            ),
            
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showAdvancedFilter(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickFilterBar(),
          
          Expanded(
            child: ListView.builder(
              itemCount: 20, // Giả lập
              itemBuilder: (context, index) {
                return ListTile( // 1. SỬA LẠI LISTTILE
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text("Kết quả Gia sư ${index + 1}"),
                          subtitle: const Text("Môn học: Toán, Lý..."),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () { // 2. THÊM ONTAP
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TutorProfileDetailScreen(tutorId: 'id_ket_qua_${index + 1}'),
                              ),
                            );
                          },
                        );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// (Toàn bộ code của SearchScreen và _SearchScreenState giữ nguyên như cũ)
// ...

// --- WIDGET NỘI DUNG CHO POPUP LỌC NÂNG CAO (ĐÃ CẬP NHẬT) ---
class _AdvancedFilterContent extends StatefulWidget {
  const _AdvancedFilterContent();

  @override
  State<_AdvancedFilterContent> createState() => _AdvancedFilterContentState();
}

class _AdvancedFilterContentState extends State<_AdvancedFilterContent> {
  // --- State cho TẤT CẢ các danh mục lọc ---
  final Set<String> _selectedTrinhDo = {};
  final Set<String> _selectedMonHoc = {};
  final Set<String> _selectedKhuVuc = {};
  
  // --- THÊM STATE CHO KỸ NĂNG MỀM ---
  final Set<String> _selectedKyNangMem = {};
  // ------------------------------------

  // (Hàm _buildFilterSection giữ nguyên)
  Widget _buildFilterSection(
      {required String title,
      required Map<String, String> options,
      required Set<String> selectedItems}) {
        
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = (constraints.maxWidth - (2 * 8)) / 3.1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0, 
              runSpacing: 8.0,
              children: options.entries.map((entry) {
                String key = entry.key;
                String label = entry.value;
                bool isSelected = selectedItems.contains(key);

                return SizedBox(
                  width: itemWidth,
                  child: ChoiceChip(
                    label: Text(label, textAlign: TextAlign.center),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() { 
                        if (selected) {
                          selectedItems.add(key);
                        } else {
                          selectedItems.remove(key);
                        }
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[100],
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 32), // Phân cách các mục
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề và nút Đóng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Bộ lọc Nâng cao", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          
          // --- NỘI DUNG LỌC (CUỘN ĐƯỢC) ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DANH MỤC 1: TRÌNH ĐỘ
                  _buildFilterSection(
                    title: "Trình độ",
                    options: {
                      'tieu_hoc': 'Tiểu học',
                      'pho_thong': 'Phổ thông',
                      'dai_hoc': 'Đại học',
                      'nguoi_di_lam': 'Người đi làm',
                      'tre_em': 'Trẻ em'
                    },
                    selectedItems: _selectedTrinhDo,
                  ),

                  // DANH MỤC 2: MÔN HỌC
                  _buildFilterSection(
                    title: "Môn học",
                    options: {
                      'toan': 'Toán',
                      'ly': 'Lý',
                      'hoa': 'Hoá',
                      'tin_hoc': 'Tin học',
                      'tieng_anh': 'Tiếng Anh',
                      'tieng_nhat': 'Tiếng Nhật',
                      'ui_ux': 'UI/UX',
                      'piano': 'Piano'
                    },
                    selectedItems: _selectedMonHoc,
                  ),

                  // --- THÊM DANH MỤC KỸ NĂNG MỀM ---
                  _buildFilterSection(
                    title: "Kỹ năng mềm",
                    options: {
                      'giao_tiep': 'Giao tiếp',
                      'thuyet_trinh': 'Thuyết trình',
                      'lam_viec_nhom': 'Làm việc nhóm',
                      'tu_duy_phan_bien': 'Tư duy phản biện',
                      'lanh_dao': 'Lãnh đạo',
                      'quan_ly_thoi_gian': 'Quản lý thời gian',
                    },
                    selectedItems: _selectedKyNangMem,
                  ),
                  // ------------------------------------

                  // DANH MỤC 4: KHU VỰC
                  _buildFilterSection(
                    title: "Khu vực",
                    options: {
                      'q1': 'Quận 1',
                      'q2': 'Quận 2',
                      // (Thêm các quận khác ở đây)
                    },
                    selectedItems: _selectedKhuVuc,
                  ),
                ],
              ),
            ),
          ),
          
          // Nút Reset và Áp dụng
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTrinhDo.clear();
                      _selectedMonHoc.clear();
                      _selectedKhuVuc.clear();
                      // --- THÊM VÀO NÚT RESET ---
                      _selectedKyNangMem.clear();
                      // -------------------------
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // (Bạn sẽ xử lý logic áp dụng lọc ở đây, 
                    // ví dụ: gửi các Set<> đã chọn về SearchScreen)
                    Navigator.pop(context, true); 
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white
                  ),
                  child: const Text("Áp dụng"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}