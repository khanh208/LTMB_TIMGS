import 'package:flutter/material.dart';

// (Giữ nguyên OnboardingScreen StatefulWidget ở đây)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  late PageController _pageController;

  List<Map<String, dynamic>> demoData = [
    {
      "illustration": "assets/images/onboard_screen_1.jpg", 
      "title": "Tìm kiếm Dễ Dàng",
      "text": "Lọc gia sư phù hợp theo môn học, trình độ, và khu vực chỉ trong vài thao tác. Tiết kiệm thời gian, tìm đúng người bạn cần.",
    },
    {
      "illustration": "assets/images/onboard_screen_2.jpg",
      "title": "Gia Sư Chất Lượng",
      "text": "Duyệt hồ sơ chi tiết, kiểm tra bằng cấp đã xác thực, và đọc đánh giá chân thực từ cộng đồng học viên.",
    },
    {
      "illustration": "assets/images/onboard_screen_3.jpg",
      "title": "Kết Nối & Xếp Lịch",
      "text": "Chat trực tiếp với gia sư, thỏa thuận lịch học linh hoạt và nhận thông báo nhắc nhở, đảm bảo không bỏ lỡ buổi học nào.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Expanded(
              flex: 14,
              child: PageView.builder(
                controller: _pageController,
                itemCount: demoData.length,
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemBuilder: (context, index) => OnboardContent(
                  illustration: demoData[index]["illustration"],
                  title: demoData[index]["title"],
                  text: demoData[index]["text"],
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                demoData.length,
                (index) => DotIndicator(isActive: index == currentPage),
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  if (currentPage == demoData.length - 1) {
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  (currentPage == demoData.length - 1) ? "BẮT ĐẦU" : "TIẾP THEO",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  final String? illustration, title, text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: Container( // Thay đổi ở đây: Dùng Container để bo góc và đổ bóng
              padding: const EdgeInsets.all(16.0), // Padding bên trong container
              decoration: BoxDecoration(
                color: Colors.white, // Nền cho hiệu ứng đổ bóng
                borderRadius: BorderRadius.circular(20), // Bo góc ảnh
                boxShadow: [ // Đổ bóng
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // Màu bóng
                    spreadRadius: 2, // Độ lan rộng
                    blurRadius: 10, // Độ mờ
                    offset: const Offset(0, 4), // Vị trí bóng (dưới và phải)
                  ),
                ],
              ),
              child: ClipRRect( // ClipRRect để hình ảnh bên trong cũng bo góc
                borderRadius: BorderRadius.circular(16), // Bo góc ít hơn so với container
                child: Image.asset(
                  illustration!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high, // Chất lượng hiển thị cao
                  isAntiAlias: true, // Chống răng cưa cho ảnh
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title!,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            text!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.6,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// (Giữ nguyên DotIndicator StatelessWidget ở đây)
class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).primaryColor;
    final inActiveColor = Colors.grey[300];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,  
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inActiveColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}