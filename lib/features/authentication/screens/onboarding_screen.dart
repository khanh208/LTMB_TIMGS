import 'package:flutter/material.dart';
import '../../../core/utils/app_preferences.dart';

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
                onPressed: () async {
                  if (currentPage == demoData.length - 1) {
                    await AppPreferences.setOnboardingCompleted();
                    if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                    }
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
            child: Container( 
              padding: const EdgeInsets.all(16.0), 
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [ 
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), 
                    spreadRadius: 2, 
                    blurRadius: 10, 
                    offset: const Offset(0, 4), 
                  ),
                ],
              ),
              child: ClipRRect( 
                borderRadius: BorderRadius.circular(16), 
                child: Image.asset(
                  illustration!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high, 
                  isAntiAlias: true, 
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