class MarkerModel {
  double lat;
  double long;
  int label;

  MarkerModel({required this.lat, required this.long, required this.label});

  MarkerModel.fromJson(Map<String, dynamic> json)
      : lat = json['lat'],
        long = json['long'],
        label = json['label'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['label'] = this.label;
    return data;
  }
}
