class IssuesList {
  String valueCode;
  String valueName;
  String value;

  IssuesList({
    required this.valueCode,
    required this.valueName,
    required this.value,
  });

  factory IssuesList.fromJson(Map<String, dynamic> json) => IssuesList(
    valueCode: json["value_code"],
    valueName: json["value_name"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "value_code": valueCode,
    "value_name": valueName,
    "value": value,
  };
}