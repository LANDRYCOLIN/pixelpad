class DeviceData {
  final String name;
  final String status;
  final int batteryPercent;
  final String idleState;
  final List<DeviceMetric> metrics;
  final List<DeviceRecord> records;

  const DeviceData({
    required this.name,
    required this.status,
    required this.batteryPercent,
    required this.idleState,
    required this.metrics,
    required this.records,
  });

  factory DeviceData.sample() {
    return const DeviceData(
      name: 'MyPixel',
      status: '已连接',
      batteryPercent: 93,
      idleState: '待机中',
      metrics: [
        DeviceMetric(label: '亮度', value: 50),
        DeviceMetric(label: '色温', value: 78),
        DeviceMetric(label: '待机', value: 36),
        DeviceMetric(label: '关机', value: 44),
      ],
      records: [
        DeviceRecord(
          weekday: 'Thu',
          day: 14,
          beans: 3679,
          duration: '1hr40m',
        ),
        DeviceRecord(
          weekday: 'Wed',
          day: 20,
          beans: 5789,
          duration: '1hr20m',
        ),
        DeviceRecord(
          weekday: 'Sat',
          day: 22,
          beans: 1859,
          duration: '1hr10m',
        ),
      ],
    );
  }
}

class DeviceMetric {
  final String label;
  final int value;

  const DeviceMetric({required this.label, required this.value});
}

class DeviceRecord {
  final String weekday;
  final int day;
  final int beans;
  final String duration;

  const DeviceRecord({
    required this.weekday,
    required this.day,
    required this.beans,
    required this.duration,
  });
}
