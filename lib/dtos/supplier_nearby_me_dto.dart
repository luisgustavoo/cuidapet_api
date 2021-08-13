class SupplierNearByMeDto {
  SupplierNearByMeDto(
      {required this.id,
      required this.name,
      required this.distance,
      required this.categoryId,
      this.logo});

  final int id;
  final String name;
  final String? logo;
  final double distance;
  final int categoryId;
}
