// class Order {
//   final String orderId;
//   final int itemCount;
//   final double subTotal;
//   final double discountTotal;
//   final double total;
//   final double shippingPrice;
//   final List<OrderItem> items;
//
//   Order({
//     required this.orderId,
//     required this.itemCount,
//     required this.subTotal,
//     required this.discountTotal,
//     required this.total,
//     required this.shippingPrice,
//     required this.items,
//   });
//
//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       orderId: json['order_id'],
//       itemCount: json['item_count'],
//       subTotal: json['sub_total'].toDouble(),
//       discountTotal: json['discount_total'].toDouble(),
//       total: json['total'].toDouble(),
//       shippingPrice: json['shipping_price'].toDouble(),
//       items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
//     );
//   }
// }
//
// class OrderItem {
//   final String skuName;
//   final String skuCode;
//   final double listPrice;
//   final int quantity;
//   final String imageUrl;
//
//   OrderItem({
//     required this.skuName,
//     required this.skuCode,
//     required this.listPrice,
//     required this.quantity,
//     required this.imageUrl,
//   });
//
//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     return OrderItem(
//       skuName: json['sku_Name'],
//       skuCode: json['sku_code'],
//       listPrice: json['list_price'].toDouble(),
//       quantity: json['quantity'],
//       imageUrl: json['image_url'],
//     );
//   }
// }
class Order {
  final String orderId;
  int itemCount;
  double subTotal;
  double discountTotal;
  double total;
  double shippingPrice;
  List<OrderItem> items;

  Order({
    required this.orderId,
    required this.itemCount,
    required this.subTotal,
    required this.discountTotal,
    required this.total,
    required this.shippingPrice,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> orderItems = (json['items'] as List)
        .map((item) => OrderItem.fromJson(item))
        .toList();

    return Order(
      orderId: json['order_id'],
      itemCount: orderItems.length,
      subTotal: orderItems.fold(0, (sum, item) => sum + (item.listPrice * item.quantity)),
      discountTotal: json['discount_total'].toDouble(),
      total: json['total'].toDouble(),
      shippingPrice: json['shipping_price'].toDouble(),
      items: orderItems,
    );
  }

  void updateOrderSummary() {
    itemCount = items.fold(0, (sum, item) => sum + item.quantity);
    subTotal = items.fold(0, (sum, item) => sum + (item.listPrice * item.quantity));
    total = subTotal - discountTotal + shippingPrice;
  }
}

class OrderItem {
  final String skuName;
  final String skuCode;
  double listPrice;
  int quantity;
  final String imageUrl;

  OrderItem({
    required this.skuName,
    required this.skuCode,
    required this.listPrice,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      skuName: json['sku_Name'],
      skuCode: json['sku_code'],
      listPrice: json['list_price'].toDouble(),
      quantity: json['quantity'],
      imageUrl: json['image_url'],
    );
  }

  void updateItem(double newPrice, int newQuantity) {
    listPrice = newPrice;
    quantity = newQuantity;
  }
}
