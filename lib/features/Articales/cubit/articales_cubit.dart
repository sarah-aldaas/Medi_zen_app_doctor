import 'package:bloc/bloc.dart';

import '../../../base/constant/app_images.dart';
import '../model/articales_model.dart';
import 'articales_state.dart';

class ArticaleCubit extends Cubit<ArticaleState> {
  ArticaleCubit() : super(ArticaleState(articales: _initialArticales()));

  static List<Articale> _initialArticales() {
    return [
      Articale(
        title: 'أحدث الاكتشافات في عالم الفضاء',
        shortDescription:
            'تعرف على آخر المستجدات والاكتشافات المذهلة في استكشاف الكون.',
        imageUrl: AppAssetImages.article7,
        content: 'تفاصيل كاملة حول أحدث الاكتشافات الفضائية...',
      ),
      Articale(
        title: 'نصائح لتحسين إنتاجيتك اليومية',
        shortDescription: 'دليل عملي لزيادة فعاليتك وإنجاز مهامك بكفاءة أكبر.',
        imageUrl: AppAssetImages.article9,
        content: 'خطوات ونصائح فعالة لتعزيز الإنتاجية اليومية...',
      ),
      Articale(
        title: 'أفضل الوصفات لتحضير قهوة منزلية مميزة',
        shortDescription:
            'استمتع بتجربة قهوة احترافية في منزلك مع هذه الوصفات السهلة.',
        imageUrl: AppAssetImages.article10,
        content: 'مجموعة من أفضل الوصفات لتحضير قهوة منزلية لذيذة...',
      ),
    ];
  }

  void addArticale(Articale articale) {
    final updatedArticales = List.from(state.articales)..add(articale);
    // emit(ArticaleState(articales: updatedArticales));
  }

  void deleteArticale(Articale articale) {
    final updatedArticales = List.from(state.articales)..remove(articale);
    //  emit(ArticaleState(articales: updatedArticales));
  }

  void updateArticale(Articale updatedArticale) {
    final updatedArticales =
        state.articales.map((articale) {
          return articale.title == updatedArticale.title
              ? updatedArticale
              : articale;
        }).toList();
    emit(ArticaleState(articales: updatedArticales));
  }
}
