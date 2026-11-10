/// Linen category definitions and preset items for Housekeeping
enum LinenCategory {
  fren,
  fast,
  rewash,
}

extension LinenCategoryExtension on LinenCategory {
  String get title {
    switch (this) {
      case LinenCategory.fren:
        return 'FREN';
      case LinenCategory.fast:
        return 'FAST';
      case LinenCategory.rewash:
        return 'REWASH';
    }
  }

  String get displayTitle {
    switch (this) {
      case LinenCategory.fren:
        return 'Fren Linen';
      case LinenCategory.fast:
        return 'Fast Items';
      case LinenCategory.rewash:
        return 'Rewash Station';
    }
  }

  String get subtitle {
    switch (this) {
      case LinenCategory.fren:
        return 'Bedding, Duvets & Bath Linen';
      case LinenCategory.fast:
        return 'F&B, Prayer Mats & Housekeeping Fabrics';
      case LinenCategory.rewash:
        return 'Dedicated Rewash & Stain Treatment';
    }
  }

  List<String> get defaultItems {
    switch (this) {
      case LinenCategory.fren:
        return const [
          'Duvet Double',
          'Duvet Single',
          'Sheet Double',
          'Sheet Single',
          'Pillowcase',
          'Bathtowel',
          'Kain Coklat',
          'Kain Batik',
        ];
      case LinenCategory.fast:
        return const [
          'Bath Towel',
          'Bath Mat',
          'Mukena',
          'Sejadah',
          'Sarung',
          'Bendera',
        ];
      case LinenCategory.rewash:
        return const [
          'Duvet Double',
          'Duvet Single',
          'Sheet Double',
          'Sheet Single',
          'Pillowcase',
          'Bathtowel',
          'Bath Mat',
          'Mukena',
          'Sejadah',
          'Sarung',
          'Kain Coklat',
          'Kain Batik',
        ];
    }
  }
}

/// Item entry with quantity and note/stain description
class LinenItem {
  final String name;
  int quantity;
  String note;

  LinenItem({
    required this.name,
    this.quantity = 0,
    this.note = '',
  });

  LinenItem copyWith({
    String? name,
    int? quantity,
    String? note,
  }) {
    return LinenItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}
