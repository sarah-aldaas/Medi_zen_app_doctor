import 'package:equatable/equatable.dart';

import '../model/articales_model.dart';


class ArticaleState extends Equatable {
  final List<Articale> articales;

  ArticaleState({required this.articales});

  @override
  List<Object> get props => [articales];
}