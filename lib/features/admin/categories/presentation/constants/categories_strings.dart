abstract final class CategoriesStrings {
  static const String title = 'Categories';
  static const String addTitle = 'Add category';
  static const String editTitle = 'Edit category';
  static const String saveChanges = 'Save changes';
  static const String addAction = 'Add category';

  static const String nameLabel = 'Name';
  static const String nameHint = 'e.g. Electronics';
  static const String descriptionLabel = 'Description';
  static const String descriptionHint = 'What is in this category?';

  static const String empty = 'No categories yet';
  static const String editTooltip = 'Edit';
  static const String deleteTooltip = 'Delete';
  static const String deleteTitle = 'Delete category?';

  static String deleteMessage(String name) =>
      '"$name" is shared with all admins and will be deleted for everyone.';
}
