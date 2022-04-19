class DriverStatusResponce {
  bool success;
  Data data;
  String message;

  DriverStatusResponce({this.success, this.data, this.message});

  DriverStatusResponce.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int id;
  int userId;
  int deliveryFee;
  int totalOrders;
  bool available;
  bool dutyStatus;
  String createdAt;
  String updatedAt;

  Data(
      {this.id,
        this.userId,
        this.deliveryFee,
        this.totalOrders,
        this.available,
        this.dutyStatus,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    deliveryFee = json['delivery_fee'];
    totalOrders = json['total_orders'];
    available = json['available'];
    dutyStatus = json['duty_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['delivery_fee'] = this.deliveryFee;
    data['total_orders'] = this.totalOrders;
    data['available'] = this.available;
    data['duty_status'] = this.dutyStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
