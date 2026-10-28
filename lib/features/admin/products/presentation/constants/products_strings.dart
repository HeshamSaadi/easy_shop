abstract final class ProductsStrings {
  static const String title = 'Products';
  static const String searchHint = 'Search products...';
  static const String manageCategories = 'Manage Categories';
  static const String addAction = 'Add product';

  static const String empty = 'No products yet';
  static const String noResults = 'No products match your search';

  static const String visible = 'Visible';
  static const String hidden = 'Hidden';
  static const String detailsTitle = 'Product Details';
  static const String priceLabel = 'Price';
  static const String stockLabel = 'In Stock';
  static const String descriptionTitle = 'Description';
  static const String detailsSection = 'Details';
  static const String categoryLabel = 'Category';
  static const String addedLabel = 'Added';
  static const String visibilityLabel = 'Visibility';
  static const String editAction = 'Edit Product';
  static const String deleteTitle = 'Delete product';
  static String deleteMessage(String name) =>
      'Delete "$name"? This cannot be undone.';

  static const String addTitle = 'Add product';
  static const String editTitle = 'Edit product';
  static const String addSubmit = 'Add Product';
  static const String saveChanges = 'Save Changes';

  static const String imageHint = 'Add product image (optional)';
  static const String changeImage = 'Change image';
  static const String imagePickFailed = 'Could not pick the image. Try again.';

  static const String nameLabel = 'Product Name';
  static const String nameHint = 'e.g. Wireless Headphones';
  static const String categoryHint = 'Select category';
  static const String categoryRequired = 'Select a category';
  static const String priceHint = '0.00';
  static const String quantityLabel = 'Quantity';
  static const String quantityHint = '0';
  static const String descriptionLabel = 'Description';
  static const String descriptionHint = 'Optional product description...';
  static const String visibleTitle = 'Visible to customers';
  static const String visibleSubtitle = 'Show this product in your store';

  static const String noCategories =
      'Create a category first, then you can add products';
  static const String invalidNumbers = 'Enter a valid price and quantity.';

  static String quantity(int value) => 'Qty $value';
}
