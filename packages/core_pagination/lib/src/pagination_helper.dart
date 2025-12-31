import 'package:flutter/material.dart';

/// Pagination Helper - Common pagination handling for lists
///
/// Usage:
/// ```dart
/// final pagination = PaginationHelper<UserModel>();
///
/// // Load initial data
/// await pagination.loadInitial(fetchData);
///
/// // Load more on scroll
/// await pagination.loadMore(fetchData);
///
/// // Use in ListView
/// ListView.builder(
///   controller: pagination.scrollController,
///   itemCount: pagination.items.length,
/// )
/// ```
class PaginationHelper<T> {
  /// Current page number
  int _currentPage = 1;

  /// Items per page
  final int perPage;

  /// Flag to track if more data is available
  bool _hasMore = true;

  /// Flag to track loading state
  bool _isLoading = false;

  /// All loaded items
  final List<T> _items = [];

  /// Scroll controller for automatic load more
  ScrollController? _scrollController;

  /// Callback for loading more data
  Function()? _onLoadMore;

  PaginationHelper({this.perPage = 10});

  // ==================== GETTERS ====================

  /// Get current page
  int get currentPage => _currentPage;

  /// Get all items
  List<T> get items => List.unmodifiable(_items);

  /// Check if has more data
  bool get hasMore => _hasMore;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Check if list is empty
  bool get isEmpty => _items.isEmpty;

  /// Check if on first page
  bool get isFirstPage => _currentPage == 1;

  /// Get total loaded items count
  int get totalLoaded => _items.length;

  /// Get scroll controller with auto load more
  ScrollController get scrollController {
    _scrollController ??= ScrollController()..addListener(_onScroll);
    return _scrollController!;
  }

  // ==================== METHODS ====================

  /// Load initial data (reset and fetch first page)
  Future<void> loadInitial(
    Future<List<T>> Function(int page, int perPage) fetchData,
  ) async {
    reset();
    await _load(fetchData);
  }

  /// Load more data (next page)
  Future<void> loadMore(
    Future<List<T>> Function(int page, int perPage) fetchData,
  ) async {
    if (!_hasMore || _isLoading) return;
    await _load(fetchData);
  }

  /// Refresh data (reset and reload)
  Future<void> refresh(
    Future<List<T>> Function(int page, int perPage) fetchData,
  ) async {
    await loadInitial(fetchData);
  }

  /// Internal load method
  Future<void> _load(
    Future<List<T>> Function(int page, int perPage) fetchData,
  ) async {
    _isLoading = true;

    try {
      final newItems = await fetchData(_currentPage, perPage);

      _items.addAll(newItems);
      _hasMore = newItems.length >= perPage;

      if (newItems.isNotEmpty) {
        _currentPage++;
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Reset pagination state
  void reset() {
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _items.clear();
  }

  /// Add items manually
  void addItems(List<T> newItems) {
    _items.addAll(newItems);
    _hasMore = newItems.length >= perPage;
    if (newItems.isNotEmpty) {
      _currentPage++;
    }
  }

  /// Insert item at beginning
  void insertFirst(T item) {
    _items.insert(0, item);
  }

  /// Remove item
  void removeItem(T item) {
    _items.remove(item);
  }

  /// Remove item at index
  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  /// Update item at index
  void updateAt(int index, T item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
    }
  }

  /// Clear all items
  void clear() {
    _items.clear();
  }

  /// Set has more flag manually
  void setHasMore(bool value) {
    _hasMore = value;
  }

  /// Setup auto load more with callback
  void setupAutoLoadMore(Function() onLoadMore) {
    _onLoadMore = onLoadMore;
  }

  /// Scroll listener for auto load more
  void _onScroll() {
    if (_scrollController == null) return;

    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.position.pixels;

    // Load more when 80% scrolled
    if (currentScroll >= maxScroll * 0.8) {
      if (_hasMore && !_isLoading && _onLoadMore != null) {
        _onLoadMore!();
      }
    }
  }

  /// Dispose scroll controller
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
  }
}

/// Extension for easy pagination state management
extension PaginationStateExtension<T> on PaginationHelper<T> {
  /// Get pagination state map
  Map<String, dynamic> get state => {
    'currentPage': currentPage,
    'perPage': perPage,
    'hasMore': hasMore,
    'isLoading': isLoading,
    'totalLoaded': totalLoaded,
  };
}
