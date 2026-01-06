// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, parentId, syncStatus, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Category(
      {required this.id,
      required this.name,
      this.description,
      this.parentId,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'parentId': serializer.toJson<String?>(parentId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Category copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> parentId = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        parentId: parentId.present ? parentId.value : this.parentId,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('parentId: $parentId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, description, parentId, syncStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.parentId == this.parentId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> parentId;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.parentId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.parentId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? parentId,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (parentId != null) 'parent_id': parentId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? parentId,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('parentId: $parentId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _purchasePriceUsdMeta =
      const VerificationMeta('purchasePriceUsd');
  @override
  late final GeneratedColumn<double> purchasePriceUsd = GeneratedColumn<double>(
      'purchase_price_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _salePriceMeta =
      const VerificationMeta('salePrice');
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
      'sale_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _salePriceUsdMeta =
      const VerificationMeta('salePriceUsd');
  @override
  late final GeneratedColumn<double> salePriceUsd = GeneratedColumn<double>(
      'sale_price_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateAtCreationMeta =
      const VerificationMeta('exchangeRateAtCreation');
  @override
  late final GeneratedColumn<double> exchangeRateAtCreation =
      GeneratedColumn<double>('exchange_rate_at_creation', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minQuantityMeta =
      const VerificationMeta('minQuantity');
  @override
  late final GeneratedColumn<int> minQuantity = GeneratedColumn<int>(
      'min_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _taxRateMeta =
      const VerificationMeta('taxRate');
  @override
  late final GeneratedColumn<double> taxRate = GeneratedColumn<double>(
      'tax_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        sku,
        barcode,
        categoryId,
        purchasePrice,
        purchasePriceUsd,
        salePrice,
        salePriceUsd,
        exchangeRateAtCreation,
        quantity,
        minQuantity,
        taxRate,
        description,
        imageUrl,
        isActive,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('purchase_price_usd')) {
      context.handle(
          _purchasePriceUsdMeta,
          purchasePriceUsd.isAcceptableOrUnknown(
              data['purchase_price_usd']!, _purchasePriceUsdMeta));
    }
    if (data.containsKey('sale_price')) {
      context.handle(_salePriceMeta,
          salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta));
    } else if (isInserting) {
      context.missing(_salePriceMeta);
    }
    if (data.containsKey('sale_price_usd')) {
      context.handle(
          _salePriceUsdMeta,
          salePriceUsd.isAcceptableOrUnknown(
              data['sale_price_usd']!, _salePriceUsdMeta));
    }
    if (data.containsKey('exchange_rate_at_creation')) {
      context.handle(
          _exchangeRateAtCreationMeta,
          exchangeRateAtCreation.isAcceptableOrUnknown(
              data['exchange_rate_at_creation']!, _exchangeRateAtCreationMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('min_quantity')) {
      context.handle(
          _minQuantityMeta,
          minQuantity.isAcceptableOrUnknown(
              data['min_quantity']!, _minQuantityMeta));
    }
    if (data.containsKey('tax_rate')) {
      context.handle(_taxRateMeta,
          taxRate.isAcceptableOrUnknown(data['tax_rate']!, _taxRateMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku']),
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_price'])!,
      purchasePriceUsd: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}purchase_price_usd']),
      salePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sale_price'])!,
      salePriceUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sale_price_usd']),
      exchangeRateAtCreation: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}exchange_rate_at_creation']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      minQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_quantity'])!,
      taxRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_rate']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final String? categoryId;
  final double purchasePrice;
  final double? purchasePriceUsd;
  final double salePrice;
  final double? salePriceUsd;
  final double? exchangeRateAtCreation;
  final int quantity;
  final int minQuantity;
  final double? taxRate;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Product(
      {required this.id,
      required this.name,
      this.sku,
      this.barcode,
      this.categoryId,
      required this.purchasePrice,
      this.purchasePriceUsd,
      required this.salePrice,
      this.salePriceUsd,
      this.exchangeRateAtCreation,
      required this.quantity,
      required this.minQuantity,
      this.taxRate,
      this.description,
      this.imageUrl,
      required this.isActive,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['purchase_price'] = Variable<double>(purchasePrice);
    if (!nullToAbsent || purchasePriceUsd != null) {
      map['purchase_price_usd'] = Variable<double>(purchasePriceUsd);
    }
    map['sale_price'] = Variable<double>(salePrice);
    if (!nullToAbsent || salePriceUsd != null) {
      map['sale_price_usd'] = Variable<double>(salePriceUsd);
    }
    if (!nullToAbsent || exchangeRateAtCreation != null) {
      map['exchange_rate_at_creation'] =
          Variable<double>(exchangeRateAtCreation);
    }
    map['quantity'] = Variable<int>(quantity);
    map['min_quantity'] = Variable<int>(minQuantity);
    if (!nullToAbsent || taxRate != null) {
      map['tax_rate'] = Variable<double>(taxRate);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      purchasePrice: Value(purchasePrice),
      purchasePriceUsd: purchasePriceUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePriceUsd),
      salePrice: Value(salePrice),
      salePriceUsd: salePriceUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(salePriceUsd),
      exchangeRateAtCreation: exchangeRateAtCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRateAtCreation),
      quantity: Value(quantity),
      minQuantity: Value(minQuantity),
      taxRate: taxRate == null && nullToAbsent
          ? const Value.absent()
          : Value(taxRate),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String?>(json['sku']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      purchasePriceUsd: serializer.fromJson<double?>(json['purchasePriceUsd']),
      salePrice: serializer.fromJson<double>(json['salePrice']),
      salePriceUsd: serializer.fromJson<double?>(json['salePriceUsd']),
      exchangeRateAtCreation:
          serializer.fromJson<double?>(json['exchangeRateAtCreation']),
      quantity: serializer.fromJson<int>(json['quantity']),
      minQuantity: serializer.fromJson<int>(json['minQuantity']),
      taxRate: serializer.fromJson<double?>(json['taxRate']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String?>(sku),
      'barcode': serializer.toJson<String?>(barcode),
      'categoryId': serializer.toJson<String?>(categoryId),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'purchasePriceUsd': serializer.toJson<double?>(purchasePriceUsd),
      'salePrice': serializer.toJson<double>(salePrice),
      'salePriceUsd': serializer.toJson<double?>(salePriceUsd),
      'exchangeRateAtCreation':
          serializer.toJson<double?>(exchangeRateAtCreation),
      'quantity': serializer.toJson<int>(quantity),
      'minQuantity': serializer.toJson<int>(minQuantity),
      'taxRate': serializer.toJson<double?>(taxRate),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Product copyWith(
          {String? id,
          String? name,
          Value<String?> sku = const Value.absent(),
          Value<String?> barcode = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          double? purchasePrice,
          Value<double?> purchasePriceUsd = const Value.absent(),
          double? salePrice,
          Value<double?> salePriceUsd = const Value.absent(),
          Value<double?> exchangeRateAtCreation = const Value.absent(),
          int? quantity,
          int? minQuantity,
          Value<double?> taxRate = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          bool? isActive,
          String? syncStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        sku: sku.present ? sku.value : this.sku,
        barcode: barcode.present ? barcode.value : this.barcode,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        purchasePriceUsd: purchasePriceUsd.present
            ? purchasePriceUsd.value
            : this.purchasePriceUsd,
        salePrice: salePrice ?? this.salePrice,
        salePriceUsd:
            salePriceUsd.present ? salePriceUsd.value : this.salePriceUsd,
        exchangeRateAtCreation: exchangeRateAtCreation.present
            ? exchangeRateAtCreation.value
            : this.exchangeRateAtCreation,
        quantity: quantity ?? this.quantity,
        minQuantity: minQuantity ?? this.minQuantity,
        taxRate: taxRate.present ? taxRate.value : this.taxRate,
        description: description.present ? description.value : this.description,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        isActive: isActive ?? this.isActive,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      purchasePriceUsd: data.purchasePriceUsd.present
          ? data.purchasePriceUsd.value
          : this.purchasePriceUsd,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      salePriceUsd: data.salePriceUsd.present
          ? data.salePriceUsd.value
          : this.salePriceUsd,
      exchangeRateAtCreation: data.exchangeRateAtCreation.present
          ? data.exchangeRateAtCreation.value
          : this.exchangeRateAtCreation,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      minQuantity:
          data.minQuantity.present ? data.minQuantity.value : this.minQuantity,
      taxRate: data.taxRate.present ? data.taxRate.value : this.taxRate,
      description:
          data.description.present ? data.description.value : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('categoryId: $categoryId, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('purchasePriceUsd: $purchasePriceUsd, ')
          ..write('salePrice: $salePrice, ')
          ..write('salePriceUsd: $salePriceUsd, ')
          ..write('exchangeRateAtCreation: $exchangeRateAtCreation, ')
          ..write('quantity: $quantity, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('taxRate: $taxRate, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      sku,
      barcode,
      categoryId,
      purchasePrice,
      purchasePriceUsd,
      salePrice,
      salePriceUsd,
      exchangeRateAtCreation,
      quantity,
      minQuantity,
      taxRate,
      description,
      imageUrl,
      isActive,
      syncStatus,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.categoryId == this.categoryId &&
          other.purchasePrice == this.purchasePrice &&
          other.purchasePriceUsd == this.purchasePriceUsd &&
          other.salePrice == this.salePrice &&
          other.salePriceUsd == this.salePriceUsd &&
          other.exchangeRateAtCreation == this.exchangeRateAtCreation &&
          other.quantity == this.quantity &&
          other.minQuantity == this.minQuantity &&
          other.taxRate == this.taxRate &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> sku;
  final Value<String?> barcode;
  final Value<String?> categoryId;
  final Value<double> purchasePrice;
  final Value<double?> purchasePriceUsd;
  final Value<double> salePrice;
  final Value<double?> salePriceUsd;
  final Value<double?> exchangeRateAtCreation;
  final Value<int> quantity;
  final Value<int> minQuantity;
  final Value<double?> taxRate;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<bool> isActive;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.purchasePriceUsd = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.salePriceUsd = const Value.absent(),
    this.exchangeRateAtCreation = const Value.absent(),
    this.quantity = const Value.absent(),
    this.minQuantity = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.categoryId = const Value.absent(),
    required double purchasePrice,
    this.purchasePriceUsd = const Value.absent(),
    required double salePrice,
    this.salePriceUsd = const Value.absent(),
    this.exchangeRateAtCreation = const Value.absent(),
    this.quantity = const Value.absent(),
    this.minQuantity = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        purchasePrice = Value(purchasePrice),
        salePrice = Value(salePrice);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<String>? categoryId,
    Expression<double>? purchasePrice,
    Expression<double>? purchasePriceUsd,
    Expression<double>? salePrice,
    Expression<double>? salePriceUsd,
    Expression<double>? exchangeRateAtCreation,
    Expression<int>? quantity,
    Expression<int>? minQuantity,
    Expression<double>? taxRate,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<bool>? isActive,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (categoryId != null) 'category_id': categoryId,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (purchasePriceUsd != null) 'purchase_price_usd': purchasePriceUsd,
      if (salePrice != null) 'sale_price': salePrice,
      if (salePriceUsd != null) 'sale_price_usd': salePriceUsd,
      if (exchangeRateAtCreation != null)
        'exchange_rate_at_creation': exchangeRateAtCreation,
      if (quantity != null) 'quantity': quantity,
      if (minQuantity != null) 'min_quantity': minQuantity,
      if (taxRate != null) 'tax_rate': taxRate,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? sku,
      Value<String?>? barcode,
      Value<String?>? categoryId,
      Value<double>? purchasePrice,
      Value<double?>? purchasePriceUsd,
      Value<double>? salePrice,
      Value<double?>? salePriceUsd,
      Value<double?>? exchangeRateAtCreation,
      Value<int>? quantity,
      Value<int>? minQuantity,
      Value<double?>? taxRate,
      Value<String?>? description,
      Value<String?>? imageUrl,
      Value<bool>? isActive,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchasePriceUsd: purchasePriceUsd ?? this.purchasePriceUsd,
      salePrice: salePrice ?? this.salePrice,
      salePriceUsd: salePriceUsd ?? this.salePriceUsd,
      exchangeRateAtCreation:
          exchangeRateAtCreation ?? this.exchangeRateAtCreation,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      taxRate: taxRate ?? this.taxRate,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (purchasePriceUsd.present) {
      map['purchase_price_usd'] = Variable<double>(purchasePriceUsd.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (salePriceUsd.present) {
      map['sale_price_usd'] = Variable<double>(salePriceUsd.value);
    }
    if (exchangeRateAtCreation.present) {
      map['exchange_rate_at_creation'] =
          Variable<double>(exchangeRateAtCreation.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (minQuantity.present) {
      map['min_quantity'] = Variable<int>(minQuantity.value);
    }
    if (taxRate.present) {
      map['tax_rate'] = Variable<double>(taxRate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('categoryId: $categoryId, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('purchasePriceUsd: $purchasePriceUsd, ')
          ..write('salePrice: $salePrice, ')
          ..write('salePriceUsd: $salePriceUsd, ')
          ..write('exchangeRateAtCreation: $exchangeRateAtCreation, ')
          ..write('quantity: $quantity, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('taxRate: $taxRate, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _balanceUsdMeta =
      const VerificationMeta('balanceUsd');
  @override
  late final GeneratedColumn<double> balanceUsd = GeneratedColumn<double>(
      'balance_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phone,
        email,
        address,
        balance,
        balanceUsd,
        notes,
        isActive,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('balance_usd')) {
      context.handle(
          _balanceUsdMeta,
          balanceUsd.isAcceptableOrUnknown(
              data['balance_usd']!, _balanceUsdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      balanceUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance_usd']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double balance;
  final double? balanceUsd;
  final String? notes;
  final bool isActive;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Customer(
      {required this.id,
      required this.name,
      this.phone,
      this.email,
      this.address,
      required this.balance,
      this.balanceUsd,
      this.notes,
      required this.isActive,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['balance'] = Variable<double>(balance);
    if (!nullToAbsent || balanceUsd != null) {
      map['balance_usd'] = Variable<double>(balanceUsd);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      balance: Value(balance),
      balanceUsd: balanceUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceUsd),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      balance: serializer.fromJson<double>(json['balance']),
      balanceUsd: serializer.fromJson<double?>(json['balanceUsd']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'balance': serializer.toJson<double>(balance),
      'balanceUsd': serializer.toJson<double?>(balanceUsd),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Customer copyWith(
          {String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> address = const Value.absent(),
          double? balance,
          Value<double?> balanceUsd = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? isActive,
          String? syncStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        address: address.present ? address.value : this.address,
        balance: balance ?? this.balance,
        balanceUsd: balanceUsd.present ? balanceUsd.value : this.balanceUsd,
        notes: notes.present ? notes.value : this.notes,
        isActive: isActive ?? this.isActive,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      balance: data.balance.present ? data.balance.value : this.balance,
      balanceUsd:
          data.balanceUsd.present ? data.balanceUsd.value : this.balanceUsd,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('balance: $balance, ')
          ..write('balanceUsd: $balanceUsd, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, email, address, balance,
      balanceUsd, notes, isActive, syncStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.balance == this.balance &&
          other.balanceUsd == this.balanceUsd &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<double> balance;
  final Value<double?> balanceUsd;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.balance = const Value.absent(),
    this.balanceUsd = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.balance = const Value.absent(),
    this.balanceUsd = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<double>? balance,
    Expression<double>? balanceUsd,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (balance != null) 'balance': balance,
      if (balanceUsd != null) 'balance_usd': balanceUsd,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? address,
      Value<double>? balance,
      Value<double?>? balanceUsd,
      Value<String?>? notes,
      Value<bool>? isActive,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      balanceUsd: balanceUsd ?? this.balanceUsd,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (balanceUsd.present) {
      map['balance_usd'] = Variable<double>(balanceUsd.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('balance: $balance, ')
          ..write('balanceUsd: $balanceUsd, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _balanceUsdMeta =
      const VerificationMeta('balanceUsd');
  @override
  late final GeneratedColumn<double> balanceUsd = GeneratedColumn<double>(
      'balance_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phone,
        email,
        address,
        balance,
        balanceUsd,
        notes,
        isActive,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(Insertable<Supplier> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('balance_usd')) {
      context.handle(
          _balanceUsdMeta,
          balanceUsd.isAcceptableOrUnknown(
              data['balance_usd']!, _balanceUsdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      balanceUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance_usd']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double balance;
  final double? balanceUsd;
  final String? notes;
  final bool isActive;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Supplier(
      {required this.id,
      required this.name,
      this.phone,
      this.email,
      this.address,
      required this.balance,
      this.balanceUsd,
      this.notes,
      required this.isActive,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['balance'] = Variable<double>(balance);
    if (!nullToAbsent || balanceUsd != null) {
      map['balance_usd'] = Variable<double>(balanceUsd);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      balance: Value(balance),
      balanceUsd: balanceUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceUsd),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      balance: serializer.fromJson<double>(json['balance']),
      balanceUsd: serializer.fromJson<double?>(json['balanceUsd']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'balance': serializer.toJson<double>(balance),
      'balanceUsd': serializer.toJson<double?>(balanceUsd),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Supplier copyWith(
          {String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> address = const Value.absent(),
          double? balance,
          Value<double?> balanceUsd = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? isActive,
          String? syncStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Supplier(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        address: address.present ? address.value : this.address,
        balance: balance ?? this.balance,
        balanceUsd: balanceUsd.present ? balanceUsd.value : this.balanceUsd,
        notes: notes.present ? notes.value : this.notes,
        isActive: isActive ?? this.isActive,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      balance: data.balance.present ? data.balance.value : this.balance,
      balanceUsd:
          data.balanceUsd.present ? data.balanceUsd.value : this.balanceUsd,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('balance: $balance, ')
          ..write('balanceUsd: $balanceUsd, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, email, address, balance,
      balanceUsd, notes, isActive, syncStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.balance == this.balance &&
          other.balanceUsd == this.balanceUsd &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<double> balance;
  final Value<double?> balanceUsd;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.balance = const Value.absent(),
    this.balanceUsd = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.balance = const Value.absent(),
    this.balanceUsd = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Supplier> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<double>? balance,
    Expression<double>? balanceUsd,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (balance != null) 'balance': balance,
      if (balanceUsd != null) 'balance_usd': balanceUsd,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? address,
      Value<double>? balance,
      Value<double?>? balanceUsd,
      Value<String?>? notes,
      Value<bool>? isActive,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      balanceUsd: balanceUsd ?? this.balanceUsd,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (balanceUsd.present) {
      map['balance_usd'] = Variable<double>(balanceUsd.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('balance: $balance, ')
          ..write('balanceUsd: $balanceUsd, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, Shift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shiftNumberMeta =
      const VerificationMeta('shiftNumber');
  @override
  late final GeneratedColumn<String> shiftNumber = GeneratedColumn<String>(
      'shift_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _openingBalanceMeta =
      const VerificationMeta('openingBalance');
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
      'opening_balance', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _closingBalanceMeta =
      const VerificationMeta('closingBalance');
  @override
  late final GeneratedColumn<double> closingBalance = GeneratedColumn<double>(
      'closing_balance', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _expectedBalanceMeta =
      const VerificationMeta('expectedBalance');
  @override
  late final GeneratedColumn<double> expectedBalance = GeneratedColumn<double>(
      'expected_balance', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _differenceMeta =
      const VerificationMeta('difference');
  @override
  late final GeneratedColumn<double> difference = GeneratedColumn<double>(
      'difference', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _openingBalanceUsdMeta =
      const VerificationMeta('openingBalanceUsd');
  @override
  late final GeneratedColumn<double> openingBalanceUsd =
      GeneratedColumn<double>('opening_balance_usd', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _closingBalanceUsdMeta =
      const VerificationMeta('closingBalanceUsd');
  @override
  late final GeneratedColumn<double> closingBalanceUsd =
      GeneratedColumn<double>('closing_balance_usd', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _expectedBalanceUsdMeta =
      const VerificationMeta('expectedBalanceUsd');
  @override
  late final GeneratedColumn<double> expectedBalanceUsd =
      GeneratedColumn<double>('expected_balance_usd', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalSalesMeta =
      const VerificationMeta('totalSales');
  @override
  late final GeneratedColumn<double> totalSales = GeneratedColumn<double>(
      'total_sales', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalReturnsMeta =
      const VerificationMeta('totalReturns');
  @override
  late final GeneratedColumn<double> totalReturns = GeneratedColumn<double>(
      'total_returns', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalExpensesMeta =
      const VerificationMeta('totalExpenses');
  @override
  late final GeneratedColumn<double> totalExpenses = GeneratedColumn<double>(
      'total_expenses', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalIncomeMeta =
      const VerificationMeta('totalIncome');
  @override
  late final GeneratedColumn<double> totalIncome = GeneratedColumn<double>(
      'total_income', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalSalesUsdMeta =
      const VerificationMeta('totalSalesUsd');
  @override
  late final GeneratedColumn<double> totalSalesUsd = GeneratedColumn<double>(
      'total_sales_usd', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalReturnsUsdMeta =
      const VerificationMeta('totalReturnsUsd');
  @override
  late final GeneratedColumn<double> totalReturnsUsd = GeneratedColumn<double>(
      'total_returns_usd', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalExpensesUsdMeta =
      const VerificationMeta('totalExpensesUsd');
  @override
  late final GeneratedColumn<double> totalExpensesUsd = GeneratedColumn<double>(
      'total_expenses_usd', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalIncomeUsdMeta =
      const VerificationMeta('totalIncomeUsd');
  @override
  late final GeneratedColumn<double> totalIncomeUsd = GeneratedColumn<double>(
      'total_income_usd', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _transactionCountMeta =
      const VerificationMeta('transactionCount');
  @override
  late final GeneratedColumn<int> transactionCount = GeneratedColumn<int>(
      'transaction_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('open'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _openedAtMeta =
      const VerificationMeta('openedAt');
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
      'opened_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _closedAtMeta =
      const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
      'closed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        shiftNumber,
        openingBalance,
        closingBalance,
        expectedBalance,
        difference,
        openingBalanceUsd,
        closingBalanceUsd,
        expectedBalanceUsd,
        exchangeRate,
        totalSales,
        totalReturns,
        totalExpenses,
        totalIncome,
        totalSalesUsd,
        totalReturnsUsd,
        totalExpensesUsd,
        totalIncomeUsd,
        transactionCount,
        status,
        notes,
        syncStatus,
        openedAt,
        closedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(Insertable<Shift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_number')) {
      context.handle(
          _shiftNumberMeta,
          shiftNumber.isAcceptableOrUnknown(
              data['shift_number']!, _shiftNumberMeta));
    } else if (isInserting) {
      context.missing(_shiftNumberMeta);
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
          _openingBalanceMeta,
          openingBalance.isAcceptableOrUnknown(
              data['opening_balance']!, _openingBalanceMeta));
    } else if (isInserting) {
      context.missing(_openingBalanceMeta);
    }
    if (data.containsKey('closing_balance')) {
      context.handle(
          _closingBalanceMeta,
          closingBalance.isAcceptableOrUnknown(
              data['closing_balance']!, _closingBalanceMeta));
    }
    if (data.containsKey('expected_balance')) {
      context.handle(
          _expectedBalanceMeta,
          expectedBalance.isAcceptableOrUnknown(
              data['expected_balance']!, _expectedBalanceMeta));
    }
    if (data.containsKey('difference')) {
      context.handle(
          _differenceMeta,
          difference.isAcceptableOrUnknown(
              data['difference']!, _differenceMeta));
    }
    if (data.containsKey('opening_balance_usd')) {
      context.handle(
          _openingBalanceUsdMeta,
          openingBalanceUsd.isAcceptableOrUnknown(
              data['opening_balance_usd']!, _openingBalanceUsdMeta));
    }
    if (data.containsKey('closing_balance_usd')) {
      context.handle(
          _closingBalanceUsdMeta,
          closingBalanceUsd.isAcceptableOrUnknown(
              data['closing_balance_usd']!, _closingBalanceUsdMeta));
    }
    if (data.containsKey('expected_balance_usd')) {
      context.handle(
          _expectedBalanceUsdMeta,
          expectedBalanceUsd.isAcceptableOrUnknown(
              data['expected_balance_usd']!, _expectedBalanceUsdMeta));
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('total_sales')) {
      context.handle(
          _totalSalesMeta,
          totalSales.isAcceptableOrUnknown(
              data['total_sales']!, _totalSalesMeta));
    }
    if (data.containsKey('total_returns')) {
      context.handle(
          _totalReturnsMeta,
          totalReturns.isAcceptableOrUnknown(
              data['total_returns']!, _totalReturnsMeta));
    }
    if (data.containsKey('total_expenses')) {
      context.handle(
          _totalExpensesMeta,
          totalExpenses.isAcceptableOrUnknown(
              data['total_expenses']!, _totalExpensesMeta));
    }
    if (data.containsKey('total_income')) {
      context.handle(
          _totalIncomeMeta,
          totalIncome.isAcceptableOrUnknown(
              data['total_income']!, _totalIncomeMeta));
    }
    if (data.containsKey('total_sales_usd')) {
      context.handle(
          _totalSalesUsdMeta,
          totalSalesUsd.isAcceptableOrUnknown(
              data['total_sales_usd']!, _totalSalesUsdMeta));
    }
    if (data.containsKey('total_returns_usd')) {
      context.handle(
          _totalReturnsUsdMeta,
          totalReturnsUsd.isAcceptableOrUnknown(
              data['total_returns_usd']!, _totalReturnsUsdMeta));
    }
    if (data.containsKey('total_expenses_usd')) {
      context.handle(
          _totalExpensesUsdMeta,
          totalExpensesUsd.isAcceptableOrUnknown(
              data['total_expenses_usd']!, _totalExpensesUsdMeta));
    }
    if (data.containsKey('total_income_usd')) {
      context.handle(
          _totalIncomeUsdMeta,
          totalIncomeUsd.isAcceptableOrUnknown(
              data['total_income_usd']!, _totalIncomeUsdMeta));
    }
    if (data.containsKey('transaction_count')) {
      context.handle(
          _transactionCountMeta,
          transactionCount.isAcceptableOrUnknown(
              data['transaction_count']!, _transactionCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('opened_at')) {
      context.handle(_openedAtMeta,
          openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta));
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta,
          closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shift(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      shiftNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_number'])!,
      openingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}opening_balance'])!,
      closingBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}closing_balance']),
      expectedBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}expected_balance']),
      difference: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}difference']),
      openingBalanceUsd: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}opening_balance_usd']),
      closingBalanceUsd: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}closing_balance_usd']),
      expectedBalanceUsd: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}expected_balance_usd']),
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate']),
      totalSales: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_sales'])!,
      totalReturns: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_returns'])!,
      totalExpenses: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_expenses'])!,
      totalIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_income'])!,
      totalSalesUsd: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_sales_usd'])!,
      totalReturnsUsd: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_returns_usd'])!,
      totalExpensesUsd: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_expenses_usd'])!,
      totalIncomeUsd: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_income_usd'])!,
      transactionCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      openedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}opened_at'])!,
      closedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}closed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class Shift extends DataClass implements Insertable<Shift> {
  final String id;
  final String shiftNumber;
  final double openingBalance;
  final double? closingBalance;
  final double? expectedBalance;
  final double? difference;
  final double? openingBalanceUsd;
  final double? closingBalanceUsd;
  final double? expectedBalanceUsd;
  final double? exchangeRate;
  final double totalSales;
  final double totalReturns;
  final double totalExpenses;
  final double totalIncome;
  final double totalSalesUsd;
  final double totalReturnsUsd;
  final double totalExpensesUsd;
  final double totalIncomeUsd;
  final int transactionCount;
  final String status;
  final String? notes;
  final String syncStatus;
  final DateTime openedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Shift(
      {required this.id,
      required this.shiftNumber,
      required this.openingBalance,
      this.closingBalance,
      this.expectedBalance,
      this.difference,
      this.openingBalanceUsd,
      this.closingBalanceUsd,
      this.expectedBalanceUsd,
      this.exchangeRate,
      required this.totalSales,
      required this.totalReturns,
      required this.totalExpenses,
      required this.totalIncome,
      required this.totalSalesUsd,
      required this.totalReturnsUsd,
      required this.totalExpensesUsd,
      required this.totalIncomeUsd,
      required this.transactionCount,
      required this.status,
      this.notes,
      required this.syncStatus,
      required this.openedAt,
      this.closedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shift_number'] = Variable<String>(shiftNumber);
    map['opening_balance'] = Variable<double>(openingBalance);
    if (!nullToAbsent || closingBalance != null) {
      map['closing_balance'] = Variable<double>(closingBalance);
    }
    if (!nullToAbsent || expectedBalance != null) {
      map['expected_balance'] = Variable<double>(expectedBalance);
    }
    if (!nullToAbsent || difference != null) {
      map['difference'] = Variable<double>(difference);
    }
    if (!nullToAbsent || openingBalanceUsd != null) {
      map['opening_balance_usd'] = Variable<double>(openingBalanceUsd);
    }
    if (!nullToAbsent || closingBalanceUsd != null) {
      map['closing_balance_usd'] = Variable<double>(closingBalanceUsd);
    }
    if (!nullToAbsent || expectedBalanceUsd != null) {
      map['expected_balance_usd'] = Variable<double>(expectedBalanceUsd);
    }
    if (!nullToAbsent || exchangeRate != null) {
      map['exchange_rate'] = Variable<double>(exchangeRate);
    }
    map['total_sales'] = Variable<double>(totalSales);
    map['total_returns'] = Variable<double>(totalReturns);
    map['total_expenses'] = Variable<double>(totalExpenses);
    map['total_income'] = Variable<double>(totalIncome);
    map['total_sales_usd'] = Variable<double>(totalSalesUsd);
    map['total_returns_usd'] = Variable<double>(totalReturnsUsd);
    map['total_expenses_usd'] = Variable<double>(totalExpensesUsd);
    map['total_income_usd'] = Variable<double>(totalIncomeUsd);
    map['transaction_count'] = Variable<int>(transactionCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      shiftNumber: Value(shiftNumber),
      openingBalance: Value(openingBalance),
      closingBalance: closingBalance == null && nullToAbsent
          ? const Value.absent()
          : Value(closingBalance),
      expectedBalance: expectedBalance == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedBalance),
      difference: difference == null && nullToAbsent
          ? const Value.absent()
          : Value(difference),
      openingBalanceUsd: openingBalanceUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(openingBalanceUsd),
      closingBalanceUsd: closingBalanceUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(closingBalanceUsd),
      expectedBalanceUsd: expectedBalanceUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedBalanceUsd),
      exchangeRate: exchangeRate == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRate),
      totalSales: Value(totalSales),
      totalReturns: Value(totalReturns),
      totalExpenses: Value(totalExpenses),
      totalIncome: Value(totalIncome),
      totalSalesUsd: Value(totalSalesUsd),
      totalReturnsUsd: Value(totalReturnsUsd),
      totalExpensesUsd: Value(totalExpensesUsd),
      totalIncomeUsd: Value(totalIncomeUsd),
      transactionCount: Value(transactionCount),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncStatus: Value(syncStatus),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Shift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shift(
      id: serializer.fromJson<String>(json['id']),
      shiftNumber: serializer.fromJson<String>(json['shiftNumber']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      closingBalance: serializer.fromJson<double?>(json['closingBalance']),
      expectedBalance: serializer.fromJson<double?>(json['expectedBalance']),
      difference: serializer.fromJson<double?>(json['difference']),
      openingBalanceUsd:
          serializer.fromJson<double?>(json['openingBalanceUsd']),
      closingBalanceUsd:
          serializer.fromJson<double?>(json['closingBalanceUsd']),
      expectedBalanceUsd:
          serializer.fromJson<double?>(json['expectedBalanceUsd']),
      exchangeRate: serializer.fromJson<double?>(json['exchangeRate']),
      totalSales: serializer.fromJson<double>(json['totalSales']),
      totalReturns: serializer.fromJson<double>(json['totalReturns']),
      totalExpenses: serializer.fromJson<double>(json['totalExpenses']),
      totalIncome: serializer.fromJson<double>(json['totalIncome']),
      totalSalesUsd: serializer.fromJson<double>(json['totalSalesUsd']),
      totalReturnsUsd: serializer.fromJson<double>(json['totalReturnsUsd']),
      totalExpensesUsd: serializer.fromJson<double>(json['totalExpensesUsd']),
      totalIncomeUsd: serializer.fromJson<double>(json['totalIncomeUsd']),
      transactionCount: serializer.fromJson<int>(json['transactionCount']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftNumber': serializer.toJson<String>(shiftNumber),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'closingBalance': serializer.toJson<double?>(closingBalance),
      'expectedBalance': serializer.toJson<double?>(expectedBalance),
      'difference': serializer.toJson<double?>(difference),
      'openingBalanceUsd': serializer.toJson<double?>(openingBalanceUsd),
      'closingBalanceUsd': serializer.toJson<double?>(closingBalanceUsd),
      'expectedBalanceUsd': serializer.toJson<double?>(expectedBalanceUsd),
      'exchangeRate': serializer.toJson<double?>(exchangeRate),
      'totalSales': serializer.toJson<double>(totalSales),
      'totalReturns': serializer.toJson<double>(totalReturns),
      'totalExpenses': serializer.toJson<double>(totalExpenses),
      'totalIncome': serializer.toJson<double>(totalIncome),
      'totalSalesUsd': serializer.toJson<double>(totalSalesUsd),
      'totalReturnsUsd': serializer.toJson<double>(totalReturnsUsd),
      'totalExpensesUsd': serializer.toJson<double>(totalExpensesUsd),
      'totalIncomeUsd': serializer.toJson<double>(totalIncomeUsd),
      'transactionCount': serializer.toJson<int>(transactionCount),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Shift copyWith(
          {String? id,
          String? shiftNumber,
          double? openingBalance,
          Value<double?> closingBalance = const Value.absent(),
          Value<double?> expectedBalance = const Value.absent(),
          Value<double?> difference = const Value.absent(),
          Value<double?> openingBalanceUsd = const Value.absent(),
          Value<double?> closingBalanceUsd = const Value.absent(),
          Value<double?> expectedBalanceUsd = const Value.absent(),
          Value<double?> exchangeRate = const Value.absent(),
          double? totalSales,
          double? totalReturns,
          double? totalExpenses,
          double? totalIncome,
          double? totalSalesUsd,
          double? totalReturnsUsd,
          double? totalExpensesUsd,
          double? totalIncomeUsd,
          int? transactionCount,
          String? status,
          Value<String?> notes = const Value.absent(),
          String? syncStatus,
          DateTime? openedAt,
          Value<DateTime?> closedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Shift(
        id: id ?? this.id,
        shiftNumber: shiftNumber ?? this.shiftNumber,
        openingBalance: openingBalance ?? this.openingBalance,
        closingBalance:
            closingBalance.present ? closingBalance.value : this.closingBalance,
        expectedBalance: expectedBalance.present
            ? expectedBalance.value
            : this.expectedBalance,
        difference: difference.present ? difference.value : this.difference,
        openingBalanceUsd: openingBalanceUsd.present
            ? openingBalanceUsd.value
            : this.openingBalanceUsd,
        closingBalanceUsd: closingBalanceUsd.present
            ? closingBalanceUsd.value
            : this.closingBalanceUsd,
        expectedBalanceUsd: expectedBalanceUsd.present
            ? expectedBalanceUsd.value
            : this.expectedBalanceUsd,
        exchangeRate:
            exchangeRate.present ? exchangeRate.value : this.exchangeRate,
        totalSales: totalSales ?? this.totalSales,
        totalReturns: totalReturns ?? this.totalReturns,
        totalExpenses: totalExpenses ?? this.totalExpenses,
        totalIncome: totalIncome ?? this.totalIncome,
        totalSalesUsd: totalSalesUsd ?? this.totalSalesUsd,
        totalReturnsUsd: totalReturnsUsd ?? this.totalReturnsUsd,
        totalExpensesUsd: totalExpensesUsd ?? this.totalExpensesUsd,
        totalIncomeUsd: totalIncomeUsd ?? this.totalIncomeUsd,
        transactionCount: transactionCount ?? this.transactionCount,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
        openedAt: openedAt ?? this.openedAt,
        closedAt: closedAt.present ? closedAt.value : this.closedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Shift copyWithCompanion(ShiftsCompanion data) {
    return Shift(
      id: data.id.present ? data.id.value : this.id,
      shiftNumber:
          data.shiftNumber.present ? data.shiftNumber.value : this.shiftNumber,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      closingBalance: data.closingBalance.present
          ? data.closingBalance.value
          : this.closingBalance,
      expectedBalance: data.expectedBalance.present
          ? data.expectedBalance.value
          : this.expectedBalance,
      difference:
          data.difference.present ? data.difference.value : this.difference,
      openingBalanceUsd: data.openingBalanceUsd.present
          ? data.openingBalanceUsd.value
          : this.openingBalanceUsd,
      closingBalanceUsd: data.closingBalanceUsd.present
          ? data.closingBalanceUsd.value
          : this.closingBalanceUsd,
      expectedBalanceUsd: data.expectedBalanceUsd.present
          ? data.expectedBalanceUsd.value
          : this.expectedBalanceUsd,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      totalSales:
          data.totalSales.present ? data.totalSales.value : this.totalSales,
      totalReturns: data.totalReturns.present
          ? data.totalReturns.value
          : this.totalReturns,
      totalExpenses: data.totalExpenses.present
          ? data.totalExpenses.value
          : this.totalExpenses,
      totalIncome:
          data.totalIncome.present ? data.totalIncome.value : this.totalIncome,
      totalSalesUsd: data.totalSalesUsd.present
          ? data.totalSalesUsd.value
          : this.totalSalesUsd,
      totalReturnsUsd: data.totalReturnsUsd.present
          ? data.totalReturnsUsd.value
          : this.totalReturnsUsd,
      totalExpensesUsd: data.totalExpensesUsd.present
          ? data.totalExpensesUsd.value
          : this.totalExpensesUsd,
      totalIncomeUsd: data.totalIncomeUsd.present
          ? data.totalIncomeUsd.value
          : this.totalIncomeUsd,
      transactionCount: data.transactionCount.present
          ? data.transactionCount.value
          : this.transactionCount,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shift(')
          ..write('id: $id, ')
          ..write('shiftNumber: $shiftNumber, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('closingBalance: $closingBalance, ')
          ..write('expectedBalance: $expectedBalance, ')
          ..write('difference: $difference, ')
          ..write('openingBalanceUsd: $openingBalanceUsd, ')
          ..write('closingBalanceUsd: $closingBalanceUsd, ')
          ..write('expectedBalanceUsd: $expectedBalanceUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('totalSales: $totalSales, ')
          ..write('totalReturns: $totalReturns, ')
          ..write('totalExpenses: $totalExpenses, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalSalesUsd: $totalSalesUsd, ')
          ..write('totalReturnsUsd: $totalReturnsUsd, ')
          ..write('totalExpensesUsd: $totalExpensesUsd, ')
          ..write('totalIncomeUsd: $totalIncomeUsd, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        shiftNumber,
        openingBalance,
        closingBalance,
        expectedBalance,
        difference,
        openingBalanceUsd,
        closingBalanceUsd,
        expectedBalanceUsd,
        exchangeRate,
        totalSales,
        totalReturns,
        totalExpenses,
        totalIncome,
        totalSalesUsd,
        totalReturnsUsd,
        totalExpensesUsd,
        totalIncomeUsd,
        transactionCount,
        status,
        notes,
        syncStatus,
        openedAt,
        closedAt,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shift &&
          other.id == this.id &&
          other.shiftNumber == this.shiftNumber &&
          other.openingBalance == this.openingBalance &&
          other.closingBalance == this.closingBalance &&
          other.expectedBalance == this.expectedBalance &&
          other.difference == this.difference &&
          other.openingBalanceUsd == this.openingBalanceUsd &&
          other.closingBalanceUsd == this.closingBalanceUsd &&
          other.expectedBalanceUsd == this.expectedBalanceUsd &&
          other.exchangeRate == this.exchangeRate &&
          other.totalSales == this.totalSales &&
          other.totalReturns == this.totalReturns &&
          other.totalExpenses == this.totalExpenses &&
          other.totalIncome == this.totalIncome &&
          other.totalSalesUsd == this.totalSalesUsd &&
          other.totalReturnsUsd == this.totalReturnsUsd &&
          other.totalExpensesUsd == this.totalExpensesUsd &&
          other.totalIncomeUsd == this.totalIncomeUsd &&
          other.transactionCount == this.transactionCount &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShiftsCompanion extends UpdateCompanion<Shift> {
  final Value<String> id;
  final Value<String> shiftNumber;
  final Value<double> openingBalance;
  final Value<double?> closingBalance;
  final Value<double?> expectedBalance;
  final Value<double?> difference;
  final Value<double?> openingBalanceUsd;
  final Value<double?> closingBalanceUsd;
  final Value<double?> expectedBalanceUsd;
  final Value<double?> exchangeRate;
  final Value<double> totalSales;
  final Value<double> totalReturns;
  final Value<double> totalExpenses;
  final Value<double> totalIncome;
  final Value<double> totalSalesUsd;
  final Value<double> totalReturnsUsd;
  final Value<double> totalExpensesUsd;
  final Value<double> totalIncomeUsd;
  final Value<int> transactionCount;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.shiftNumber = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.closingBalance = const Value.absent(),
    this.expectedBalance = const Value.absent(),
    this.difference = const Value.absent(),
    this.openingBalanceUsd = const Value.absent(),
    this.closingBalanceUsd = const Value.absent(),
    this.expectedBalanceUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.totalSales = const Value.absent(),
    this.totalReturns = const Value.absent(),
    this.totalExpenses = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.totalSalesUsd = const Value.absent(),
    this.totalReturnsUsd = const Value.absent(),
    this.totalExpensesUsd = const Value.absent(),
    this.totalIncomeUsd = const Value.absent(),
    this.transactionCount = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required String shiftNumber,
    required double openingBalance,
    this.closingBalance = const Value.absent(),
    this.expectedBalance = const Value.absent(),
    this.difference = const Value.absent(),
    this.openingBalanceUsd = const Value.absent(),
    this.closingBalanceUsd = const Value.absent(),
    this.expectedBalanceUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.totalSales = const Value.absent(),
    this.totalReturns = const Value.absent(),
    this.totalExpenses = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.totalSalesUsd = const Value.absent(),
    this.totalReturnsUsd = const Value.absent(),
    this.totalExpensesUsd = const Value.absent(),
    this.totalIncomeUsd = const Value.absent(),
    this.transactionCount = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        shiftNumber = Value(shiftNumber),
        openingBalance = Value(openingBalance);
  static Insertable<Shift> custom({
    Expression<String>? id,
    Expression<String>? shiftNumber,
    Expression<double>? openingBalance,
    Expression<double>? closingBalance,
    Expression<double>? expectedBalance,
    Expression<double>? difference,
    Expression<double>? openingBalanceUsd,
    Expression<double>? closingBalanceUsd,
    Expression<double>? expectedBalanceUsd,
    Expression<double>? exchangeRate,
    Expression<double>? totalSales,
    Expression<double>? totalReturns,
    Expression<double>? totalExpenses,
    Expression<double>? totalIncome,
    Expression<double>? totalSalesUsd,
    Expression<double>? totalReturnsUsd,
    Expression<double>? totalExpensesUsd,
    Expression<double>? totalIncomeUsd,
    Expression<int>? transactionCount,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftNumber != null) 'shift_number': shiftNumber,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (closingBalance != null) 'closing_balance': closingBalance,
      if (expectedBalance != null) 'expected_balance': expectedBalance,
      if (difference != null) 'difference': difference,
      if (openingBalanceUsd != null) 'opening_balance_usd': openingBalanceUsd,
      if (closingBalanceUsd != null) 'closing_balance_usd': closingBalanceUsd,
      if (expectedBalanceUsd != null)
        'expected_balance_usd': expectedBalanceUsd,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (totalSales != null) 'total_sales': totalSales,
      if (totalReturns != null) 'total_returns': totalReturns,
      if (totalExpenses != null) 'total_expenses': totalExpenses,
      if (totalIncome != null) 'total_income': totalIncome,
      if (totalSalesUsd != null) 'total_sales_usd': totalSalesUsd,
      if (totalReturnsUsd != null) 'total_returns_usd': totalReturnsUsd,
      if (totalExpensesUsd != null) 'total_expenses_usd': totalExpensesUsd,
      if (totalIncomeUsd != null) 'total_income_usd': totalIncomeUsd,
      if (transactionCount != null) 'transaction_count': transactionCount,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith(
      {Value<String>? id,
      Value<String>? shiftNumber,
      Value<double>? openingBalance,
      Value<double?>? closingBalance,
      Value<double?>? expectedBalance,
      Value<double?>? difference,
      Value<double?>? openingBalanceUsd,
      Value<double?>? closingBalanceUsd,
      Value<double?>? expectedBalanceUsd,
      Value<double?>? exchangeRate,
      Value<double>? totalSales,
      Value<double>? totalReturns,
      Value<double>? totalExpenses,
      Value<double>? totalIncome,
      Value<double>? totalSalesUsd,
      Value<double>? totalReturnsUsd,
      Value<double>? totalExpensesUsd,
      Value<double>? totalIncomeUsd,
      Value<int>? transactionCount,
      Value<String>? status,
      Value<String?>? notes,
      Value<String>? syncStatus,
      Value<DateTime>? openedAt,
      Value<DateTime?>? closedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ShiftsCompanion(
      id: id ?? this.id,
      shiftNumber: shiftNumber ?? this.shiftNumber,
      openingBalance: openingBalance ?? this.openingBalance,
      closingBalance: closingBalance ?? this.closingBalance,
      expectedBalance: expectedBalance ?? this.expectedBalance,
      difference: difference ?? this.difference,
      openingBalanceUsd: openingBalanceUsd ?? this.openingBalanceUsd,
      closingBalanceUsd: closingBalanceUsd ?? this.closingBalanceUsd,
      expectedBalanceUsd: expectedBalanceUsd ?? this.expectedBalanceUsd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      totalSales: totalSales ?? this.totalSales,
      totalReturns: totalReturns ?? this.totalReturns,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalIncome: totalIncome ?? this.totalIncome,
      totalSalesUsd: totalSalesUsd ?? this.totalSalesUsd,
      totalReturnsUsd: totalReturnsUsd ?? this.totalReturnsUsd,
      totalExpensesUsd: totalExpensesUsd ?? this.totalExpensesUsd,
      totalIncomeUsd: totalIncomeUsd ?? this.totalIncomeUsd,
      transactionCount: transactionCount ?? this.transactionCount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftNumber.present) {
      map['shift_number'] = Variable<String>(shiftNumber.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (closingBalance.present) {
      map['closing_balance'] = Variable<double>(closingBalance.value);
    }
    if (expectedBalance.present) {
      map['expected_balance'] = Variable<double>(expectedBalance.value);
    }
    if (difference.present) {
      map['difference'] = Variable<double>(difference.value);
    }
    if (openingBalanceUsd.present) {
      map['opening_balance_usd'] = Variable<double>(openingBalanceUsd.value);
    }
    if (closingBalanceUsd.present) {
      map['closing_balance_usd'] = Variable<double>(closingBalanceUsd.value);
    }
    if (expectedBalanceUsd.present) {
      map['expected_balance_usd'] = Variable<double>(expectedBalanceUsd.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (totalSales.present) {
      map['total_sales'] = Variable<double>(totalSales.value);
    }
    if (totalReturns.present) {
      map['total_returns'] = Variable<double>(totalReturns.value);
    }
    if (totalExpenses.present) {
      map['total_expenses'] = Variable<double>(totalExpenses.value);
    }
    if (totalIncome.present) {
      map['total_income'] = Variable<double>(totalIncome.value);
    }
    if (totalSalesUsd.present) {
      map['total_sales_usd'] = Variable<double>(totalSalesUsd.value);
    }
    if (totalReturnsUsd.present) {
      map['total_returns_usd'] = Variable<double>(totalReturnsUsd.value);
    }
    if (totalExpensesUsd.present) {
      map['total_expenses_usd'] = Variable<double>(totalExpensesUsd.value);
    }
    if (totalIncomeUsd.present) {
      map['total_income_usd'] = Variable<double>(totalIncomeUsd.value);
    }
    if (transactionCount.present) {
      map['transaction_count'] = Variable<int>(transactionCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('shiftNumber: $shiftNumber, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('closingBalance: $closingBalance, ')
          ..write('expectedBalance: $expectedBalance, ')
          ..write('difference: $difference, ')
          ..write('openingBalanceUsd: $openingBalanceUsd, ')
          ..write('closingBalanceUsd: $closingBalanceUsd, ')
          ..write('expectedBalanceUsd: $expectedBalanceUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('totalSales: $totalSales, ')
          ..write('totalReturns: $totalReturns, ')
          ..write('totalExpenses: $totalExpenses, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalSalesUsd: $totalSalesUsd, ')
          ..write('totalReturnsUsd: $totalReturnsUsd, ')
          ..write('totalExpensesUsd: $totalExpensesUsd, ')
          ..write('totalIncomeUsd: $totalIncomeUsd, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES customers (id)'));
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
      'supplier_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES suppliers (id)'));
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _taxAmountMeta =
      const VerificationMeta('taxAmount');
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
      'tax_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountAmountMeta =
      const VerificationMeta('discountAmount');
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
      'discount_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalUsdMeta =
      const VerificationMeta('totalUsd');
  @override
  late final GeneratedColumn<double> totalUsd = GeneratedColumn<double>(
      'total_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _paidAmountUsdMeta =
      const VerificationMeta('paidAmountUsd');
  @override
  late final GeneratedColumn<double> paidAmountUsd = GeneratedColumn<double>(
      'paid_amount_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('completed'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shiftIdMeta =
      const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
      'shift_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES shifts (id)'));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _invoiceDateMeta =
      const VerificationMeta('invoiceDate');
  @override
  late final GeneratedColumn<DateTime> invoiceDate = GeneratedColumn<DateTime>(
      'invoice_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceNumber,
        type,
        customerId,
        supplierId,
        warehouseId,
        subtotal,
        taxAmount,
        discountAmount,
        total,
        paidAmount,
        totalUsd,
        paidAmountUsd,
        exchangeRate,
        paymentMethod,
        status,
        notes,
        shiftId,
        syncStatus,
        invoiceDate,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(Insertable<Invoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('tax_amount')) {
      context.handle(_taxAmountMeta,
          taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta));
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
          _discountAmountMeta,
          discountAmount.isAcceptableOrUnknown(
              data['discount_amount']!, _discountAmountMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('total_usd')) {
      context.handle(_totalUsdMeta,
          totalUsd.isAcceptableOrUnknown(data['total_usd']!, _totalUsdMeta));
    }
    if (data.containsKey('paid_amount_usd')) {
      context.handle(
          _paidAmountUsdMeta,
          paidAmountUsd.isAcceptableOrUnknown(
              data['paid_amount_usd']!, _paidAmountUsdMeta));
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta,
          shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
          _invoiceDateMeta,
          invoiceDate.isAcceptableOrUnknown(
              data['invoice_date']!, _invoiceDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_id']),
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id']),
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      taxAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_amount'])!,
      discountAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}discount_amount'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}paid_amount'])!,
      totalUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_usd']),
      paidAmountUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}paid_amount_usd']),
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate']),
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      shiftId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      invoiceDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}invoice_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String invoiceNumber;
  final String type;
  final String? customerId;
  final String? supplierId;
  final String? warehouseId;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double total;
  final double paidAmount;
  final double? totalUsd;
  final double? paidAmountUsd;
  final double? exchangeRate;
  final String paymentMethod;
  final String status;
  final String? notes;
  final String? shiftId;
  final String syncStatus;
  final DateTime invoiceDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Invoice(
      {required this.id,
      required this.invoiceNumber,
      required this.type,
      this.customerId,
      this.supplierId,
      this.warehouseId,
      required this.subtotal,
      required this.taxAmount,
      required this.discountAmount,
      required this.total,
      required this.paidAmount,
      this.totalUsd,
      this.paidAmountUsd,
      this.exchangeRate,
      required this.paymentMethod,
      required this.status,
      this.notes,
      this.shiftId,
      required this.syncStatus,
      required this.invoiceDate,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    if (!nullToAbsent || warehouseId != null) {
      map['warehouse_id'] = Variable<String>(warehouseId);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['total'] = Variable<double>(total);
    map['paid_amount'] = Variable<double>(paidAmount);
    if (!nullToAbsent || totalUsd != null) {
      map['total_usd'] = Variable<double>(totalUsd);
    }
    if (!nullToAbsent || paidAmountUsd != null) {
      map['paid_amount_usd'] = Variable<double>(paidAmountUsd);
    }
    if (!nullToAbsent || exchangeRate != null) {
      map['exchange_rate'] = Variable<double>(exchangeRate);
    }
    map['payment_method'] = Variable<String>(paymentMethod);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['invoice_date'] = Variable<DateTime>(invoiceDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      type: Value(type),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      warehouseId: warehouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouseId),
      subtotal: Value(subtotal),
      taxAmount: Value(taxAmount),
      discountAmount: Value(discountAmount),
      total: Value(total),
      paidAmount: Value(paidAmount),
      totalUsd: totalUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(totalUsd),
      paidAmountUsd: paidAmountUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAmountUsd),
      exchangeRate: exchangeRate == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRate),
      paymentMethod: Value(paymentMethod),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      syncStatus: Value(syncStatus),
      invoiceDate: Value(invoiceDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      type: serializer.fromJson<String>(json['type']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      warehouseId: serializer.fromJson<String?>(json['warehouseId']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      total: serializer.fromJson<double>(json['total']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      totalUsd: serializer.fromJson<double?>(json['totalUsd']),
      paidAmountUsd: serializer.fromJson<double?>(json['paidAmountUsd']),
      exchangeRate: serializer.fromJson<double?>(json['exchangeRate']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      invoiceDate: serializer.fromJson<DateTime>(json['invoiceDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'type': serializer.toJson<String>(type),
      'customerId': serializer.toJson<String?>(customerId),
      'supplierId': serializer.toJson<String?>(supplierId),
      'warehouseId': serializer.toJson<String?>(warehouseId),
      'subtotal': serializer.toJson<double>(subtotal),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'total': serializer.toJson<double>(total),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'totalUsd': serializer.toJson<double?>(totalUsd),
      'paidAmountUsd': serializer.toJson<double?>(paidAmountUsd),
      'exchangeRate': serializer.toJson<double?>(exchangeRate),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'shiftId': serializer.toJson<String?>(shiftId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'invoiceDate': serializer.toJson<DateTime>(invoiceDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Invoice copyWith(
          {String? id,
          String? invoiceNumber,
          String? type,
          Value<String?> customerId = const Value.absent(),
          Value<String?> supplierId = const Value.absent(),
          Value<String?> warehouseId = const Value.absent(),
          double? subtotal,
          double? taxAmount,
          double? discountAmount,
          double? total,
          double? paidAmount,
          Value<double?> totalUsd = const Value.absent(),
          Value<double?> paidAmountUsd = const Value.absent(),
          Value<double?> exchangeRate = const Value.absent(),
          String? paymentMethod,
          String? status,
          Value<String?> notes = const Value.absent(),
          Value<String?> shiftId = const Value.absent(),
          String? syncStatus,
          DateTime? invoiceDate,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Invoice(
        id: id ?? this.id,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        type: type ?? this.type,
        customerId: customerId.present ? customerId.value : this.customerId,
        supplierId: supplierId.present ? supplierId.value : this.supplierId,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
        subtotal: subtotal ?? this.subtotal,
        taxAmount: taxAmount ?? this.taxAmount,
        discountAmount: discountAmount ?? this.discountAmount,
        total: total ?? this.total,
        paidAmount: paidAmount ?? this.paidAmount,
        totalUsd: totalUsd.present ? totalUsd.value : this.totalUsd,
        paidAmountUsd:
            paidAmountUsd.present ? paidAmountUsd.value : this.paidAmountUsd,
        exchangeRate:
            exchangeRate.present ? exchangeRate.value : this.exchangeRate,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        shiftId: shiftId.present ? shiftId.value : this.shiftId,
        syncStatus: syncStatus ?? this.syncStatus,
        invoiceDate: invoiceDate ?? this.invoiceDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      type: data.type.present ? data.type.value : this.type,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      total: data.total.present ? data.total.value : this.total,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      totalUsd: data.totalUsd.present ? data.totalUsd.value : this.totalUsd,
      paidAmountUsd: data.paidAmountUsd.present
          ? data.paidAmountUsd.value
          : this.paidAmountUsd,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      invoiceDate:
          data.invoiceDate.present ? data.invoiceDate.value : this.invoiceDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('type: $type, ')
          ..write('customerId: $customerId, ')
          ..write('supplierId: $supplierId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('total: $total, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('totalUsd: $totalUsd, ')
          ..write('paidAmountUsd: $paidAmountUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('shiftId: $shiftId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        invoiceNumber,
        type,
        customerId,
        supplierId,
        warehouseId,
        subtotal,
        taxAmount,
        discountAmount,
        total,
        paidAmount,
        totalUsd,
        paidAmountUsd,
        exchangeRate,
        paymentMethod,
        status,
        notes,
        shiftId,
        syncStatus,
        invoiceDate,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.type == this.type &&
          other.customerId == this.customerId &&
          other.supplierId == this.supplierId &&
          other.warehouseId == this.warehouseId &&
          other.subtotal == this.subtotal &&
          other.taxAmount == this.taxAmount &&
          other.discountAmount == this.discountAmount &&
          other.total == this.total &&
          other.paidAmount == this.paidAmount &&
          other.totalUsd == this.totalUsd &&
          other.paidAmountUsd == this.paidAmountUsd &&
          other.exchangeRate == this.exchangeRate &&
          other.paymentMethod == this.paymentMethod &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.shiftId == this.shiftId &&
          other.syncStatus == this.syncStatus &&
          other.invoiceDate == this.invoiceDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> invoiceNumber;
  final Value<String> type;
  final Value<String?> customerId;
  final Value<String?> supplierId;
  final Value<String?> warehouseId;
  final Value<double> subtotal;
  final Value<double> taxAmount;
  final Value<double> discountAmount;
  final Value<double> total;
  final Value<double> paidAmount;
  final Value<double?> totalUsd;
  final Value<double?> paidAmountUsd;
  final Value<double?> exchangeRate;
  final Value<String> paymentMethod;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> shiftId;
  final Value<String> syncStatus;
  final Value<DateTime> invoiceDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.type = const Value.absent(),
    this.customerId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.total = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.totalUsd = const Value.absent(),
    this.paidAmountUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String invoiceNumber,
    required String type,
    this.customerId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.warehouseId = const Value.absent(),
    required double subtotal,
    this.taxAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    required double total,
    this.paidAmount = const Value.absent(),
    this.totalUsd = const Value.absent(),
    this.paidAmountUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceNumber = Value(invoiceNumber),
        type = Value(type),
        subtotal = Value(subtotal),
        total = Value(total);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? invoiceNumber,
    Expression<String>? type,
    Expression<String>? customerId,
    Expression<String>? supplierId,
    Expression<String>? warehouseId,
    Expression<double>? subtotal,
    Expression<double>? taxAmount,
    Expression<double>? discountAmount,
    Expression<double>? total,
    Expression<double>? paidAmount,
    Expression<double>? totalUsd,
    Expression<double>? paidAmountUsd,
    Expression<double>? exchangeRate,
    Expression<String>? paymentMethod,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? shiftId,
    Expression<String>? syncStatus,
    Expression<DateTime>? invoiceDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (type != null) 'type': type,
      if (customerId != null) 'customer_id': customerId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (subtotal != null) 'subtotal': subtotal,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (total != null) 'total': total,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (totalUsd != null) 'total_usd': totalUsd,
      if (paidAmountUsd != null) 'paid_amount_usd': paidAmountUsd,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (shiftId != null) 'shift_id': shiftId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceNumber,
      Value<String>? type,
      Value<String?>? customerId,
      Value<String?>? supplierId,
      Value<String?>? warehouseId,
      Value<double>? subtotal,
      Value<double>? taxAmount,
      Value<double>? discountAmount,
      Value<double>? total,
      Value<double>? paidAmount,
      Value<double?>? totalUsd,
      Value<double?>? paidAmountUsd,
      Value<double?>? exchangeRate,
      Value<String>? paymentMethod,
      Value<String>? status,
      Value<String?>? notes,
      Value<String?>? shiftId,
      Value<String>? syncStatus,
      Value<DateTime>? invoiceDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return InvoicesCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      type: type ?? this.type,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      warehouseId: warehouseId ?? this.warehouseId,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      totalUsd: totalUsd ?? this.totalUsd,
      paidAmountUsd: paidAmountUsd ?? this.paidAmountUsd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      shiftId: shiftId ?? this.shiftId,
      syncStatus: syncStatus ?? this.syncStatus,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (totalUsd.present) {
      map['total_usd'] = Variable<double>(totalUsd.value);
    }
    if (paidAmountUsd.present) {
      map['paid_amount_usd'] = Variable<double>(paidAmountUsd.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('type: $type, ')
          ..write('customerId: $customerId, ')
          ..write('supplierId: $supplierId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('total: $total, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('totalUsd: $totalUsd, ')
          ..write('paidAmountUsd: $paidAmountUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('shiftId: $shiftId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES invoices (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _costPriceMeta =
      const VerificationMeta('costPrice');
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
      'cost_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _costPriceUsdMeta =
      const VerificationMeta('costPriceUsd');
  @override
  late final GeneratedColumn<double> costPriceUsd = GeneratedColumn<double>(
      'cost_price_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _discountAmountMeta =
      const VerificationMeta('discountAmount');
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
      'discount_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _taxAmountMeta =
      const VerificationMeta('taxAmount');
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
      'tax_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceUsdMeta =
      const VerificationMeta('unitPriceUsd');
  @override
  late final GeneratedColumn<double> unitPriceUsd = GeneratedColumn<double>(
      'unit_price_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalUsdMeta =
      const VerificationMeta('totalUsd');
  @override
  late final GeneratedColumn<double> totalUsd = GeneratedColumn<double>(
      'total_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceId,
        productId,
        productName,
        quantity,
        unitPrice,
        purchasePrice,
        costPrice,
        costPriceUsd,
        discountAmount,
        taxAmount,
        total,
        unitPriceUsd,
        totalUsd,
        exchangeRate,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('cost_price')) {
      context.handle(_costPriceMeta,
          costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta));
    }
    if (data.containsKey('cost_price_usd')) {
      context.handle(
          _costPriceUsdMeta,
          costPriceUsd.isAcceptableOrUnknown(
              data['cost_price_usd']!, _costPriceUsdMeta));
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
          _discountAmountMeta,
          discountAmount.isAcceptableOrUnknown(
              data['discount_amount']!, _discountAmountMeta));
    }
    if (data.containsKey('tax_amount')) {
      context.handle(_taxAmountMeta,
          taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('unit_price_usd')) {
      context.handle(
          _unitPriceUsdMeta,
          unitPriceUsd.isAcceptableOrUnknown(
              data['unit_price_usd']!, _unitPriceUsdMeta));
    }
    if (data.containsKey('total_usd')) {
      context.handle(_totalUsdMeta,
          totalUsd.isAcceptableOrUnknown(data['total_usd']!, _totalUsdMeta));
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_price'])!,
      costPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price']),
      costPriceUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price_usd']),
      discountAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}discount_amount'])!,
      taxAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_amount'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      unitPriceUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price_usd']),
      totalUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_usd']),
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final String id;
  final String invoiceId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double purchasePrice;
  final double? costPrice;
  final double? costPriceUsd;
  final double discountAmount;
  final double taxAmount;
  final double total;
  final double? unitPriceUsd;
  final double? totalUsd;
  final double? exchangeRate;
  final String syncStatus;
  final DateTime createdAt;
  const InvoiceItem(
      {required this.id,
      required this.invoiceId,
      required this.productId,
      required this.productName,
      required this.quantity,
      required this.unitPrice,
      required this.purchasePrice,
      this.costPrice,
      this.costPriceUsd,
      required this.discountAmount,
      required this.taxAmount,
      required this.total,
      this.unitPriceUsd,
      this.totalUsd,
      this.exchangeRate,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['purchase_price'] = Variable<double>(purchasePrice);
    if (!nullToAbsent || costPrice != null) {
      map['cost_price'] = Variable<double>(costPrice);
    }
    if (!nullToAbsent || costPriceUsd != null) {
      map['cost_price_usd'] = Variable<double>(costPriceUsd);
    }
    map['discount_amount'] = Variable<double>(discountAmount);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['total'] = Variable<double>(total);
    if (!nullToAbsent || unitPriceUsd != null) {
      map['unit_price_usd'] = Variable<double>(unitPriceUsd);
    }
    if (!nullToAbsent || totalUsd != null) {
      map['total_usd'] = Variable<double>(totalUsd);
    }
    if (!nullToAbsent || exchangeRate != null) {
      map['exchange_rate'] = Variable<double>(exchangeRate);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: Value(productId),
      productName: Value(productName),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      purchasePrice: Value(purchasePrice),
      costPrice: costPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(costPrice),
      costPriceUsd: costPriceUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(costPriceUsd),
      discountAmount: Value(discountAmount),
      taxAmount: Value(taxAmount),
      total: Value(total),
      unitPriceUsd: unitPriceUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPriceUsd),
      totalUsd: totalUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(totalUsd),
      exchangeRate: exchangeRate == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRate),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      costPrice: serializer.fromJson<double?>(json['costPrice']),
      costPriceUsd: serializer.fromJson<double?>(json['costPriceUsd']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      total: serializer.fromJson<double>(json['total']),
      unitPriceUsd: serializer.fromJson<double?>(json['unitPriceUsd']),
      totalUsd: serializer.fromJson<double?>(json['totalUsd']),
      exchangeRate: serializer.fromJson<double?>(json['exchangeRate']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'costPrice': serializer.toJson<double?>(costPrice),
      'costPriceUsd': serializer.toJson<double?>(costPriceUsd),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'total': serializer.toJson<double>(total),
      'unitPriceUsd': serializer.toJson<double?>(unitPriceUsd),
      'totalUsd': serializer.toJson<double?>(totalUsd),
      'exchangeRate': serializer.toJson<double?>(exchangeRate),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InvoiceItem copyWith(
          {String? id,
          String? invoiceId,
          String? productId,
          String? productName,
          int? quantity,
          double? unitPrice,
          double? purchasePrice,
          Value<double?> costPrice = const Value.absent(),
          Value<double?> costPriceUsd = const Value.absent(),
          double? discountAmount,
          double? taxAmount,
          double? total,
          Value<double?> unitPriceUsd = const Value.absent(),
          Value<double?> totalUsd = const Value.absent(),
          Value<double?> exchangeRate = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt}) =>
      InvoiceItem(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        costPrice: costPrice.present ? costPrice.value : this.costPrice,
        costPriceUsd:
            costPriceUsd.present ? costPriceUsd.value : this.costPriceUsd,
        discountAmount: discountAmount ?? this.discountAmount,
        taxAmount: taxAmount ?? this.taxAmount,
        total: total ?? this.total,
        unitPriceUsd:
            unitPriceUsd.present ? unitPriceUsd.value : this.unitPriceUsd,
        totalUsd: totalUsd.present ? totalUsd.value : this.totalUsd,
        exchangeRate:
            exchangeRate.present ? exchangeRate.value : this.exchangeRate,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      costPriceUsd: data.costPriceUsd.present
          ? data.costPriceUsd.value
          : this.costPriceUsd,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      total: data.total.present ? data.total.value : this.total,
      unitPriceUsd: data.unitPriceUsd.present
          ? data.unitPriceUsd.value
          : this.unitPriceUsd,
      totalUsd: data.totalUsd.present ? data.totalUsd.value : this.totalUsd,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('costPrice: $costPrice, ')
          ..write('costPriceUsd: $costPriceUsd, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('total: $total, ')
          ..write('unitPriceUsd: $unitPriceUsd, ')
          ..write('totalUsd: $totalUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      invoiceId,
      productId,
      productName,
      quantity,
      unitPrice,
      purchasePrice,
      costPrice,
      costPriceUsd,
      discountAmount,
      taxAmount,
      total,
      unitPriceUsd,
      totalUsd,
      exchangeRate,
      syncStatus,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.purchasePrice == this.purchasePrice &&
          other.costPrice == this.costPrice &&
          other.costPriceUsd == this.costPriceUsd &&
          other.discountAmount == this.discountAmount &&
          other.taxAmount == this.taxAmount &&
          other.total == this.total &&
          other.unitPriceUsd == this.unitPriceUsd &&
          other.totalUsd == this.totalUsd &&
          other.exchangeRate == this.exchangeRate &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> purchasePrice;
  final Value<double?> costPrice;
  final Value<double?> costPriceUsd;
  final Value<double> discountAmount;
  final Value<double> taxAmount;
  final Value<double> total;
  final Value<double?> unitPriceUsd;
  final Value<double?> totalUsd;
  final Value<double?> exchangeRate;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.costPriceUsd = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.total = const Value.absent(),
    this.unitPriceUsd = const Value.absent(),
    this.totalUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    required String id,
    required String invoiceId,
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double purchasePrice,
    this.costPrice = const Value.absent(),
    this.costPriceUsd = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    required double total,
    this.unitPriceUsd = const Value.absent(),
    this.totalUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceId = Value(invoiceId),
        productId = Value(productId),
        productName = Value(productName),
        quantity = Value(quantity),
        unitPrice = Value(unitPrice),
        purchasePrice = Value(purchasePrice),
        total = Value(total);
  static Insertable<InvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? purchasePrice,
    Expression<double>? costPrice,
    Expression<double>? costPriceUsd,
    Expression<double>? discountAmount,
    Expression<double>? taxAmount,
    Expression<double>? total,
    Expression<double>? unitPriceUsd,
    Expression<double>? totalUsd,
    Expression<double>? exchangeRate,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (costPrice != null) 'cost_price': costPrice,
      if (costPriceUsd != null) 'cost_price_usd': costPriceUsd,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (total != null) 'total': total,
      if (unitPriceUsd != null) 'unit_price_usd': unitPriceUsd,
      if (totalUsd != null) 'total_usd': totalUsd,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceId,
      Value<String>? productId,
      Value<String>? productName,
      Value<int>? quantity,
      Value<double>? unitPrice,
      Value<double>? purchasePrice,
      Value<double?>? costPrice,
      Value<double?>? costPriceUsd,
      Value<double>? discountAmount,
      Value<double>? taxAmount,
      Value<double>? total,
      Value<double?>? unitPriceUsd,
      Value<double?>? totalUsd,
      Value<double?>? exchangeRate,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      costPrice: costPrice ?? this.costPrice,
      costPriceUsd: costPriceUsd ?? this.costPriceUsd,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      unitPriceUsd: unitPriceUsd ?? this.unitPriceUsd,
      totalUsd: totalUsd ?? this.totalUsd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (costPriceUsd.present) {
      map['cost_price_usd'] = Variable<double>(costPriceUsd.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (unitPriceUsd.present) {
      map['unit_price_usd'] = Variable<double>(unitPriceUsd.value);
    }
    if (totalUsd.present) {
      map['total_usd'] = Variable<double>(totalUsd.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('costPrice: $costPrice, ')
          ..write('costPriceUsd: $costPriceUsd, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('total: $total, ')
          ..write('unitPriceUsd: $unitPriceUsd, ')
          ..write('totalUsd: $totalUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryMovementsTable extends InventoryMovements
    with TableInfo<$InventoryMovementsTable, InventoryMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _previousQuantityMeta =
      const VerificationMeta('previousQuantity');
  @override
  late final GeneratedColumn<int> previousQuantity = GeneratedColumn<int>(
      'previous_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _newQuantityMeta =
      const VerificationMeta('newQuantity');
  @override
  late final GeneratedColumn<int> newQuantity = GeneratedColumn<int>(
      'new_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceTypeMeta =
      const VerificationMeta('referenceType');
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
      'reference_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        warehouseId,
        type,
        quantity,
        previousQuantity,
        newQuantity,
        reason,
        referenceId,
        referenceType,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_movements';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('previous_quantity')) {
      context.handle(
          _previousQuantityMeta,
          previousQuantity.isAcceptableOrUnknown(
              data['previous_quantity']!, _previousQuantityMeta));
    } else if (isInserting) {
      context.missing(_previousQuantityMeta);
    }
    if (data.containsKey('new_quantity')) {
      context.handle(
          _newQuantityMeta,
          newQuantity.isAcceptableOrUnknown(
              data['new_quantity']!, _newQuantityMeta));
    } else if (isInserting) {
      context.missing(_newQuantityMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('reference_type')) {
      context.handle(
          _referenceTypeMeta,
          referenceType.isAcceptableOrUnknown(
              data['reference_type']!, _referenceTypeMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      previousQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}previous_quantity'])!,
      newQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_quantity'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      referenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_type']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InventoryMovementsTable createAlias(String alias) {
    return $InventoryMovementsTable(attachedDatabase, alias);
  }
}

class InventoryMovement extends DataClass
    implements Insertable<InventoryMovement> {
  final String id;
  final String productId;
  final String? warehouseId;
  final String type;
  final int quantity;
  final int previousQuantity;
  final int newQuantity;
  final String? reason;
  final String? referenceId;
  final String? referenceType;
  final String syncStatus;
  final DateTime createdAt;
  const InventoryMovement(
      {required this.id,
      required this.productId,
      this.warehouseId,
      required this.type,
      required this.quantity,
      required this.previousQuantity,
      required this.newQuantity,
      this.reason,
      this.referenceId,
      this.referenceType,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    if (!nullToAbsent || warehouseId != null) {
      map['warehouse_id'] = Variable<String>(warehouseId);
    }
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<int>(quantity);
    map['previous_quantity'] = Variable<int>(previousQuantity);
    map['new_quantity'] = Variable<int>(newQuantity);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryMovementsCompanion toCompanion(bool nullToAbsent) {
    return InventoryMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      warehouseId: warehouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouseId),
      type: Value(type),
      quantity: Value(quantity),
      previousQuantity: Value(previousQuantity),
      newQuantity: Value(newQuantity),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryMovement(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      warehouseId: serializer.fromJson<String?>(json['warehouseId']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<int>(json['quantity']),
      previousQuantity: serializer.fromJson<int>(json['previousQuantity']),
      newQuantity: serializer.fromJson<int>(json['newQuantity']),
      reason: serializer.fromJson<String?>(json['reason']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'warehouseId': serializer.toJson<String?>(warehouseId),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<int>(quantity),
      'previousQuantity': serializer.toJson<int>(previousQuantity),
      'newQuantity': serializer.toJson<int>(newQuantity),
      'reason': serializer.toJson<String?>(reason),
      'referenceId': serializer.toJson<String?>(referenceId),
      'referenceType': serializer.toJson<String?>(referenceType),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryMovement copyWith(
          {String? id,
          String? productId,
          Value<String?> warehouseId = const Value.absent(),
          String? type,
          int? quantity,
          int? previousQuantity,
          int? newQuantity,
          Value<String?> reason = const Value.absent(),
          Value<String?> referenceId = const Value.absent(),
          Value<String?> referenceType = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt}) =>
      InventoryMovement(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
        type: type ?? this.type,
        quantity: quantity ?? this.quantity,
        previousQuantity: previousQuantity ?? this.previousQuantity,
        newQuantity: newQuantity ?? this.newQuantity,
        reason: reason.present ? reason.value : this.reason,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        referenceType:
            referenceType.present ? referenceType.value : this.referenceType,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  InventoryMovement copyWithCompanion(InventoryMovementsCompanion data) {
    return InventoryMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      previousQuantity: data.previousQuantity.present
          ? data.previousQuantity.value
          : this.previousQuantity,
      newQuantity:
          data.newQuantity.present ? data.newQuantity.value : this.newQuantity,
      reason: data.reason.present ? data.reason.value : this.reason,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('previousQuantity: $previousQuantity, ')
          ..write('newQuantity: $newQuantity, ')
          ..write('reason: $reason, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productId,
      warehouseId,
      type,
      quantity,
      previousQuantity,
      newQuantity,
      reason,
      referenceId,
      referenceType,
      syncStatus,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.warehouseId == this.warehouseId &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.previousQuantity == this.previousQuantity &&
          other.newQuantity == this.newQuantity &&
          other.reason == this.reason &&
          other.referenceId == this.referenceId &&
          other.referenceType == this.referenceType &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class InventoryMovementsCompanion extends UpdateCompanion<InventoryMovement> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String?> warehouseId;
  final Value<String> type;
  final Value<int> quantity;
  final Value<int> previousQuantity;
  final Value<int> newQuantity;
  final Value<String?> reason;
  final Value<String?> referenceId;
  final Value<String?> referenceType;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InventoryMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.previousQuantity = const Value.absent(),
    this.newQuantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryMovementsCompanion.insert({
    required String id,
    required String productId,
    this.warehouseId = const Value.absent(),
    required String type,
    required int quantity,
    required int previousQuantity,
    required int newQuantity,
    this.reason = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        type = Value(type),
        quantity = Value(quantity),
        previousQuantity = Value(previousQuantity),
        newQuantity = Value(newQuantity);
  static Insertable<InventoryMovement> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? warehouseId,
    Expression<String>? type,
    Expression<int>? quantity,
    Expression<int>? previousQuantity,
    Expression<int>? newQuantity,
    Expression<String>? reason,
    Expression<String>? referenceId,
    Expression<String>? referenceType,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (previousQuantity != null) 'previous_quantity': previousQuantity,
      if (newQuantity != null) 'new_quantity': newQuantity,
      if (reason != null) 'reason': reason,
      if (referenceId != null) 'reference_id': referenceId,
      if (referenceType != null) 'reference_type': referenceType,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryMovementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? productId,
      Value<String?>? warehouseId,
      Value<String>? type,
      Value<int>? quantity,
      Value<int>? previousQuantity,
      Value<int>? newQuantity,
      Value<String?>? reason,
      Value<String?>? referenceId,
      Value<String?>? referenceType,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return InventoryMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      previousQuantity: previousQuantity ?? this.previousQuantity,
      newQuantity: newQuantity ?? this.newQuantity,
      reason: reason ?? this.reason,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (previousQuantity.present) {
      map['previous_quantity'] = Variable<int>(previousQuantity.value);
    }
    if (newQuantity.present) {
      map['new_quantity'] = Variable<int>(newQuantity.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('previousQuantity: $previousQuantity, ')
          ..write('newQuantity: $newQuantity, ')
          ..write('reason: $reason, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashMovementsTable extends CashMovements
    with TableInfo<$CashMovementsTable, CashMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shiftIdMeta =
      const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
      'shift_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES shifts (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _amountUsdMeta =
      const VerificationMeta('amountUsd');
  @override
  late final GeneratedColumn<double> amountUsd = GeneratedColumn<double>(
      'amount_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceTypeMeta =
      const VerificationMeta('referenceType');
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
      'reference_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        shiftId,
        type,
        amount,
        amountUsd,
        exchangeRate,
        description,
        category,
        referenceId,
        referenceType,
        paymentMethod,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_movements';
  @override
  VerificationContext validateIntegrity(Insertable<CashMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta,
          shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_usd')) {
      context.handle(_amountUsdMeta,
          amountUsd.isAcceptableOrUnknown(data['amount_usd']!, _amountUsdMeta));
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('reference_type')) {
      context.handle(
          _referenceTypeMeta,
          referenceType.isAcceptableOrUnknown(
              data['reference_type']!, _referenceTypeMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      shiftId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      amountUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount_usd']),
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      referenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_type']),
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CashMovementsTable createAlias(String alias) {
    return $CashMovementsTable(attachedDatabase, alias);
  }
}

class CashMovement extends DataClass implements Insertable<CashMovement> {
  final String id;
  final String shiftId;
  final String type;
  final double amount;
  final double? amountUsd;
  final double? exchangeRate;
  final String description;
  final String? category;
  final String? referenceId;
  final String? referenceType;
  final String paymentMethod;
  final String syncStatus;
  final DateTime createdAt;
  const CashMovement(
      {required this.id,
      required this.shiftId,
      required this.type,
      required this.amount,
      this.amountUsd,
      this.exchangeRate,
      required this.description,
      this.category,
      this.referenceId,
      this.referenceType,
      required this.paymentMethod,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shift_id'] = Variable<String>(shiftId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || amountUsd != null) {
      map['amount_usd'] = Variable<double>(amountUsd);
    }
    if (!nullToAbsent || exchangeRate != null) {
      map['exchange_rate'] = Variable<double>(exchangeRate);
    }
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    map['payment_method'] = Variable<String>(paymentMethod);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CashMovementsCompanion toCompanion(bool nullToAbsent) {
    return CashMovementsCompanion(
      id: Value(id),
      shiftId: Value(shiftId),
      type: Value(type),
      amount: Value(amount),
      amountUsd: amountUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(amountUsd),
      exchangeRate: exchangeRate == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRate),
      description: Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      paymentMethod: Value(paymentMethod),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory CashMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashMovement(
      id: serializer.fromJson<String>(json['id']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      amountUsd: serializer.fromJson<double?>(json['amountUsd']),
      exchangeRate: serializer.fromJson<double?>(json['exchangeRate']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftId': serializer.toJson<String>(shiftId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'amountUsd': serializer.toJson<double?>(amountUsd),
      'exchangeRate': serializer.toJson<double?>(exchangeRate),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String?>(category),
      'referenceId': serializer.toJson<String?>(referenceId),
      'referenceType': serializer.toJson<String?>(referenceType),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CashMovement copyWith(
          {String? id,
          String? shiftId,
          String? type,
          double? amount,
          Value<double?> amountUsd = const Value.absent(),
          Value<double?> exchangeRate = const Value.absent(),
          String? description,
          Value<String?> category = const Value.absent(),
          Value<String?> referenceId = const Value.absent(),
          Value<String?> referenceType = const Value.absent(),
          String? paymentMethod,
          String? syncStatus,
          DateTime? createdAt}) =>
      CashMovement(
        id: id ?? this.id,
        shiftId: shiftId ?? this.shiftId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        amountUsd: amountUsd.present ? amountUsd.value : this.amountUsd,
        exchangeRate:
            exchangeRate.present ? exchangeRate.value : this.exchangeRate,
        description: description ?? this.description,
        category: category.present ? category.value : this.category,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        referenceType:
            referenceType.present ? referenceType.value : this.referenceType,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  CashMovement copyWithCompanion(CashMovementsCompanion data) {
    return CashMovement(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountUsd: data.amountUsd.present ? data.amountUsd.value : this.amountUsd,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashMovement(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('amountUsd: $amountUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      shiftId,
      type,
      amount,
      amountUsd,
      exchangeRate,
      description,
      category,
      referenceId,
      referenceType,
      paymentMethod,
      syncStatus,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMovement &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.amountUsd == this.amountUsd &&
          other.exchangeRate == this.exchangeRate &&
          other.description == this.description &&
          other.category == this.category &&
          other.referenceId == this.referenceId &&
          other.referenceType == this.referenceType &&
          other.paymentMethod == this.paymentMethod &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class CashMovementsCompanion extends UpdateCompanion<CashMovement> {
  final Value<String> id;
  final Value<String> shiftId;
  final Value<String> type;
  final Value<double> amount;
  final Value<double?> amountUsd;
  final Value<double?> exchangeRate;
  final Value<String> description;
  final Value<String?> category;
  final Value<String?> referenceId;
  final Value<String?> referenceType;
  final Value<String> paymentMethod;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CashMovementsCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashMovementsCompanion.insert({
    required String id,
    required String shiftId,
    required String type,
    required double amount,
    this.amountUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    required String description,
    this.category = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        shiftId = Value(shiftId),
        type = Value(type),
        amount = Value(amount),
        description = Value(description);
  static Insertable<CashMovement> custom({
    Expression<String>? id,
    Expression<String>? shiftId,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<double>? amountUsd,
    Expression<double>? exchangeRate,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? referenceId,
    Expression<String>? referenceType,
    Expression<String>? paymentMethod,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (amountUsd != null) 'amount_usd': amountUsd,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (referenceId != null) 'reference_id': referenceId,
      if (referenceType != null) 'reference_type': referenceType,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashMovementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? shiftId,
      Value<String>? type,
      Value<double>? amount,
      Value<double?>? amountUsd,
      Value<double?>? exchangeRate,
      Value<String>? description,
      Value<String?>? category,
      Value<String?>? referenceId,
      Value<String?>? referenceType,
      Value<String>? paymentMethod,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CashMovementsCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      amountUsd: amountUsd ?? this.amountUsd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      description: description ?? this.description,
      category: category ?? this.category,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountUsd.present) {
      map['amount_usd'] = Variable<double>(amountUsd.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementsCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('amountUsd: $amountUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const Setting(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      Setting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VoucherCategoriesTable extends VoucherCategories
    with TableInfo<$VoucherCategoriesTable, VoucherCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoucherCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, isActive, syncStatus, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voucher_categories';
  @override
  VerificationContext validateIntegrity(Insertable<VoucherCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoucherCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoucherCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $VoucherCategoriesTable createAlias(String alias) {
    return $VoucherCategoriesTable(attachedDatabase, alias);
  }
}

class VoucherCategory extends DataClass implements Insertable<VoucherCategory> {
  final String id;
  final String name;
  final String type;
  final bool isActive;
  final String syncStatus;
  final DateTime createdAt;
  const VoucherCategory(
      {required this.id,
      required this.name,
      required this.type,
      required this.isActive,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['is_active'] = Variable<bool>(isActive);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VoucherCategoriesCompanion toCompanion(bool nullToAbsent) {
    return VoucherCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory VoucherCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoucherCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VoucherCategory copyWith(
          {String? id,
          String? name,
          String? type,
          bool? isActive,
          String? syncStatus,
          DateTime? createdAt}) =>
      VoucherCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        isActive: isActive ?? this.isActive,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  VoucherCategory copyWithCompanion(VoucherCategoriesCompanion data) {
    return VoucherCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoucherCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, isActive, syncStatus, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoucherCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class VoucherCategoriesCompanion extends UpdateCompanion<VoucherCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<bool> isActive;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VoucherCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoucherCategoriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type);
  static Insertable<VoucherCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<bool>? isActive,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoucherCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<bool>? isActive,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return VoucherCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoucherCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VouchersTable extends Vouchers with TableInfo<$VouchersTable, Voucher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VouchersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _voucherNumberMeta =
      const VerificationMeta('voucherNumber');
  @override
  late final GeneratedColumn<String> voucherNumber = GeneratedColumn<String>(
      'voucher_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES voucher_categories (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _amountUsdMeta =
      const VerificationMeta('amountUsd');
  @override
  late final GeneratedColumn<double> amountUsd = GeneratedColumn<double>(
      'amount_usd', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES customers (id)'));
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
      'supplier_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES suppliers (id)'));
  static const VerificationMeta _shiftIdMeta =
      const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
      'shift_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES shifts (id)'));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _voucherDateMeta =
      const VerificationMeta('voucherDate');
  @override
  late final GeneratedColumn<DateTime> voucherDate = GeneratedColumn<DateTime>(
      'voucher_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        voucherNumber,
        type,
        categoryId,
        amount,
        amountUsd,
        exchangeRate,
        description,
        customerId,
        supplierId,
        shiftId,
        syncStatus,
        voucherDate,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vouchers';
  @override
  VerificationContext validateIntegrity(Insertable<Voucher> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('voucher_number')) {
      context.handle(
          _voucherNumberMeta,
          voucherNumber.isAcceptableOrUnknown(
              data['voucher_number']!, _voucherNumberMeta));
    } else if (isInserting) {
      context.missing(_voucherNumberMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_usd')) {
      context.handle(_amountUsdMeta,
          amountUsd.isAcceptableOrUnknown(data['amount_usd']!, _amountUsdMeta));
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    }
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta,
          shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('voucher_date')) {
      context.handle(
          _voucherDateMeta,
          voucherDate.isAcceptableOrUnknown(
              data['voucher_date']!, _voucherDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Voucher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Voucher(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      voucherNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voucher_number'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      amountUsd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount_usd']),
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_id']),
      shiftId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      voucherDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}voucher_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $VouchersTable createAlias(String alias) {
    return $VouchersTable(attachedDatabase, alias);
  }
}

class Voucher extends DataClass implements Insertable<Voucher> {
  final String id;
  final String voucherNumber;
  final String type;
  final String? categoryId;
  final double amount;
  final double? amountUsd;
  final double exchangeRate;
  final String? description;
  final String? customerId;
  final String? supplierId;
  final String? shiftId;
  final String syncStatus;
  final DateTime voucherDate;
  final DateTime createdAt;
  const Voucher(
      {required this.id,
      required this.voucherNumber,
      required this.type,
      this.categoryId,
      required this.amount,
      this.amountUsd,
      required this.exchangeRate,
      this.description,
      this.customerId,
      this.supplierId,
      this.shiftId,
      required this.syncStatus,
      required this.voucherDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['voucher_number'] = Variable<String>(voucherNumber);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || amountUsd != null) {
      map['amount_usd'] = Variable<double>(amountUsd);
    }
    map['exchange_rate'] = Variable<double>(exchangeRate);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['voucher_date'] = Variable<DateTime>(voucherDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VouchersCompanion toCompanion(bool nullToAbsent) {
    return VouchersCompanion(
      id: Value(id),
      voucherNumber: Value(voucherNumber),
      type: Value(type),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amount: Value(amount),
      amountUsd: amountUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(amountUsd),
      exchangeRate: Value(exchangeRate),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      syncStatus: Value(syncStatus),
      voucherDate: Value(voucherDate),
      createdAt: Value(createdAt),
    );
  }

  factory Voucher.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Voucher(
      id: serializer.fromJson<String>(json['id']),
      voucherNumber: serializer.fromJson<String>(json['voucherNumber']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      amountUsd: serializer.fromJson<double?>(json['amountUsd']),
      exchangeRate: serializer.fromJson<double>(json['exchangeRate']),
      description: serializer.fromJson<String?>(json['description']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      voucherDate: serializer.fromJson<DateTime>(json['voucherDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'voucherNumber': serializer.toJson<String>(voucherNumber),
      'type': serializer.toJson<String>(type),
      'categoryId': serializer.toJson<String?>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'amountUsd': serializer.toJson<double?>(amountUsd),
      'exchangeRate': serializer.toJson<double>(exchangeRate),
      'description': serializer.toJson<String?>(description),
      'customerId': serializer.toJson<String?>(customerId),
      'supplierId': serializer.toJson<String?>(supplierId),
      'shiftId': serializer.toJson<String?>(shiftId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'voucherDate': serializer.toJson<DateTime>(voucherDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Voucher copyWith(
          {String? id,
          String? voucherNumber,
          String? type,
          Value<String?> categoryId = const Value.absent(),
          double? amount,
          Value<double?> amountUsd = const Value.absent(),
          double? exchangeRate,
          Value<String?> description = const Value.absent(),
          Value<String?> customerId = const Value.absent(),
          Value<String?> supplierId = const Value.absent(),
          Value<String?> shiftId = const Value.absent(),
          String? syncStatus,
          DateTime? voucherDate,
          DateTime? createdAt}) =>
      Voucher(
        id: id ?? this.id,
        voucherNumber: voucherNumber ?? this.voucherNumber,
        type: type ?? this.type,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        amount: amount ?? this.amount,
        amountUsd: amountUsd.present ? amountUsd.value : this.amountUsd,
        exchangeRate: exchangeRate ?? this.exchangeRate,
        description: description.present ? description.value : this.description,
        customerId: customerId.present ? customerId.value : this.customerId,
        supplierId: supplierId.present ? supplierId.value : this.supplierId,
        shiftId: shiftId.present ? shiftId.value : this.shiftId,
        syncStatus: syncStatus ?? this.syncStatus,
        voucherDate: voucherDate ?? this.voucherDate,
        createdAt: createdAt ?? this.createdAt,
      );
  Voucher copyWithCompanion(VouchersCompanion data) {
    return Voucher(
      id: data.id.present ? data.id.value : this.id,
      voucherNumber: data.voucherNumber.present
          ? data.voucherNumber.value
          : this.voucherNumber,
      type: data.type.present ? data.type.value : this.type,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountUsd: data.amountUsd.present ? data.amountUsd.value : this.amountUsd,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      description:
          data.description.present ? data.description.value : this.description,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      voucherDate:
          data.voucherDate.present ? data.voucherDate.value : this.voucherDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Voucher(')
          ..write('id: $id, ')
          ..write('voucherNumber: $voucherNumber, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('amountUsd: $amountUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('description: $description, ')
          ..write('customerId: $customerId, ')
          ..write('supplierId: $supplierId, ')
          ..write('shiftId: $shiftId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('voucherDate: $voucherDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      voucherNumber,
      type,
      categoryId,
      amount,
      amountUsd,
      exchangeRate,
      description,
      customerId,
      supplierId,
      shiftId,
      syncStatus,
      voucherDate,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Voucher &&
          other.id == this.id &&
          other.voucherNumber == this.voucherNumber &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.amountUsd == this.amountUsd &&
          other.exchangeRate == this.exchangeRate &&
          other.description == this.description &&
          other.customerId == this.customerId &&
          other.supplierId == this.supplierId &&
          other.shiftId == this.shiftId &&
          other.syncStatus == this.syncStatus &&
          other.voucherDate == this.voucherDate &&
          other.createdAt == this.createdAt);
}

class VouchersCompanion extends UpdateCompanion<Voucher> {
  final Value<String> id;
  final Value<String> voucherNumber;
  final Value<String> type;
  final Value<String?> categoryId;
  final Value<double> amount;
  final Value<double?> amountUsd;
  final Value<double> exchangeRate;
  final Value<String?> description;
  final Value<String?> customerId;
  final Value<String?> supplierId;
  final Value<String?> shiftId;
  final Value<String> syncStatus;
  final Value<DateTime> voucherDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VouchersCompanion({
    this.id = const Value.absent(),
    this.voucherNumber = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.description = const Value.absent(),
    this.customerId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.voucherDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VouchersCompanion.insert({
    required String id,
    required String voucherNumber,
    required String type,
    this.categoryId = const Value.absent(),
    required double amount,
    this.amountUsd = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.description = const Value.absent(),
    this.customerId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.voucherDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        voucherNumber = Value(voucherNumber),
        type = Value(type),
        amount = Value(amount);
  static Insertable<Voucher> custom({
    Expression<String>? id,
    Expression<String>? voucherNumber,
    Expression<String>? type,
    Expression<String>? categoryId,
    Expression<double>? amount,
    Expression<double>? amountUsd,
    Expression<double>? exchangeRate,
    Expression<String>? description,
    Expression<String>? customerId,
    Expression<String>? supplierId,
    Expression<String>? shiftId,
    Expression<String>? syncStatus,
    Expression<DateTime>? voucherDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (voucherNumber != null) 'voucher_number': voucherNumber,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (amountUsd != null) 'amount_usd': amountUsd,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (description != null) 'description': description,
      if (customerId != null) 'customer_id': customerId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (shiftId != null) 'shift_id': shiftId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (voucherDate != null) 'voucher_date': voucherDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VouchersCompanion copyWith(
      {Value<String>? id,
      Value<String>? voucherNumber,
      Value<String>? type,
      Value<String?>? categoryId,
      Value<double>? amount,
      Value<double?>? amountUsd,
      Value<double>? exchangeRate,
      Value<String?>? description,
      Value<String?>? customerId,
      Value<String?>? supplierId,
      Value<String?>? shiftId,
      Value<String>? syncStatus,
      Value<DateTime>? voucherDate,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return VouchersCompanion(
      id: id ?? this.id,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      amountUsd: amountUsd ?? this.amountUsd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      description: description ?? this.description,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      shiftId: shiftId ?? this.shiftId,
      syncStatus: syncStatus ?? this.syncStatus,
      voucherDate: voucherDate ?? this.voucherDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (voucherNumber.present) {
      map['voucher_number'] = Variable<String>(voucherNumber.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountUsd.present) {
      map['amount_usd'] = Variable<double>(amountUsd.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (voucherDate.present) {
      map['voucher_date'] = Variable<DateTime>(voucherDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VouchersCompanion(')
          ..write('id: $id, ')
          ..write('voucherNumber: $voucherNumber, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('amountUsd: $amountUsd, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('description: $description, ')
          ..write('customerId: $customerId, ')
          ..write('supplierId: $supplierId, ')
          ..write('shiftId: $shiftId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('voucherDate: $voucherDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WarehousesTable extends Warehouses
    with TableInfo<$WarehousesTable, Warehouse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarehousesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _managerIdMeta =
      const VerificationMeta('managerId');
  @override
  late final GeneratedColumn<String> managerId = GeneratedColumn<String>(
      'manager_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        code,
        address,
        phone,
        managerId,
        isDefault,
        isActive,
        notes,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warehouses';
  @override
  VerificationContext validateIntegrity(Insertable<Warehouse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('manager_id')) {
      context.handle(_managerIdMeta,
          managerId.isAcceptableOrUnknown(data['manager_id']!, _managerIdMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Warehouse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Warehouse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      managerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manager_id']),
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WarehousesTable createAlias(String alias) {
    return $WarehousesTable(attachedDatabase, alias);
  }
}

class Warehouse extends DataClass implements Insertable<Warehouse> {
  final String id;
  final String name;
  final String? code;
  final String? address;
  final String? phone;
  final String? managerId;
  final bool isDefault;
  final bool isActive;
  final String? notes;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Warehouse(
      {required this.id,
      required this.name,
      this.code,
      this.address,
      this.phone,
      this.managerId,
      required this.isDefault,
      required this.isActive,
      this.notes,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || managerId != null) {
      map['manager_id'] = Variable<String>(managerId);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WarehousesCompanion toCompanion(bool nullToAbsent) {
    return WarehousesCompanion(
      id: Value(id),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      managerId: managerId == null && nullToAbsent
          ? const Value.absent()
          : Value(managerId),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Warehouse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Warehouse(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      managerId: serializer.fromJson<String?>(json['managerId']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'managerId': serializer.toJson<String?>(managerId),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Warehouse copyWith(
          {String? id,
          String? name,
          Value<String?> code = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> managerId = const Value.absent(),
          bool? isDefault,
          bool? isActive,
          Value<String?> notes = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Warehouse(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code.present ? code.value : this.code,
        address: address.present ? address.value : this.address,
        phone: phone.present ? phone.value : this.phone,
        managerId: managerId.present ? managerId.value : this.managerId,
        isDefault: isDefault ?? this.isDefault,
        isActive: isActive ?? this.isActive,
        notes: notes.present ? notes.value : this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Warehouse copyWithCompanion(WarehousesCompanion data) {
    return Warehouse(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      managerId: data.managerId.present ? data.managerId.value : this.managerId,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Warehouse(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('managerId: $managerId, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, code, address, phone, managerId,
      isDefault, isActive, notes, syncStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Warehouse &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.managerId == this.managerId &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WarehousesCompanion extends UpdateCompanion<Warehouse> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> code;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String?> managerId;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WarehousesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.managerId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WarehousesCompanion.insert({
    required String id,
    required String name,
    this.code = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.managerId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Warehouse> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? managerId,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (managerId != null) 'manager_id': managerId,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WarehousesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? code,
      Value<String?>? address,
      Value<String?>? phone,
      Value<String?>? managerId,
      Value<bool>? isDefault,
      Value<bool>? isActive,
      Value<String?>? notes,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return WarehousesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      managerId: managerId ?? this.managerId,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (managerId.present) {
      map['manager_id'] = Variable<String>(managerId.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarehousesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('managerId: $managerId, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WarehouseStockTable extends WarehouseStock
    with TableInfo<$WarehouseStockTable, WarehouseStockData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarehouseStockTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES warehouses (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minQuantityMeta =
      const VerificationMeta('minQuantity');
  @override
  late final GeneratedColumn<int> minQuantity = GeneratedColumn<int>(
      'min_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _maxQuantityMeta =
      const VerificationMeta('maxQuantity');
  @override
  late final GeneratedColumn<int> maxQuantity = GeneratedColumn<int>(
      'max_quantity', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        warehouseId,
        productId,
        quantity,
        minQuantity,
        maxQuantity,
        location,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warehouse_stock';
  @override
  VerificationContext validateIntegrity(Insertable<WarehouseStockData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('min_quantity')) {
      context.handle(
          _minQuantityMeta,
          minQuantity.isAcceptableOrUnknown(
              data['min_quantity']!, _minQuantityMeta));
    }
    if (data.containsKey('max_quantity')) {
      context.handle(
          _maxQuantityMeta,
          maxQuantity.isAcceptableOrUnknown(
              data['max_quantity']!, _maxQuantityMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WarehouseStockData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WarehouseStockData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      minQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_quantity'])!,
      maxQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_quantity']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WarehouseStockTable createAlias(String alias) {
    return $WarehouseStockTable(attachedDatabase, alias);
  }
}

class WarehouseStockData extends DataClass
    implements Insertable<WarehouseStockData> {
  final String id;
  final String warehouseId;
  final String productId;
  final int quantity;
  final int minQuantity;
  final int? maxQuantity;
  final String? location;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WarehouseStockData(
      {required this.id,
      required this.warehouseId,
      required this.productId,
      required this.quantity,
      required this.minQuantity,
      this.maxQuantity,
      this.location,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['min_quantity'] = Variable<int>(minQuantity);
    if (!nullToAbsent || maxQuantity != null) {
      map['max_quantity'] = Variable<int>(maxQuantity);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WarehouseStockCompanion toCompanion(bool nullToAbsent) {
    return WarehouseStockCompanion(
      id: Value(id),
      warehouseId: Value(warehouseId),
      productId: Value(productId),
      quantity: Value(quantity),
      minQuantity: Value(minQuantity),
      maxQuantity: maxQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(maxQuantity),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WarehouseStockData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WarehouseStockData(
      id: serializer.fromJson<String>(json['id']),
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      minQuantity: serializer.fromJson<int>(json['minQuantity']),
      maxQuantity: serializer.fromJson<int?>(json['maxQuantity']),
      location: serializer.fromJson<String?>(json['location']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'warehouseId': serializer.toJson<String>(warehouseId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'minQuantity': serializer.toJson<int>(minQuantity),
      'maxQuantity': serializer.toJson<int?>(maxQuantity),
      'location': serializer.toJson<String?>(location),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WarehouseStockData copyWith(
          {String? id,
          String? warehouseId,
          String? productId,
          int? quantity,
          int? minQuantity,
          Value<int?> maxQuantity = const Value.absent(),
          Value<String?> location = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      WarehouseStockData(
        id: id ?? this.id,
        warehouseId: warehouseId ?? this.warehouseId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        minQuantity: minQuantity ?? this.minQuantity,
        maxQuantity: maxQuantity.present ? maxQuantity.value : this.maxQuantity,
        location: location.present ? location.value : this.location,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  WarehouseStockData copyWithCompanion(WarehouseStockCompanion data) {
    return WarehouseStockData(
      id: data.id.present ? data.id.value : this.id,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      minQuantity:
          data.minQuantity.present ? data.minQuantity.value : this.minQuantity,
      maxQuantity:
          data.maxQuantity.present ? data.maxQuantity.value : this.maxQuantity,
      location: data.location.present ? data.location.value : this.location,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WarehouseStockData(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('maxQuantity: $maxQuantity, ')
          ..write('location: $location, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, warehouseId, productId, quantity,
      minQuantity, maxQuantity, location, syncStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WarehouseStockData &&
          other.id == this.id &&
          other.warehouseId == this.warehouseId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.minQuantity == this.minQuantity &&
          other.maxQuantity == this.maxQuantity &&
          other.location == this.location &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WarehouseStockCompanion extends UpdateCompanion<WarehouseStockData> {
  final Value<String> id;
  final Value<String> warehouseId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<int> minQuantity;
  final Value<int?> maxQuantity;
  final Value<String?> location;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WarehouseStockCompanion({
    this.id = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.minQuantity = const Value.absent(),
    this.maxQuantity = const Value.absent(),
    this.location = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WarehouseStockCompanion.insert({
    required String id,
    required String warehouseId,
    required String productId,
    this.quantity = const Value.absent(),
    this.minQuantity = const Value.absent(),
    this.maxQuantity = const Value.absent(),
    this.location = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        warehouseId = Value(warehouseId),
        productId = Value(productId);
  static Insertable<WarehouseStockData> custom({
    Expression<String>? id,
    Expression<String>? warehouseId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<int>? minQuantity,
    Expression<int>? maxQuantity,
    Expression<String>? location,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (minQuantity != null) 'min_quantity': minQuantity,
      if (maxQuantity != null) 'max_quantity': maxQuantity,
      if (location != null) 'location': location,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WarehouseStockCompanion copyWith(
      {Value<String>? id,
      Value<String>? warehouseId,
      Value<String>? productId,
      Value<int>? quantity,
      Value<int>? minQuantity,
      Value<int?>? maxQuantity,
      Value<String?>? location,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return WarehouseStockCompanion(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      location: location ?? this.location,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (minQuantity.present) {
      map['min_quantity'] = Variable<int>(minQuantity.value);
    }
    if (maxQuantity.present) {
      map['max_quantity'] = Variable<int>(maxQuantity.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarehouseStockCompanion(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('maxQuantity: $maxQuantity, ')
          ..write('location: $location, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockTransfersTable extends StockTransfers
    with TableInfo<$StockTransfersTable, StockTransfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockTransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transferNumberMeta =
      const VerificationMeta('transferNumber');
  @override
  late final GeneratedColumn<String> transferNumber = GeneratedColumn<String>(
      'transfer_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromWarehouseIdMeta =
      const VerificationMeta('fromWarehouseId');
  @override
  late final GeneratedColumn<String> fromWarehouseId = GeneratedColumn<String>(
      'from_warehouse_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES warehouses (id)'));
  static const VerificationMeta _toWarehouseIdMeta =
      const VerificationMeta('toWarehouseId');
  @override
  late final GeneratedColumn<String> toWarehouseId = GeneratedColumn<String>(
      'to_warehouse_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES warehouses (id)'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _transferDateMeta =
      const VerificationMeta('transferDate');
  @override
  late final GeneratedColumn<DateTime> transferDate = GeneratedColumn<DateTime>(
      'transfer_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transferNumber,
        fromWarehouseId,
        toWarehouseId,
        status,
        notes,
        syncStatus,
        transferDate,
        completedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_transfers';
  @override
  VerificationContext validateIntegrity(Insertable<StockTransfer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transfer_number')) {
      context.handle(
          _transferNumberMeta,
          transferNumber.isAcceptableOrUnknown(
              data['transfer_number']!, _transferNumberMeta));
    } else if (isInserting) {
      context.missing(_transferNumberMeta);
    }
    if (data.containsKey('from_warehouse_id')) {
      context.handle(
          _fromWarehouseIdMeta,
          fromWarehouseId.isAcceptableOrUnknown(
              data['from_warehouse_id']!, _fromWarehouseIdMeta));
    } else if (isInserting) {
      context.missing(_fromWarehouseIdMeta);
    }
    if (data.containsKey('to_warehouse_id')) {
      context.handle(
          _toWarehouseIdMeta,
          toWarehouseId.isAcceptableOrUnknown(
              data['to_warehouse_id']!, _toWarehouseIdMeta));
    } else if (isInserting) {
      context.missing(_toWarehouseIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('transfer_date')) {
      context.handle(
          _transferDateMeta,
          transferDate.isAcceptableOrUnknown(
              data['transfer_date']!, _transferDateMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockTransfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockTransfer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transferNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transfer_number'])!,
      fromWarehouseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}from_warehouse_id'])!,
      toWarehouseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}to_warehouse_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      transferDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transfer_date'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StockTransfersTable createAlias(String alias) {
    return $StockTransfersTable(attachedDatabase, alias);
  }
}

class StockTransfer extends DataClass implements Insertable<StockTransfer> {
  final String id;
  final String transferNumber;
  final String fromWarehouseId;
  final String toWarehouseId;
  final String status;
  final String? notes;
  final String syncStatus;
  final DateTime transferDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  const StockTransfer(
      {required this.id,
      required this.transferNumber,
      required this.fromWarehouseId,
      required this.toWarehouseId,
      required this.status,
      this.notes,
      required this.syncStatus,
      required this.transferDate,
      this.completedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transfer_number'] = Variable<String>(transferNumber);
    map['from_warehouse_id'] = Variable<String>(fromWarehouseId);
    map['to_warehouse_id'] = Variable<String>(toWarehouseId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['transfer_date'] = Variable<DateTime>(transferDate);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockTransfersCompanion toCompanion(bool nullToAbsent) {
    return StockTransfersCompanion(
      id: Value(id),
      transferNumber: Value(transferNumber),
      fromWarehouseId: Value(fromWarehouseId),
      toWarehouseId: Value(toWarehouseId),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncStatus: Value(syncStatus),
      transferDate: Value(transferDate),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
    );
  }

  factory StockTransfer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockTransfer(
      id: serializer.fromJson<String>(json['id']),
      transferNumber: serializer.fromJson<String>(json['transferNumber']),
      fromWarehouseId: serializer.fromJson<String>(json['fromWarehouseId']),
      toWarehouseId: serializer.fromJson<String>(json['toWarehouseId']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      transferDate: serializer.fromJson<DateTime>(json['transferDate']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transferNumber': serializer.toJson<String>(transferNumber),
      'fromWarehouseId': serializer.toJson<String>(fromWarehouseId),
      'toWarehouseId': serializer.toJson<String>(toWarehouseId),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'transferDate': serializer.toJson<DateTime>(transferDate),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockTransfer copyWith(
          {String? id,
          String? transferNumber,
          String? fromWarehouseId,
          String? toWarehouseId,
          String? status,
          Value<String?> notes = const Value.absent(),
          String? syncStatus,
          DateTime? transferDate,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt}) =>
      StockTransfer(
        id: id ?? this.id,
        transferNumber: transferNumber ?? this.transferNumber,
        fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
        toWarehouseId: toWarehouseId ?? this.toWarehouseId,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
        transferDate: transferDate ?? this.transferDate,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  StockTransfer copyWithCompanion(StockTransfersCompanion data) {
    return StockTransfer(
      id: data.id.present ? data.id.value : this.id,
      transferNumber: data.transferNumber.present
          ? data.transferNumber.value
          : this.transferNumber,
      fromWarehouseId: data.fromWarehouseId.present
          ? data.fromWarehouseId.value
          : this.fromWarehouseId,
      toWarehouseId: data.toWarehouseId.present
          ? data.toWarehouseId.value
          : this.toWarehouseId,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      transferDate: data.transferDate.present
          ? data.transferDate.value
          : this.transferDate,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockTransfer(')
          ..write('id: $id, ')
          ..write('transferNumber: $transferNumber, ')
          ..write('fromWarehouseId: $fromWarehouseId, ')
          ..write('toWarehouseId: $toWarehouseId, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('transferDate: $transferDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transferNumber,
      fromWarehouseId,
      toWarehouseId,
      status,
      notes,
      syncStatus,
      transferDate,
      completedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockTransfer &&
          other.id == this.id &&
          other.transferNumber == this.transferNumber &&
          other.fromWarehouseId == this.fromWarehouseId &&
          other.toWarehouseId == this.toWarehouseId &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.transferDate == this.transferDate &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt);
}

class StockTransfersCompanion extends UpdateCompanion<StockTransfer> {
  final Value<String> id;
  final Value<String> transferNumber;
  final Value<String> fromWarehouseId;
  final Value<String> toWarehouseId;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<DateTime> transferDate;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StockTransfersCompanion({
    this.id = const Value.absent(),
    this.transferNumber = const Value.absent(),
    this.fromWarehouseId = const Value.absent(),
    this.toWarehouseId = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.transferDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockTransfersCompanion.insert({
    required String id,
    required String transferNumber,
    required String fromWarehouseId,
    required String toWarehouseId,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.transferDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transferNumber = Value(transferNumber),
        fromWarehouseId = Value(fromWarehouseId),
        toWarehouseId = Value(toWarehouseId);
  static Insertable<StockTransfer> custom({
    Expression<String>? id,
    Expression<String>? transferNumber,
    Expression<String>? fromWarehouseId,
    Expression<String>? toWarehouseId,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<DateTime>? transferDate,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transferNumber != null) 'transfer_number': transferNumber,
      if (fromWarehouseId != null) 'from_warehouse_id': fromWarehouseId,
      if (toWarehouseId != null) 'to_warehouse_id': toWarehouseId,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (transferDate != null) 'transfer_date': transferDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockTransfersCompanion copyWith(
      {Value<String>? id,
      Value<String>? transferNumber,
      Value<String>? fromWarehouseId,
      Value<String>? toWarehouseId,
      Value<String>? status,
      Value<String?>? notes,
      Value<String>? syncStatus,
      Value<DateTime>? transferDate,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return StockTransfersCompanion(
      id: id ?? this.id,
      transferNumber: transferNumber ?? this.transferNumber,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      transferDate: transferDate ?? this.transferDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transferNumber.present) {
      map['transfer_number'] = Variable<String>(transferNumber.value);
    }
    if (fromWarehouseId.present) {
      map['from_warehouse_id'] = Variable<String>(fromWarehouseId.value);
    }
    if (toWarehouseId.present) {
      map['to_warehouse_id'] = Variable<String>(toWarehouseId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (transferDate.present) {
      map['transfer_date'] = Variable<DateTime>(transferDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockTransfersCompanion(')
          ..write('id: $id, ')
          ..write('transferNumber: $transferNumber, ')
          ..write('fromWarehouseId: $fromWarehouseId, ')
          ..write('toWarehouseId: $toWarehouseId, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('transferDate: $transferDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockTransferItemsTable extends StockTransferItems
    with TableInfo<$StockTransferItemsTable, StockTransferItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockTransferItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transferIdMeta =
      const VerificationMeta('transferId');
  @override
  late final GeneratedColumn<String> transferId = GeneratedColumn<String>(
      'transfer_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES stock_transfers (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requestedQuantityMeta =
      const VerificationMeta('requestedQuantity');
  @override
  late final GeneratedColumn<int> requestedQuantity = GeneratedColumn<int>(
      'requested_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _transferredQuantityMeta =
      const VerificationMeta('transferredQuantity');
  @override
  late final GeneratedColumn<int> transferredQuantity = GeneratedColumn<int>(
      'transferred_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transferId,
        productId,
        productName,
        requestedQuantity,
        transferredQuantity,
        notes,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_transfer_items';
  @override
  VerificationContext validateIntegrity(Insertable<StockTransferItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transfer_id')) {
      context.handle(
          _transferIdMeta,
          transferId.isAcceptableOrUnknown(
              data['transfer_id']!, _transferIdMeta));
    } else if (isInserting) {
      context.missing(_transferIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('requested_quantity')) {
      context.handle(
          _requestedQuantityMeta,
          requestedQuantity.isAcceptableOrUnknown(
              data['requested_quantity']!, _requestedQuantityMeta));
    } else if (isInserting) {
      context.missing(_requestedQuantityMeta);
    }
    if (data.containsKey('transferred_quantity')) {
      context.handle(
          _transferredQuantityMeta,
          transferredQuantity.isAcceptableOrUnknown(
              data['transferred_quantity']!, _transferredQuantityMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockTransferItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockTransferItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transferId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transfer_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      requestedQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}requested_quantity'])!,
      transferredQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}transferred_quantity'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StockTransferItemsTable createAlias(String alias) {
    return $StockTransferItemsTable(attachedDatabase, alias);
  }
}

class StockTransferItem extends DataClass
    implements Insertable<StockTransferItem> {
  final String id;
  final String transferId;
  final String productId;
  final String productName;
  final int requestedQuantity;
  final int transferredQuantity;
  final String? notes;
  final String syncStatus;
  final DateTime createdAt;
  const StockTransferItem(
      {required this.id,
      required this.transferId,
      required this.productId,
      required this.productName,
      required this.requestedQuantity,
      required this.transferredQuantity,
      this.notes,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transfer_id'] = Variable<String>(transferId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['requested_quantity'] = Variable<int>(requestedQuantity);
    map['transferred_quantity'] = Variable<int>(transferredQuantity);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockTransferItemsCompanion toCompanion(bool nullToAbsent) {
    return StockTransferItemsCompanion(
      id: Value(id),
      transferId: Value(transferId),
      productId: Value(productId),
      productName: Value(productName),
      requestedQuantity: Value(requestedQuantity),
      transferredQuantity: Value(transferredQuantity),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory StockTransferItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockTransferItem(
      id: serializer.fromJson<String>(json['id']),
      transferId: serializer.fromJson<String>(json['transferId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      requestedQuantity: serializer.fromJson<int>(json['requestedQuantity']),
      transferredQuantity:
          serializer.fromJson<int>(json['transferredQuantity']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transferId': serializer.toJson<String>(transferId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'requestedQuantity': serializer.toJson<int>(requestedQuantity),
      'transferredQuantity': serializer.toJson<int>(transferredQuantity),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockTransferItem copyWith(
          {String? id,
          String? transferId,
          String? productId,
          String? productName,
          int? requestedQuantity,
          int? transferredQuantity,
          Value<String?> notes = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt}) =>
      StockTransferItem(
        id: id ?? this.id,
        transferId: transferId ?? this.transferId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        requestedQuantity: requestedQuantity ?? this.requestedQuantity,
        transferredQuantity: transferredQuantity ?? this.transferredQuantity,
        notes: notes.present ? notes.value : this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  StockTransferItem copyWithCompanion(StockTransferItemsCompanion data) {
    return StockTransferItem(
      id: data.id.present ? data.id.value : this.id,
      transferId:
          data.transferId.present ? data.transferId.value : this.transferId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      requestedQuantity: data.requestedQuantity.present
          ? data.requestedQuantity.value
          : this.requestedQuantity,
      transferredQuantity: data.transferredQuantity.present
          ? data.transferredQuantity.value
          : this.transferredQuantity,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockTransferItem(')
          ..write('id: $id, ')
          ..write('transferId: $transferId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('requestedQuantity: $requestedQuantity, ')
          ..write('transferredQuantity: $transferredQuantity, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transferId, productId, productName,
      requestedQuantity, transferredQuantity, notes, syncStatus, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockTransferItem &&
          other.id == this.id &&
          other.transferId == this.transferId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.requestedQuantity == this.requestedQuantity &&
          other.transferredQuantity == this.transferredQuantity &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class StockTransferItemsCompanion extends UpdateCompanion<StockTransferItem> {
  final Value<String> id;
  final Value<String> transferId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> requestedQuantity;
  final Value<int> transferredQuantity;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StockTransferItemsCompanion({
    this.id = const Value.absent(),
    this.transferId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.requestedQuantity = const Value.absent(),
    this.transferredQuantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockTransferItemsCompanion.insert({
    required String id,
    required String transferId,
    required String productId,
    required String productName,
    required int requestedQuantity,
    this.transferredQuantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transferId = Value(transferId),
        productId = Value(productId),
        productName = Value(productName),
        requestedQuantity = Value(requestedQuantity);
  static Insertable<StockTransferItem> custom({
    Expression<String>? id,
    Expression<String>? transferId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<int>? requestedQuantity,
    Expression<int>? transferredQuantity,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transferId != null) 'transfer_id': transferId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (requestedQuantity != null) 'requested_quantity': requestedQuantity,
      if (transferredQuantity != null)
        'transferred_quantity': transferredQuantity,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockTransferItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? transferId,
      Value<String>? productId,
      Value<String>? productName,
      Value<int>? requestedQuantity,
      Value<int>? transferredQuantity,
      Value<String?>? notes,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return StockTransferItemsCompanion(
      id: id ?? this.id,
      transferId: transferId ?? this.transferId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      transferredQuantity: transferredQuantity ?? this.transferredQuantity,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transferId.present) {
      map['transfer_id'] = Variable<String>(transferId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (requestedQuantity.present) {
      map['requested_quantity'] = Variable<int>(requestedQuantity.value);
    }
    if (transferredQuantity.present) {
      map['transferred_quantity'] = Variable<int>(transferredQuantity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockTransferItemsCompanion(')
          ..write('id: $id, ')
          ..write('transferId: $transferId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('requestedQuantity: $requestedQuantity, ')
          ..write('transferredQuantity: $transferredQuantity, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryCountsTable extends InventoryCounts
    with TableInfo<$InventoryCountsTable, InventoryCount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryCountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _countNumberMeta =
      const VerificationMeta('countNumber');
  @override
  late final GeneratedColumn<String> countNumber = GeneratedColumn<String>(
      'count_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES warehouses (id)'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _countTypeMeta =
      const VerificationMeta('countType');
  @override
  late final GeneratedColumn<String> countType = GeneratedColumn<String>(
      'count_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('full'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _approvedByMeta =
      const VerificationMeta('approvedBy');
  @override
  late final GeneratedColumn<String> approvedBy = GeneratedColumn<String>(
      'approved_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalItemsMeta =
      const VerificationMeta('totalItems');
  @override
  late final GeneratedColumn<int> totalItems = GeneratedColumn<int>(
      'total_items', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _countedItemsMeta =
      const VerificationMeta('countedItems');
  @override
  late final GeneratedColumn<int> countedItems = GeneratedColumn<int>(
      'counted_items', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _varianceItemsMeta =
      const VerificationMeta('varianceItems');
  @override
  late final GeneratedColumn<int> varianceItems = GeneratedColumn<int>(
      'variance_items', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalVarianceValueMeta =
      const VerificationMeta('totalVarianceValue');
  @override
  late final GeneratedColumn<double> totalVarianceValue =
      GeneratedColumn<double>('total_variance_value', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _countDateMeta =
      const VerificationMeta('countDate');
  @override
  late final GeneratedColumn<DateTime> countDate = GeneratedColumn<DateTime>(
      'count_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _approvedAtMeta =
      const VerificationMeta('approvedAt');
  @override
  late final GeneratedColumn<DateTime> approvedAt = GeneratedColumn<DateTime>(
      'approved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        countNumber,
        warehouseId,
        status,
        countType,
        notes,
        createdBy,
        approvedBy,
        totalItems,
        countedItems,
        varianceItems,
        totalVarianceValue,
        syncStatus,
        countDate,
        completedAt,
        approvedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_counts';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryCount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('count_number')) {
      context.handle(
          _countNumberMeta,
          countNumber.isAcceptableOrUnknown(
              data['count_number']!, _countNumberMeta));
    } else if (isInserting) {
      context.missing(_countNumberMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('count_type')) {
      context.handle(_countTypeMeta,
          countType.isAcceptableOrUnknown(data['count_type']!, _countTypeMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('approved_by')) {
      context.handle(
          _approvedByMeta,
          approvedBy.isAcceptableOrUnknown(
              data['approved_by']!, _approvedByMeta));
    }
    if (data.containsKey('total_items')) {
      context.handle(
          _totalItemsMeta,
          totalItems.isAcceptableOrUnknown(
              data['total_items']!, _totalItemsMeta));
    }
    if (data.containsKey('counted_items')) {
      context.handle(
          _countedItemsMeta,
          countedItems.isAcceptableOrUnknown(
              data['counted_items']!, _countedItemsMeta));
    }
    if (data.containsKey('variance_items')) {
      context.handle(
          _varianceItemsMeta,
          varianceItems.isAcceptableOrUnknown(
              data['variance_items']!, _varianceItemsMeta));
    }
    if (data.containsKey('total_variance_value')) {
      context.handle(
          _totalVarianceValueMeta,
          totalVarianceValue.isAcceptableOrUnknown(
              data['total_variance_value']!, _totalVarianceValueMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('count_date')) {
      context.handle(_countDateMeta,
          countDate.isAcceptableOrUnknown(data['count_date']!, _countDateMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('approved_at')) {
      context.handle(
          _approvedAtMeta,
          approvedAt.isAcceptableOrUnknown(
              data['approved_at']!, _approvedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryCount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryCount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      countNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}count_number'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      countType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}count_type'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      approvedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}approved_by']),
      totalItems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_items'])!,
      countedItems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}counted_items'])!,
      varianceItems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}variance_items'])!,
      totalVarianceValue: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_variance_value'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      countDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}count_date'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      approvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}approved_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InventoryCountsTable createAlias(String alias) {
    return $InventoryCountsTable(attachedDatabase, alias);
  }
}

class InventoryCount extends DataClass implements Insertable<InventoryCount> {
  final String id;
  final String countNumber;
  final String warehouseId;
  final String status;
  final String countType;
  final String? notes;
  final String? createdBy;
  final String? approvedBy;
  final int totalItems;
  final int countedItems;
  final int varianceItems;
  final double totalVarianceValue;
  final String syncStatus;
  final DateTime countDate;
  final DateTime? completedAt;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const InventoryCount(
      {required this.id,
      required this.countNumber,
      required this.warehouseId,
      required this.status,
      required this.countType,
      this.notes,
      this.createdBy,
      this.approvedBy,
      required this.totalItems,
      required this.countedItems,
      required this.varianceItems,
      required this.totalVarianceValue,
      required this.syncStatus,
      required this.countDate,
      this.completedAt,
      this.approvedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['count_number'] = Variable<String>(countNumber);
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['status'] = Variable<String>(status);
    map['count_type'] = Variable<String>(countType);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || approvedBy != null) {
      map['approved_by'] = Variable<String>(approvedBy);
    }
    map['total_items'] = Variable<int>(totalItems);
    map['counted_items'] = Variable<int>(countedItems);
    map['variance_items'] = Variable<int>(varianceItems);
    map['total_variance_value'] = Variable<double>(totalVarianceValue);
    map['sync_status'] = Variable<String>(syncStatus);
    map['count_date'] = Variable<DateTime>(countDate);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || approvedAt != null) {
      map['approved_at'] = Variable<DateTime>(approvedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InventoryCountsCompanion toCompanion(bool nullToAbsent) {
    return InventoryCountsCompanion(
      id: Value(id),
      countNumber: Value(countNumber),
      warehouseId: Value(warehouseId),
      status: Value(status),
      countType: Value(countType),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      approvedBy: approvedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedBy),
      totalItems: Value(totalItems),
      countedItems: Value(countedItems),
      varianceItems: Value(varianceItems),
      totalVarianceValue: Value(totalVarianceValue),
      syncStatus: Value(syncStatus),
      countDate: Value(countDate),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      approvedAt: approvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InventoryCount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryCount(
      id: serializer.fromJson<String>(json['id']),
      countNumber: serializer.fromJson<String>(json['countNumber']),
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      status: serializer.fromJson<String>(json['status']),
      countType: serializer.fromJson<String>(json['countType']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      approvedBy: serializer.fromJson<String?>(json['approvedBy']),
      totalItems: serializer.fromJson<int>(json['totalItems']),
      countedItems: serializer.fromJson<int>(json['countedItems']),
      varianceItems: serializer.fromJson<int>(json['varianceItems']),
      totalVarianceValue:
          serializer.fromJson<double>(json['totalVarianceValue']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      countDate: serializer.fromJson<DateTime>(json['countDate']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      approvedAt: serializer.fromJson<DateTime?>(json['approvedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'countNumber': serializer.toJson<String>(countNumber),
      'warehouseId': serializer.toJson<String>(warehouseId),
      'status': serializer.toJson<String>(status),
      'countType': serializer.toJson<String>(countType),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String?>(createdBy),
      'approvedBy': serializer.toJson<String?>(approvedBy),
      'totalItems': serializer.toJson<int>(totalItems),
      'countedItems': serializer.toJson<int>(countedItems),
      'varianceItems': serializer.toJson<int>(varianceItems),
      'totalVarianceValue': serializer.toJson<double>(totalVarianceValue),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'countDate': serializer.toJson<DateTime>(countDate),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'approvedAt': serializer.toJson<DateTime?>(approvedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InventoryCount copyWith(
          {String? id,
          String? countNumber,
          String? warehouseId,
          String? status,
          String? countType,
          Value<String?> notes = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> approvedBy = const Value.absent(),
          int? totalItems,
          int? countedItems,
          int? varianceItems,
          double? totalVarianceValue,
          String? syncStatus,
          DateTime? countDate,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<DateTime?> approvedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      InventoryCount(
        id: id ?? this.id,
        countNumber: countNumber ?? this.countNumber,
        warehouseId: warehouseId ?? this.warehouseId,
        status: status ?? this.status,
        countType: countType ?? this.countType,
        notes: notes.present ? notes.value : this.notes,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        approvedBy: approvedBy.present ? approvedBy.value : this.approvedBy,
        totalItems: totalItems ?? this.totalItems,
        countedItems: countedItems ?? this.countedItems,
        varianceItems: varianceItems ?? this.varianceItems,
        totalVarianceValue: totalVarianceValue ?? this.totalVarianceValue,
        syncStatus: syncStatus ?? this.syncStatus,
        countDate: countDate ?? this.countDate,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        approvedAt: approvedAt.present ? approvedAt.value : this.approvedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  InventoryCount copyWithCompanion(InventoryCountsCompanion data) {
    return InventoryCount(
      id: data.id.present ? data.id.value : this.id,
      countNumber:
          data.countNumber.present ? data.countNumber.value : this.countNumber,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      status: data.status.present ? data.status.value : this.status,
      countType: data.countType.present ? data.countType.value : this.countType,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      approvedBy:
          data.approvedBy.present ? data.approvedBy.value : this.approvedBy,
      totalItems:
          data.totalItems.present ? data.totalItems.value : this.totalItems,
      countedItems: data.countedItems.present
          ? data.countedItems.value
          : this.countedItems,
      varianceItems: data.varianceItems.present
          ? data.varianceItems.value
          : this.varianceItems,
      totalVarianceValue: data.totalVarianceValue.present
          ? data.totalVarianceValue.value
          : this.totalVarianceValue,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      countDate: data.countDate.present ? data.countDate.value : this.countDate,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      approvedAt:
          data.approvedAt.present ? data.approvedAt.value : this.approvedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCount(')
          ..write('id: $id, ')
          ..write('countNumber: $countNumber, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('status: $status, ')
          ..write('countType: $countType, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('totalItems: $totalItems, ')
          ..write('countedItems: $countedItems, ')
          ..write('varianceItems: $varianceItems, ')
          ..write('totalVarianceValue: $totalVarianceValue, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('countDate: $countDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      countNumber,
      warehouseId,
      status,
      countType,
      notes,
      createdBy,
      approvedBy,
      totalItems,
      countedItems,
      varianceItems,
      totalVarianceValue,
      syncStatus,
      countDate,
      completedAt,
      approvedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryCount &&
          other.id == this.id &&
          other.countNumber == this.countNumber &&
          other.warehouseId == this.warehouseId &&
          other.status == this.status &&
          other.countType == this.countType &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.approvedBy == this.approvedBy &&
          other.totalItems == this.totalItems &&
          other.countedItems == this.countedItems &&
          other.varianceItems == this.varianceItems &&
          other.totalVarianceValue == this.totalVarianceValue &&
          other.syncStatus == this.syncStatus &&
          other.countDate == this.countDate &&
          other.completedAt == this.completedAt &&
          other.approvedAt == this.approvedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InventoryCountsCompanion extends UpdateCompanion<InventoryCount> {
  final Value<String> id;
  final Value<String> countNumber;
  final Value<String> warehouseId;
  final Value<String> status;
  final Value<String> countType;
  final Value<String?> notes;
  final Value<String?> createdBy;
  final Value<String?> approvedBy;
  final Value<int> totalItems;
  final Value<int> countedItems;
  final Value<int> varianceItems;
  final Value<double> totalVarianceValue;
  final Value<String> syncStatus;
  final Value<DateTime> countDate;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> approvedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InventoryCountsCompanion({
    this.id = const Value.absent(),
    this.countNumber = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.status = const Value.absent(),
    this.countType = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.countedItems = const Value.absent(),
    this.varianceItems = const Value.absent(),
    this.totalVarianceValue = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.countDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCountsCompanion.insert({
    required String id,
    required String countNumber,
    required String warehouseId,
    this.status = const Value.absent(),
    this.countType = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.countedItems = const Value.absent(),
    this.varianceItems = const Value.absent(),
    this.totalVarianceValue = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.countDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        countNumber = Value(countNumber),
        warehouseId = Value(warehouseId);
  static Insertable<InventoryCount> custom({
    Expression<String>? id,
    Expression<String>? countNumber,
    Expression<String>? warehouseId,
    Expression<String>? status,
    Expression<String>? countType,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<String>? approvedBy,
    Expression<int>? totalItems,
    Expression<int>? countedItems,
    Expression<int>? varianceItems,
    Expression<double>? totalVarianceValue,
    Expression<String>? syncStatus,
    Expression<DateTime>? countDate,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? approvedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (countNumber != null) 'count_number': countNumber,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (status != null) 'status': status,
      if (countType != null) 'count_type': countType,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (totalItems != null) 'total_items': totalItems,
      if (countedItems != null) 'counted_items': countedItems,
      if (varianceItems != null) 'variance_items': varianceItems,
      if (totalVarianceValue != null)
        'total_variance_value': totalVarianceValue,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (countDate != null) 'count_date': countDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? countNumber,
      Value<String>? warehouseId,
      Value<String>? status,
      Value<String>? countType,
      Value<String?>? notes,
      Value<String?>? createdBy,
      Value<String?>? approvedBy,
      Value<int>? totalItems,
      Value<int>? countedItems,
      Value<int>? varianceItems,
      Value<double>? totalVarianceValue,
      Value<String>? syncStatus,
      Value<DateTime>? countDate,
      Value<DateTime?>? completedAt,
      Value<DateTime?>? approvedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return InventoryCountsCompanion(
      id: id ?? this.id,
      countNumber: countNumber ?? this.countNumber,
      warehouseId: warehouseId ?? this.warehouseId,
      status: status ?? this.status,
      countType: countType ?? this.countType,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      totalItems: totalItems ?? this.totalItems,
      countedItems: countedItems ?? this.countedItems,
      varianceItems: varianceItems ?? this.varianceItems,
      totalVarianceValue: totalVarianceValue ?? this.totalVarianceValue,
      syncStatus: syncStatus ?? this.syncStatus,
      countDate: countDate ?? this.countDate,
      completedAt: completedAt ?? this.completedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (countNumber.present) {
      map['count_number'] = Variable<String>(countNumber.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (countType.present) {
      map['count_type'] = Variable<String>(countType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (approvedBy.present) {
      map['approved_by'] = Variable<String>(approvedBy.value);
    }
    if (totalItems.present) {
      map['total_items'] = Variable<int>(totalItems.value);
    }
    if (countedItems.present) {
      map['counted_items'] = Variable<int>(countedItems.value);
    }
    if (varianceItems.present) {
      map['variance_items'] = Variable<int>(varianceItems.value);
    }
    if (totalVarianceValue.present) {
      map['total_variance_value'] = Variable<double>(totalVarianceValue.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (countDate.present) {
      map['count_date'] = Variable<DateTime>(countDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<DateTime>(approvedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCountsCompanion(')
          ..write('id: $id, ')
          ..write('countNumber: $countNumber, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('status: $status, ')
          ..write('countType: $countType, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('totalItems: $totalItems, ')
          ..write('countedItems: $countedItems, ')
          ..write('varianceItems: $varianceItems, ')
          ..write('totalVarianceValue: $totalVarianceValue, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('countDate: $countDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryCountItemsTable extends InventoryCountItems
    with TableInfo<$InventoryCountItemsTable, InventoryCountItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryCountItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _countIdMeta =
      const VerificationMeta('countId');
  @override
  late final GeneratedColumn<String> countId = GeneratedColumn<String>(
      'count_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES inventory_counts (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productSkuMeta =
      const VerificationMeta('productSku');
  @override
  late final GeneratedColumn<String> productSku = GeneratedColumn<String>(
      'product_sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productBarcodeMeta =
      const VerificationMeta('productBarcode');
  @override
  late final GeneratedColumn<String> productBarcode = GeneratedColumn<String>(
      'product_barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _systemQuantityMeta =
      const VerificationMeta('systemQuantity');
  @override
  late final GeneratedColumn<int> systemQuantity = GeneratedColumn<int>(
      'system_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _physicalQuantityMeta =
      const VerificationMeta('physicalQuantity');
  @override
  late final GeneratedColumn<int> physicalQuantity = GeneratedColumn<int>(
      'physical_quantity', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _varianceMeta =
      const VerificationMeta('variance');
  @override
  late final GeneratedColumn<int> variance = GeneratedColumn<int>(
      'variance', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _varianceValueMeta =
      const VerificationMeta('varianceValue');
  @override
  late final GeneratedColumn<double> varianceValue = GeneratedColumn<double>(
      'variance_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _varianceReasonMeta =
      const VerificationMeta('varianceReason');
  @override
  late final GeneratedColumn<String> varianceReason = GeneratedColumn<String>(
      'variance_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCountedMeta =
      const VerificationMeta('isCounted');
  @override
  late final GeneratedColumn<bool> isCounted = GeneratedColumn<bool>(
      'is_counted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_counted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _countedAtMeta =
      const VerificationMeta('countedAt');
  @override
  late final GeneratedColumn<DateTime> countedAt = GeneratedColumn<DateTime>(
      'counted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        countId,
        productId,
        productName,
        productSku,
        productBarcode,
        systemQuantity,
        physicalQuantity,
        variance,
        unitCost,
        varianceValue,
        varianceReason,
        isCounted,
        location,
        notes,
        syncStatus,
        countedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_count_items';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryCountItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('count_id')) {
      context.handle(_countIdMeta,
          countId.isAcceptableOrUnknown(data['count_id']!, _countIdMeta));
    } else if (isInserting) {
      context.missing(_countIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('product_sku')) {
      context.handle(
          _productSkuMeta,
          productSku.isAcceptableOrUnknown(
              data['product_sku']!, _productSkuMeta));
    }
    if (data.containsKey('product_barcode')) {
      context.handle(
          _productBarcodeMeta,
          productBarcode.isAcceptableOrUnknown(
              data['product_barcode']!, _productBarcodeMeta));
    }
    if (data.containsKey('system_quantity')) {
      context.handle(
          _systemQuantityMeta,
          systemQuantity.isAcceptableOrUnknown(
              data['system_quantity']!, _systemQuantityMeta));
    } else if (isInserting) {
      context.missing(_systemQuantityMeta);
    }
    if (data.containsKey('physical_quantity')) {
      context.handle(
          _physicalQuantityMeta,
          physicalQuantity.isAcceptableOrUnknown(
              data['physical_quantity']!, _physicalQuantityMeta));
    }
    if (data.containsKey('variance')) {
      context.handle(_varianceMeta,
          variance.isAcceptableOrUnknown(data['variance']!, _varianceMeta));
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('variance_value')) {
      context.handle(
          _varianceValueMeta,
          varianceValue.isAcceptableOrUnknown(
              data['variance_value']!, _varianceValueMeta));
    }
    if (data.containsKey('variance_reason')) {
      context.handle(
          _varianceReasonMeta,
          varianceReason.isAcceptableOrUnknown(
              data['variance_reason']!, _varianceReasonMeta));
    }
    if (data.containsKey('is_counted')) {
      context.handle(_isCountedMeta,
          isCounted.isAcceptableOrUnknown(data['is_counted']!, _isCountedMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('counted_at')) {
      context.handle(_countedAtMeta,
          countedAt.isAcceptableOrUnknown(data['counted_at']!, _countedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryCountItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryCountItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      countId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}count_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      productSku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_sku']),
      productBarcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_barcode']),
      systemQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}system_quantity'])!,
      physicalQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}physical_quantity']),
      variance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}variance']),
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      varianceValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}variance_value']),
      varianceReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variance_reason']),
      isCounted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_counted'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      countedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}counted_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InventoryCountItemsTable createAlias(String alias) {
    return $InventoryCountItemsTable(attachedDatabase, alias);
  }
}

class InventoryCountItem extends DataClass
    implements Insertable<InventoryCountItem> {
  final String id;
  final String countId;
  final String productId;
  final String productName;
  final String? productSku;
  final String? productBarcode;
  final int systemQuantity;
  final int? physicalQuantity;
  final int? variance;
  final double unitCost;
  final double? varianceValue;
  final String? varianceReason;
  final bool isCounted;
  final String? location;
  final String? notes;
  final String syncStatus;
  final DateTime? countedAt;
  final DateTime createdAt;
  const InventoryCountItem(
      {required this.id,
      required this.countId,
      required this.productId,
      required this.productName,
      this.productSku,
      this.productBarcode,
      required this.systemQuantity,
      this.physicalQuantity,
      this.variance,
      required this.unitCost,
      this.varianceValue,
      this.varianceReason,
      required this.isCounted,
      this.location,
      this.notes,
      required this.syncStatus,
      this.countedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['count_id'] = Variable<String>(countId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || productSku != null) {
      map['product_sku'] = Variable<String>(productSku);
    }
    if (!nullToAbsent || productBarcode != null) {
      map['product_barcode'] = Variable<String>(productBarcode);
    }
    map['system_quantity'] = Variable<int>(systemQuantity);
    if (!nullToAbsent || physicalQuantity != null) {
      map['physical_quantity'] = Variable<int>(physicalQuantity);
    }
    if (!nullToAbsent || variance != null) {
      map['variance'] = Variable<int>(variance);
    }
    map['unit_cost'] = Variable<double>(unitCost);
    if (!nullToAbsent || varianceValue != null) {
      map['variance_value'] = Variable<double>(varianceValue);
    }
    if (!nullToAbsent || varianceReason != null) {
      map['variance_reason'] = Variable<String>(varianceReason);
    }
    map['is_counted'] = Variable<bool>(isCounted);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || countedAt != null) {
      map['counted_at'] = Variable<DateTime>(countedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryCountItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryCountItemsCompanion(
      id: Value(id),
      countId: Value(countId),
      productId: Value(productId),
      productName: Value(productName),
      productSku: productSku == null && nullToAbsent
          ? const Value.absent()
          : Value(productSku),
      productBarcode: productBarcode == null && nullToAbsent
          ? const Value.absent()
          : Value(productBarcode),
      systemQuantity: Value(systemQuantity),
      physicalQuantity: physicalQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalQuantity),
      variance: variance == null && nullToAbsent
          ? const Value.absent()
          : Value(variance),
      unitCost: Value(unitCost),
      varianceValue: varianceValue == null && nullToAbsent
          ? const Value.absent()
          : Value(varianceValue),
      varianceReason: varianceReason == null && nullToAbsent
          ? const Value.absent()
          : Value(varianceReason),
      isCounted: Value(isCounted),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncStatus: Value(syncStatus),
      countedAt: countedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(countedAt),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryCountItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryCountItem(
      id: serializer.fromJson<String>(json['id']),
      countId: serializer.fromJson<String>(json['countId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      productSku: serializer.fromJson<String?>(json['productSku']),
      productBarcode: serializer.fromJson<String?>(json['productBarcode']),
      systemQuantity: serializer.fromJson<int>(json['systemQuantity']),
      physicalQuantity: serializer.fromJson<int?>(json['physicalQuantity']),
      variance: serializer.fromJson<int?>(json['variance']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      varianceValue: serializer.fromJson<double?>(json['varianceValue']),
      varianceReason: serializer.fromJson<String?>(json['varianceReason']),
      isCounted: serializer.fromJson<bool>(json['isCounted']),
      location: serializer.fromJson<String?>(json['location']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      countedAt: serializer.fromJson<DateTime?>(json['countedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'countId': serializer.toJson<String>(countId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'productSku': serializer.toJson<String?>(productSku),
      'productBarcode': serializer.toJson<String?>(productBarcode),
      'systemQuantity': serializer.toJson<int>(systemQuantity),
      'physicalQuantity': serializer.toJson<int?>(physicalQuantity),
      'variance': serializer.toJson<int?>(variance),
      'unitCost': serializer.toJson<double>(unitCost),
      'varianceValue': serializer.toJson<double?>(varianceValue),
      'varianceReason': serializer.toJson<String?>(varianceReason),
      'isCounted': serializer.toJson<bool>(isCounted),
      'location': serializer.toJson<String?>(location),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'countedAt': serializer.toJson<DateTime?>(countedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryCountItem copyWith(
          {String? id,
          String? countId,
          String? productId,
          String? productName,
          Value<String?> productSku = const Value.absent(),
          Value<String?> productBarcode = const Value.absent(),
          int? systemQuantity,
          Value<int?> physicalQuantity = const Value.absent(),
          Value<int?> variance = const Value.absent(),
          double? unitCost,
          Value<double?> varianceValue = const Value.absent(),
          Value<String?> varianceReason = const Value.absent(),
          bool? isCounted,
          Value<String?> location = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? syncStatus,
          Value<DateTime?> countedAt = const Value.absent(),
          DateTime? createdAt}) =>
      InventoryCountItem(
        id: id ?? this.id,
        countId: countId ?? this.countId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        productSku: productSku.present ? productSku.value : this.productSku,
        productBarcode:
            productBarcode.present ? productBarcode.value : this.productBarcode,
        systemQuantity: systemQuantity ?? this.systemQuantity,
        physicalQuantity: physicalQuantity.present
            ? physicalQuantity.value
            : this.physicalQuantity,
        variance: variance.present ? variance.value : this.variance,
        unitCost: unitCost ?? this.unitCost,
        varianceValue:
            varianceValue.present ? varianceValue.value : this.varianceValue,
        varianceReason:
            varianceReason.present ? varianceReason.value : this.varianceReason,
        isCounted: isCounted ?? this.isCounted,
        location: location.present ? location.value : this.location,
        notes: notes.present ? notes.value : this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
        countedAt: countedAt.present ? countedAt.value : this.countedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  InventoryCountItem copyWithCompanion(InventoryCountItemsCompanion data) {
    return InventoryCountItem(
      id: data.id.present ? data.id.value : this.id,
      countId: data.countId.present ? data.countId.value : this.countId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      productSku:
          data.productSku.present ? data.productSku.value : this.productSku,
      productBarcode: data.productBarcode.present
          ? data.productBarcode.value
          : this.productBarcode,
      systemQuantity: data.systemQuantity.present
          ? data.systemQuantity.value
          : this.systemQuantity,
      physicalQuantity: data.physicalQuantity.present
          ? data.physicalQuantity.value
          : this.physicalQuantity,
      variance: data.variance.present ? data.variance.value : this.variance,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      varianceValue: data.varianceValue.present
          ? data.varianceValue.value
          : this.varianceValue,
      varianceReason: data.varianceReason.present
          ? data.varianceReason.value
          : this.varianceReason,
      isCounted: data.isCounted.present ? data.isCounted.value : this.isCounted,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      countedAt: data.countedAt.present ? data.countedAt.value : this.countedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCountItem(')
          ..write('id: $id, ')
          ..write('countId: $countId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productSku: $productSku, ')
          ..write('productBarcode: $productBarcode, ')
          ..write('systemQuantity: $systemQuantity, ')
          ..write('physicalQuantity: $physicalQuantity, ')
          ..write('variance: $variance, ')
          ..write('unitCost: $unitCost, ')
          ..write('varianceValue: $varianceValue, ')
          ..write('varianceReason: $varianceReason, ')
          ..write('isCounted: $isCounted, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('countedAt: $countedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      countId,
      productId,
      productName,
      productSku,
      productBarcode,
      systemQuantity,
      physicalQuantity,
      variance,
      unitCost,
      varianceValue,
      varianceReason,
      isCounted,
      location,
      notes,
      syncStatus,
      countedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryCountItem &&
          other.id == this.id &&
          other.countId == this.countId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.productSku == this.productSku &&
          other.productBarcode == this.productBarcode &&
          other.systemQuantity == this.systemQuantity &&
          other.physicalQuantity == this.physicalQuantity &&
          other.variance == this.variance &&
          other.unitCost == this.unitCost &&
          other.varianceValue == this.varianceValue &&
          other.varianceReason == this.varianceReason &&
          other.isCounted == this.isCounted &&
          other.location == this.location &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.countedAt == this.countedAt &&
          other.createdAt == this.createdAt);
}

class InventoryCountItemsCompanion extends UpdateCompanion<InventoryCountItem> {
  final Value<String> id;
  final Value<String> countId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<String?> productSku;
  final Value<String?> productBarcode;
  final Value<int> systemQuantity;
  final Value<int?> physicalQuantity;
  final Value<int?> variance;
  final Value<double> unitCost;
  final Value<double?> varianceValue;
  final Value<String?> varianceReason;
  final Value<bool> isCounted;
  final Value<String?> location;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<DateTime?> countedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InventoryCountItemsCompanion({
    this.id = const Value.absent(),
    this.countId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.productSku = const Value.absent(),
    this.productBarcode = const Value.absent(),
    this.systemQuantity = const Value.absent(),
    this.physicalQuantity = const Value.absent(),
    this.variance = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.varianceValue = const Value.absent(),
    this.varianceReason = const Value.absent(),
    this.isCounted = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.countedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCountItemsCompanion.insert({
    required String id,
    required String countId,
    required String productId,
    required String productName,
    this.productSku = const Value.absent(),
    this.productBarcode = const Value.absent(),
    required int systemQuantity,
    this.physicalQuantity = const Value.absent(),
    this.variance = const Value.absent(),
    required double unitCost,
    this.varianceValue = const Value.absent(),
    this.varianceReason = const Value.absent(),
    this.isCounted = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.countedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        countId = Value(countId),
        productId = Value(productId),
        productName = Value(productName),
        systemQuantity = Value(systemQuantity),
        unitCost = Value(unitCost);
  static Insertable<InventoryCountItem> custom({
    Expression<String>? id,
    Expression<String>? countId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? productSku,
    Expression<String>? productBarcode,
    Expression<int>? systemQuantity,
    Expression<int>? physicalQuantity,
    Expression<int>? variance,
    Expression<double>? unitCost,
    Expression<double>? varianceValue,
    Expression<String>? varianceReason,
    Expression<bool>? isCounted,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<DateTime>? countedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (countId != null) 'count_id': countId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (productSku != null) 'product_sku': productSku,
      if (productBarcode != null) 'product_barcode': productBarcode,
      if (systemQuantity != null) 'system_quantity': systemQuantity,
      if (physicalQuantity != null) 'physical_quantity': physicalQuantity,
      if (variance != null) 'variance': variance,
      if (unitCost != null) 'unit_cost': unitCost,
      if (varianceValue != null) 'variance_value': varianceValue,
      if (varianceReason != null) 'variance_reason': varianceReason,
      if (isCounted != null) 'is_counted': isCounted,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (countedAt != null) 'counted_at': countedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCountItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? countId,
      Value<String>? productId,
      Value<String>? productName,
      Value<String?>? productSku,
      Value<String?>? productBarcode,
      Value<int>? systemQuantity,
      Value<int?>? physicalQuantity,
      Value<int?>? variance,
      Value<double>? unitCost,
      Value<double?>? varianceValue,
      Value<String?>? varianceReason,
      Value<bool>? isCounted,
      Value<String?>? location,
      Value<String?>? notes,
      Value<String>? syncStatus,
      Value<DateTime?>? countedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return InventoryCountItemsCompanion(
      id: id ?? this.id,
      countId: countId ?? this.countId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productBarcode: productBarcode ?? this.productBarcode,
      systemQuantity: systemQuantity ?? this.systemQuantity,
      physicalQuantity: physicalQuantity ?? this.physicalQuantity,
      variance: variance ?? this.variance,
      unitCost: unitCost ?? this.unitCost,
      varianceValue: varianceValue ?? this.varianceValue,
      varianceReason: varianceReason ?? this.varianceReason,
      isCounted: isCounted ?? this.isCounted,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      countedAt: countedAt ?? this.countedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (countId.present) {
      map['count_id'] = Variable<String>(countId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productSku.present) {
      map['product_sku'] = Variable<String>(productSku.value);
    }
    if (productBarcode.present) {
      map['product_barcode'] = Variable<String>(productBarcode.value);
    }
    if (systemQuantity.present) {
      map['system_quantity'] = Variable<int>(systemQuantity.value);
    }
    if (physicalQuantity.present) {
      map['physical_quantity'] = Variable<int>(physicalQuantity.value);
    }
    if (variance.present) {
      map['variance'] = Variable<int>(variance.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (varianceValue.present) {
      map['variance_value'] = Variable<double>(varianceValue.value);
    }
    if (varianceReason.present) {
      map['variance_reason'] = Variable<String>(varianceReason.value);
    }
    if (isCounted.present) {
      map['is_counted'] = Variable<bool>(isCounted.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (countedAt.present) {
      map['counted_at'] = Variable<DateTime>(countedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCountItemsCompanion(')
          ..write('id: $id, ')
          ..write('countId: $countId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productSku: $productSku, ')
          ..write('productBarcode: $productBarcode, ')
          ..write('systemQuantity: $systemQuantity, ')
          ..write('physicalQuantity: $physicalQuantity, ')
          ..write('variance: $variance, ')
          ..write('unitCost: $unitCost, ')
          ..write('varianceValue: $varianceValue, ')
          ..write('varianceReason: $varianceReason, ')
          ..write('isCounted: $isCounted, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('countedAt: $countedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryAdjustmentsTable extends InventoryAdjustments
    with TableInfo<$InventoryAdjustmentsTable, InventoryAdjustment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryAdjustmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _adjustmentNumberMeta =
      const VerificationMeta('adjustmentNumber');
  @override
  late final GeneratedColumn<String> adjustmentNumber = GeneratedColumn<String>(
      'adjustment_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _countIdMeta =
      const VerificationMeta('countId');
  @override
  late final GeneratedColumn<String> countId = GeneratedColumn<String>(
      'count_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES inventory_counts (id)'));
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES warehouses (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _approvedByMeta =
      const VerificationMeta('approvedBy');
  @override
  late final GeneratedColumn<String> approvedBy = GeneratedColumn<String>(
      'approved_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalValueMeta =
      const VerificationMeta('totalValue');
  @override
  late final GeneratedColumn<double> totalValue = GeneratedColumn<double>(
      'total_value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _adjustmentDateMeta =
      const VerificationMeta('adjustmentDate');
  @override
  late final GeneratedColumn<DateTime> adjustmentDate =
      GeneratedColumn<DateTime>('adjustment_date', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _approvedAtMeta =
      const VerificationMeta('approvedAt');
  @override
  late final GeneratedColumn<DateTime> approvedAt = GeneratedColumn<DateTime>(
      'approved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        adjustmentNumber,
        countId,
        warehouseId,
        type,
        reason,
        status,
        approvedBy,
        totalValue,
        notes,
        syncStatus,
        adjustmentDate,
        approvedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_adjustments';
  @override
  VerificationContext validateIntegrity(
      Insertable<InventoryAdjustment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('adjustment_number')) {
      context.handle(
          _adjustmentNumberMeta,
          adjustmentNumber.isAcceptableOrUnknown(
              data['adjustment_number']!, _adjustmentNumberMeta));
    } else if (isInserting) {
      context.missing(_adjustmentNumberMeta);
    }
    if (data.containsKey('count_id')) {
      context.handle(_countIdMeta,
          countId.isAcceptableOrUnknown(data['count_id']!, _countIdMeta));
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('approved_by')) {
      context.handle(
          _approvedByMeta,
          approvedBy.isAcceptableOrUnknown(
              data['approved_by']!, _approvedByMeta));
    }
    if (data.containsKey('total_value')) {
      context.handle(
          _totalValueMeta,
          totalValue.isAcceptableOrUnknown(
              data['total_value']!, _totalValueMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('adjustment_date')) {
      context.handle(
          _adjustmentDateMeta,
          adjustmentDate.isAcceptableOrUnknown(
              data['adjustment_date']!, _adjustmentDateMeta));
    }
    if (data.containsKey('approved_at')) {
      context.handle(
          _approvedAtMeta,
          approvedAt.isAcceptableOrUnknown(
              data['approved_at']!, _approvedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryAdjustment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryAdjustment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      adjustmentNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}adjustment_number'])!,
      countId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}count_id']),
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      approvedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}approved_by']),
      totalValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_value'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      adjustmentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}adjustment_date'])!,
      approvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}approved_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InventoryAdjustmentsTable createAlias(String alias) {
    return $InventoryAdjustmentsTable(attachedDatabase, alias);
  }
}

class InventoryAdjustment extends DataClass
    implements Insertable<InventoryAdjustment> {
  final String id;
  final String adjustmentNumber;
  final String? countId;
  final String warehouseId;
  final String type;
  final String reason;
  final String status;
  final String? approvedBy;
  final double totalValue;
  final String? notes;
  final String syncStatus;
  final DateTime adjustmentDate;
  final DateTime? approvedAt;
  final DateTime createdAt;
  const InventoryAdjustment(
      {required this.id,
      required this.adjustmentNumber,
      this.countId,
      required this.warehouseId,
      required this.type,
      required this.reason,
      required this.status,
      this.approvedBy,
      required this.totalValue,
      this.notes,
      required this.syncStatus,
      required this.adjustmentDate,
      this.approvedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['adjustment_number'] = Variable<String>(adjustmentNumber);
    if (!nullToAbsent || countId != null) {
      map['count_id'] = Variable<String>(countId);
    }
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['type'] = Variable<String>(type);
    map['reason'] = Variable<String>(reason);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || approvedBy != null) {
      map['approved_by'] = Variable<String>(approvedBy);
    }
    map['total_value'] = Variable<double>(totalValue);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['adjustment_date'] = Variable<DateTime>(adjustmentDate);
    if (!nullToAbsent || approvedAt != null) {
      map['approved_at'] = Variable<DateTime>(approvedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return InventoryAdjustmentsCompanion(
      id: Value(id),
      adjustmentNumber: Value(adjustmentNumber),
      countId: countId == null && nullToAbsent
          ? const Value.absent()
          : Value(countId),
      warehouseId: Value(warehouseId),
      type: Value(type),
      reason: Value(reason),
      status: Value(status),
      approvedBy: approvedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedBy),
      totalValue: Value(totalValue),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncStatus: Value(syncStatus),
      adjustmentDate: Value(adjustmentDate),
      approvedAt: approvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAt),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryAdjustment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryAdjustment(
      id: serializer.fromJson<String>(json['id']),
      adjustmentNumber: serializer.fromJson<String>(json['adjustmentNumber']),
      countId: serializer.fromJson<String?>(json['countId']),
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      type: serializer.fromJson<String>(json['type']),
      reason: serializer.fromJson<String>(json['reason']),
      status: serializer.fromJson<String>(json['status']),
      approvedBy: serializer.fromJson<String?>(json['approvedBy']),
      totalValue: serializer.fromJson<double>(json['totalValue']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      adjustmentDate: serializer.fromJson<DateTime>(json['adjustmentDate']),
      approvedAt: serializer.fromJson<DateTime?>(json['approvedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'adjustmentNumber': serializer.toJson<String>(adjustmentNumber),
      'countId': serializer.toJson<String?>(countId),
      'warehouseId': serializer.toJson<String>(warehouseId),
      'type': serializer.toJson<String>(type),
      'reason': serializer.toJson<String>(reason),
      'status': serializer.toJson<String>(status),
      'approvedBy': serializer.toJson<String?>(approvedBy),
      'totalValue': serializer.toJson<double>(totalValue),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'adjustmentDate': serializer.toJson<DateTime>(adjustmentDate),
      'approvedAt': serializer.toJson<DateTime?>(approvedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryAdjustment copyWith(
          {String? id,
          String? adjustmentNumber,
          Value<String?> countId = const Value.absent(),
          String? warehouseId,
          String? type,
          String? reason,
          String? status,
          Value<String?> approvedBy = const Value.absent(),
          double? totalValue,
          Value<String?> notes = const Value.absent(),
          String? syncStatus,
          DateTime? adjustmentDate,
          Value<DateTime?> approvedAt = const Value.absent(),
          DateTime? createdAt}) =>
      InventoryAdjustment(
        id: id ?? this.id,
        adjustmentNumber: adjustmentNumber ?? this.adjustmentNumber,
        countId: countId.present ? countId.value : this.countId,
        warehouseId: warehouseId ?? this.warehouseId,
        type: type ?? this.type,
        reason: reason ?? this.reason,
        status: status ?? this.status,
        approvedBy: approvedBy.present ? approvedBy.value : this.approvedBy,
        totalValue: totalValue ?? this.totalValue,
        notes: notes.present ? notes.value : this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
        adjustmentDate: adjustmentDate ?? this.adjustmentDate,
        approvedAt: approvedAt.present ? approvedAt.value : this.approvedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  InventoryAdjustment copyWithCompanion(InventoryAdjustmentsCompanion data) {
    return InventoryAdjustment(
      id: data.id.present ? data.id.value : this.id,
      adjustmentNumber: data.adjustmentNumber.present
          ? data.adjustmentNumber.value
          : this.adjustmentNumber,
      countId: data.countId.present ? data.countId.value : this.countId,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      type: data.type.present ? data.type.value : this.type,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
      approvedBy:
          data.approvedBy.present ? data.approvedBy.value : this.approvedBy,
      totalValue:
          data.totalValue.present ? data.totalValue.value : this.totalValue,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      adjustmentDate: data.adjustmentDate.present
          ? data.adjustmentDate.value
          : this.adjustmentDate,
      approvedAt:
          data.approvedAt.present ? data.approvedAt.value : this.approvedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryAdjustment(')
          ..write('id: $id, ')
          ..write('adjustmentNumber: $adjustmentNumber, ')
          ..write('countId: $countId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('type: $type, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('totalValue: $totalValue, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('adjustmentDate: $adjustmentDate, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      adjustmentNumber,
      countId,
      warehouseId,
      type,
      reason,
      status,
      approvedBy,
      totalValue,
      notes,
      syncStatus,
      adjustmentDate,
      approvedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryAdjustment &&
          other.id == this.id &&
          other.adjustmentNumber == this.adjustmentNumber &&
          other.countId == this.countId &&
          other.warehouseId == this.warehouseId &&
          other.type == this.type &&
          other.reason == this.reason &&
          other.status == this.status &&
          other.approvedBy == this.approvedBy &&
          other.totalValue == this.totalValue &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.adjustmentDate == this.adjustmentDate &&
          other.approvedAt == this.approvedAt &&
          other.createdAt == this.createdAt);
}

class InventoryAdjustmentsCompanion
    extends UpdateCompanion<InventoryAdjustment> {
  final Value<String> id;
  final Value<String> adjustmentNumber;
  final Value<String?> countId;
  final Value<String> warehouseId;
  final Value<String> type;
  final Value<String> reason;
  final Value<String> status;
  final Value<String?> approvedBy;
  final Value<double> totalValue;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<DateTime> adjustmentDate;
  final Value<DateTime?> approvedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InventoryAdjustmentsCompanion({
    this.id = const Value.absent(),
    this.adjustmentNumber = const Value.absent(),
    this.countId = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.type = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.totalValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.adjustmentDate = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryAdjustmentsCompanion.insert({
    required String id,
    required String adjustmentNumber,
    this.countId = const Value.absent(),
    required String warehouseId,
    required String type,
    required String reason,
    this.status = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.totalValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.adjustmentDate = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        adjustmentNumber = Value(adjustmentNumber),
        warehouseId = Value(warehouseId),
        type = Value(type),
        reason = Value(reason);
  static Insertable<InventoryAdjustment> custom({
    Expression<String>? id,
    Expression<String>? adjustmentNumber,
    Expression<String>? countId,
    Expression<String>? warehouseId,
    Expression<String>? type,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<String>? approvedBy,
    Expression<double>? totalValue,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<DateTime>? adjustmentDate,
    Expression<DateTime>? approvedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (adjustmentNumber != null) 'adjustment_number': adjustmentNumber,
      if (countId != null) 'count_id': countId,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (type != null) 'type': type,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (totalValue != null) 'total_value': totalValue,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (adjustmentDate != null) 'adjustment_date': adjustmentDate,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryAdjustmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? adjustmentNumber,
      Value<String?>? countId,
      Value<String>? warehouseId,
      Value<String>? type,
      Value<String>? reason,
      Value<String>? status,
      Value<String?>? approvedBy,
      Value<double>? totalValue,
      Value<String?>? notes,
      Value<String>? syncStatus,
      Value<DateTime>? adjustmentDate,
      Value<DateTime?>? approvedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return InventoryAdjustmentsCompanion(
      id: id ?? this.id,
      adjustmentNumber: adjustmentNumber ?? this.adjustmentNumber,
      countId: countId ?? this.countId,
      warehouseId: warehouseId ?? this.warehouseId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      totalValue: totalValue ?? this.totalValue,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      adjustmentDate: adjustmentDate ?? this.adjustmentDate,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (adjustmentNumber.present) {
      map['adjustment_number'] = Variable<String>(adjustmentNumber.value);
    }
    if (countId.present) {
      map['count_id'] = Variable<String>(countId.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (approvedBy.present) {
      map['approved_by'] = Variable<String>(approvedBy.value);
    }
    if (totalValue.present) {
      map['total_value'] = Variable<double>(totalValue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (adjustmentDate.present) {
      map['adjustment_date'] = Variable<DateTime>(adjustmentDate.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<DateTime>(approvedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryAdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('adjustmentNumber: $adjustmentNumber, ')
          ..write('countId: $countId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('type: $type, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('totalValue: $totalValue, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('adjustmentDate: $adjustmentDate, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryAdjustmentItemsTable extends InventoryAdjustmentItems
    with TableInfo<$InventoryAdjustmentItemsTable, InventoryAdjustmentItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryAdjustmentItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _adjustmentIdMeta =
      const VerificationMeta('adjustmentId');
  @override
  late final GeneratedColumn<String> adjustmentId = GeneratedColumn<String>(
      'adjustment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES inventory_adjustments (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityBeforeMeta =
      const VerificationMeta('quantityBefore');
  @override
  late final GeneratedColumn<int> quantityBefore = GeneratedColumn<int>(
      'quantity_before', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityAdjustedMeta =
      const VerificationMeta('quantityAdjusted');
  @override
  late final GeneratedColumn<int> quantityAdjusted = GeneratedColumn<int>(
      'quantity_adjusted', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityAfterMeta =
      const VerificationMeta('quantityAfter');
  @override
  late final GeneratedColumn<int> quantityAfter = GeneratedColumn<int>(
      'quantity_after', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _adjustmentValueMeta =
      const VerificationMeta('adjustmentValue');
  @override
  late final GeneratedColumn<double> adjustmentValue = GeneratedColumn<double>(
      'adjustment_value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        adjustmentId,
        productId,
        productName,
        quantityBefore,
        quantityAdjusted,
        quantityAfter,
        unitCost,
        adjustmentValue,
        reason,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_adjustment_items';
  @override
  VerificationContext validateIntegrity(
      Insertable<InventoryAdjustmentItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('adjustment_id')) {
      context.handle(
          _adjustmentIdMeta,
          adjustmentId.isAcceptableOrUnknown(
              data['adjustment_id']!, _adjustmentIdMeta));
    } else if (isInserting) {
      context.missing(_adjustmentIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity_before')) {
      context.handle(
          _quantityBeforeMeta,
          quantityBefore.isAcceptableOrUnknown(
              data['quantity_before']!, _quantityBeforeMeta));
    } else if (isInserting) {
      context.missing(_quantityBeforeMeta);
    }
    if (data.containsKey('quantity_adjusted')) {
      context.handle(
          _quantityAdjustedMeta,
          quantityAdjusted.isAcceptableOrUnknown(
              data['quantity_adjusted']!, _quantityAdjustedMeta));
    } else if (isInserting) {
      context.missing(_quantityAdjustedMeta);
    }
    if (data.containsKey('quantity_after')) {
      context.handle(
          _quantityAfterMeta,
          quantityAfter.isAcceptableOrUnknown(
              data['quantity_after']!, _quantityAfterMeta));
    } else if (isInserting) {
      context.missing(_quantityAfterMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('adjustment_value')) {
      context.handle(
          _adjustmentValueMeta,
          adjustmentValue.isAcceptableOrUnknown(
              data['adjustment_value']!, _adjustmentValueMeta));
    } else if (isInserting) {
      context.missing(_adjustmentValueMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryAdjustmentItem map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryAdjustmentItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      adjustmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}adjustment_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      quantityBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_before'])!,
      quantityAdjusted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_adjusted'])!,
      quantityAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_after'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      adjustmentValue: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}adjustment_value'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InventoryAdjustmentItemsTable createAlias(String alias) {
    return $InventoryAdjustmentItemsTable(attachedDatabase, alias);
  }
}

class InventoryAdjustmentItem extends DataClass
    implements Insertable<InventoryAdjustmentItem> {
  final String id;
  final String adjustmentId;
  final String productId;
  final String productName;
  final int quantityBefore;
  final int quantityAdjusted;
  final int quantityAfter;
  final double unitCost;
  final double adjustmentValue;
  final String? reason;
  final String syncStatus;
  final DateTime createdAt;
  const InventoryAdjustmentItem(
      {required this.id,
      required this.adjustmentId,
      required this.productId,
      required this.productName,
      required this.quantityBefore,
      required this.quantityAdjusted,
      required this.quantityAfter,
      required this.unitCost,
      required this.adjustmentValue,
      this.reason,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['adjustment_id'] = Variable<String>(adjustmentId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['quantity_before'] = Variable<int>(quantityBefore);
    map['quantity_adjusted'] = Variable<int>(quantityAdjusted);
    map['quantity_after'] = Variable<int>(quantityAfter);
    map['unit_cost'] = Variable<double>(unitCost);
    map['adjustment_value'] = Variable<double>(adjustmentValue);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryAdjustmentItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryAdjustmentItemsCompanion(
      id: Value(id),
      adjustmentId: Value(adjustmentId),
      productId: Value(productId),
      productName: Value(productName),
      quantityBefore: Value(quantityBefore),
      quantityAdjusted: Value(quantityAdjusted),
      quantityAfter: Value(quantityAfter),
      unitCost: Value(unitCost),
      adjustmentValue: Value(adjustmentValue),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryAdjustmentItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryAdjustmentItem(
      id: serializer.fromJson<String>(json['id']),
      adjustmentId: serializer.fromJson<String>(json['adjustmentId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantityBefore: serializer.fromJson<int>(json['quantityBefore']),
      quantityAdjusted: serializer.fromJson<int>(json['quantityAdjusted']),
      quantityAfter: serializer.fromJson<int>(json['quantityAfter']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      adjustmentValue: serializer.fromJson<double>(json['adjustmentValue']),
      reason: serializer.fromJson<String?>(json['reason']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'adjustmentId': serializer.toJson<String>(adjustmentId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantityBefore': serializer.toJson<int>(quantityBefore),
      'quantityAdjusted': serializer.toJson<int>(quantityAdjusted),
      'quantityAfter': serializer.toJson<int>(quantityAfter),
      'unitCost': serializer.toJson<double>(unitCost),
      'adjustmentValue': serializer.toJson<double>(adjustmentValue),
      'reason': serializer.toJson<String?>(reason),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryAdjustmentItem copyWith(
          {String? id,
          String? adjustmentId,
          String? productId,
          String? productName,
          int? quantityBefore,
          int? quantityAdjusted,
          int? quantityAfter,
          double? unitCost,
          double? adjustmentValue,
          Value<String?> reason = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt}) =>
      InventoryAdjustmentItem(
        id: id ?? this.id,
        adjustmentId: adjustmentId ?? this.adjustmentId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        quantityBefore: quantityBefore ?? this.quantityBefore,
        quantityAdjusted: quantityAdjusted ?? this.quantityAdjusted,
        quantityAfter: quantityAfter ?? this.quantityAfter,
        unitCost: unitCost ?? this.unitCost,
        adjustmentValue: adjustmentValue ?? this.adjustmentValue,
        reason: reason.present ? reason.value : this.reason,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  InventoryAdjustmentItem copyWithCompanion(
      InventoryAdjustmentItemsCompanion data) {
    return InventoryAdjustmentItem(
      id: data.id.present ? data.id.value : this.id,
      adjustmentId: data.adjustmentId.present
          ? data.adjustmentId.value
          : this.adjustmentId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      quantityBefore: data.quantityBefore.present
          ? data.quantityBefore.value
          : this.quantityBefore,
      quantityAdjusted: data.quantityAdjusted.present
          ? data.quantityAdjusted.value
          : this.quantityAdjusted,
      quantityAfter: data.quantityAfter.present
          ? data.quantityAfter.value
          : this.quantityAfter,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      adjustmentValue: data.adjustmentValue.present
          ? data.adjustmentValue.value
          : this.adjustmentValue,
      reason: data.reason.present ? data.reason.value : this.reason,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryAdjustmentItem(')
          ..write('id: $id, ')
          ..write('adjustmentId: $adjustmentId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantityBefore: $quantityBefore, ')
          ..write('quantityAdjusted: $quantityAdjusted, ')
          ..write('quantityAfter: $quantityAfter, ')
          ..write('unitCost: $unitCost, ')
          ..write('adjustmentValue: $adjustmentValue, ')
          ..write('reason: $reason, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      adjustmentId,
      productId,
      productName,
      quantityBefore,
      quantityAdjusted,
      quantityAfter,
      unitCost,
      adjustmentValue,
      reason,
      syncStatus,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryAdjustmentItem &&
          other.id == this.id &&
          other.adjustmentId == this.adjustmentId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantityBefore == this.quantityBefore &&
          other.quantityAdjusted == this.quantityAdjusted &&
          other.quantityAfter == this.quantityAfter &&
          other.unitCost == this.unitCost &&
          other.adjustmentValue == this.adjustmentValue &&
          other.reason == this.reason &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class InventoryAdjustmentItemsCompanion
    extends UpdateCompanion<InventoryAdjustmentItem> {
  final Value<String> id;
  final Value<String> adjustmentId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> quantityBefore;
  final Value<int> quantityAdjusted;
  final Value<int> quantityAfter;
  final Value<double> unitCost;
  final Value<double> adjustmentValue;
  final Value<String?> reason;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InventoryAdjustmentItemsCompanion({
    this.id = const Value.absent(),
    this.adjustmentId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantityBefore = const Value.absent(),
    this.quantityAdjusted = const Value.absent(),
    this.quantityAfter = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.adjustmentValue = const Value.absent(),
    this.reason = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryAdjustmentItemsCompanion.insert({
    required String id,
    required String adjustmentId,
    required String productId,
    required String productName,
    required int quantityBefore,
    required int quantityAdjusted,
    required int quantityAfter,
    required double unitCost,
    required double adjustmentValue,
    this.reason = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        adjustmentId = Value(adjustmentId),
        productId = Value(productId),
        productName = Value(productName),
        quantityBefore = Value(quantityBefore),
        quantityAdjusted = Value(quantityAdjusted),
        quantityAfter = Value(quantityAfter),
        unitCost = Value(unitCost),
        adjustmentValue = Value(adjustmentValue);
  static Insertable<InventoryAdjustmentItem> custom({
    Expression<String>? id,
    Expression<String>? adjustmentId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<int>? quantityBefore,
    Expression<int>? quantityAdjusted,
    Expression<int>? quantityAfter,
    Expression<double>? unitCost,
    Expression<double>? adjustmentValue,
    Expression<String>? reason,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (adjustmentId != null) 'adjustment_id': adjustmentId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantityBefore != null) 'quantity_before': quantityBefore,
      if (quantityAdjusted != null) 'quantity_adjusted': quantityAdjusted,
      if (quantityAfter != null) 'quantity_after': quantityAfter,
      if (unitCost != null) 'unit_cost': unitCost,
      if (adjustmentValue != null) 'adjustment_value': adjustmentValue,
      if (reason != null) 'reason': reason,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryAdjustmentItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? adjustmentId,
      Value<String>? productId,
      Value<String>? productName,
      Value<int>? quantityBefore,
      Value<int>? quantityAdjusted,
      Value<int>? quantityAfter,
      Value<double>? unitCost,
      Value<double>? adjustmentValue,
      Value<String?>? reason,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return InventoryAdjustmentItemsCompanion(
      id: id ?? this.id,
      adjustmentId: adjustmentId ?? this.adjustmentId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantityBefore: quantityBefore ?? this.quantityBefore,
      quantityAdjusted: quantityAdjusted ?? this.quantityAdjusted,
      quantityAfter: quantityAfter ?? this.quantityAfter,
      unitCost: unitCost ?? this.unitCost,
      adjustmentValue: adjustmentValue ?? this.adjustmentValue,
      reason: reason ?? this.reason,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (adjustmentId.present) {
      map['adjustment_id'] = Variable<String>(adjustmentId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantityBefore.present) {
      map['quantity_before'] = Variable<int>(quantityBefore.value);
    }
    if (quantityAdjusted.present) {
      map['quantity_adjusted'] = Variable<int>(quantityAdjusted.value);
    }
    if (quantityAfter.present) {
      map['quantity_after'] = Variable<int>(quantityAfter.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (adjustmentValue.present) {
      map['adjustment_value'] = Variable<double>(adjustmentValue.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryAdjustmentItemsCompanion(')
          ..write('id: $id, ')
          ..write('adjustmentId: $adjustmentId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantityBefore: $quantityBefore, ')
          ..write('quantityAdjusted: $quantityAdjusted, ')
          ..write('quantityAfter: $quantityAfter, ')
          ..write('unitCost: $unitCost, ')
          ..write('adjustmentValue: $adjustmentValue, ')
          ..write('reason: $reason, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $InventoryMovementsTable inventoryMovements =
      $InventoryMovementsTable(this);
  late final $CashMovementsTable cashMovements = $CashMovementsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $VoucherCategoriesTable voucherCategories =
      $VoucherCategoriesTable(this);
  late final $VouchersTable vouchers = $VouchersTable(this);
  late final $WarehousesTable warehouses = $WarehousesTable(this);
  late final $WarehouseStockTable warehouseStock = $WarehouseStockTable(this);
  late final $StockTransfersTable stockTransfers = $StockTransfersTable(this);
  late final $StockTransferItemsTable stockTransferItems =
      $StockTransferItemsTable(this);
  late final $InventoryCountsTable inventoryCounts =
      $InventoryCountsTable(this);
  late final $InventoryCountItemsTable inventoryCountItems =
      $InventoryCountItemsTable(this);
  late final $InventoryAdjustmentsTable inventoryAdjustments =
      $InventoryAdjustmentsTable(this);
  late final $InventoryAdjustmentItemsTable inventoryAdjustmentItems =
      $InventoryAdjustmentItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        products,
        customers,
        suppliers,
        shifts,
        invoices,
        invoiceItems,
        inventoryMovements,
        cashMovements,
        settings,
        voucherCategories,
        vouchers,
        warehouses,
        warehouseStock,
        stockTransfers,
        stockTransferItems,
        inventoryCounts,
        inventoryCountItems,
        inventoryAdjustments,
        inventoryAdjustmentItems
      ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> parentId,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> parentId,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<Product>> _productsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.products,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.products.categoryId));

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> productsRefs(
      Expression<bool> Function($$ProductsTableFilterComposer f) f) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
      Expression<T> Function($$ProductsTableAnnotationComposer a) f) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool productsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            description: description,
            parentId: parentId,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            description: description,
            parentId: parentId,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._productsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .productsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool productsRefs})>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String name,
  Value<String?> sku,
  Value<String?> barcode,
  Value<String?> categoryId,
  required double purchasePrice,
  Value<double?> purchasePriceUsd,
  required double salePrice,
  Value<double?> salePriceUsd,
  Value<double?> exchangeRateAtCreation,
  Value<int> quantity,
  Value<int> minQuantity,
  Value<double?> taxRate,
  Value<String?> description,
  Value<String?> imageUrl,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> sku,
  Value<String?> barcode,
  Value<String?> categoryId,
  Value<double> purchasePrice,
  Value<double?> purchasePriceUsd,
  Value<double> salePrice,
  Value<double?> salePriceUsd,
  Value<double?> exchangeRateAtCreation,
  Value<int> quantity,
  Value<int> minQuantity,
  Value<double?> taxRate,
  Value<String?> description,
  Value<String?> imageUrl,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.products.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
      _invoiceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.invoiceItems,
          aliasName:
              $_aliasNameGenerator(db.products.id, db.invoiceItems.productId));

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager($_db, $_db.invoiceItems)
        .filter((f) => f.productId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryMovementsTable, List<InventoryMovement>>
      _inventoryMovementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryMovements,
              aliasName: $_aliasNameGenerator(
                  db.products.id, db.inventoryMovements.productId));

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager =
        $$InventoryMovementsTableTableManager($_db, $_db.inventoryMovements)
            .filter((f) => f.productId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_inventoryMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WarehouseStockTable, List<WarehouseStockData>>
      _warehouseStockRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.warehouseStock,
              aliasName: $_aliasNameGenerator(
                  db.products.id, db.warehouseStock.productId));

  $$WarehouseStockTableProcessedTableManager get warehouseStockRefs {
    final manager = $$WarehouseStockTableTableManager($_db, $_db.warehouseStock)
        .filter((f) => f.productId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_warehouseStockRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StockTransferItemsTable, List<StockTransferItem>>
      _stockTransferItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.stockTransferItems,
              aliasName: $_aliasNameGenerator(
                  db.products.id, db.stockTransferItems.productId));

  $$StockTransferItemsTableProcessedTableManager get stockTransferItemsRefs {
    final manager =
        $$StockTransferItemsTableTableManager($_db, $_db.stockTransferItems)
            .filter((f) => f.productId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_stockTransferItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryCountItemsTable,
      List<InventoryCountItem>> _inventoryCountItemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.inventoryCountItems,
          aliasName: $_aliasNameGenerator(
              db.products.id, db.inventoryCountItems.productId));

  $$InventoryCountItemsTableProcessedTableManager get inventoryCountItemsRefs {
    final manager =
        $$InventoryCountItemsTableTableManager($_db, $_db.inventoryCountItems)
            .filter((f) => f.productId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_inventoryCountItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryAdjustmentItemsTable,
      List<InventoryAdjustmentItem>> _inventoryAdjustmentItemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.inventoryAdjustmentItems,
          aliasName: $_aliasNameGenerator(
              db.products.id, db.inventoryAdjustmentItems.productId));

  $$InventoryAdjustmentItemsTableProcessedTableManager
      get inventoryAdjustmentItemsRefs {
    final manager = $$InventoryAdjustmentItemsTableTableManager(
            $_db, $_db.inventoryAdjustmentItems)
        .filter((f) => f.productId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_inventoryAdjustmentItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchasePriceUsd => $composableBuilder(
      column: $table.purchasePriceUsd,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salePriceUsd => $composableBuilder(
      column: $table.salePriceUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRateAtCreation => $composableBuilder(
      column: $table.exchangeRateAtCreation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minQuantity => $composableBuilder(
      column: $table.minQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxRate => $composableBuilder(
      column: $table.taxRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> invoiceItemsRefs(
      Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceItemsTableFilterComposer(
              $db: $db,
              $table: $db.invoiceItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
      Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryMovements,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryMovementsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> warehouseStockRefs(
      Expression<bool> Function($$WarehouseStockTableFilterComposer f) f) {
    final $$WarehouseStockTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.warehouseStock,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehouseStockTableFilterComposer(
              $db: $db,
              $table: $db.warehouseStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> stockTransferItemsRefs(
      Expression<bool> Function($$StockTransferItemsTableFilterComposer f) f) {
    final $$StockTransferItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.stockTransferItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StockTransferItemsTableFilterComposer(
              $db: $db,
              $table: $db.stockTransferItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryCountItemsRefs(
      Expression<bool> Function($$InventoryCountItemsTableFilterComposer f) f) {
    final $$InventoryCountItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryCountItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountItemsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryCountItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryAdjustmentItemsRefs(
      Expression<bool> Function($$InventoryAdjustmentItemsTableFilterComposer f)
          f) {
    final $$InventoryAdjustmentItemsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryAdjustmentItems,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryAdjustmentItemsTableFilterComposer(
                  $db: $db,
                  $table: $db.inventoryAdjustmentItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchasePriceUsd => $composableBuilder(
      column: $table.purchasePriceUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salePriceUsd => $composableBuilder(
      column: $table.salePriceUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRateAtCreation => $composableBuilder(
      column: $table.exchangeRateAtCreation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minQuantity => $composableBuilder(
      column: $table.minQuantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxRate => $composableBuilder(
      column: $table.taxRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<double> get purchasePriceUsd => $composableBuilder(
      column: $table.purchasePriceUsd, builder: (column) => column);

  GeneratedColumn<double> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<double> get salePriceUsd => $composableBuilder(
      column: $table.salePriceUsd, builder: (column) => column);

  GeneratedColumn<double> get exchangeRateAtCreation => $composableBuilder(
      column: $table.exchangeRateAtCreation, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get minQuantity => $composableBuilder(
      column: $table.minQuantity, builder: (column) => column);

  GeneratedColumn<double> get taxRate =>
      $composableBuilder(column: $table.taxRate, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
      Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.invoiceItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
      Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryMovements,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryMovementsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryMovements,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> warehouseStockRefs<T extends Object>(
      Expression<T> Function($$WarehouseStockTableAnnotationComposer a) f) {
    final $$WarehouseStockTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.warehouseStock,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehouseStockTableAnnotationComposer(
              $db: $db,
              $table: $db.warehouseStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> stockTransferItemsRefs<T extends Object>(
      Expression<T> Function($$StockTransferItemsTableAnnotationComposer a) f) {
    final $$StockTransferItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.stockTransferItems,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$StockTransferItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.stockTransferItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> inventoryCountItemsRefs<T extends Object>(
      Expression<T> Function($$InventoryCountItemsTableAnnotationComposer a)
          f) {
    final $$InventoryCountItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryCountItems,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryCountItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryCountItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> inventoryAdjustmentItemsRefs<T extends Object>(
      Expression<T> Function(
              $$InventoryAdjustmentItemsTableAnnotationComposer a)
          f) {
    final $$InventoryAdjustmentItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryAdjustmentItems,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryAdjustmentItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryAdjustmentItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool categoryId,
        bool invoiceItemsRefs,
        bool inventoryMovementsRefs,
        bool warehouseStockRefs,
        bool stockTransferItemsRefs,
        bool inventoryCountItemsRefs,
        bool inventoryAdjustmentItemsRefs})> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<double> purchasePrice = const Value.absent(),
            Value<double?> purchasePriceUsd = const Value.absent(),
            Value<double> salePrice = const Value.absent(),
            Value<double?> salePriceUsd = const Value.absent(),
            Value<double?> exchangeRateAtCreation = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> minQuantity = const Value.absent(),
            Value<double?> taxRate = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            sku: sku,
            barcode: barcode,
            categoryId: categoryId,
            purchasePrice: purchasePrice,
            purchasePriceUsd: purchasePriceUsd,
            salePrice: salePrice,
            salePriceUsd: salePriceUsd,
            exchangeRateAtCreation: exchangeRateAtCreation,
            quantity: quantity,
            minQuantity: minQuantity,
            taxRate: taxRate,
            description: description,
            imageUrl: imageUrl,
            isActive: isActive,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> sku = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            required double purchasePrice,
            Value<double?> purchasePriceUsd = const Value.absent(),
            required double salePrice,
            Value<double?> salePriceUsd = const Value.absent(),
            Value<double?> exchangeRateAtCreation = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> minQuantity = const Value.absent(),
            Value<double?> taxRate = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            sku: sku,
            barcode: barcode,
            categoryId: categoryId,
            purchasePrice: purchasePrice,
            purchasePriceUsd: purchasePriceUsd,
            salePrice: salePrice,
            salePriceUsd: salePriceUsd,
            exchangeRateAtCreation: exchangeRateAtCreation,
            quantity: quantity,
            minQuantity: minQuantity,
            taxRate: taxRate,
            description: description,
            imageUrl: imageUrl,
            isActive: isActive,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProductsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              invoiceItemsRefs = false,
              inventoryMovementsRefs = false,
              warehouseStockRefs = false,
              stockTransferItemsRefs = false,
              inventoryCountItemsRefs = false,
              inventoryAdjustmentItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (invoiceItemsRefs) db.invoiceItems,
                if (inventoryMovementsRefs) db.inventoryMovements,
                if (warehouseStockRefs) db.warehouseStock,
                if (stockTransferItemsRefs) db.stockTransferItems,
                if (inventoryCountItemsRefs) db.inventoryCountItems,
                if (inventoryAdjustmentItemsRefs) db.inventoryAdjustmentItems
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ProductsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ProductsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoiceItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._invoiceItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .invoiceItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (inventoryMovementsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._inventoryMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .inventoryMovementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (warehouseStockRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._warehouseStockRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .warehouseStockRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (stockTransferItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._stockTransferItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .stockTransferItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (inventoryCountItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._inventoryCountItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .inventoryCountItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (inventoryAdjustmentItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._inventoryAdjustmentItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .inventoryAdjustmentItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool categoryId,
        bool invoiceItemsRefs,
        bool inventoryMovementsRefs,
        bool warehouseStockRefs,
        bool stockTransferItemsRefs,
        bool inventoryCountItemsRefs,
        bool inventoryAdjustmentItemsRefs})>;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<double> balance,
  Value<double?> balanceUsd,
  Value<String?> notes,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<double> balance,
  Value<double?> balanceUsd,
  Value<String?> notes,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.invoices,
          aliasName:
              $_aliasNameGenerator(db.customers.id, db.invoices.customerId));

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.customerId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$VouchersTable, List<Voucher>> _vouchersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.vouchers,
          aliasName:
              $_aliasNameGenerator(db.customers.id, db.vouchers.customerId));

  $$VouchersTableProcessedTableManager get vouchersRefs {
    final manager = $$VouchersTableTableManager($_db, $_db.vouchers)
        .filter((f) => f.customerId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_vouchersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balanceUsd => $composableBuilder(
      column: $table.balanceUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> invoicesRefs(
      Expression<bool> Function($$InvoicesTableFilterComposer f) f) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> vouchersRefs(
      Expression<bool> Function($$VouchersTableFilterComposer f) f) {
    final $$VouchersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vouchers,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VouchersTableFilterComposer(
              $db: $db,
              $table: $db.vouchers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balanceUsd => $composableBuilder(
      column: $table.balanceUsd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<double> get balanceUsd => $composableBuilder(
      column: $table.balanceUsd, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> invoicesRefs<T extends Object>(
      Expression<T> Function($$InvoicesTableAnnotationComposer a) f) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> vouchersRefs<T extends Object>(
      Expression<T> Function($$VouchersTableAnnotationComposer a) f) {
    final $$VouchersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vouchers,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VouchersTableAnnotationComposer(
              $db: $db,
              $table: $db.vouchers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, $$CustomersTableReferences),
    Customer,
    PrefetchHooks Function({bool invoicesRefs, bool vouchersRefs})> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<double?> balanceUsd = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            name: name,
            phone: phone,
            email: email,
            address: address,
            balance: balance,
            balanceUsd: balanceUsd,
            notes: notes,
            isActive: isActive,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<double?> balanceUsd = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            email: email,
            address: address,
            balance: balance,
            balanceUsd: balanceUsd,
            notes: notes,
            isActive: isActive,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CustomersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {invoicesRefs = false, vouchersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (invoicesRefs) db.invoices,
                if (vouchersRefs) db.vouchers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CustomersTableReferences._invoicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomersTableReferences(db, table, p0)
                                .invoicesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.customerId == item.id),
                        typedResults: items),
                  if (vouchersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CustomersTableReferences._vouchersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomersTableReferences(db, table, p0)
                                .vouchersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.customerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, $$CustomersTableReferences),
    Customer,
    PrefetchHooks Function({bool invoicesRefs, bool vouchersRefs})>;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<double> balance,
  Value<double?> balanceUsd,
  Value<String?> notes,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<double> balance,
  Value<double?> balanceUsd,
  Value<String?> notes,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$SuppliersTableReferences
    extends BaseReferences<_$AppDatabase, $SuppliersTable, Supplier> {
  $$SuppliersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.invoices,
          aliasName:
              $_aliasNameGenerator(db.suppliers.id, db.invoices.supplierId));

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.supplierId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$VouchersTable, List<Voucher>> _vouchersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.vouchers,
          aliasName:
              $_aliasNameGenerator(db.suppliers.id, db.vouchers.supplierId));

  $$VouchersTableProcessedTableManager get vouchersRefs {
    final manager = $$VouchersTableTableManager($_db, $_db.vouchers)
        .filter((f) => f.supplierId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_vouchersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balanceUsd => $composableBuilder(
      column: $table.balanceUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> invoicesRefs(
      Expression<bool> Function($$InvoicesTableFilterComposer f) f) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.supplierId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> vouchersRefs(
      Expression<bool> Function($$VouchersTableFilterComposer f) f) {
    final $$VouchersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vouchers,
        getReferencedColumn: (t) => t.supplierId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VouchersTableFilterComposer(
              $db: $db,
              $table: $db.vouchers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balanceUsd => $composableBuilder(
      column: $table.balanceUsd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<double> get balanceUsd => $composableBuilder(
      column: $table.balanceUsd, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> invoicesRefs<T extends Object>(
      Expression<T> Function($$InvoicesTableAnnotationComposer a) f) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.supplierId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> vouchersRefs<T extends Object>(
      Expression<T> Function($$VouchersTableAnnotationComposer a) f) {
    final $$VouchersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vouchers,
        getReferencedColumn: (t) => t.supplierId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VouchersTableAnnotationComposer(
              $db: $db,
              $table: $db.vouchers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SuppliersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, $$SuppliersTableReferences),
    Supplier,
    PrefetchHooks Function({bool invoicesRefs, bool vouchersRefs})> {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<double?> balanceUsd = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliersCompanion(
            id: id,
            name: name,
            phone: phone,
            email: email,
            address: address,
            balance: balance,
            balanceUsd: balanceUsd,
            notes: notes,
            isActive: isActive,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<double?> balanceUsd = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            email: email,
            address: address,
            balance: balance,
            balanceUsd: balanceUsd,
            notes: notes,
            isActive: isActive,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SuppliersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {invoicesRefs = false, vouchersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (invoicesRefs) db.invoices,
                if (vouchersRefs) db.vouchers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SuppliersTableReferences._invoicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SuppliersTableReferences(db, table, p0)
                                .invoicesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.supplierId == item.id),
                        typedResults: items),
                  if (vouchersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SuppliersTableReferences._vouchersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SuppliersTableReferences(db, table, p0)
                                .vouchersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.supplierId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SuppliersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, $$SuppliersTableReferences),
    Supplier,
    PrefetchHooks Function({bool invoicesRefs, bool vouchersRefs})>;
typedef $$ShiftsTableCreateCompanionBuilder = ShiftsCompanion Function({
  required String id,
  required String shiftNumber,
  required double openingBalance,
  Value<double?> closingBalance,
  Value<double?> expectedBalance,
  Value<double?> difference,
  Value<double?> openingBalanceUsd,
  Value<double?> closingBalanceUsd,
  Value<double?> expectedBalanceUsd,
  Value<double?> exchangeRate,
  Value<double> totalSales,
  Value<double> totalReturns,
  Value<double> totalExpenses,
  Value<double> totalIncome,
  Value<double> totalSalesUsd,
  Value<double> totalReturnsUsd,
  Value<double> totalExpensesUsd,
  Value<double> totalIncomeUsd,
  Value<int> transactionCount,
  Value<String> status,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> openedAt,
  Value<DateTime?> closedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ShiftsTableUpdateCompanionBuilder = ShiftsCompanion Function({
  Value<String> id,
  Value<String> shiftNumber,
  Value<double> openingBalance,
  Value<double?> closingBalance,
  Value<double?> expectedBalance,
  Value<double?> difference,
  Value<double?> openingBalanceUsd,
  Value<double?> closingBalanceUsd,
  Value<double?> expectedBalanceUsd,
  Value<double?> exchangeRate,
  Value<double> totalSales,
  Value<double> totalReturns,
  Value<double> totalExpenses,
  Value<double> totalIncome,
  Value<double> totalSalesUsd,
  Value<double> totalReturnsUsd,
  Value<double> totalExpensesUsd,
  Value<double> totalIncomeUsd,
  Value<int> transactionCount,
  Value<String> status,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> openedAt,
  Value<DateTime?> closedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ShiftsTableReferences
    extends BaseReferences<_$AppDatabase, $ShiftsTable, Shift> {
  $$ShiftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.invoices,
          aliasName: $_aliasNameGenerator(db.shifts.id, db.invoices.shiftId));

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.shiftId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CashMovementsTable, List<CashMovement>>
      _cashMovementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.cashMovements,
              aliasName:
                  $_aliasNameGenerator(db.shifts.id, db.cashMovements.shiftId));

  $$CashMovementsTableProcessedTableManager get cashMovementsRefs {
    final manager = $$CashMovementsTableTableManager($_db, $_db.cashMovements)
        .filter((f) => f.shiftId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_cashMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$VouchersTable, List<Voucher>> _vouchersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.vouchers,
          aliasName: $_aliasNameGenerator(db.shifts.id, db.vouchers.shiftId));

  $$VouchersTableProcessedTableManager get vouchersRefs {
    final manager = $$VouchersTableTableManager($_db, $_db.vouchers)
        .filter((f) => f.shiftId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_vouchersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiftNumber => $composableBuilder(
      column: $table.shiftNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get closingBalance => $composableBuilder(
      column: $table.closingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get expectedBalance => $composableBuilder(
      column: $table.expectedBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get openingBalanceUsd => $composableBuilder(
      column: $table.openingBalanceUsd,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get closingBalanceUsd => $composableBuilder(
      column: $table.closingBalanceUsd,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get expectedBalanceUsd => $composableBuilder(
      column: $table.expectedBalanceUsd,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalSales => $composableBuilder(
      column: $table.totalSales, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalReturns => $composableBuilder(
      column: $table.totalReturns, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalExpenses => $composableBuilder(
      column: $table.totalExpenses, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalIncome => $composableBuilder(
      column: $table.totalIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalSalesUsd => $composableBuilder(
      column: $table.totalSalesUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalReturnsUsd => $composableBuilder(
      column: $table.totalReturnsUsd,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalExpensesUsd => $composableBuilder(
      column: $table.totalExpensesUsd,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalIncomeUsd => $composableBuilder(
      column: $table.totalIncomeUsd,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get transactionCount => $composableBuilder(
      column: $table.transactionCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> invoicesRefs(
      Expression<bool> Function($$InvoicesTableFilterComposer f) f) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.shiftId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> cashMovementsRefs(
      Expression<bool> Function($$CashMovementsTableFilterComposer f) f) {
    final $$CashMovementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cashMovements,
        getReferencedColumn: (t) => t.shiftId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CashMovementsTableFilterComposer(
              $db: $db,
              $table: $db.cashMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> vouchersRefs(
      Expression<bool> Function($$VouchersTableFilterComposer f) f) {
    final $$VouchersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vouchers,
        getReferencedColumn: (t) => t.shiftId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VouchersTableFilterComposer(
              $db: $db,
              $table: $db.vouchers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiftNumber => $composableBuilder(
      column: $table.shiftNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get closingBalance => $composableBuilder(
      column: $table.closingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get expectedBalance => $composableBuilder(
      column: $table.expectedBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get openingBalanceUsd => $composableBuilder(
      column: $table.openingBalanceUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get closingBalanceUsd => $composableBuilder(
      column: $table.closingBalanceUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get expectedBalanceUsd => $composableBuilder(
      column: $table.expectedBalanceUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalSales => $composableBuilder(
      column: $table.totalSales, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalReturns => $composableBuilder(
      column: $table.totalReturns,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalExpenses => $composableBuilder(
      column: $table.totalExpenses,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalIncome => $composableBuilder(
      column: $table.totalIncome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalSalesUsd => $composableBuilder(
      column: $table.totalSalesUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalReturnsUsd => $composableBuilder(
      column: $table.totalReturnsUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalExpensesUsd => $composableBuilder(
      column: $table.totalExpensesUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalIncomeUsd => $composableBuilder(
      column: $table.totalIncomeUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transactionCount => $composableBuilder(
      column: $table.transactionCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shiftNumber => $composableBuilder(
      column: $table.shiftNumber, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance, builder: (column) => column);

  GeneratedColumn<double> get closingBalance => $composableBuilder(
      column: $table.closingBalance, builder: (column) => column);

  GeneratedColumn<double> get expectedBalance => $composableBuilder(
      column: $table.expectedBalance, builder: (column) => column);

  GeneratedColumn<double> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => column);

  GeneratedColumn<double> get openingBalanceUsd => $composableBuilder(
      column: $table.openingBalanceUsd, builder: (column) => column);

  GeneratedColumn<double> get closingBalanceUsd => $composableBuilder(
      column: $table.closingBalanceUsd, builder: (column) => column);

  GeneratedColumn<double> get expectedBalanceUsd => $composableBuilder(
      column: $table.expectedBalanceUsd, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<double> get totalSales => $composableBuilder(
      column: $table.totalSales, builder: (column) => column);

  GeneratedColumn<double> get totalReturns => $composableBuilder(
      column: $table.totalReturns, builder: (column) => column);

  GeneratedColumn<double> get totalExpenses => $composableBuilder(
      column: $table.totalExpenses, builder: (column) => column);

  GeneratedColumn<double> get totalIncome => $composableBuilder(
      column: $table.totalIncome, builder: (column) => column);

  GeneratedColumn<double> get totalSalesUsd => $composableBuilder(
      column: $table.totalSalesUsd, builder: (column) => column);

  GeneratedColumn<double> get totalReturnsUsd => $composableBuilder(
      column: $table.totalReturnsUsd, builder: (column) => column);

  GeneratedColumn<double> get totalExpensesUsd => $composableBuilder(
      column: $table.totalExpensesUsd, builder: (column) => column);

  GeneratedColumn<double> get totalIncomeUsd => $composableBuilder(
      column: $table.totalIncomeUsd, builder: (column) => column);

  GeneratedColumn<int> get transactionCount => $composableBuilder(
      column: $table.transactionCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> invoicesRefs<T extends Object>(
      Expression<T> Function($$InvoicesTableAnnotationComposer a) f) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.shiftId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> cashMovementsRefs<T extends Object>(
      Expression<T> Function($$CashMovementsTableAnnotationComposer a) f) {
    final $$CashMovementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cashMovements,
        getReferencedColumn: (t) => t.shiftId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CashMovementsTableAnnotationComposer(
              $db: $db,
              $table: $db.cashMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> vouchersRefs<T extends Object>(
      Expression<T> Function($$VouchersTableAnnotationComposer a) f) {
    final $$VouchersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vouchers,
        getReferencedColumn: (t) => t.shiftId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VouchersTableAnnotationComposer(
              $db: $db,
              $table: $db.vouchers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ShiftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShiftsTable,
    Shift,
    $$ShiftsTableFilterComposer,
    $$ShiftsTableOrderingComposer,
    $$ShiftsTableAnnotationComposer,
    $$ShiftsTableCreateCompanionBuilder,
    $$ShiftsTableUpdateCompanionBuilder,
    (Shift, $$ShiftsTableReferences),
    Shift,
    PrefetchHooks Function(
        {bool invoicesRefs, bool cashMovementsRefs, bool vouchersRefs})> {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> shiftNumber = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<double?> closingBalance = const Value.absent(),
            Value<double?> expectedBalance = const Value.absent(),
            Value<double?> difference = const Value.absent(),
            Value<double?> openingBalanceUsd = const Value.absent(),
            Value<double?> closingBalanceUsd = const Value.absent(),
            Value<double?> expectedBalanceUsd = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<double> totalSales = const Value.absent(),
            Value<double> totalReturns = const Value.absent(),
            Value<double> totalExpenses = const Value.absent(),
            Value<double> totalIncome = const Value.absent(),
            Value<double> totalSalesUsd = const Value.absent(),
            Value<double> totalReturnsUsd = const Value.absent(),
            Value<double> totalExpensesUsd = const Value.absent(),
            Value<double> totalIncomeUsd = const Value.absent(),
            Value<int> transactionCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> openedAt = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftsCompanion(
            id: id,
            shiftNumber: shiftNumber,
            openingBalance: openingBalance,
            closingBalance: closingBalance,
            expectedBalance: expectedBalance,
            difference: difference,
            openingBalanceUsd: openingBalanceUsd,
            closingBalanceUsd: closingBalanceUsd,
            expectedBalanceUsd: expectedBalanceUsd,
            exchangeRate: exchangeRate,
            totalSales: totalSales,
            totalReturns: totalReturns,
            totalExpenses: totalExpenses,
            totalIncome: totalIncome,
            totalSalesUsd: totalSalesUsd,
            totalReturnsUsd: totalReturnsUsd,
            totalExpensesUsd: totalExpensesUsd,
            totalIncomeUsd: totalIncomeUsd,
            transactionCount: transactionCount,
            status: status,
            notes: notes,
            syncStatus: syncStatus,
            openedAt: openedAt,
            closedAt: closedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String shiftNumber,
            required double openingBalance,
            Value<double?> closingBalance = const Value.absent(),
            Value<double?> expectedBalance = const Value.absent(),
            Value<double?> difference = const Value.absent(),
            Value<double?> openingBalanceUsd = const Value.absent(),
            Value<double?> closingBalanceUsd = const Value.absent(),
            Value<double?> expectedBalanceUsd = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<double> totalSales = const Value.absent(),
            Value<double> totalReturns = const Value.absent(),
            Value<double> totalExpenses = const Value.absent(),
            Value<double> totalIncome = const Value.absent(),
            Value<double> totalSalesUsd = const Value.absent(),
            Value<double> totalReturnsUsd = const Value.absent(),
            Value<double> totalExpensesUsd = const Value.absent(),
            Value<double> totalIncomeUsd = const Value.absent(),
            Value<int> transactionCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> openedAt = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftsCompanion.insert(
            id: id,
            shiftNumber: shiftNumber,
            openingBalance: openingBalance,
            closingBalance: closingBalance,
            expectedBalance: expectedBalance,
            difference: difference,
            openingBalanceUsd: openingBalanceUsd,
            closingBalanceUsd: closingBalanceUsd,
            expectedBalanceUsd: expectedBalanceUsd,
            exchangeRate: exchangeRate,
            totalSales: totalSales,
            totalReturns: totalReturns,
            totalExpenses: totalExpenses,
            totalIncome: totalIncome,
            totalSalesUsd: totalSalesUsd,
            totalReturnsUsd: totalReturnsUsd,
            totalExpensesUsd: totalExpensesUsd,
            totalIncomeUsd: totalIncomeUsd,
            transactionCount: transactionCount,
            status: status,
            notes: notes,
            syncStatus: syncStatus,
            openedAt: openedAt,
            closedAt: closedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ShiftsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {invoicesRefs = false,
              cashMovementsRefs = false,
              vouchersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (invoicesRefs) db.invoices,
                if (cashMovementsRefs) db.cashMovements,
                if (vouchersRefs) db.vouchers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ShiftsTableReferences._invoicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ShiftsTableReferences(db, table, p0).invoicesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.shiftId == item.id),
                        typedResults: items),
                  if (cashMovementsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ShiftsTableReferences._cashMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ShiftsTableReferences(db, table, p0)
                                .cashMovementsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.shiftId == item.id),
                        typedResults: items),
                  if (vouchersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ShiftsTableReferences._vouchersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ShiftsTableReferences(db, table, p0).vouchersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.shiftId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ShiftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShiftsTable,
    Shift,
    $$ShiftsTableFilterComposer,
    $$ShiftsTableOrderingComposer,
    $$ShiftsTableAnnotationComposer,
    $$ShiftsTableCreateCompanionBuilder,
    $$ShiftsTableUpdateCompanionBuilder,
    (Shift, $$ShiftsTableReferences),
    Shift,
    PrefetchHooks Function(
        {bool invoicesRefs, bool cashMovementsRefs, bool vouchersRefs})>;
typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  required String id,
  required String invoiceNumber,
  required String type,
  Value<String?> customerId,
  Value<String?> supplierId,
  Value<String?> warehouseId,
  required double subtotal,
  Value<double> taxAmount,
  Value<double> discountAmount,
  required double total,
  Value<double> paidAmount,
  Value<double?> totalUsd,
  Value<double?> paidAmountUsd,
  Value<double?> exchangeRate,
  Value<String> paymentMethod,
  Value<String> status,
  Value<String?> notes,
  Value<String?> shiftId,
  Value<String> syncStatus,
  Value<DateTime> invoiceDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<String> id,
  Value<String> invoiceNumber,
  Value<String> type,
  Value<String?> customerId,
  Value<String?> supplierId,
  Value<String?> warehouseId,
  Value<double> subtotal,
  Value<double> taxAmount,
  Value<double> discountAmount,
  Value<double> total,
  Value<double> paidAmount,
  Value<double?> totalUsd,
  Value<double?> paidAmountUsd,
  Value<double?> exchangeRate,
  Value<String> paymentMethod,
  Value<String> status,
  Value<String?> notes,
  Value<String?> shiftId,
  Value<String> syncStatus,
  Value<DateTime> invoiceDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, Invoice> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
          $_aliasNameGenerator(db.invoices.customerId, db.customers.id));

  $$CustomersTableProcessedTableManager? get customerId {
    if ($_item.customerId == null) return null;
    final manager = $$CustomersTableTableManager($_db, $_db.customers)
        .filter((f) => f.id($_item.customerId!));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias(
          $_aliasNameGenerator(db.invoices.supplierId, db.suppliers.id));

  $$SuppliersTableProcessedTableManager? get supplierId {
    if ($_item.supplierId == null) return null;
    final manager = $$SuppliersTableTableManager($_db, $_db.suppliers)
        .filter((f) => f.id($_item.supplierId!));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ShiftsTable _shiftIdTable(_$AppDatabase db) => db.shifts
      .createAlias($_aliasNameGenerator(db.invoices.shiftId, db.shifts.id));

  $$ShiftsTableProcessedTableManager? get shiftId {
    if ($_item.shiftId == null) return null;
    final manager = $$ShiftsTableTableManager($_db, $_db.shifts)
        .filter((f) => f.id($_item.shiftId!));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
      _invoiceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.invoiceItems,
          aliasName:
              $_aliasNameGenerator(db.invoices.id, db.invoiceItems.invoiceId));

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager($_db, $_db.invoiceItems)
        .filter((f) => f.invoiceId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalUsd => $composableBuilder(
      column: $table.totalUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paidAmountUsd => $composableBuilder(
      column: $table.paidAmountUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get invoiceDate => $composableBuilder(
      column: $table.invoiceDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableFilterComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplierId,
        referencedTable: $db.suppliers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SuppliersTableFilterComposer(
              $db: $db,
              $table: $db.suppliers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ShiftsTableFilterComposer get shiftId {
    final $$ShiftsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableFilterComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> invoiceItemsRefs(
      Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceItems,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceItemsTableFilterComposer(
              $db: $db,
              $table: $db.invoiceItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalUsd => $composableBuilder(
      column: $table.totalUsd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paidAmountUsd => $composableBuilder(
      column: $table.paidAmountUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get invoiceDate => $composableBuilder(
      column: $table.invoiceDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableOrderingComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplierId,
        referencedTable: $db.suppliers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SuppliersTableOrderingComposer(
              $db: $db,
              $table: $db.suppliers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ShiftsTableOrderingComposer get shiftId {
    final $$ShiftsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableOrderingComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<double> get totalUsd =>
      $composableBuilder(column: $table.totalUsd, builder: (column) => column);

  GeneratedColumn<double> get paidAmountUsd => $composableBuilder(
      column: $table.paidAmountUsd, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get invoiceDate => $composableBuilder(
      column: $table.invoiceDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableAnnotationComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplierId,
        referencedTable: $db.suppliers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SuppliersTableAnnotationComposer(
              $db: $db,
              $table: $db.suppliers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ShiftsTableAnnotationComposer get shiftId {
    final $$ShiftsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableAnnotationComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
      Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceItems,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.invoiceItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, $$InvoicesTableReferences),
    Invoice,
    PrefetchHooks Function(
        {bool customerId,
        bool supplierId,
        bool shiftId,
        bool invoiceItemsRefs})> {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> taxAmount = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<double?> totalUsd = const Value.absent(),
            Value<double?> paidAmountUsd = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> shiftId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> invoiceDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion(
            id: id,
            invoiceNumber: invoiceNumber,
            type: type,
            customerId: customerId,
            supplierId: supplierId,
            warehouseId: warehouseId,
            subtotal: subtotal,
            taxAmount: taxAmount,
            discountAmount: discountAmount,
            total: total,
            paidAmount: paidAmount,
            totalUsd: totalUsd,
            paidAmountUsd: paidAmountUsd,
            exchangeRate: exchangeRate,
            paymentMethod: paymentMethod,
            status: status,
            notes: notes,
            shiftId: shiftId,
            syncStatus: syncStatus,
            invoiceDate: invoiceDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceNumber,
            required String type,
            Value<String?> customerId = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            required double subtotal,
            Value<double> taxAmount = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            required double total,
            Value<double> paidAmount = const Value.absent(),
            Value<double?> totalUsd = const Value.absent(),
            Value<double?> paidAmountUsd = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> shiftId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> invoiceDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion.insert(
            id: id,
            invoiceNumber: invoiceNumber,
            type: type,
            customerId: customerId,
            supplierId: supplierId,
            warehouseId: warehouseId,
            subtotal: subtotal,
            taxAmount: taxAmount,
            discountAmount: discountAmount,
            total: total,
            paidAmount: paidAmount,
            totalUsd: totalUsd,
            paidAmountUsd: paidAmountUsd,
            exchangeRate: exchangeRate,
            paymentMethod: paymentMethod,
            status: status,
            notes: notes,
            shiftId: shiftId,
            syncStatus: syncStatus,
            invoiceDate: invoiceDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$InvoicesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {customerId = false,
              supplierId = false,
              shiftId = false,
              invoiceItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoiceItemsRefs) db.invoiceItems],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (customerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.customerId,
                    referencedTable:
                        $$InvoicesTableReferences._customerIdTable(db),
                    referencedColumn:
                        $$InvoicesTableReferences._customerIdTable(db).id,
                  ) as T;
                }
                if (supplierId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.supplierId,
                    referencedTable:
                        $$InvoicesTableReferences._supplierIdTable(db),
                    referencedColumn:
                        $$InvoicesTableReferences._supplierIdTable(db).id,
                  ) as T;
                }
                if (shiftId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.shiftId,
                    referencedTable:
                        $$InvoicesTableReferences._shiftIdTable(db),
                    referencedColumn:
                        $$InvoicesTableReferences._shiftIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoiceItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$InvoicesTableReferences
                            ._invoiceItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InvoicesTableReferences(db, table, p0)
                                .invoiceItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.invoiceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$InvoicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, $$InvoicesTableReferences),
    Invoice,
    PrefetchHooks Function(
        {bool customerId,
        bool supplierId,
        bool shiftId,
        bool invoiceItemsRefs})>;
typedef $$InvoiceItemsTableCreateCompanionBuilder = InvoiceItemsCompanion
    Function({
  required String id,
  required String invoiceId,
  required String productId,
  required String productName,
  required int quantity,
  required double unitPrice,
  required double purchasePrice,
  Value<double?> costPrice,
  Value<double?> costPriceUsd,
  Value<double> discountAmount,
  Value<double> taxAmount,
  required double total,
  Value<double?> unitPriceUsd,
  Value<double?> totalUsd,
  Value<double?> exchangeRate,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$InvoiceItemsTableUpdateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<String> id,
  Value<String> invoiceId,
  Value<String> productId,
  Value<String> productName,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> purchasePrice,
  Value<double?> costPrice,
  Value<double?> costPriceUsd,
  Value<double> discountAmount,
  Value<double> taxAmount,
  Value<double> total,
  Value<double?> unitPriceUsd,
  Value<double?> totalUsd,
  Value<double?> exchangeRate,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$InvoiceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem> {
  $$InvoiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias(
          $_aliasNameGenerator(db.invoiceItems.invoiceId, db.invoices.id));

  $$InvoicesTableProcessedTableManager? get invoiceId {
    if ($_item.invoiceId == null) return null;
    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.id($_item.invoiceId!));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.invoiceItems.productId, db.products.id));

  $$ProductsTableProcessedTableManager? get productId {
    if ($_item.productId == null) return null;
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id($_item.productId!));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPriceUsd => $composableBuilder(
      column: $table.costPriceUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPriceUsd => $composableBuilder(
      column: $table.unitPriceUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalUsd => $composableBuilder(
      column: $table.totalUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPriceUsd => $composableBuilder(
      column: $table.costPriceUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPriceUsd => $composableBuilder(
      column: $table.unitPriceUsd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalUsd => $composableBuilder(
      column: $table.totalUsd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableOrderingComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get costPriceUsd => $composableBuilder(
      column: $table.costPriceUsd, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get unitPriceUsd => $composableBuilder(
      column: $table.unitPriceUsd, builder: (column) => column);

  GeneratedColumn<double> get totalUsd =>
      $composableBuilder(column: $table.totalUsd, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (InvoiceItem, $$InvoiceItemsTableReferences),
    InvoiceItem,
    PrefetchHooks Function({bool invoiceId, bool productId})> {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> purchasePrice = const Value.absent(),
            Value<double?> costPrice = const Value.absent(),
            Value<double?> costPriceUsd = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<double> taxAmount = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<double?> unitPriceUsd = const Value.absent(),
            Value<double?> totalUsd = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceItemsCompanion(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            productName: productName,
            quantity: quantity,
            unitPrice: unitPrice,
            purchasePrice: purchasePrice,
            costPrice: costPrice,
            costPriceUsd: costPriceUsd,
            discountAmount: discountAmount,
            taxAmount: taxAmount,
            total: total,
            unitPriceUsd: unitPriceUsd,
            totalUsd: totalUsd,
            exchangeRate: exchangeRate,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceId,
            required String productId,
            required String productName,
            required int quantity,
            required double unitPrice,
            required double purchasePrice,
            Value<double?> costPrice = const Value.absent(),
            Value<double?> costPriceUsd = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<double> taxAmount = const Value.absent(),
            required double total,
            Value<double?> unitPriceUsd = const Value.absent(),
            Value<double?> totalUsd = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceItemsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            productName: productName,
            quantity: quantity,
            unitPrice: unitPrice,
            purchasePrice: purchasePrice,
            costPrice: costPrice,
            costPriceUsd: costPriceUsd,
            discountAmount: discountAmount,
            taxAmount: taxAmount,
            total: total,
            unitPriceUsd: unitPriceUsd,
            totalUsd: totalUsd,
            exchangeRate: exchangeRate,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InvoiceItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({invoiceId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (invoiceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.invoiceId,
                    referencedTable:
                        $$InvoiceItemsTableReferences._invoiceIdTable(db),
                    referencedColumn:
                        $$InvoiceItemsTableReferences._invoiceIdTable(db).id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$InvoiceItemsTableReferences._productIdTable(db),
                    referencedColumn:
                        $$InvoiceItemsTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InvoiceItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (InvoiceItem, $$InvoiceItemsTableReferences),
    InvoiceItem,
    PrefetchHooks Function({bool invoiceId, bool productId})>;
typedef $$InventoryMovementsTableCreateCompanionBuilder
    = InventoryMovementsCompanion Function({
  required String id,
  required String productId,
  Value<String?> warehouseId,
  required String type,
  required int quantity,
  required int previousQuantity,
  required int newQuantity,
  Value<String?> reason,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$InventoryMovementsTableUpdateCompanionBuilder
    = InventoryMovementsCompanion Function({
  Value<String> id,
  Value<String> productId,
  Value<String?> warehouseId,
  Value<String> type,
  Value<int> quantity,
  Value<int> previousQuantity,
  Value<int> newQuantity,
  Value<String?> reason,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$InventoryMovementsTableReferences extends BaseReferences<
    _$AppDatabase, $InventoryMovementsTable, InventoryMovement> {
  $$InventoryMovementsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.inventoryMovements.productId, db.products.id));

  $$ProductsTableProcessedTableManager? get productId {
    if ($_item.productId == null) return null;
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id($_item.productId!));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InventoryMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get previousQuantity => $composableBuilder(
      column: $table.previousQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get newQuantity => $composableBuilder(
      column: $table.newQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get previousQuantity => $composableBuilder(
      column: $table.previousQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get newQuantity => $composableBuilder(
      column: $table.newQuantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceType => $composableBuilder(
      column: $table.referenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get previousQuantity => $composableBuilder(
      column: $table.previousQuantity, builder: (column) => column);

  GeneratedColumn<int> get newQuantity => $composableBuilder(
      column: $table.newQuantity, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryMovementsTable,
    InventoryMovement,
    $$InventoryMovementsTableFilterComposer,
    $$InventoryMovementsTableOrderingComposer,
    $$InventoryMovementsTableAnnotationComposer,
    $$InventoryMovementsTableCreateCompanionBuilder,
    $$InventoryMovementsTableUpdateCompanionBuilder,
    (InventoryMovement, $$InventoryMovementsTableReferences),
    InventoryMovement,
    PrefetchHooks Function({bool productId})> {
  $$InventoryMovementsTableTableManager(
      _$AppDatabase db, $InventoryMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryMovementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> previousQuantity = const Value.absent(),
            Value<int> newQuantity = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryMovementsCompanion(
            id: id,
            productId: productId,
            warehouseId: warehouseId,
            type: type,
            quantity: quantity,
            previousQuantity: previousQuantity,
            newQuantity: newQuantity,
            reason: reason,
            referenceId: referenceId,
            referenceType: referenceType,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String productId,
            Value<String?> warehouseId = const Value.absent(),
            required String type,
            required int quantity,
            required int previousQuantity,
            required int newQuantity,
            Value<String?> reason = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryMovementsCompanion.insert(
            id: id,
            productId: productId,
            warehouseId: warehouseId,
            type: type,
            quantity: quantity,
            previousQuantity: previousQuantity,
            newQuantity: newQuantity,
            reason: reason,
            referenceId: referenceId,
            referenceType: referenceType,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryMovementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$InventoryMovementsTableReferences._productIdTable(db),
                    referencedColumn: $$InventoryMovementsTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InventoryMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryMovementsTable,
    InventoryMovement,
    $$InventoryMovementsTableFilterComposer,
    $$InventoryMovementsTableOrderingComposer,
    $$InventoryMovementsTableAnnotationComposer,
    $$InventoryMovementsTableCreateCompanionBuilder,
    $$InventoryMovementsTableUpdateCompanionBuilder,
    (InventoryMovement, $$InventoryMovementsTableReferences),
    InventoryMovement,
    PrefetchHooks Function({bool productId})>;
typedef $$CashMovementsTableCreateCompanionBuilder = CashMovementsCompanion
    Function({
  required String id,
  required String shiftId,
  required String type,
  required double amount,
  Value<double?> amountUsd,
  Value<double?> exchangeRate,
  required String description,
  Value<String?> category,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String> paymentMethod,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CashMovementsTableUpdateCompanionBuilder = CashMovementsCompanion
    Function({
  Value<String> id,
  Value<String> shiftId,
  Value<String> type,
  Value<double> amount,
  Value<double?> amountUsd,
  Value<double?> exchangeRate,
  Value<String> description,
  Value<String?> category,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String> paymentMethod,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$CashMovementsTableReferences
    extends BaseReferences<_$AppDatabase, $CashMovementsTable, CashMovement> {
  $$CashMovementsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ShiftsTable _shiftIdTable(_$AppDatabase db) => db.shifts.createAlias(
      $_aliasNameGenerator(db.cashMovements.shiftId, db.shifts.id));

  $$ShiftsTableProcessedTableManager? get shiftId {
    if ($_item.shiftId == null) return null;
    final manager = $$ShiftsTableTableManager($_db, $_db.shifts)
        .filter((f) => f.id($_item.shiftId!));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CashMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amountUsd => $composableBuilder(
      column: $table.amountUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ShiftsTableFilterComposer get shiftId {
    final $$ShiftsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableFilterComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CashMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amountUsd => $composableBuilder(
      column: $table.amountUsd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceType => $composableBuilder(
      column: $table.referenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ShiftsTableOrderingComposer get shiftId {
    final $$ShiftsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableOrderingComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CashMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get amountUsd =>
      $composableBuilder(column: $table.amountUsd, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShiftsTableAnnotationComposer get shiftId {
    final $$ShiftsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableAnnotationComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CashMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CashMovementsTable,
    CashMovement,
    $$CashMovementsTableFilterComposer,
    $$CashMovementsTableOrderingComposer,
    $$CashMovementsTableAnnotationComposer,
    $$CashMovementsTableCreateCompanionBuilder,
    $$CashMovementsTableUpdateCompanionBuilder,
    (CashMovement, $$CashMovementsTableReferences),
    CashMovement,
    PrefetchHooks Function({bool shiftId})> {
  $$CashMovementsTableTableManager(_$AppDatabase db, $CashMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> shiftId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<double?> amountUsd = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CashMovementsCompanion(
            id: id,
            shiftId: shiftId,
            type: type,
            amount: amount,
            amountUsd: amountUsd,
            exchangeRate: exchangeRate,
            description: description,
            category: category,
            referenceId: referenceId,
            referenceType: referenceType,
            paymentMethod: paymentMethod,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String shiftId,
            required String type,
            required double amount,
            Value<double?> amountUsd = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            required String description,
            Value<String?> category = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CashMovementsCompanion.insert(
            id: id,
            shiftId: shiftId,
            type: type,
            amount: amount,
            amountUsd: amountUsd,
            exchangeRate: exchangeRate,
            description: description,
            category: category,
            referenceId: referenceId,
            referenceType: referenceType,
            paymentMethod: paymentMethod,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CashMovementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({shiftId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (shiftId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.shiftId,
                    referencedTable:
                        $$CashMovementsTableReferences._shiftIdTable(db),
                    referencedColumn:
                        $$CashMovementsTableReferences._shiftIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CashMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CashMovementsTable,
    CashMovement,
    $$CashMovementsTableFilterComposer,
    $$CashMovementsTableOrderingComposer,
    $$CashMovementsTableAnnotationComposer,
    $$CashMovementsTableCreateCompanionBuilder,
    $$CashMovementsTableUpdateCompanionBuilder,
    (CashMovement, $$CashMovementsTableReferences),
    CashMovement,
    PrefetchHooks Function({bool shiftId})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$VoucherCategoriesTableCreateCompanionBuilder
    = VoucherCategoriesCompanion Function({
  required String id,
  required String name,
  required String type,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$VoucherCategoriesTableUpdateCompanionBuilder
    = VoucherCategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$VoucherCategoriesTableReferences extends BaseReferences<
    _$AppDatabase, $VoucherCategoriesTable, VoucherCategory> {
  $$VoucherCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VouchersTable, List<Voucher>> _vouchersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.vouchers,
          aliasName: $_aliasNameGenerator(
              db.voucherCategories.id, db.vouchers.categoryId));

  $$VouchersTableProcessedTableManager get vouchersRefs {
    final manager = $$VouchersTableTableManager($_db, $_db.vouchers)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_vouchersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VoucherCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $VoucherCategoriesTable> {
  $$VoucherCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> vouchersRefs(
      Expression<bool> Function($$VouchersTableFilterComposer f) f) {
    final $$VouchersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vouchers,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VouchersTableFilterComposer(
              $db: $db,
              $table: $db.vouchers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VoucherCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $VoucherCategoriesTable> {
  $$VoucherCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$VoucherCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoucherCategoriesTable> {
  $$VoucherCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> vouchersRefs<T extends Object>(
      Expression<T> Function($$VouchersTableAnnotationComposer a) f) {
    final $$VouchersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vouchers,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VouchersTableAnnotationComposer(
              $db: $db,
              $table: $db.vouchers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VoucherCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VoucherCategoriesTable,
    VoucherCategory,
    $$VoucherCategoriesTableFilterComposer,
    $$VoucherCategoriesTableOrderingComposer,
    $$VoucherCategoriesTableAnnotationComposer,
    $$VoucherCategoriesTableCreateCompanionBuilder,
    $$VoucherCategoriesTableUpdateCompanionBuilder,
    (VoucherCategory, $$VoucherCategoriesTableReferences),
    VoucherCategory,
    PrefetchHooks Function({bool vouchersRefs})> {
  $$VoucherCategoriesTableTableManager(
      _$AppDatabase db, $VoucherCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoucherCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoucherCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoucherCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VoucherCategoriesCompanion(
            id: id,
            name: name,
            type: type,
            isActive: isActive,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VoucherCategoriesCompanion.insert(
            id: id,
            name: name,
            type: type,
            isActive: isActive,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VoucherCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({vouchersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (vouchersRefs) db.vouchers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vouchersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$VoucherCategoriesTableReferences
                            ._vouchersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VoucherCategoriesTableReferences(db, table, p0)
                                .vouchersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VoucherCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VoucherCategoriesTable,
    VoucherCategory,
    $$VoucherCategoriesTableFilterComposer,
    $$VoucherCategoriesTableOrderingComposer,
    $$VoucherCategoriesTableAnnotationComposer,
    $$VoucherCategoriesTableCreateCompanionBuilder,
    $$VoucherCategoriesTableUpdateCompanionBuilder,
    (VoucherCategory, $$VoucherCategoriesTableReferences),
    VoucherCategory,
    PrefetchHooks Function({bool vouchersRefs})>;
typedef $$VouchersTableCreateCompanionBuilder = VouchersCompanion Function({
  required String id,
  required String voucherNumber,
  required String type,
  Value<String?> categoryId,
  required double amount,
  Value<double?> amountUsd,
  Value<double> exchangeRate,
  Value<String?> description,
  Value<String?> customerId,
  Value<String?> supplierId,
  Value<String?> shiftId,
  Value<String> syncStatus,
  Value<DateTime> voucherDate,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$VouchersTableUpdateCompanionBuilder = VouchersCompanion Function({
  Value<String> id,
  Value<String> voucherNumber,
  Value<String> type,
  Value<String?> categoryId,
  Value<double> amount,
  Value<double?> amountUsd,
  Value<double> exchangeRate,
  Value<String?> description,
  Value<String?> customerId,
  Value<String?> supplierId,
  Value<String?> shiftId,
  Value<String> syncStatus,
  Value<DateTime> voucherDate,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$VouchersTableReferences
    extends BaseReferences<_$AppDatabase, $VouchersTable, Voucher> {
  $$VouchersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VoucherCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.voucherCategories.createAlias($_aliasNameGenerator(
          db.vouchers.categoryId, db.voucherCategories.id));

  $$VoucherCategoriesTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager =
        $$VoucherCategoriesTableTableManager($_db, $_db.voucherCategories)
            .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
          $_aliasNameGenerator(db.vouchers.customerId, db.customers.id));

  $$CustomersTableProcessedTableManager? get customerId {
    if ($_item.customerId == null) return null;
    final manager = $$CustomersTableTableManager($_db, $_db.customers)
        .filter((f) => f.id($_item.customerId!));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias(
          $_aliasNameGenerator(db.vouchers.supplierId, db.suppliers.id));

  $$SuppliersTableProcessedTableManager? get supplierId {
    if ($_item.supplierId == null) return null;
    final manager = $$SuppliersTableTableManager($_db, $_db.suppliers)
        .filter((f) => f.id($_item.supplierId!));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ShiftsTable _shiftIdTable(_$AppDatabase db) => db.shifts
      .createAlias($_aliasNameGenerator(db.vouchers.shiftId, db.shifts.id));

  $$ShiftsTableProcessedTableManager? get shiftId {
    if ($_item.shiftId == null) return null;
    final manager = $$ShiftsTableTableManager($_db, $_db.shifts)
        .filter((f) => f.id($_item.shiftId!));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VouchersTableFilterComposer
    extends Composer<_$AppDatabase, $VouchersTable> {
  $$VouchersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voucherNumber => $composableBuilder(
      column: $table.voucherNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amountUsd => $composableBuilder(
      column: $table.amountUsd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get voucherDate => $composableBuilder(
      column: $table.voucherDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$VoucherCategoriesTableFilterComposer get categoryId {
    final $$VoucherCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.voucherCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VoucherCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.voucherCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableFilterComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplierId,
        referencedTable: $db.suppliers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SuppliersTableFilterComposer(
              $db: $db,
              $table: $db.suppliers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ShiftsTableFilterComposer get shiftId {
    final $$ShiftsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableFilterComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VouchersTableOrderingComposer
    extends Composer<_$AppDatabase, $VouchersTable> {
  $$VouchersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voucherNumber => $composableBuilder(
      column: $table.voucherNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amountUsd => $composableBuilder(
      column: $table.amountUsd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get voucherDate => $composableBuilder(
      column: $table.voucherDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$VoucherCategoriesTableOrderingComposer get categoryId {
    final $$VoucherCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.voucherCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VoucherCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.voucherCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableOrderingComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplierId,
        referencedTable: $db.suppliers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SuppliersTableOrderingComposer(
              $db: $db,
              $table: $db.suppliers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ShiftsTableOrderingComposer get shiftId {
    final $$ShiftsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableOrderingComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VouchersTableAnnotationComposer
    extends Composer<_$AppDatabase, $VouchersTable> {
  $$VouchersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get voucherNumber => $composableBuilder(
      column: $table.voucherNumber, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get amountUsd =>
      $composableBuilder(column: $table.amountUsd, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get voucherDate => $composableBuilder(
      column: $table.voucherDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VoucherCategoriesTableAnnotationComposer get categoryId {
    final $$VoucherCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.voucherCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$VoucherCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.voucherCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableAnnotationComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplierId,
        referencedTable: $db.suppliers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SuppliersTableAnnotationComposer(
              $db: $db,
              $table: $db.suppliers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ShiftsTableAnnotationComposer get shiftId {
    final $$ShiftsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableAnnotationComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VouchersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VouchersTable,
    Voucher,
    $$VouchersTableFilterComposer,
    $$VouchersTableOrderingComposer,
    $$VouchersTableAnnotationComposer,
    $$VouchersTableCreateCompanionBuilder,
    $$VouchersTableUpdateCompanionBuilder,
    (Voucher, $$VouchersTableReferences),
    Voucher,
    PrefetchHooks Function(
        {bool categoryId, bool customerId, bool supplierId, bool shiftId})> {
  $$VouchersTableTableManager(_$AppDatabase db, $VouchersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VouchersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VouchersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VouchersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> voucherNumber = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<double?> amountUsd = const Value.absent(),
            Value<double> exchangeRate = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            Value<String?> shiftId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> voucherDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VouchersCompanion(
            id: id,
            voucherNumber: voucherNumber,
            type: type,
            categoryId: categoryId,
            amount: amount,
            amountUsd: amountUsd,
            exchangeRate: exchangeRate,
            description: description,
            customerId: customerId,
            supplierId: supplierId,
            shiftId: shiftId,
            syncStatus: syncStatus,
            voucherDate: voucherDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String voucherNumber,
            required String type,
            Value<String?> categoryId = const Value.absent(),
            required double amount,
            Value<double?> amountUsd = const Value.absent(),
            Value<double> exchangeRate = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            Value<String?> shiftId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> voucherDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VouchersCompanion.insert(
            id: id,
            voucherNumber: voucherNumber,
            type: type,
            categoryId: categoryId,
            amount: amount,
            amountUsd: amountUsd,
            exchangeRate: exchangeRate,
            description: description,
            customerId: customerId,
            supplierId: supplierId,
            shiftId: shiftId,
            syncStatus: syncStatus,
            voucherDate: voucherDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VouchersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              customerId = false,
              supplierId = false,
              shiftId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$VouchersTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$VouchersTableReferences._categoryIdTable(db).id,
                  ) as T;
                }
                if (customerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.customerId,
                    referencedTable:
                        $$VouchersTableReferences._customerIdTable(db),
                    referencedColumn:
                        $$VouchersTableReferences._customerIdTable(db).id,
                  ) as T;
                }
                if (supplierId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.supplierId,
                    referencedTable:
                        $$VouchersTableReferences._supplierIdTable(db),
                    referencedColumn:
                        $$VouchersTableReferences._supplierIdTable(db).id,
                  ) as T;
                }
                if (shiftId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.shiftId,
                    referencedTable:
                        $$VouchersTableReferences._shiftIdTable(db),
                    referencedColumn:
                        $$VouchersTableReferences._shiftIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VouchersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VouchersTable,
    Voucher,
    $$VouchersTableFilterComposer,
    $$VouchersTableOrderingComposer,
    $$VouchersTableAnnotationComposer,
    $$VouchersTableCreateCompanionBuilder,
    $$VouchersTableUpdateCompanionBuilder,
    (Voucher, $$VouchersTableReferences),
    Voucher,
    PrefetchHooks Function(
        {bool categoryId, bool customerId, bool supplierId, bool shiftId})>;
typedef $$WarehousesTableCreateCompanionBuilder = WarehousesCompanion Function({
  required String id,
  required String name,
  Value<String?> code,
  Value<String?> address,
  Value<String?> phone,
  Value<String?> managerId,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$WarehousesTableUpdateCompanionBuilder = WarehousesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> code,
  Value<String?> address,
  Value<String?> phone,
  Value<String?> managerId,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$WarehousesTableReferences
    extends BaseReferences<_$AppDatabase, $WarehousesTable, Warehouse> {
  $$WarehousesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WarehouseStockTable, List<WarehouseStockData>>
      _warehouseStockRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.warehouseStock,
              aliasName: $_aliasNameGenerator(
                  db.warehouses.id, db.warehouseStock.warehouseId));

  $$WarehouseStockTableProcessedTableManager get warehouseStockRefs {
    final manager = $$WarehouseStockTableTableManager($_db, $_db.warehouseStock)
        .filter((f) => f.warehouseId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_warehouseStockRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryCountsTable, List<InventoryCount>>
      _inventoryCountsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryCounts,
              aliasName: $_aliasNameGenerator(
                  db.warehouses.id, db.inventoryCounts.warehouseId));

  $$InventoryCountsTableProcessedTableManager get inventoryCountsRefs {
    final manager =
        $$InventoryCountsTableTableManager($_db, $_db.inventoryCounts)
            .filter((f) => f.warehouseId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_inventoryCountsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryAdjustmentsTable,
      List<InventoryAdjustment>> _inventoryAdjustmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.inventoryAdjustments,
          aliasName: $_aliasNameGenerator(
              db.warehouses.id, db.inventoryAdjustments.warehouseId));

  $$InventoryAdjustmentsTableProcessedTableManager
      get inventoryAdjustmentsRefs {
    final manager =
        $$InventoryAdjustmentsTableTableManager($_db, $_db.inventoryAdjustments)
            .filter((f) => f.warehouseId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_inventoryAdjustmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WarehousesTableFilterComposer
    extends Composer<_$AppDatabase, $WarehousesTable> {
  $$WarehousesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get managerId => $composableBuilder(
      column: $table.managerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> warehouseStockRefs(
      Expression<bool> Function($$WarehouseStockTableFilterComposer f) f) {
    final $$WarehouseStockTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.warehouseStock,
        getReferencedColumn: (t) => t.warehouseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehouseStockTableFilterComposer(
              $db: $db,
              $table: $db.warehouseStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryCountsRefs(
      Expression<bool> Function($$InventoryCountsTableFilterComposer f) f) {
    final $$InventoryCountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryCounts,
        getReferencedColumn: (t) => t.warehouseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryAdjustmentsRefs(
      Expression<bool> Function($$InventoryAdjustmentsTableFilterComposer f)
          f) {
    final $$InventoryAdjustmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryAdjustments,
        getReferencedColumn: (t) => t.warehouseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryAdjustmentsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryAdjustments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WarehousesTableOrderingComposer
    extends Composer<_$AppDatabase, $WarehousesTable> {
  $$WarehousesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get managerId => $composableBuilder(
      column: $table.managerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$WarehousesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarehousesTable> {
  $$WarehousesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get managerId =>
      $composableBuilder(column: $table.managerId, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> warehouseStockRefs<T extends Object>(
      Expression<T> Function($$WarehouseStockTableAnnotationComposer a) f) {
    final $$WarehouseStockTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.warehouseStock,
        getReferencedColumn: (t) => t.warehouseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehouseStockTableAnnotationComposer(
              $db: $db,
              $table: $db.warehouseStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> inventoryCountsRefs<T extends Object>(
      Expression<T> Function($$InventoryCountsTableAnnotationComposer a) f) {
    final $$InventoryCountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryCounts,
        getReferencedColumn: (t) => t.warehouseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountsTableAnnotationComposer(
              $db: $db,
              $table: $db.inventoryCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> inventoryAdjustmentsRefs<T extends Object>(
      Expression<T> Function($$InventoryAdjustmentsTableAnnotationComposer a)
          f) {
    final $$InventoryAdjustmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryAdjustments,
            getReferencedColumn: (t) => t.warehouseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryAdjustmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryAdjustments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$WarehousesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WarehousesTable,
    Warehouse,
    $$WarehousesTableFilterComposer,
    $$WarehousesTableOrderingComposer,
    $$WarehousesTableAnnotationComposer,
    $$WarehousesTableCreateCompanionBuilder,
    $$WarehousesTableUpdateCompanionBuilder,
    (Warehouse, $$WarehousesTableReferences),
    Warehouse,
    PrefetchHooks Function(
        {bool warehouseStockRefs,
        bool inventoryCountsRefs,
        bool inventoryAdjustmentsRefs})> {
  $$WarehousesTableTableManager(_$AppDatabase db, $WarehousesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarehousesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarehousesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarehousesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> code = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> managerId = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehousesCompanion(
            id: id,
            name: name,
            code: code,
            address: address,
            phone: phone,
            managerId: managerId,
            isDefault: isDefault,
            isActive: isActive,
            notes: notes,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> code = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> managerId = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehousesCompanion.insert(
            id: id,
            name: name,
            code: code,
            address: address,
            phone: phone,
            managerId: managerId,
            isDefault: isDefault,
            isActive: isActive,
            notes: notes,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WarehousesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {warehouseStockRefs = false,
              inventoryCountsRefs = false,
              inventoryAdjustmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (warehouseStockRefs) db.warehouseStock,
                if (inventoryCountsRefs) db.inventoryCounts,
                if (inventoryAdjustmentsRefs) db.inventoryAdjustments
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (warehouseStockRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$WarehousesTableReferences
                            ._warehouseStockRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WarehousesTableReferences(db, table, p0)
                                .warehouseStockRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.warehouseId == item.id),
                        typedResults: items),
                  if (inventoryCountsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$WarehousesTableReferences
                            ._inventoryCountsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WarehousesTableReferences(db, table, p0)
                                .inventoryCountsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.warehouseId == item.id),
                        typedResults: items),
                  if (inventoryAdjustmentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$WarehousesTableReferences
                            ._inventoryAdjustmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WarehousesTableReferences(db, table, p0)
                                .inventoryAdjustmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.warehouseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WarehousesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WarehousesTable,
    Warehouse,
    $$WarehousesTableFilterComposer,
    $$WarehousesTableOrderingComposer,
    $$WarehousesTableAnnotationComposer,
    $$WarehousesTableCreateCompanionBuilder,
    $$WarehousesTableUpdateCompanionBuilder,
    (Warehouse, $$WarehousesTableReferences),
    Warehouse,
    PrefetchHooks Function(
        {bool warehouseStockRefs,
        bool inventoryCountsRefs,
        bool inventoryAdjustmentsRefs})>;
typedef $$WarehouseStockTableCreateCompanionBuilder = WarehouseStockCompanion
    Function({
  required String id,
  required String warehouseId,
  required String productId,
  Value<int> quantity,
  Value<int> minQuantity,
  Value<int?> maxQuantity,
  Value<String?> location,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$WarehouseStockTableUpdateCompanionBuilder = WarehouseStockCompanion
    Function({
  Value<String> id,
  Value<String> warehouseId,
  Value<String> productId,
  Value<int> quantity,
  Value<int> minQuantity,
  Value<int?> maxQuantity,
  Value<String?> location,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$WarehouseStockTableReferences extends BaseReferences<
    _$AppDatabase, $WarehouseStockTable, WarehouseStockData> {
  $$WarehouseStockTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WarehousesTable _warehouseIdTable(_$AppDatabase db) =>
      db.warehouses.createAlias($_aliasNameGenerator(
          db.warehouseStock.warehouseId, db.warehouses.id));

  $$WarehousesTableProcessedTableManager? get warehouseId {
    if ($_item.warehouseId == null) return null;
    final manager = $$WarehousesTableTableManager($_db, $_db.warehouses)
        .filter((f) => f.id($_item.warehouseId!));
    final item = $_typedResult.readTableOrNull(_warehouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.warehouseStock.productId, db.products.id));

  $$ProductsTableProcessedTableManager? get productId {
    if ($_item.productId == null) return null;
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id($_item.productId!));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WarehouseStockTableFilterComposer
    extends Composer<_$AppDatabase, $WarehouseStockTable> {
  $$WarehouseStockTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minQuantity => $composableBuilder(
      column: $table.minQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxQuantity => $composableBuilder(
      column: $table.maxQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$WarehousesTableFilterComposer get warehouseId {
    final $$WarehousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableFilterComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WarehouseStockTableOrderingComposer
    extends Composer<_$AppDatabase, $WarehouseStockTable> {
  $$WarehouseStockTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minQuantity => $composableBuilder(
      column: $table.minQuantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxQuantity => $composableBuilder(
      column: $table.maxQuantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$WarehousesTableOrderingComposer get warehouseId {
    final $$WarehousesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableOrderingComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WarehouseStockTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarehouseStockTable> {
  $$WarehouseStockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get minQuantity => $composableBuilder(
      column: $table.minQuantity, builder: (column) => column);

  GeneratedColumn<int> get maxQuantity => $composableBuilder(
      column: $table.maxQuantity, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WarehousesTableAnnotationComposer get warehouseId {
    final $$WarehousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableAnnotationComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WarehouseStockTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WarehouseStockTable,
    WarehouseStockData,
    $$WarehouseStockTableFilterComposer,
    $$WarehouseStockTableOrderingComposer,
    $$WarehouseStockTableAnnotationComposer,
    $$WarehouseStockTableCreateCompanionBuilder,
    $$WarehouseStockTableUpdateCompanionBuilder,
    (WarehouseStockData, $$WarehouseStockTableReferences),
    WarehouseStockData,
    PrefetchHooks Function({bool warehouseId, bool productId})> {
  $$WarehouseStockTableTableManager(
      _$AppDatabase db, $WarehouseStockTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarehouseStockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarehouseStockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarehouseStockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> warehouseId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> minQuantity = const Value.absent(),
            Value<int?> maxQuantity = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehouseStockCompanion(
            id: id,
            warehouseId: warehouseId,
            productId: productId,
            quantity: quantity,
            minQuantity: minQuantity,
            maxQuantity: maxQuantity,
            location: location,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String warehouseId,
            required String productId,
            Value<int> quantity = const Value.absent(),
            Value<int> minQuantity = const Value.absent(),
            Value<int?> maxQuantity = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehouseStockCompanion.insert(
            id: id,
            warehouseId: warehouseId,
            productId: productId,
            quantity: quantity,
            minQuantity: minQuantity,
            maxQuantity: maxQuantity,
            location: location,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WarehouseStockTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({warehouseId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (warehouseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.warehouseId,
                    referencedTable:
                        $$WarehouseStockTableReferences._warehouseIdTable(db),
                    referencedColumn: $$WarehouseStockTableReferences
                        ._warehouseIdTable(db)
                        .id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$WarehouseStockTableReferences._productIdTable(db),
                    referencedColumn:
                        $$WarehouseStockTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WarehouseStockTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WarehouseStockTable,
    WarehouseStockData,
    $$WarehouseStockTableFilterComposer,
    $$WarehouseStockTableOrderingComposer,
    $$WarehouseStockTableAnnotationComposer,
    $$WarehouseStockTableCreateCompanionBuilder,
    $$WarehouseStockTableUpdateCompanionBuilder,
    (WarehouseStockData, $$WarehouseStockTableReferences),
    WarehouseStockData,
    PrefetchHooks Function({bool warehouseId, bool productId})>;
typedef $$StockTransfersTableCreateCompanionBuilder = StockTransfersCompanion
    Function({
  required String id,
  required String transferNumber,
  required String fromWarehouseId,
  required String toWarehouseId,
  Value<String> status,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> transferDate,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$StockTransfersTableUpdateCompanionBuilder = StockTransfersCompanion
    Function({
  Value<String> id,
  Value<String> transferNumber,
  Value<String> fromWarehouseId,
  Value<String> toWarehouseId,
  Value<String> status,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> transferDate,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$StockTransfersTableReferences
    extends BaseReferences<_$AppDatabase, $StockTransfersTable, StockTransfer> {
  $$StockTransfersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WarehousesTable _fromWarehouseIdTable(_$AppDatabase db) =>
      db.warehouses.createAlias($_aliasNameGenerator(
          db.stockTransfers.fromWarehouseId, db.warehouses.id));

  $$WarehousesTableProcessedTableManager? get fromWarehouseId {
    if ($_item.fromWarehouseId == null) return null;
    final manager = $$WarehousesTableTableManager($_db, $_db.warehouses)
        .filter((f) => f.id($_item.fromWarehouseId!));
    final item = $_typedResult.readTableOrNull(_fromWarehouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WarehousesTable _toWarehouseIdTable(_$AppDatabase db) =>
      db.warehouses.createAlias($_aliasNameGenerator(
          db.stockTransfers.toWarehouseId, db.warehouses.id));

  $$WarehousesTableProcessedTableManager? get toWarehouseId {
    if ($_item.toWarehouseId == null) return null;
    final manager = $$WarehousesTableTableManager($_db, $_db.warehouses)
        .filter((f) => f.id($_item.toWarehouseId!));
    final item = $_typedResult.readTableOrNull(_toWarehouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$StockTransferItemsTable, List<StockTransferItem>>
      _stockTransferItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.stockTransferItems,
              aliasName: $_aliasNameGenerator(
                  db.stockTransfers.id, db.stockTransferItems.transferId));

  $$StockTransferItemsTableProcessedTableManager get stockTransferItemsRefs {
    final manager =
        $$StockTransferItemsTableTableManager($_db, $_db.stockTransferItems)
            .filter((f) => f.transferId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_stockTransferItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StockTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $StockTransfersTable> {
  $$StockTransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transferNumber => $composableBuilder(
      column: $table.transferNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transferDate => $composableBuilder(
      column: $table.transferDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$WarehousesTableFilterComposer get fromWarehouseId {
    final $$WarehousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromWarehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableFilterComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WarehousesTableFilterComposer get toWarehouseId {
    final $$WarehousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toWarehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableFilterComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> stockTransferItemsRefs(
      Expression<bool> Function($$StockTransferItemsTableFilterComposer f) f) {
    final $$StockTransferItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.stockTransferItems,
        getReferencedColumn: (t) => t.transferId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StockTransferItemsTableFilterComposer(
              $db: $db,
              $table: $db.stockTransferItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StockTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $StockTransfersTable> {
  $$StockTransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transferNumber => $composableBuilder(
      column: $table.transferNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transferDate => $composableBuilder(
      column: $table.transferDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$WarehousesTableOrderingComposer get fromWarehouseId {
    final $$WarehousesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromWarehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableOrderingComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WarehousesTableOrderingComposer get toWarehouseId {
    final $$WarehousesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toWarehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableOrderingComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockTransfersTable> {
  $$StockTransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transferNumber => $composableBuilder(
      column: $table.transferNumber, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get transferDate => $composableBuilder(
      column: $table.transferDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WarehousesTableAnnotationComposer get fromWarehouseId {
    final $$WarehousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromWarehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableAnnotationComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WarehousesTableAnnotationComposer get toWarehouseId {
    final $$WarehousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toWarehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableAnnotationComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> stockTransferItemsRefs<T extends Object>(
      Expression<T> Function($$StockTransferItemsTableAnnotationComposer a) f) {
    final $$StockTransferItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.stockTransferItems,
            getReferencedColumn: (t) => t.transferId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$StockTransferItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.stockTransferItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$StockTransfersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockTransfersTable,
    StockTransfer,
    $$StockTransfersTableFilterComposer,
    $$StockTransfersTableOrderingComposer,
    $$StockTransfersTableAnnotationComposer,
    $$StockTransfersTableCreateCompanionBuilder,
    $$StockTransfersTableUpdateCompanionBuilder,
    (StockTransfer, $$StockTransfersTableReferences),
    StockTransfer,
    PrefetchHooks Function(
        {bool fromWarehouseId,
        bool toWarehouseId,
        bool stockTransferItemsRefs})> {
  $$StockTransfersTableTableManager(
      _$AppDatabase db, $StockTransfersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockTransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transferNumber = const Value.absent(),
            Value<String> fromWarehouseId = const Value.absent(),
            Value<String> toWarehouseId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> transferDate = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockTransfersCompanion(
            id: id,
            transferNumber: transferNumber,
            fromWarehouseId: fromWarehouseId,
            toWarehouseId: toWarehouseId,
            status: status,
            notes: notes,
            syncStatus: syncStatus,
            transferDate: transferDate,
            completedAt: completedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transferNumber,
            required String fromWarehouseId,
            required String toWarehouseId,
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> transferDate = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockTransfersCompanion.insert(
            id: id,
            transferNumber: transferNumber,
            fromWarehouseId: fromWarehouseId,
            toWarehouseId: toWarehouseId,
            status: status,
            notes: notes,
            syncStatus: syncStatus,
            transferDate: transferDate,
            completedAt: completedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StockTransfersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {fromWarehouseId = false,
              toWarehouseId = false,
              stockTransferItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (stockTransferItemsRefs) db.stockTransferItems
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (fromWarehouseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fromWarehouseId,
                    referencedTable: $$StockTransfersTableReferences
                        ._fromWarehouseIdTable(db),
                    referencedColumn: $$StockTransfersTableReferences
                        ._fromWarehouseIdTable(db)
                        .id,
                  ) as T;
                }
                if (toWarehouseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toWarehouseId,
                    referencedTable:
                        $$StockTransfersTableReferences._toWarehouseIdTable(db),
                    referencedColumn: $$StockTransfersTableReferences
                        ._toWarehouseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stockTransferItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$StockTransfersTableReferences
                            ._stockTransferItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StockTransfersTableReferences(db, table, p0)
                                .stockTransferItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transferId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$StockTransfersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockTransfersTable,
    StockTransfer,
    $$StockTransfersTableFilterComposer,
    $$StockTransfersTableOrderingComposer,
    $$StockTransfersTableAnnotationComposer,
    $$StockTransfersTableCreateCompanionBuilder,
    $$StockTransfersTableUpdateCompanionBuilder,
    (StockTransfer, $$StockTransfersTableReferences),
    StockTransfer,
    PrefetchHooks Function(
        {bool fromWarehouseId,
        bool toWarehouseId,
        bool stockTransferItemsRefs})>;
typedef $$StockTransferItemsTableCreateCompanionBuilder
    = StockTransferItemsCompanion Function({
  required String id,
  required String transferId,
  required String productId,
  required String productName,
  required int requestedQuantity,
  Value<int> transferredQuantity,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$StockTransferItemsTableUpdateCompanionBuilder
    = StockTransferItemsCompanion Function({
  Value<String> id,
  Value<String> transferId,
  Value<String> productId,
  Value<String> productName,
  Value<int> requestedQuantity,
  Value<int> transferredQuantity,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$StockTransferItemsTableReferences extends BaseReferences<
    _$AppDatabase, $StockTransferItemsTable, StockTransferItem> {
  $$StockTransferItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $StockTransfersTable _transferIdTable(_$AppDatabase db) =>
      db.stockTransfers.createAlias($_aliasNameGenerator(
          db.stockTransferItems.transferId, db.stockTransfers.id));

  $$StockTransfersTableProcessedTableManager? get transferId {
    if ($_item.transferId == null) return null;
    final manager = $$StockTransfersTableTableManager($_db, $_db.stockTransfers)
        .filter((f) => f.id($_item.transferId!));
    final item = $_typedResult.readTableOrNull(_transferIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.stockTransferItems.productId, db.products.id));

  $$ProductsTableProcessedTableManager? get productId {
    if ($_item.productId == null) return null;
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id($_item.productId!));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StockTransferItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StockTransferItemsTable> {
  $$StockTransferItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get requestedQuantity => $composableBuilder(
      column: $table.requestedQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get transferredQuantity => $composableBuilder(
      column: $table.transferredQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$StockTransfersTableFilterComposer get transferId {
    final $$StockTransfersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transferId,
        referencedTable: $db.stockTransfers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StockTransfersTableFilterComposer(
              $db: $db,
              $table: $db.stockTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockTransferItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockTransferItemsTable> {
  $$StockTransferItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get requestedQuantity => $composableBuilder(
      column: $table.requestedQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transferredQuantity => $composableBuilder(
      column: $table.transferredQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$StockTransfersTableOrderingComposer get transferId {
    final $$StockTransfersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transferId,
        referencedTable: $db.stockTransfers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StockTransfersTableOrderingComposer(
              $db: $db,
              $table: $db.stockTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockTransferItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockTransferItemsTable> {
  $$StockTransferItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<int> get requestedQuantity => $composableBuilder(
      column: $table.requestedQuantity, builder: (column) => column);

  GeneratedColumn<int> get transferredQuantity => $composableBuilder(
      column: $table.transferredQuantity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StockTransfersTableAnnotationComposer get transferId {
    final $$StockTransfersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transferId,
        referencedTable: $db.stockTransfers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StockTransfersTableAnnotationComposer(
              $db: $db,
              $table: $db.stockTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockTransferItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockTransferItemsTable,
    StockTransferItem,
    $$StockTransferItemsTableFilterComposer,
    $$StockTransferItemsTableOrderingComposer,
    $$StockTransferItemsTableAnnotationComposer,
    $$StockTransferItemsTableCreateCompanionBuilder,
    $$StockTransferItemsTableUpdateCompanionBuilder,
    (StockTransferItem, $$StockTransferItemsTableReferences),
    StockTransferItem,
    PrefetchHooks Function({bool transferId, bool productId})> {
  $$StockTransferItemsTableTableManager(
      _$AppDatabase db, $StockTransferItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockTransferItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockTransferItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockTransferItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transferId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<int> requestedQuantity = const Value.absent(),
            Value<int> transferredQuantity = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockTransferItemsCompanion(
            id: id,
            transferId: transferId,
            productId: productId,
            productName: productName,
            requestedQuantity: requestedQuantity,
            transferredQuantity: transferredQuantity,
            notes: notes,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transferId,
            required String productId,
            required String productName,
            required int requestedQuantity,
            Value<int> transferredQuantity = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockTransferItemsCompanion.insert(
            id: id,
            transferId: transferId,
            productId: productId,
            productName: productName,
            requestedQuantity: requestedQuantity,
            transferredQuantity: transferredQuantity,
            notes: notes,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StockTransferItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transferId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transferId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transferId,
                    referencedTable: $$StockTransferItemsTableReferences
                        ._transferIdTable(db),
                    referencedColumn: $$StockTransferItemsTableReferences
                        ._transferIdTable(db)
                        .id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$StockTransferItemsTableReferences._productIdTable(db),
                    referencedColumn: $$StockTransferItemsTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StockTransferItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockTransferItemsTable,
    StockTransferItem,
    $$StockTransferItemsTableFilterComposer,
    $$StockTransferItemsTableOrderingComposer,
    $$StockTransferItemsTableAnnotationComposer,
    $$StockTransferItemsTableCreateCompanionBuilder,
    $$StockTransferItemsTableUpdateCompanionBuilder,
    (StockTransferItem, $$StockTransferItemsTableReferences),
    StockTransferItem,
    PrefetchHooks Function({bool transferId, bool productId})>;
typedef $$InventoryCountsTableCreateCompanionBuilder = InventoryCountsCompanion
    Function({
  required String id,
  required String countNumber,
  required String warehouseId,
  Value<String> status,
  Value<String> countType,
  Value<String?> notes,
  Value<String?> createdBy,
  Value<String?> approvedBy,
  Value<int> totalItems,
  Value<int> countedItems,
  Value<int> varianceItems,
  Value<double> totalVarianceValue,
  Value<String> syncStatus,
  Value<DateTime> countDate,
  Value<DateTime?> completedAt,
  Value<DateTime?> approvedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$InventoryCountsTableUpdateCompanionBuilder = InventoryCountsCompanion
    Function({
  Value<String> id,
  Value<String> countNumber,
  Value<String> warehouseId,
  Value<String> status,
  Value<String> countType,
  Value<String?> notes,
  Value<String?> createdBy,
  Value<String?> approvedBy,
  Value<int> totalItems,
  Value<int> countedItems,
  Value<int> varianceItems,
  Value<double> totalVarianceValue,
  Value<String> syncStatus,
  Value<DateTime> countDate,
  Value<DateTime?> completedAt,
  Value<DateTime?> approvedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$InventoryCountsTableReferences extends BaseReferences<
    _$AppDatabase, $InventoryCountsTable, InventoryCount> {
  $$InventoryCountsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WarehousesTable _warehouseIdTable(_$AppDatabase db) =>
      db.warehouses.createAlias($_aliasNameGenerator(
          db.inventoryCounts.warehouseId, db.warehouses.id));

  $$WarehousesTableProcessedTableManager? get warehouseId {
    if ($_item.warehouseId == null) return null;
    final manager = $$WarehousesTableTableManager($_db, $_db.warehouses)
        .filter((f) => f.id($_item.warehouseId!));
    final item = $_typedResult.readTableOrNull(_warehouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InventoryCountItemsTable,
      List<InventoryCountItem>> _inventoryCountItemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.inventoryCountItems,
          aliasName: $_aliasNameGenerator(
              db.inventoryCounts.id, db.inventoryCountItems.countId));

  $$InventoryCountItemsTableProcessedTableManager get inventoryCountItemsRefs {
    final manager =
        $$InventoryCountItemsTableTableManager($_db, $_db.inventoryCountItems)
            .filter((f) => f.countId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_inventoryCountItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryAdjustmentsTable,
      List<InventoryAdjustment>> _inventoryAdjustmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.inventoryAdjustments,
          aliasName: $_aliasNameGenerator(
              db.inventoryCounts.id, db.inventoryAdjustments.countId));

  $$InventoryAdjustmentsTableProcessedTableManager
      get inventoryAdjustmentsRefs {
    final manager =
        $$InventoryAdjustmentsTableTableManager($_db, $_db.inventoryAdjustments)
            .filter((f) => f.countId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_inventoryAdjustmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$InventoryCountsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryCountsTable> {
  $$InventoryCountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countNumber => $composableBuilder(
      column: $table.countNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countType => $composableBuilder(
      column: $table.countType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get countedItems => $composableBuilder(
      column: $table.countedItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get varianceItems => $composableBuilder(
      column: $table.varianceItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalVarianceValue => $composableBuilder(
      column: $table.totalVarianceValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get countDate => $composableBuilder(
      column: $table.countDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$WarehousesTableFilterComposer get warehouseId {
    final $$WarehousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableFilterComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> inventoryCountItemsRefs(
      Expression<bool> Function($$InventoryCountItemsTableFilterComposer f) f) {
    final $$InventoryCountItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryCountItems,
        getReferencedColumn: (t) => t.countId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountItemsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryCountItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryAdjustmentsRefs(
      Expression<bool> Function($$InventoryAdjustmentsTableFilterComposer f)
          f) {
    final $$InventoryAdjustmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryAdjustments,
        getReferencedColumn: (t) => t.countId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryAdjustmentsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryAdjustments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InventoryCountsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryCountsTable> {
  $$InventoryCountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countNumber => $composableBuilder(
      column: $table.countNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countType => $composableBuilder(
      column: $table.countType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get countedItems => $composableBuilder(
      column: $table.countedItems,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get varianceItems => $composableBuilder(
      column: $table.varianceItems,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalVarianceValue => $composableBuilder(
      column: $table.totalVarianceValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get countDate => $composableBuilder(
      column: $table.countDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$WarehousesTableOrderingComposer get warehouseId {
    final $$WarehousesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableOrderingComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryCountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryCountsTable> {
  $$InventoryCountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get countNumber => $composableBuilder(
      column: $table.countNumber, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get countType =>
      $composableBuilder(column: $table.countType, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => column);

  GeneratedColumn<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => column);

  GeneratedColumn<int> get countedItems => $composableBuilder(
      column: $table.countedItems, builder: (column) => column);

  GeneratedColumn<int> get varianceItems => $composableBuilder(
      column: $table.varianceItems, builder: (column) => column);

  GeneratedColumn<double> get totalVarianceValue => $composableBuilder(
      column: $table.totalVarianceValue, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get countDate =>
      $composableBuilder(column: $table.countDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WarehousesTableAnnotationComposer get warehouseId {
    final $$WarehousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableAnnotationComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> inventoryCountItemsRefs<T extends Object>(
      Expression<T> Function($$InventoryCountItemsTableAnnotationComposer a)
          f) {
    final $$InventoryCountItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryCountItems,
            getReferencedColumn: (t) => t.countId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryCountItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryCountItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> inventoryAdjustmentsRefs<T extends Object>(
      Expression<T> Function($$InventoryAdjustmentsTableAnnotationComposer a)
          f) {
    final $$InventoryAdjustmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryAdjustments,
            getReferencedColumn: (t) => t.countId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryAdjustmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryAdjustments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$InventoryCountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryCountsTable,
    InventoryCount,
    $$InventoryCountsTableFilterComposer,
    $$InventoryCountsTableOrderingComposer,
    $$InventoryCountsTableAnnotationComposer,
    $$InventoryCountsTableCreateCompanionBuilder,
    $$InventoryCountsTableUpdateCompanionBuilder,
    (InventoryCount, $$InventoryCountsTableReferences),
    InventoryCount,
    PrefetchHooks Function(
        {bool warehouseId,
        bool inventoryCountItemsRefs,
        bool inventoryAdjustmentsRefs})> {
  $$InventoryCountsTableTableManager(
      _$AppDatabase db, $InventoryCountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> countNumber = const Value.absent(),
            Value<String> warehouseId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> countType = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> approvedBy = const Value.absent(),
            Value<int> totalItems = const Value.absent(),
            Value<int> countedItems = const Value.absent(),
            Value<int> varianceItems = const Value.absent(),
            Value<double> totalVarianceValue = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> countDate = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> approvedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryCountsCompanion(
            id: id,
            countNumber: countNumber,
            warehouseId: warehouseId,
            status: status,
            countType: countType,
            notes: notes,
            createdBy: createdBy,
            approvedBy: approvedBy,
            totalItems: totalItems,
            countedItems: countedItems,
            varianceItems: varianceItems,
            totalVarianceValue: totalVarianceValue,
            syncStatus: syncStatus,
            countDate: countDate,
            completedAt: completedAt,
            approvedAt: approvedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String countNumber,
            required String warehouseId,
            Value<String> status = const Value.absent(),
            Value<String> countType = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> approvedBy = const Value.absent(),
            Value<int> totalItems = const Value.absent(),
            Value<int> countedItems = const Value.absent(),
            Value<int> varianceItems = const Value.absent(),
            Value<double> totalVarianceValue = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> countDate = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> approvedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryCountsCompanion.insert(
            id: id,
            countNumber: countNumber,
            warehouseId: warehouseId,
            status: status,
            countType: countType,
            notes: notes,
            createdBy: createdBy,
            approvedBy: approvedBy,
            totalItems: totalItems,
            countedItems: countedItems,
            varianceItems: varianceItems,
            totalVarianceValue: totalVarianceValue,
            syncStatus: syncStatus,
            countDate: countDate,
            completedAt: completedAt,
            approvedAt: approvedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryCountsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {warehouseId = false,
              inventoryCountItemsRefs = false,
              inventoryAdjustmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (inventoryCountItemsRefs) db.inventoryCountItems,
                if (inventoryAdjustmentsRefs) db.inventoryAdjustments
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (warehouseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.warehouseId,
                    referencedTable:
                        $$InventoryCountsTableReferences._warehouseIdTable(db),
                    referencedColumn: $$InventoryCountsTableReferences
                        ._warehouseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (inventoryCountItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$InventoryCountsTableReferences
                            ._inventoryCountItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InventoryCountsTableReferences(db, table, p0)
                                .inventoryCountItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.countId == item.id),
                        typedResults: items),
                  if (inventoryAdjustmentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$InventoryCountsTableReferences
                            ._inventoryAdjustmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InventoryCountsTableReferences(db, table, p0)
                                .inventoryAdjustmentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.countId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$InventoryCountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryCountsTable,
    InventoryCount,
    $$InventoryCountsTableFilterComposer,
    $$InventoryCountsTableOrderingComposer,
    $$InventoryCountsTableAnnotationComposer,
    $$InventoryCountsTableCreateCompanionBuilder,
    $$InventoryCountsTableUpdateCompanionBuilder,
    (InventoryCount, $$InventoryCountsTableReferences),
    InventoryCount,
    PrefetchHooks Function(
        {bool warehouseId,
        bool inventoryCountItemsRefs,
        bool inventoryAdjustmentsRefs})>;
typedef $$InventoryCountItemsTableCreateCompanionBuilder
    = InventoryCountItemsCompanion Function({
  required String id,
  required String countId,
  required String productId,
  required String productName,
  Value<String?> productSku,
  Value<String?> productBarcode,
  required int systemQuantity,
  Value<int?> physicalQuantity,
  Value<int?> variance,
  required double unitCost,
  Value<double?> varianceValue,
  Value<String?> varianceReason,
  Value<bool> isCounted,
  Value<String?> location,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime?> countedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$InventoryCountItemsTableUpdateCompanionBuilder
    = InventoryCountItemsCompanion Function({
  Value<String> id,
  Value<String> countId,
  Value<String> productId,
  Value<String> productName,
  Value<String?> productSku,
  Value<String?> productBarcode,
  Value<int> systemQuantity,
  Value<int?> physicalQuantity,
  Value<int?> variance,
  Value<double> unitCost,
  Value<double?> varianceValue,
  Value<String?> varianceReason,
  Value<bool> isCounted,
  Value<String?> location,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime?> countedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$InventoryCountItemsTableReferences extends BaseReferences<
    _$AppDatabase, $InventoryCountItemsTable, InventoryCountItem> {
  $$InventoryCountItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $InventoryCountsTable _countIdTable(_$AppDatabase db) =>
      db.inventoryCounts.createAlias($_aliasNameGenerator(
          db.inventoryCountItems.countId, db.inventoryCounts.id));

  $$InventoryCountsTableProcessedTableManager? get countId {
    if ($_item.countId == null) return null;
    final manager =
        $$InventoryCountsTableTableManager($_db, $_db.inventoryCounts)
            .filter((f) => f.id($_item.countId!));
    final item = $_typedResult.readTableOrNull(_countIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.inventoryCountItems.productId, db.products.id));

  $$ProductsTableProcessedTableManager? get productId {
    if ($_item.productId == null) return null;
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id($_item.productId!));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InventoryCountItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryCountItemsTable> {
  $$InventoryCountItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productSku => $composableBuilder(
      column: $table.productSku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productBarcode => $composableBuilder(
      column: $table.productBarcode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get systemQuantity => $composableBuilder(
      column: $table.systemQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get physicalQuantity => $composableBuilder(
      column: $table.physicalQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get variance => $composableBuilder(
      column: $table.variance, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get varianceValue => $composableBuilder(
      column: $table.varianceValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get varianceReason => $composableBuilder(
      column: $table.varianceReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCounted => $composableBuilder(
      column: $table.isCounted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get countedAt => $composableBuilder(
      column: $table.countedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$InventoryCountsTableFilterComposer get countId {
    final $$InventoryCountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countId,
        referencedTable: $db.inventoryCounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryCountItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryCountItemsTable> {
  $$InventoryCountItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productSku => $composableBuilder(
      column: $table.productSku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productBarcode => $composableBuilder(
      column: $table.productBarcode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get systemQuantity => $composableBuilder(
      column: $table.systemQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get physicalQuantity => $composableBuilder(
      column: $table.physicalQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get variance => $composableBuilder(
      column: $table.variance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get varianceValue => $composableBuilder(
      column: $table.varianceValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get varianceReason => $composableBuilder(
      column: $table.varianceReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCounted => $composableBuilder(
      column: $table.isCounted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get countedAt => $composableBuilder(
      column: $table.countedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$InventoryCountsTableOrderingComposer get countId {
    final $$InventoryCountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countId,
        referencedTable: $db.inventoryCounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountsTableOrderingComposer(
              $db: $db,
              $table: $db.inventoryCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryCountItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryCountItemsTable> {
  $$InventoryCountItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get productSku => $composableBuilder(
      column: $table.productSku, builder: (column) => column);

  GeneratedColumn<String> get productBarcode => $composableBuilder(
      column: $table.productBarcode, builder: (column) => column);

  GeneratedColumn<int> get systemQuantity => $composableBuilder(
      column: $table.systemQuantity, builder: (column) => column);

  GeneratedColumn<int> get physicalQuantity => $composableBuilder(
      column: $table.physicalQuantity, builder: (column) => column);

  GeneratedColumn<int> get variance =>
      $composableBuilder(column: $table.variance, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<double> get varianceValue => $composableBuilder(
      column: $table.varianceValue, builder: (column) => column);

  GeneratedColumn<String> get varianceReason => $composableBuilder(
      column: $table.varianceReason, builder: (column) => column);

  GeneratedColumn<bool> get isCounted =>
      $composableBuilder(column: $table.isCounted, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get countedAt =>
      $composableBuilder(column: $table.countedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$InventoryCountsTableAnnotationComposer get countId {
    final $$InventoryCountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countId,
        referencedTable: $db.inventoryCounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountsTableAnnotationComposer(
              $db: $db,
              $table: $db.inventoryCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryCountItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryCountItemsTable,
    InventoryCountItem,
    $$InventoryCountItemsTableFilterComposer,
    $$InventoryCountItemsTableOrderingComposer,
    $$InventoryCountItemsTableAnnotationComposer,
    $$InventoryCountItemsTableCreateCompanionBuilder,
    $$InventoryCountItemsTableUpdateCompanionBuilder,
    (InventoryCountItem, $$InventoryCountItemsTableReferences),
    InventoryCountItem,
    PrefetchHooks Function({bool countId, bool productId})> {
  $$InventoryCountItemsTableTableManager(
      _$AppDatabase db, $InventoryCountItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryCountItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryCountItemsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryCountItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> countId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String?> productSku = const Value.absent(),
            Value<String?> productBarcode = const Value.absent(),
            Value<int> systemQuantity = const Value.absent(),
            Value<int?> physicalQuantity = const Value.absent(),
            Value<int?> variance = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<double?> varianceValue = const Value.absent(),
            Value<String?> varianceReason = const Value.absent(),
            Value<bool> isCounted = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> countedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryCountItemsCompanion(
            id: id,
            countId: countId,
            productId: productId,
            productName: productName,
            productSku: productSku,
            productBarcode: productBarcode,
            systemQuantity: systemQuantity,
            physicalQuantity: physicalQuantity,
            variance: variance,
            unitCost: unitCost,
            varianceValue: varianceValue,
            varianceReason: varianceReason,
            isCounted: isCounted,
            location: location,
            notes: notes,
            syncStatus: syncStatus,
            countedAt: countedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String countId,
            required String productId,
            required String productName,
            Value<String?> productSku = const Value.absent(),
            Value<String?> productBarcode = const Value.absent(),
            required int systemQuantity,
            Value<int?> physicalQuantity = const Value.absent(),
            Value<int?> variance = const Value.absent(),
            required double unitCost,
            Value<double?> varianceValue = const Value.absent(),
            Value<String?> varianceReason = const Value.absent(),
            Value<bool> isCounted = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> countedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryCountItemsCompanion.insert(
            id: id,
            countId: countId,
            productId: productId,
            productName: productName,
            productSku: productSku,
            productBarcode: productBarcode,
            systemQuantity: systemQuantity,
            physicalQuantity: physicalQuantity,
            variance: variance,
            unitCost: unitCost,
            varianceValue: varianceValue,
            varianceReason: varianceReason,
            isCounted: isCounted,
            location: location,
            notes: notes,
            syncStatus: syncStatus,
            countedAt: countedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryCountItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({countId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (countId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.countId,
                    referencedTable:
                        $$InventoryCountItemsTableReferences._countIdTable(db),
                    referencedColumn: $$InventoryCountItemsTableReferences
                        ._countIdTable(db)
                        .id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable: $$InventoryCountItemsTableReferences
                        ._productIdTable(db),
                    referencedColumn: $$InventoryCountItemsTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InventoryCountItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryCountItemsTable,
    InventoryCountItem,
    $$InventoryCountItemsTableFilterComposer,
    $$InventoryCountItemsTableOrderingComposer,
    $$InventoryCountItemsTableAnnotationComposer,
    $$InventoryCountItemsTableCreateCompanionBuilder,
    $$InventoryCountItemsTableUpdateCompanionBuilder,
    (InventoryCountItem, $$InventoryCountItemsTableReferences),
    InventoryCountItem,
    PrefetchHooks Function({bool countId, bool productId})>;
typedef $$InventoryAdjustmentsTableCreateCompanionBuilder
    = InventoryAdjustmentsCompanion Function({
  required String id,
  required String adjustmentNumber,
  Value<String?> countId,
  required String warehouseId,
  required String type,
  required String reason,
  Value<String> status,
  Value<String?> approvedBy,
  Value<double> totalValue,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> adjustmentDate,
  Value<DateTime?> approvedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$InventoryAdjustmentsTableUpdateCompanionBuilder
    = InventoryAdjustmentsCompanion Function({
  Value<String> id,
  Value<String> adjustmentNumber,
  Value<String?> countId,
  Value<String> warehouseId,
  Value<String> type,
  Value<String> reason,
  Value<String> status,
  Value<String?> approvedBy,
  Value<double> totalValue,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<DateTime> adjustmentDate,
  Value<DateTime?> approvedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$InventoryAdjustmentsTableReferences extends BaseReferences<
    _$AppDatabase, $InventoryAdjustmentsTable, InventoryAdjustment> {
  $$InventoryAdjustmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $InventoryCountsTable _countIdTable(_$AppDatabase db) =>
      db.inventoryCounts.createAlias($_aliasNameGenerator(
          db.inventoryAdjustments.countId, db.inventoryCounts.id));

  $$InventoryCountsTableProcessedTableManager? get countId {
    if ($_item.countId == null) return null;
    final manager =
        $$InventoryCountsTableTableManager($_db, $_db.inventoryCounts)
            .filter((f) => f.id($_item.countId!));
    final item = $_typedResult.readTableOrNull(_countIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WarehousesTable _warehouseIdTable(_$AppDatabase db) =>
      db.warehouses.createAlias($_aliasNameGenerator(
          db.inventoryAdjustments.warehouseId, db.warehouses.id));

  $$WarehousesTableProcessedTableManager? get warehouseId {
    if ($_item.warehouseId == null) return null;
    final manager = $$WarehousesTableTableManager($_db, $_db.warehouses)
        .filter((f) => f.id($_item.warehouseId!));
    final item = $_typedResult.readTableOrNull(_warehouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InventoryAdjustmentItemsTable,
      List<InventoryAdjustmentItem>> _inventoryAdjustmentItemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.inventoryAdjustmentItems,
          aliasName: $_aliasNameGenerator(db.inventoryAdjustments.id,
              db.inventoryAdjustmentItems.adjustmentId));

  $$InventoryAdjustmentItemsTableProcessedTableManager
      get inventoryAdjustmentItemsRefs {
    final manager = $$InventoryAdjustmentItemsTableTableManager(
            $_db, $_db.inventoryAdjustmentItems)
        .filter((f) => f.adjustmentId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_inventoryAdjustmentItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$InventoryAdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryAdjustmentsTable> {
  $$InventoryAdjustmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adjustmentNumber => $composableBuilder(
      column: $table.adjustmentNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalValue => $composableBuilder(
      column: $table.totalValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get adjustmentDate => $composableBuilder(
      column: $table.adjustmentDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$InventoryCountsTableFilterComposer get countId {
    final $$InventoryCountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countId,
        referencedTable: $db.inventoryCounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WarehousesTableFilterComposer get warehouseId {
    final $$WarehousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableFilterComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> inventoryAdjustmentItemsRefs(
      Expression<bool> Function($$InventoryAdjustmentItemsTableFilterComposer f)
          f) {
    final $$InventoryAdjustmentItemsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryAdjustmentItems,
            getReferencedColumn: (t) => t.adjustmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryAdjustmentItemsTableFilterComposer(
                  $db: $db,
                  $table: $db.inventoryAdjustmentItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$InventoryAdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryAdjustmentsTable> {
  $$InventoryAdjustmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adjustmentNumber => $composableBuilder(
      column: $table.adjustmentNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalValue => $composableBuilder(
      column: $table.totalValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get adjustmentDate => $composableBuilder(
      column: $table.adjustmentDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$InventoryCountsTableOrderingComposer get countId {
    final $$InventoryCountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countId,
        referencedTable: $db.inventoryCounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountsTableOrderingComposer(
              $db: $db,
              $table: $db.inventoryCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WarehousesTableOrderingComposer get warehouseId {
    final $$WarehousesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableOrderingComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryAdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryAdjustmentsTable> {
  $$InventoryAdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get adjustmentNumber => $composableBuilder(
      column: $table.adjustmentNumber, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => column);

  GeneratedColumn<double> get totalValue => $composableBuilder(
      column: $table.totalValue, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get adjustmentDate => $composableBuilder(
      column: $table.adjustmentDate, builder: (column) => column);

  GeneratedColumn<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$InventoryCountsTableAnnotationComposer get countId {
    final $$InventoryCountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countId,
        referencedTable: $db.inventoryCounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryCountsTableAnnotationComposer(
              $db: $db,
              $table: $db.inventoryCounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WarehousesTableAnnotationComposer get warehouseId {
    final $$WarehousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableAnnotationComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> inventoryAdjustmentItemsRefs<T extends Object>(
      Expression<T> Function(
              $$InventoryAdjustmentItemsTableAnnotationComposer a)
          f) {
    final $$InventoryAdjustmentItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryAdjustmentItems,
            getReferencedColumn: (t) => t.adjustmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryAdjustmentItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryAdjustmentItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$InventoryAdjustmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryAdjustmentsTable,
    InventoryAdjustment,
    $$InventoryAdjustmentsTableFilterComposer,
    $$InventoryAdjustmentsTableOrderingComposer,
    $$InventoryAdjustmentsTableAnnotationComposer,
    $$InventoryAdjustmentsTableCreateCompanionBuilder,
    $$InventoryAdjustmentsTableUpdateCompanionBuilder,
    (InventoryAdjustment, $$InventoryAdjustmentsTableReferences),
    InventoryAdjustment,
    PrefetchHooks Function(
        {bool countId, bool warehouseId, bool inventoryAdjustmentItemsRefs})> {
  $$InventoryAdjustmentsTableTableManager(
      _$AppDatabase db, $InventoryAdjustmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryAdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryAdjustmentsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryAdjustmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> adjustmentNumber = const Value.absent(),
            Value<String?> countId = const Value.absent(),
            Value<String> warehouseId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> approvedBy = const Value.absent(),
            Value<double> totalValue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> adjustmentDate = const Value.absent(),
            Value<DateTime?> approvedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryAdjustmentsCompanion(
            id: id,
            adjustmentNumber: adjustmentNumber,
            countId: countId,
            warehouseId: warehouseId,
            type: type,
            reason: reason,
            status: status,
            approvedBy: approvedBy,
            totalValue: totalValue,
            notes: notes,
            syncStatus: syncStatus,
            adjustmentDate: adjustmentDate,
            approvedAt: approvedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String adjustmentNumber,
            Value<String?> countId = const Value.absent(),
            required String warehouseId,
            required String type,
            required String reason,
            Value<String> status = const Value.absent(),
            Value<String?> approvedBy = const Value.absent(),
            Value<double> totalValue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> adjustmentDate = const Value.absent(),
            Value<DateTime?> approvedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryAdjustmentsCompanion.insert(
            id: id,
            adjustmentNumber: adjustmentNumber,
            countId: countId,
            warehouseId: warehouseId,
            type: type,
            reason: reason,
            status: status,
            approvedBy: approvedBy,
            totalValue: totalValue,
            notes: notes,
            syncStatus: syncStatus,
            adjustmentDate: adjustmentDate,
            approvedAt: approvedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryAdjustmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {countId = false,
              warehouseId = false,
              inventoryAdjustmentItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (inventoryAdjustmentItemsRefs) db.inventoryAdjustmentItems
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (countId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.countId,
                    referencedTable:
                        $$InventoryAdjustmentsTableReferences._countIdTable(db),
                    referencedColumn: $$InventoryAdjustmentsTableReferences
                        ._countIdTable(db)
                        .id,
                  ) as T;
                }
                if (warehouseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.warehouseId,
                    referencedTable: $$InventoryAdjustmentsTableReferences
                        ._warehouseIdTable(db),
                    referencedColumn: $$InventoryAdjustmentsTableReferences
                        ._warehouseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (inventoryAdjustmentItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$InventoryAdjustmentsTableReferences
                            ._inventoryAdjustmentItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InventoryAdjustmentsTableReferences(db, table, p0)
                                .inventoryAdjustmentItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.adjustmentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$InventoryAdjustmentsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $InventoryAdjustmentsTable,
        InventoryAdjustment,
        $$InventoryAdjustmentsTableFilterComposer,
        $$InventoryAdjustmentsTableOrderingComposer,
        $$InventoryAdjustmentsTableAnnotationComposer,
        $$InventoryAdjustmentsTableCreateCompanionBuilder,
        $$InventoryAdjustmentsTableUpdateCompanionBuilder,
        (InventoryAdjustment, $$InventoryAdjustmentsTableReferences),
        InventoryAdjustment,
        PrefetchHooks Function(
            {bool countId,
            bool warehouseId,
            bool inventoryAdjustmentItemsRefs})>;
typedef $$InventoryAdjustmentItemsTableCreateCompanionBuilder
    = InventoryAdjustmentItemsCompanion Function({
  required String id,
  required String adjustmentId,
  required String productId,
  required String productName,
  required int quantityBefore,
  required int quantityAdjusted,
  required int quantityAfter,
  required double unitCost,
  required double adjustmentValue,
  Value<String?> reason,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$InventoryAdjustmentItemsTableUpdateCompanionBuilder
    = InventoryAdjustmentItemsCompanion Function({
  Value<String> id,
  Value<String> adjustmentId,
  Value<String> productId,
  Value<String> productName,
  Value<int> quantityBefore,
  Value<int> quantityAdjusted,
  Value<int> quantityAfter,
  Value<double> unitCost,
  Value<double> adjustmentValue,
  Value<String?> reason,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$InventoryAdjustmentItemsTableReferences extends BaseReferences<
    _$AppDatabase, $InventoryAdjustmentItemsTable, InventoryAdjustmentItem> {
  $$InventoryAdjustmentItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $InventoryAdjustmentsTable _adjustmentIdTable(_$AppDatabase db) =>
      db.inventoryAdjustments.createAlias($_aliasNameGenerator(
          db.inventoryAdjustmentItems.adjustmentId,
          db.inventoryAdjustments.id));

  $$InventoryAdjustmentsTableProcessedTableManager? get adjustmentId {
    if ($_item.adjustmentId == null) return null;
    final manager =
        $$InventoryAdjustmentsTableTableManager($_db, $_db.inventoryAdjustments)
            .filter((f) => f.id($_item.adjustmentId!));
    final item = $_typedResult.readTableOrNull(_adjustmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.inventoryAdjustmentItems.productId, db.products.id));

  $$ProductsTableProcessedTableManager? get productId {
    if ($_item.productId == null) return null;
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id($_item.productId!));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InventoryAdjustmentItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryAdjustmentItemsTable> {
  $$InventoryAdjustmentItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityBefore => $composableBuilder(
      column: $table.quantityBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityAdjusted => $composableBuilder(
      column: $table.quantityAdjusted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityAfter => $composableBuilder(
      column: $table.quantityAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get adjustmentValue => $composableBuilder(
      column: $table.adjustmentValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$InventoryAdjustmentsTableFilterComposer get adjustmentId {
    final $$InventoryAdjustmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.adjustmentId,
        referencedTable: $db.inventoryAdjustments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryAdjustmentsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryAdjustments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryAdjustmentItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryAdjustmentItemsTable> {
  $$InventoryAdjustmentItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityBefore => $composableBuilder(
      column: $table.quantityBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityAdjusted => $composableBuilder(
      column: $table.quantityAdjusted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityAfter => $composableBuilder(
      column: $table.quantityAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get adjustmentValue => $composableBuilder(
      column: $table.adjustmentValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$InventoryAdjustmentsTableOrderingComposer get adjustmentId {
    final $$InventoryAdjustmentsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.adjustmentId,
            referencedTable: $db.inventoryAdjustments,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryAdjustmentsTableOrderingComposer(
                  $db: $db,
                  $table: $db.inventoryAdjustments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryAdjustmentItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryAdjustmentItemsTable> {
  $$InventoryAdjustmentItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<int> get quantityBefore => $composableBuilder(
      column: $table.quantityBefore, builder: (column) => column);

  GeneratedColumn<int> get quantityAdjusted => $composableBuilder(
      column: $table.quantityAdjusted, builder: (column) => column);

  GeneratedColumn<int> get quantityAfter => $composableBuilder(
      column: $table.quantityAfter, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<double> get adjustmentValue => $composableBuilder(
      column: $table.adjustmentValue, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$InventoryAdjustmentsTableAnnotationComposer get adjustmentId {
    final $$InventoryAdjustmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.adjustmentId,
            referencedTable: $db.inventoryAdjustments,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryAdjustmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryAdjustments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryAdjustmentItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryAdjustmentItemsTable,
    InventoryAdjustmentItem,
    $$InventoryAdjustmentItemsTableFilterComposer,
    $$InventoryAdjustmentItemsTableOrderingComposer,
    $$InventoryAdjustmentItemsTableAnnotationComposer,
    $$InventoryAdjustmentItemsTableCreateCompanionBuilder,
    $$InventoryAdjustmentItemsTableUpdateCompanionBuilder,
    (InventoryAdjustmentItem, $$InventoryAdjustmentItemsTableReferences),
    InventoryAdjustmentItem,
    PrefetchHooks Function({bool adjustmentId, bool productId})> {
  $$InventoryAdjustmentItemsTableTableManager(
      _$AppDatabase db, $InventoryAdjustmentItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryAdjustmentItemsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryAdjustmentItemsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryAdjustmentItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> adjustmentId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<int> quantityBefore = const Value.absent(),
            Value<int> quantityAdjusted = const Value.absent(),
            Value<int> quantityAfter = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<double> adjustmentValue = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryAdjustmentItemsCompanion(
            id: id,
            adjustmentId: adjustmentId,
            productId: productId,
            productName: productName,
            quantityBefore: quantityBefore,
            quantityAdjusted: quantityAdjusted,
            quantityAfter: quantityAfter,
            unitCost: unitCost,
            adjustmentValue: adjustmentValue,
            reason: reason,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String adjustmentId,
            required String productId,
            required String productName,
            required int quantityBefore,
            required int quantityAdjusted,
            required int quantityAfter,
            required double unitCost,
            required double adjustmentValue,
            Value<String?> reason = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryAdjustmentItemsCompanion.insert(
            id: id,
            adjustmentId: adjustmentId,
            productId: productId,
            productName: productName,
            quantityBefore: quantityBefore,
            quantityAdjusted: quantityAdjusted,
            quantityAfter: quantityAfter,
            unitCost: unitCost,
            adjustmentValue: adjustmentValue,
            reason: reason,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryAdjustmentItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({adjustmentId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (adjustmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.adjustmentId,
                    referencedTable: $$InventoryAdjustmentItemsTableReferences
                        ._adjustmentIdTable(db),
                    referencedColumn: $$InventoryAdjustmentItemsTableReferences
                        ._adjustmentIdTable(db)
                        .id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable: $$InventoryAdjustmentItemsTableReferences
                        ._productIdTable(db),
                    referencedColumn: $$InventoryAdjustmentItemsTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InventoryAdjustmentItemsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $InventoryAdjustmentItemsTable,
        InventoryAdjustmentItem,
        $$InventoryAdjustmentItemsTableFilterComposer,
        $$InventoryAdjustmentItemsTableOrderingComposer,
        $$InventoryAdjustmentItemsTableAnnotationComposer,
        $$InventoryAdjustmentItemsTableCreateCompanionBuilder,
        $$InventoryAdjustmentItemsTableUpdateCompanionBuilder,
        (InventoryAdjustmentItem, $$InventoryAdjustmentItemsTableReferences),
        InventoryAdjustmentItem,
        PrefetchHooks Function({bool adjustmentId, bool productId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$InventoryMovementsTableTableManager get inventoryMovements =>
      $$InventoryMovementsTableTableManager(_db, _db.inventoryMovements);
  $$CashMovementsTableTableManager get cashMovements =>
      $$CashMovementsTableTableManager(_db, _db.cashMovements);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$VoucherCategoriesTableTableManager get voucherCategories =>
      $$VoucherCategoriesTableTableManager(_db, _db.voucherCategories);
  $$VouchersTableTableManager get vouchers =>
      $$VouchersTableTableManager(_db, _db.vouchers);
  $$WarehousesTableTableManager get warehouses =>
      $$WarehousesTableTableManager(_db, _db.warehouses);
  $$WarehouseStockTableTableManager get warehouseStock =>
      $$WarehouseStockTableTableManager(_db, _db.warehouseStock);
  $$StockTransfersTableTableManager get stockTransfers =>
      $$StockTransfersTableTableManager(_db, _db.stockTransfers);
  $$StockTransferItemsTableTableManager get stockTransferItems =>
      $$StockTransferItemsTableTableManager(_db, _db.stockTransferItems);
  $$InventoryCountsTableTableManager get inventoryCounts =>
      $$InventoryCountsTableTableManager(_db, _db.inventoryCounts);
  $$InventoryCountItemsTableTableManager get inventoryCountItems =>
      $$InventoryCountItemsTableTableManager(_db, _db.inventoryCountItems);
  $$InventoryAdjustmentsTableTableManager get inventoryAdjustments =>
      $$InventoryAdjustmentsTableTableManager(_db, _db.inventoryAdjustments);
  $$InventoryAdjustmentItemsTableTableManager get inventoryAdjustmentItems =>
      $$InventoryAdjustmentItemsTableTableManager(
          _db, _db.inventoryAdjustmentItems);
}
