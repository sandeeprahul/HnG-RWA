# Order Management Module Documentation

This module handles the end-to-end order processing flow, from viewing store orders to final delivery confirmation.

## Screens Overview

1.  **OrderManagementScreen**: The main dashboard providing navigation to Order Lists, Out for Delivery updates, and Delivery confirmations.
2.  **OrderListScreen**: Displays all orders for a selected location. Allows navigation to details for picking and packing.
3.  **OrderDetailsScreen**: Handles the item picking process. Includes barcode/QR scanning or manual entry to validate SKUs, select MRP/Batch, and update the order to "Ready to Ship".
4.  **OutForDeliveryScreen**: 
    - **Type 0 (Ready to Ship)**: Used to assign a delivery executive (Name, Mobile, Est. Time).
    - **Type 1 (Out for Delivery)**: Used to confirm delivery to the customer via OTP verification.

## API Integration Details

### Base URLs
- **OMS API**: `https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/`
- **Product API**: `https://rwaweb.healthandglowonline.co.in/mposgetean/api/checkout/`
- **Location API**: Defined in `Constants.apiHttpsUrl`

### Endpoint Summary

#### 1. Locations
- `GET /Login/GetLocation/{userid}`: Fetch authorized store locations.

#### 2. Order Listing (GET)
- `StoreOrderlist/{locationCode}`: All orders.
- `StoreOrderlistRTS/{locationCode}`: Orders waiting for delivery assignment.
- `StoreOrderlistOFD/{locationCode}`: Orders currently out for delivery.

#### 3. Order Processing
- `GET StoreOrderDetailslist/{orderId}`: Fetch items in an order.
- `GET geteandetail?location={loc}&ean_code={sku}`: Validate scanned products.
- `POST UpdateRTS`: Submit picked items (JSON Body: `List<PickedItems>`).

#### 4. Delivery Management (POST)
- `DeliveryCheckoutDetails`: Assign executive details.
- `DeliveryConfSendOTP`: Trigger OTP to customer.
- `UpdateDeliveryStatus`: Finalize delivery (requires internal OTP verification).

## State Management
The module uses **GetX** for state management:
- `OrderController`: Manages order lists and status filtering.
- `OrderDetailsController`: Handles product scanning, MRP selection, and picking logic.
- `DeliveryController`: Manages OTP flow and delivery status updates.

## Permissions Required
- **Location**: Required to verify if the user is within 100 meters of the store before performing actions.
- **Camera**: Required for scanning Product SKUs and Order IDs.
