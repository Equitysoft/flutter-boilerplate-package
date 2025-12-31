/// Core Pagination Package
///
/// Pagination utilities for list data with scroll-based loading.
///
/// Usage:
/// ```dart
/// import 'package:core_pagination/core_pagination.dart';
///
/// final pagination = PaginationHelper<UserModel>();
/// await pagination.loadInitial(fetchData);
/// ```
library core_pagination;

export 'src/pagination_helper.dart';
