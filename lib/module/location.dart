class Location {
  String id;
  String x;
  String y;
  String type;
  String progressLevel;
  String radius;
  String description;

  Location({
    this.id,
    this.x,
    this.y,
    this.type,
    this.progressLevel = '0',
    this.radius,
    this.description,
  });

  @override
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      x: json['x'],
      y: json['y'],
      type: json['type'],
      progressLevel: json['progressLevel'],
      radius: json['radius'],
      description: json['description'],
    );
  }

  String getId() {
    return id;
  }

  int getProgressLevel() {
    return int.parse(progressLevel);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['x'] = x;
    data['y'] = y;
    data['type'] = type;
    data['progressLevel'] = progressLevel;
    data['radius'] = radius;
    data['description'] = description;

    return data;
  }
}