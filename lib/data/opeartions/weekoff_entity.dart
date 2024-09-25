class WeekoffEntity {
    String empCode;
    DateTime date;
    String leaveType;
    String comment;

    WeekoffEntity({
        required this.empCode,
        required this.date,
        required this.leaveType,
        required this.comment,
    });

    factory WeekoffEntity.fromJson(Map<String, dynamic> json) => WeekoffEntity(
        empCode: json["empCode"],
        date: DateTime.parse(json["date"]),
        leaveType: json["leaveType"],
        comment: json["comment"],
    );

    Map<String, dynamic> toJson() => {
        "empCode": empCode,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "leaveType": leaveType,
        "comment": comment,
    };
}