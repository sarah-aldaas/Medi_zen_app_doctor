class PaginatedResponse<T> {
  final bool? status;
  final int? errNum;
  final String? msg;
  final PaginatedData<T>? paginatedData;
  final MetaModel? meta;
  final LinksModel? links;

  PaginatedResponse({
    this.status,
    this.errNum,
    this.msg,
    this.paginatedData,
    this.meta,
    this.links,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      String dataKey,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PaginatedResponse<T>(
      status: json['status'] as bool,
      errNum: json['errNum'] as int,
      msg: json['msg'] as String,
      paginatedData: json[dataKey] != null
          ? PaginatedData<T>.fromJson(
              json[dataKey] as Map<String, dynamic>,
              fromJsonT,
            )
          : null,
      meta:json[dataKey] != null? json[dataKey]['meta'] != null
          ? MetaModel.fromJson(json[dataKey]['meta'])
          : null:null,
      links:json[dataKey] != null? json[dataKey]['links'] != null
          ? LinksModel.fromJson(json[dataKey]['links'])
          : null:null,
    );
  }
}
class PaginatedData<T> {
  final List<T> items;

  PaginatedData({required this.items});

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = (json['data'] as List<dynamic>)
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();
    return PaginatedData<T>(items: items);
  }
}

class MetaModel {
  final int currentPage;
  final int from;
  final int lastPage;
  final int perPage;
  final int to;
  final int total;

  MetaModel({required this.currentPage, required this.from, required this.lastPage, required this.perPage, required this.to, required this.total});

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      currentPage: json['current_page'] as int,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      to: json['to'] as int,
      total: json['total'] as int,
    );
  }
}

class LinksModel {
  final String first;
  final String last;
  final String? prev;
  final String? next;

  LinksModel({required this.first, required this.last, this.prev, this.next});

  factory LinksModel.fromJson(Map<String, dynamic> json) {
    return LinksModel(first: json['first'] as String, last: json['last'] as String, prev: json['prev'] as String?, next: json['next'] as String?);
  }
}
