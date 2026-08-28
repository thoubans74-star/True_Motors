import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FilterBottomSheet(),
  );
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  int _selectedCategory = 0;

  final List<String> _categories = [
    'Budget',
    'Brand',
    'Fuel type',
    'Transmission',
    'Body Type',
    'Seater',
    'Ownership',
    'Year',
    'RTO',
    'Colors',
  ];

  // ── Filter State ────────────────────────────────────────────────────────────

  // Budget
  String? _selectedBudget;
  final List<String> _budgetOptions = [
    'Under 5 lakhs',
    '5-10 lakhs',
    '10-25 lakhs',
    '25-50 lakhs',
    '50-75 lakhs',
    '75-1 crore',
    'Above 1 crore',
  ];

  // Brand
  final TextEditingController _brandSearchController = TextEditingController();
  final Set<String> _selectedBrands = {};
  final List<String> _allBrands = [
    'Maruti', 'Suzuki', 'Swift', 'Hyundai', 'Honda', 'Toyota',
    'Tata', 'Mahindra', 'Ford', 'Audi', 'BMW',
  ];
  final List<String> _brandRecentSearches = [];

  // Fuel Type
  final Set<String> _selectedFuelTypes = {};
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric'];

  // Transmission
  final Set<String> _selectedTransmissions = {};
  final List<String> _transmissions = [
    'AMT (Automatic Manual Transmission)',
    'CVT (Continuous variable Transmission)',
    'TC (Torque Converter)',
    'DCT (Dual Clutch Transmission)',
    'IMT (Intelligent Manual Transmission)',
    'Regular Manual',
  ];

  // Body Type
  final Set<String> _selectedBodyTypes = {};
  final List<String> _bodyTypes = ['SUV', 'MUV', 'Sedan', 'Hatchback'];

  // Seater
  final Set<String> _selectedSeatCounts = {};
  final List<String> _seatCounts = ['4', '5', '6', '7'];

  // Ownership
  final Set<String> _selectedOwnerships = {};
  final List<String> _ownerships = [
    '1st owner',
    '2nd owner',
    '3rd owner',
    '4th owner',
    'Above 4 owners',
  ];

  // Year
  final Set<String> _selectedYears = {};
  final List<String> _yearRanges = [
    '1975-2000',
    '2001-2005',
    '2006-2010',
    '2011-2015',
    '2016-2020',
    '2021 & above',
  ];

  // RTO
  final TextEditingController _rtoSearchController = TextEditingController();
  final Set<String> _selectedRTOs = {};
  final List<String> _allRTOs = [
    'Tiruppur North',
    'Tiruppur South',
    'Chennai North',
    'Chennai South',
    'Coimbatore',
    'Salem',
    'Madurai',
    'Trichy',
  ];
  final List<String> _rtoRecentSearches = [];

  // Colors
  final Set<String> _selectedColors = {};
  final List<Map<String, dynamic>> _colors = [
    {'name': 'White', 'color': Colors.white, 'border': true},
    {'name': 'Black', 'color': Colors.black, 'border': false},
    {'name': 'Silver', 'color': const Color(0xFFC0C0C0), 'border': false},
    {'name': 'Grey', 'color': const Color(0xFF808080), 'border': false},
    {'name': 'Red', 'color': Color(0xFFFF0000), 'border': false},
    {'name': 'Blue', 'color': Color(0xFF0000FF), 'border': false},
    {'name': 'Navy Blue', 'color': const Color(0xFF000080), 'border': false},
    {'name': 'Maroon', 'color': const Color(0xFF800000), 'border': false},
    {'name': 'Purple', 'color': Color(0xFF800080), 'border': false},
  ];

  @override
  void dispose() {
    _brandSearchController.dispose();
    _rtoSearchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedBudget = null;
      _selectedBrands.clear();
      _brandSearchController.clear();
      _selectedFuelTypes.clear();
      _selectedTransmissions.clear();
      _selectedBodyTypes.clear();
      _selectedSeatCounts.clear();
      _selectedOwnerships.clear();
      _selectedYears.clear();
      _selectedRTOs.clear();
      _rtoSearchController.clear();
      _selectedColors.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────────────
              _FilterHeader(onClose: () => Navigator.pop(context)),
              const Divider(height: 1, thickness: 1, color: Color(0xFFBBBBBB)),

              // ── Body ───────────────────────────────────────────────────────
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left sidebar
                    _CategorySidebar(
                      categories: _categories,
                      selectedIndex: _selectedCategory,
                      onSelect: (i) => setState(() => _selectedCategory = i),
                    ),
                    // Vertical divider between sidebar and right panel
                    const VerticalDivider(
                        width: 1, thickness: 1, color: Color(0xFFBBBBBB)),
                    // Right content
                    Expanded(
                      child: _buildRightPanel(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFBBBBBB)),

              // ── Footer ─────────────────────────────────────────────────────
              _FilterFooter(
                onClear: _clearFilters,
                onUpdate: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRightPanel() {
    switch (_selectedCategory) {
      case 0:
        return _BudgetPanel(
          options: _budgetOptions,
          selected: _selectedBudget,
          onSelect: (v) => setState(() => _selectedBudget = v),
        );
      case 1:
        return _SearchCheckboxPanel(
          title: 'Search & select brand',
          controller: _brandSearchController,
          allItems: _allBrands,
          selected: _selectedBrands,
          recentSearches: _brandRecentSearches,
          onToggle: (v) => setState(() {
            _selectedBrands.contains(v)
                ? _selectedBrands.remove(v)
                : _selectedBrands.add(v);
          }),
          onRemoveRecent: (v) =>
              setState(() => _brandRecentSearches.remove(v)),
        );
      case 2:
        return _CheckboxPanel(
          title: 'Choose fuel type you desire',
          items: _fuelTypes,
          selected: _selectedFuelTypes,
          onToggle: (v) => setState(() {
            _selectedFuelTypes.contains(v)
                ? _selectedFuelTypes.remove(v)
                : _selectedFuelTypes.add(v);
          }),
        );
      case 3:
        return _CheckboxPanel(
          title: 'Select the transmission',
          items: _transmissions,
          selected: _selectedTransmissions,
          onToggle: (v) => setState(() {
            _selectedTransmissions.contains(v)
                ? _selectedTransmissions.remove(v)
                : _selectedTransmissions.add(v);
          }),
        );
      case 4:
        return _CheckboxPanel(
          title: 'Select body type',
          items: _bodyTypes,
          selected: _selectedBodyTypes,
          onToggle: (v) => setState(() {
            _selectedBodyTypes.contains(v)
                ? _selectedBodyTypes.remove(v)
                : _selectedBodyTypes.add(v);
          }),
        );
      case 5:
        return _CheckboxPanel(
          title: 'Select seater count',
          items: _seatCounts,
          selected: _selectedSeatCounts,
          onToggle: (v) => setState(() {
            _selectedSeatCounts.contains(v)
                ? _selectedSeatCounts.remove(v)
                : _selectedSeatCounts.add(v);
          }),
        );
      case 6:
        return _CheckboxPanel(
          title: 'Select ownership',
          items: _ownerships,
          selected: _selectedOwnerships,
          onToggle: (v) => setState(() {
            _selectedOwnerships.contains(v)
                ? _selectedOwnerships.remove(v)
                : _selectedOwnerships.add(v);
          }),
        );
      case 7:
        return _CheckboxPanel(
          title: 'Select year',
          items: _yearRanges,
          selected: _selectedYears,
          onToggle: (v) => setState(() {
            _selectedYears.contains(v)
                ? _selectedYears.remove(v)
                : _selectedYears.add(v);
          }),
        );
      case 8:
        return _SearchCheckboxPanel(
          title: 'Search & select RTO',
          controller: _rtoSearchController,
          allItems: _allRTOs,
          selected: _selectedRTOs,
          recentSearches: _rtoRecentSearches,
          onToggle: (v) => setState(() {
            _selectedRTOs.contains(v)
                ? _selectedRTOs.remove(v)
                : _selectedRTOs.add(v);
          }),
          onRemoveRecent: (v) =>
              setState(() => _rtoRecentSearches.remove(v)),
        );
      case 9:
        return _ColorsPanel(
          colors: _colors,
          selected: _selectedColors,
          onToggle: (v) => setState(() {
            _selectedColors.contains(v)
                ? _selectedColors.remove(v)
                : _selectedColors.add(v);
          }),
        );
      default:
        return const SizedBox();
    }
  }
}

// ─── Filter Header ────────────────────────────────────────────────────────────

class _FilterHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _FilterHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Text(
            'Filter options',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF005F65),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF5F6368)),
              ),
              child: Icon(Icons.close,
                  size: 14.r, color: const Color(0xFF5F6368)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Sidebar ─────────────────────────────────────────────────────────

class _CategorySidebar extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _CategorySidebar({
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.w,
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final isSelected = i == selectedIndex;
          return Column(
            children: [
              GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F5F2)
                        : Colors.transparent,
                    border: isSelected
                        ? Border(
                      left: BorderSide(
                          color: const Color(0xFF005F65), width: 4.w),
                    )
                        : Border(
                      left: BorderSide(
                          color: const Color(0xFFBBBBBB), width: 1.w),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 14.h),
                  child: Text(
                    categories[i],
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: const Color(0xFF000000)
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFBBBBBB),
                indent: 0,
                endIndent: 0,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Budget Panel ─────────────────────────────────────────────────────────────

class _BudgetPanel extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _BudgetPanel({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
          child: Text(
            'Select your budget range',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF414141),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () => onSelect(options[i]),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: Radio<String>(
                          value: options[i],
                          groupValue: selected,
                          onChanged: (v) => onSelect(v!),
                          activeColor: const Color(0xFF005F65),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        options[i],
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: const Color(0xFF414141),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Checkbox Panel ───────────────────────────────────────────────────────────

class _CheckboxPanel extends StatelessWidget {
  final String title;
  final List<String> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _CheckboxPanel({
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF414141),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final isChecked = selected.contains(items[i]);
              return GestureDetector(
                onTap: () => onToggle(items[i]),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 18.r,
                        height: 18.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.r),
                          border: Border.all(
                            color: isChecked
                                ? const Color(0xFF005F65)
                                : const Color(0xFF5F6368),
                            width: 1.5,
                          ),
                          color: isChecked
                              ? const Color(0xFF005F65)
                              : Colors.transparent,
                        ),
                        child: isChecked
                            ? Icon(Icons.check,
                            size: 12.r, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          items[i],
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: const Color(0xFF414141),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Search + Checkbox Panel (Brand / RTO) ────────────────────────────────────

class _SearchCheckboxPanel extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final List<String> allItems;
  final Set<String> selected;
  final List<String> recentSearches;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onRemoveRecent;

  const _SearchCheckboxPanel({
    required this.title,
    required this.controller,
    required this.allItems,
    required this.selected,
    required this.recentSearches,
    required this.onToggle,
    required this.onRemoveRecent,
  });

  @override
  State<_SearchCheckboxPanel> createState() => _SearchCheckboxPanelState();
}

class _SearchCheckboxPanelState extends State<_SearchCheckboxPanel> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        setState(() => _query = widget.controller.text.toLowerCase());
      }
    });
  }

  List<String> get _filtered => _query.isEmpty
      ? widget.allItems
      : widget.allItems
      .where((e) => e.toLowerCase().contains(_query))
      .toList();

  @override
  Widget build(BuildContext context) {
    final Set<String> recentSet = widget.recentSearches.toSet();
    final List<String> bottomChips = [
      ...widget.selected,
      ...recentSet.where((r) => !widget.selected.contains(r)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF414141),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Container(
            height: 38.h,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF005F65)),
              borderRadius: BorderRadius.circular(6.r),
              color: const Color(0xFFFFFFFF),
            ),
            child: TextField(
              controller: widget.controller,
              style: TextStyle(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle:
                TextStyle(fontSize: 13.sp, color: const Color(0xFF909090)),
                suffixIcon:
                Icon(Icons.search, size: 20.r, color: const Color(0xFF909090)),
                border: InputBorder.none,
                contentPadding:
                EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                isDense: true,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),

        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final item = _filtered[i];
              final isChecked = widget.selected.contains(item);
              return GestureDetector(
                onTap: () => widget.onToggle(item),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Container(
                        width: 18.r,
                        height: 18.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.r),
                          border: Border.all(
                            color: isChecked
                                ? const Color(0xFF005F65)
                                : const Color(0xFF5F6368),
                            width: 1.5,
                          ),
                          color: isChecked
                              ? const Color(0xFF005F65)
                              : Colors.transparent,
                        ),
                        child: isChecked
                            ? Icon(Icons.check,
                            size: 12.r, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: const Color(0xFF414141),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (bottomChips.isNotEmpty) ...[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: bottomChips.map((item) {
                  final isSelected = widget.selected.contains(item);
                  final isRecent = recentSet.contains(item);
                  return _FilterChip(
                    label: item,
                    onRemove: () {
                      if (isSelected) {
                        widget.onToggle(item);
                      } else if (isRecent) {
                        widget.onRemoveRecent(item);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF005F65), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: const Color(0xFF005F65),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 5.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 13.r,
              color: const Color(0xFF005F65),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Colors Panel ─────────────────────────────────────────────────────────────

class _ColorsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> colors;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _ColorsPanel({
    required this.colors,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
          child: Text(
            'Select colors you want',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF414141),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: colors.length,
            itemBuilder: (_, i) {
              final item = colors[i];
              final name = item['name'] as String;
              final color = item['color'] as Color;
              final needsBorder = item['border'] as bool;
              final isChecked = selected.contains(name);

              return GestureDetector(
                onTap: () => onToggle(name),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Container(
                        width: 18.r,
                        height: 18.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.r),
                          border: Border.all(
                            color: isChecked
                                ? const Color(0xFF005F65)
                                : const Color(0xFF414141),
                            width: 1.5,
                          ),
                          color: isChecked
                              ? const Color(0xFF005F65)
                              : Colors.transparent,
                        ),
                        child: isChecked
                            ? Icon(Icons.check,
                            size: 12.r, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: needsBorder
                                ? const Color(0xFFBABABA)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: const Color(0xFF414141),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Filter Footer ────────────────────────────────────────────────────────────

class _FilterFooter extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onUpdate;

  const _FilterFooter({required this.onClear, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClear,
            child: Text(
              'Clear filters',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFBE000C),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 42.h,
            child: ElevatedButton(
              onPressed: onUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005F65),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 36.w),
                elevation: 0,
              ),
              child: Text(
                'Update',
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}