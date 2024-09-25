// class Coupon {
//   final String skuCode;
//   final String skuName;
//   final String mrp;
//   final String discountValue;
//
//   Coupon({
//     required this.skuCode,
//     required this.skuName,
//     required this.mrp,
//     required this.discountValue,
//   });
// }
class Coupon {
  final String statusCode;
  final String status;
  final String multipleMRP;
  final List<Product> products;
  final List<Batch> batches;

  Coupon({
    required this.statusCode,
    required this.status,
    required this.multipleMRP,
    required this.products,
    required this.batches,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    List<Product> parsedProducts = <Product>[];
    if (json['product'] != null) {
      json['product'].forEach((v) {
        parsedProducts.add(Product.fromJson(v));
      });
    }

    List<Batch> parsedBatches = <Batch>[];
    if (json['batch'] != null) {
      json['batch'].forEach((v) {
        parsedBatches.add(Batch.fromJson(v));
      });
    }

    return Coupon(
      statusCode: json['statusCode'] ?? '',
      status: json['status'] ?? '',
      multipleMRP: json['multiplemrp'] ?? '',
      products: parsedProducts,
      batches: parsedBatches,
    );
  }
}

class Product {
  final String locationCode;
  final String skuCode;
  final String skuName;
  final String hsnCode;
  final String hsnDescription;
  final String taxCode;
  final String taxRate;
  final String eanCode;

  Product({
    required this.locationCode,
    required this.skuCode,
    required this.skuName,
    required this.hsnCode,
    required this.hsnDescription,
    required this.taxCode,
    required this.taxRate,
    required this.eanCode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      locationCode: json['LOCATION_CODE'] ?? '',
      skuCode: json['SKU_CODE'] ?? '',
      skuName: json['SKU_NAME'] ?? '',
      hsnCode: json['HSN_CODE'] ?? '',
      hsnDescription: json['HSN_DESCRIPTION'] ?? '',
      taxCode: json['TAX_CODE'] ?? '',
      taxRate: json['TAX_RATE'] ?? '',
      eanCode: json['ean_code'] ?? '',
    );
  }
}

class Batch {
  final String storeSkuLocStockNo;
  final String mrp;

  Batch({
    required this.storeSkuLocStockNo,
    required this.mrp,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      storeSkuLocStockNo: json['STORE_SKU_LOC_STOCK_NO'] ?? '',
      mrp: json['MRP'] ?? '',
    );
  }
}