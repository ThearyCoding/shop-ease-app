import 'dart:developer';
import '../../providers/cart_notifier.dart';
import '../../providers/category_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../providers/product_notifier.dart';
import '../../services/locals/shared_pres_service.dart';
import '../../widgets/product_card.dart';
import '../auth/is_auth.dart';
import '../cart/my_cart_screen.dart';
import '../product_detail.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final selectedCategoryProvider = StateProvider<int>((ref) => 0);
  final List<PageStorageKey> _scrollKeys = [];
  final AutoScrollController _scrollController = AutoScrollController();
  final Map<int, GlobalKey> _itemKeys = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    await Future.wait([
      _fetchProducts(),
      _fetchCart(),
      _fetchCategories(),
    ]);
  }

  Future<void> _fetchCart() async {
    await ref.read(cartStateNotifierProvider.notifier).fetchCart();
  }

  Future<void> _fetchProducts() async {
    await ref.read(productStateNotifierProvider.notifier).fetchProducts();
  }

  Future<void> _fetchCategories() async {
    await ref.read(categoryNotifierProvider.notifier).fetchCategories();
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCart = ref.watch(cartStateNotifierProvider).items.length;
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(right: 20),
          child: Text("Discover"),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await SharedPresService.clearToken();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (ctx) => IsAuth()));
              },
              icon: Icon(Icons.logout)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (ctx) => MyCartScreen()));
            },
            child: Padding(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: badges.Badge(
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.circle,
                  badgeColor: Colors.green,
                  padding: EdgeInsets.all(5),
                  elevation: 0,
                ),
                badgeContent: Text(
                  totalCart.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                position: badges.BadgePosition.topEnd(top: -10, end: -5),
                showBadge: totalCart == 0 ? false : true,
                ignorePointer: false,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(Icons.shopping_basket),
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(right: 20, left: 20),
        child: Column(
          spacing: 25,
          children: [
            _buildSearch(),
            _buildBanner(),
            _buildheaderCatories(),
            _buildCategoriesItems(),
            _buildProductCarts()
          ],
        ),
      ),
    );
  }

  void _scrollToCategory(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final keyContext = _itemKeys[index]?.currentContext;

      if (keyContext != null) {
        final RenderBox box = keyContext.findRenderObject() as RenderBox;
        final itemPosition = box.localToGlobal(Offset.zero).dx;
        final itemWidth = box.size.width;

        // Calculate target offset to center the selected item
        final targetOffset = _scrollController.offset +
            itemPosition -
            (screenWidth / 2) +
            (itemWidth / 2);

        // Ensure the calculated offset is within valid bounds
        final minScrollExtent = _scrollController.position.minScrollExtent;
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final boundedOffset =
            targetOffset.clamp(minScrollExtent, maxScrollExtent);
        _scrollController.animateTo(
          boundedOffset,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        log("keyContext for index $index is null.");
      }
    });
  }

  Widget _buildProductCarts() {
    final productState = ref.watch(productStateNotifierProvider);
    final selectedCategoryIndex = ref.watch(selectedCategoryProvider);
    final categories = ref.watch(categoryNotifierProvider).categories;
    if (categories.isEmpty) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final selectedCategory = categories[selectedCategoryIndex];
    while (_scrollKeys.length <= selectedCategoryIndex) {
      _scrollKeys.add(PageStorageKey(selectedCategoryIndex));
    }
    return Expanded(
      child: productState.isLoading
          ? Center(child: CircularProgressIndicator())
          : productState.products.isEmpty
              ? Center(
                  child: Text(
                    "No products found for this category",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    if (selectedCategory.id == 'all') {
                      await ref
                          .read(productStateNotifierProvider.notifier)
                          .fetchProducts();
                    } else {
                      await ref
                          .read(productStateNotifierProvider.notifier)
                          .fetchProductsByCategory(selectedCategory.id ?? '');
                    }
                  },
                  child: GridView.builder(
                    key: _scrollKeys[selectedCategoryIndex],
                    itemCount: productState.products.length,
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (ctx, index) {
                      final product = productState.products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (ctx) {
                            return ProductDetail(
                              product: product,
                            );
                          }));
                        },
                        child: ProductCart(product: product),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildCategoriesItems() {
    final categoryState = ref.watch(categoryNotifierProvider);
    final selectedCategoryIndex = ref.watch(selectedCategoryProvider);

    return categoryState.isLoading
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 40,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: categoryState.categories.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                if (!_itemKeys.containsKey(index)) {
                  _itemKeys[index] = GlobalKey();
                }
                final category = categoryState.categories[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = index;
                    _scrollToCategory(index);
                    if (category.id == 'all') {
                      ref
                          .read(productStateNotifierProvider.notifier)
                          .fetchProducts();
                    } else {
                      ref
                          .read(productStateNotifierProvider.notifier)
                          .fetchProductsByCategory(category.id ?? '');
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Container(
                      key: _itemKeys[index],
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: index != selectedCategoryIndex
                            ? Border.all(color: Colors.black)
                            : Border(),
                        borderRadius: BorderRadius.circular(10),
                        color: index == selectedCategoryIndex
                            ? Color(0xff19C463)
                            : Colors.transparent,
                      ),
                      child: Text(
                        category.name!,
                        style: TextStyle(
                          color: index == selectedCategoryIndex
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildheaderCatories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Categories",
          style: TextStyle(fontSize: 20),
        ),
        Text(
          "See all",
          style: TextStyle(fontSize: 20, color: Colors.green),
        )
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xff19C463),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Clearance",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Sales",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffFFFFFF)),
                  onPressed: () {},
                  label: Text(
                    "Up to 50%",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: -10,
            child: Image.asset(
              "assets/images/iphone_banner.png",
              width: 210,
              height: 210,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "Search",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
