import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _recentSearches = [];
  bool _isTyping = false;

  final List<String> _trendingSearches = [
    'EV Car',
    'Test Drive',
    'KIA',
    'BIKE',
  ];

  static const String _prefKey = 'home_recent_searches';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(() {
      setState(() {
        _isTyping = _searchController.text.isNotEmpty;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList(_prefKey) ??
          ['Car', 'Bike', 'KIA', 'Honda', 'EV Car'];
    });
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, _recentSearches);
  }

  void _addRecentSearch(String query) {
    if (query
        .trim()
        .isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
    _saveRecentSearches();
  }

  void _onSearchSubmit(String query) {
    if (query
        .trim()
        .isEmpty) return;
    _addRecentSearch(query.trim());
    // Stay on screen — do not pop
  }

  void _onChipTap(String label) {
    _addRecentSearch(label);
    // Stay on screen — do not pop
  }

  Widget _buildChip(String label, {bool showArrow = true}) {
    return GestureDetector(
      onTap: () => _onChipTap(label),
      child: Container(
        margin: EdgeInsets.only(right: 8.w, bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFF005F65)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF414141),
              ),
            ),
            if (showArrow) ...[
              SizedBox(width: 4.w),
              Icon(Icons.trending_up, size: 16.r, color: const Color(0xFF414141)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fills the status bar area ──
            Container(
              width: double.infinity,
              height: statusBarHeight,
              color: const Color(0xFF615C5C),
            ),

            // ── AppBar: back arrow + Search title ──
            Container(
              color: const Color(0xFFFBF8F8),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        size: 24.r, color: const Color(0xFF01422D)),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF01422D),
                    ),
                  ),
                ],
              ),
            ),

            // ── Animated search bar below AppBar ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: _AnimatedSearchBar(
                controller: _searchController,
                focusNode: _focusNode,
                isTyping: _isTyping,
                onSubmitted: _onSearchSubmit,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_recentSearches.isNotEmpty) ...[
                      Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF414141),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        children: _recentSearches
                            .map((s) => _buildChip(s))
                            .toList(),
                      ),
                      SizedBox(height: 8.h),
                      const Divider(color: Color(0xFF797979)),
                      SizedBox(height: 8.h),
                    ],
                    Text(
                      'Trending Searches',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF414141),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      children: _trendingSearches
                          .map((s) => _buildChip(s))
                          .toList(),
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

// ─── Animated Search Bar ──────────────────────────────────────────────────────

class _AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isTyping;
  final ValueChanged<String> onSubmitted;

  const _AnimatedSearchBar({
    required this.controller,
    required this.focusNode,
    required this.isTyping,
    required this.onSubmitted,
  });

  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  static const List<String> _hints = [
    'Price',
    'Model',
    'Year',
    'Body Type',
    'Fuel Type',
    'Transmission',
    'Owner Count',
    'Kms Driven',
  ];

  int _currentIndex = 0;
  late AnimationController _animController;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;
  Timer? _hintTimer;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _hintTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isAnimating && !widget.isTyping) _triggerTransition();
    });
  }

  void _triggerTransition() async {
    _isAnimating = true;
    await _animController.forward();
    if (mounted) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _hints.length;
      });
    }
    _animController.reset();
    _isAnimating = false;
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF005F65)),
      ),
      child: Row(
        children: [
          SizedBox(width: 10.w),
          Icon(Icons.search, color: const Color(0xFF5F6368), size: 20.r),
          SizedBox(width: 6.w),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // ── Animated hint visible only when not typing ──
                if (!widget.isTyping)
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      return ClipRect(
                        child: Row(
                          children: [
                            Text(
                              'Search Cars by ',
                              style: TextStyle(
                                color: const Color(0xFF676767),
                                fontSize: 14.sp,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 48.h,
                                child: Stack(
                                  clipBehavior: Clip.hardEdge,
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    SlideTransition(
                                      position: _slideOutAnimation,
                                      child: FadeTransition(
                                        opacity: _fadeOutAnimation,
                                        child: Text(
                                          '"${_hints[_currentIndex]}"',
                                          style: TextStyle(
                                            color: const Color(0xFF005F65),
                                            fontSize: 14.sp,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    SlideTransition(
                                      position: _slideInAnimation,
                                      child: FadeTransition(
                                        opacity: _fadeInAnimation,
                                        child: Text(
                                          '"${_hints[(_currentIndex + 1) % _hints.length]}"',
                                          style: TextStyle(
                                            color: const Color(0xFF005F65),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                // ── Actual TextField always on top ──
                TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  cursorColor: const Color(0xFF5F6368),
                  textInputAction: TextInputAction.search,
                  onSubmitted: widget.onSubmitted,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                  ),
                ),
              ],
            ),
          ),

          // ── Clear button when typing ──
          if (widget.isTyping)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                widget.focusNode.requestFocus();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Icon(Icons.close, size: 18.r, color: const Color(0xFF5F6368)),
              ),
            )
          else
            SizedBox(width: 10.w),
        ],
      ),
    );
  }
}