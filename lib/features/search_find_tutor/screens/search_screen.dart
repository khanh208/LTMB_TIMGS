
import 'package:flutter/material.dart';
import '../../profile/screens/tutor_profile_detail_screen.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/tutor_model.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/avatar_widget.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  
  const SearchScreen({super.key, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  final Set<String> _selectedQuickFilters = {};
  
  bool _isAdvancedFilterActive = false;

  List<TutorModel> _tutors = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _searchController.text = _getCategoryName(widget.initialCategory!);
    }
    _loadTutors();
  }

  String _getCategoryName(String key) {
    if (key == 'tin_hoc') return "Tin học";
    if (key == 'ngoai_ngu') return "Ngoại ngữ";
    if (key == 'ky_nang_mem') return "Kỹ năng mềm";
    if (key == 'pho_thong') return "Phổ thông";
    if (key == 'tieu_hoc') return "Tiểu học";
    return key;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTutors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Map quick filters to API parameters
      double? minRating;
      double? maxPrice;
      String? sortBy;

      if (_selectedQuickFilters.contains('danh_gia_cao')) {
        minRating = 4.0;
        sortBy = 'rating_desc';
      }
      if (_selectedQuickFilters.contains('gia_thap')) {
        maxPrice = 200000.0;
        if (sortBy == null) {
          sortBy = 'price_asc';
        }
      }

      final tutorsData = await _apiService.searchTutors(
        search: _searchController.text.trim().isEmpty 
            ? null 
            : _searchController.text.trim(),
        category: widget.initialCategory,
        minRating: minRating,
        maxPrice: maxPrice,
        sortBy: sortBy,
      );
      
      setState(() {
        _tutors = tutorsData.map((json) => TutorModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _performSearch() {
    _loadTutors();
  }

  void _showAdvancedFilter(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _AdvancedFilterContent();
      },
    );

    if (result == true) {
      setState(() {
        _isAdvancedFilterActive = true; 
        _selectedQuickFilters.clear(); 
      });
      _loadTutors(); 
    }
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
              onPressed: _performSearch,
            ),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [
          if (_isAdvancedFilterActive)
            TextButton(
              onPressed: () {
                setState(() {
                  _isAdvancedFilterActive = false; 
                });
                _loadTutors();
              },
              child: const Text("Reset", style: TextStyle(color: Colors.red)),
            ),
            
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showAdvancedFilter(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lỗi: $_error',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTutors,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _tutors.isEmpty
                        ? const Center(
                            child: Text(
                              'Không tìm thấy gia sư nào',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _tutors.length,
              itemBuilder: (context, index) {
                              final tutor = _tutors[index];
                              return ListTile(
                                leading: AvatarWidget(
                                  avatarUrl: tutor.avatarUrl,
                                  radius: 20,
                                ),
                                title: Text(tutor.fullName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (tutor.bio != null)
                                      Text(
                                        tutor.bio!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(tutor.ratingValue.toStringAsFixed(1)),
                                        const SizedBox(width: 16),
                                        Text(
                                          tutor.formattedPrice,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                      builder: (context) => TutorProfileDetailScreen(tutorId: tutor.userId),
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

class _AdvancedFilterContent extends StatefulWidget {
  const _AdvancedFilterContent();

  @override
  State<_AdvancedFilterContent> createState() => _AdvancedFilterContentState();
}

class _AdvancedFilterContentState extends State<_AdvancedFilterContent> {
  final Set<String> _selectedTrinhDo = {};
  final Set<String> _selectedMonHoc = {};
  final Set<String> _selectedKhuVuc = {};
  
  final Set<String> _selectedKyNangMem = {};

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
            const Divider(height: 32), 
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
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  _buildFilterSection(
                    title: "Khu vực",
                    options: {
                      'q1': 'Quận 1',
                      'q2': 'Quận 2',
                    },
                    selectedItems: _selectedKhuVuc,
                  ),
                ],
              ),
            ),
          ),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTrinhDo.clear();
                      _selectedMonHoc.clear();
                      _selectedKhuVuc.clear();
                      _selectedKyNangMem.clear();
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