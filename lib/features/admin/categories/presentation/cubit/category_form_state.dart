sealed class CategoryFormState {
  const CategoryFormState();
}

class CategoryFormIdle extends CategoryFormState {
  const CategoryFormIdle();
}

class CategoryFormSubmitting extends CategoryFormState {
  const CategoryFormSubmitting();
}

class CategoryFormSuccess extends CategoryFormState {
  const CategoryFormSuccess();
}

class CategoryFormFailure extends CategoryFormState {
  const CategoryFormFailure(this.message);

  final String message;
}
