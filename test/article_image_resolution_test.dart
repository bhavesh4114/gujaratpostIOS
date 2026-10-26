import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/models/article.dart';
import 'package:gujarat_post_flutter/models/advertisement.dart';

void main() {
  group('Article and Advertisement Image Resolution', () {
    test('Cloudinary .avif image is converted to .jpg with f_jpg,q_auto transformation', () {
      const rawAvif =
          'https://res.cloudinary.com/kohg6a5j/image/upload/v1792991479/gujarat-post/MODI_K_CON_1792991477773_8227_uh9nja.avif';

      final resolved = Article.resolveImageUrl(rawAvif);

      expect(resolved, isNotNull);
      expect(resolved, contains('/image/upload/f_jpg,q_auto/'));
      expect(resolved!.endsWith('.jpg'), isTrue);
      expect(resolved, isNot(contains('.avif')));
    });

    test('Article.fromJson parses live API response with Cloudinary AVIF and produces working JPEG URL', () {
      final json = {
        'id': 'art-modi-test',
        'titleGu': 'ખડગેએ કહ્યું મોદીનો બાપ પણ જેલમાં જશે...',
        'slug': 'modi-kharge-case',
        'image':
            'https://res.cloudinary.com/kohg6a5j/image/upload/v1792991479/gujarat-post/MODI_K_CON_1792991477773_8227_uh9nja.avif',
        'category': 'National',
        'categorySlug': 'national',
      };

      final article = Article.fromJson(json);

      expect(article.displayImageUrl, contains('f_jpg,q_auto'));
      expect(article.displayImageUrl.endsWith('.jpg'), isTrue);
      expect(article.displayImageUrl, isNot(contains('.avif')));
    });

    test('Advertisement.resolvedImageUrl converts Cloudinary AVIF to JPEG', () {
      const ad = Advertisement(
        id: 'ad-1',
        image1:
            'https://res.cloudinary.com/kohg6a5j/image/upload/v1792945002/gujarat-post/ad_banner_1.avif',
      );

      expect(ad.resolvedImageUrl, contains('f_jpg,q_auto'));
      expect(ad.resolvedImageUrl!.endsWith('.jpg'), isTrue);
    });
  });
}
