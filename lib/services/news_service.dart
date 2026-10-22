import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../models/advertisement.dart';

class NewsCategory {
  final String id;
  final String name;
  final String slug;

  const NewsCategory({
    required this.id,
    required this.name,
    required this.slug,
  });
}

class CategorySectionGroup {
  final String title;
  final String slug;
  final List<Article> articles;
  final bool isCarousel;

  const CategorySectionGroup({
    required this.title,
    required this.slug,
    required this.articles,
    this.isCarousel = false,
  });
}

class NewsService {
  static const String baseUrl = 'https://api.gujaratpost.in/api/public';

  // Exact fallback articles matching screenshot from Gujarat Post app
  static final List<Article> fallbackArticles = [
    Article(
      id: 'tiger-shroff-firing-1',
      title:
          'ટાઈગર શ્રોફ પર અઠવાડિયા પહેલાં જ ચાલવાની હતી ગોળી, આ એક કારણથી બચી ગયો હતો જીવ',
      slug: 'tiger-shroff-firing',
      content:
          '<p>ટાઈગર શ્રોફ ફાયરિંગ કેસમાં પોલીસે અત્યાર સુધીમાં 6 લોકોની ધરપકડ કરી\n11 ઓક્ટોબરે ફૂટબોલ ગ્રાઉન્ડ પર ત્રણ શંકાસ્પદ શખ્સો જોવા મળ્યાં હતા\n\nમુંબઈ: ટાઈગર શ્રોફ પર ગોળીબાર કરનારા શૂટરો એક અઠવાડિયા પહેલાં પણ તેને મારવા માટે પહોંચ્યાં હતા. પરંતુ તે દિવસે ટાઈગર ફૂટબોલ રમવા ગયો ન હતો. સીસીટીવી ફૂટેજ અને કોલ ડેટા રેકોર્ડ્સ પરથી આ માહિતી સામે આવી છે. ઈન્ડિયન એક્સપ્રેસના અહેવાલ મુજબ, ટાઈગર જે ફૂટબોલ ગ્રાઉન્ડ પર સામાન્ય રીતે રવિવારની સાંજે રમવા જાય છે, ત્યાં 11 ઓક્ટોબરે પણ ત્રણ શંકાસ્પદ શખ્સો જોવા મળ્યાં હતા. તેના લગભગ એક અઠવાડિયા પછી એ જ ત્રણ લોકો ફરી તે જ સ્થળે પહોંચ્યાં હતા. આ વખતે ટાઈગર મેદાનમાં હાજર હતો અને જેવો તે પોતાની બીએમડબલ્યુ કારમાં સવાર થઈને બહાર નીકળ્યો, તેના પર અંધાધૂંધ ગોળીબાર કરી દેવાયો હતો. ઈન્ડિયન એક્સપ્રેસ સાથેની વાતચીતમાં ટાઈગરના એક મિત્રએ જણાવ્યું હતું કે મુંબઈના જુહુ વિસ્તારમાં આવેલા પુષ્પા નરસી પાર્કના ફૂટબોલ ગ્રાઉન્ડમાં ટાઈગર સામાન્ય રીતે દર રવિવારે સાંજે 5 થી 7 વાગ્યા સુધી ફૂટબોલ રમે છે. એવું ભાગ્યે જ બને છે કે તે રવિવારની મેચ ચૂકી જાય.</p><p>હુમલાખોરોને ટાઈગરના આ રોજીંદા ક્રમની સંપૂર્ણ માહિતી હતી. 11 ઓક્ટોબરે ત્રણેય શંકાસ્પદો આ ફૂટબોલ ગ્રાઉન્ડની આસપાસ જોવા મળ્યાં હતા. સીસીટીવી અને કોલ ડેટા રેકોર્ડ્સ પરથી પોલીસને જાણવા મળ્યું કે તેઓ ત્યાં થોડા સમય માટે હાજર હતા. પોલીસને આશંકા છે કે તે દિવસે પણ તેમનો પ્લાન ટાઈગરની હત્યાનો હતો. પરંતુ તે રવિવારે ટાઈગર ફૂટબોલ રમવા ગયો જ ન હતો.</p><p>તેના એક અઠવાડિયા બાદ 18 ઓક્ટોબરની તારીખ આવી. આ વખતે ત્રણેય શંકાસ્પદો ફરી તે જ જગ્યાએ પહોંચ્યાં હતા. સીસીટીવી મુજબ, તેઓ સાંજે લગભગ સાડા ચાર વાગ્યાથી પાર્કની આસપાસ આંટાફેરા કરી રહ્યાં હતા. વારંવાર ફૂટબોલ ગ્રાઉન્ડના દરવાજા સુધી જતા, અંદર નજર નાખતા અને ટાઈગરના આવવાની રાહ જોતા દેખાયા હતા. પોલીસને શંકા છે કે અન્ય કેટલાક લોકો પણ ટાઈગરની મૂવમેન્ટ પર નજર રાખી રહ્યાં હતા અને યોગ્ય સમયે શૂટરોને માહિતી આપી રહ્યાં હતા.</p><p>સાંજે લગભગ 7 વાગ્યે ટાઈગર મેદાનમાંથી બહાર નીકળ્યો. તે પોતાની બીએમડબલ્યુ કારમાં બેઠો હતો અને કાર જેવી ગેટમાંથી બહાર આવી કે શૂટરોએ ફાયરિંગ શરૂ કરી દીધું. કાર બુલેટપ્રૂફ હોવાને કારણે ટાઈગરનો આબાદ બચાવ થયો હતો.</p><p>પોલીસ સૂત્રોના જણાવ્યા મુજબ, આરોપીઓ ગુનો આચર્યા બાદ મુંબઈથી ભાગીને નેપાળ જવાના હતા.</p><p>આ તરફ, આ કેસમાં વધુ એક ધરપકડ હરિયાણાના સોનીપતથી કરવામાં આવી છે. સમીર નામના શખ્સે શૂટરોનો સંપર્ક અનિલ પંડિત સાથે કરાવ્યો હતો. પંડિત લોરેન્સ બિશ્નોઈ ગેંગ સાથે જોડાયેલો છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/tiger1.jpg',
      category: 'Entertainment',
      categorySlug: 'entertainment',
      timeAgo: '1 day ago',
      authorName: 'ગુજરાત પોસ્ટ બ્યુરો',
      publishedAt: DateTime(2026, 10, 20, 22, 37),
    ),
    const Article(
      id: 'tiger-shroff-hand-burn-rel-1',
      title:
          'ફાયરિંગમાં ગોળી નથી વાગી છતાં અભિનેતા ટાઈગરનો હાથ કેવી રીતે દાઝ્યો,જાણો ગન પા...',
      slug: 'tiger-shroff-hand-burn',
      content: '<p>ફાયરિંગની ઘટનામાં ગોળી વાગવાથી બચી ગયેલા ટાઈગર શ્રોફને હાથમાં ગન પાઉડર અને તણખાને કારણે ઈજા થઈ હતી.</p>',
      imageUrl: 'https://gujaratpost.in/news/tiger1.jpg',
      category: 'Entertainment',
      categorySlug: 'entertainment',
      timeAgo: '2 days ago',
    ),
    const Article(
      id: 'tiger-shroff-shooter-rehan-rel-2',
      title:
          'ટાઈગર શ્રોફ ફાયરિંગ કેસ: જાણો- સોનીપતનો શાર્પ શૂટર રેહાન કેવી રીતે બન્યો ગુનેગાર...',
      slug: 'tiger-shroff-shooter-rehan',
      content: '<p>સોનીપતના રહેવાસી શાર્પ શૂટર રેહાન સામે અગાઉ પણ અનેક ગુના નોંધાઈ ચૂક્યા છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/tiger1.jpg',
      category: 'Crime',
      categorySlug: 'crime',
      timeAgo: '2 days ago',
    ),
    const Article(
      id: 'shiva-sharma-case-2',
      title:
          'શિવા શર્મા હત્યા કેસ: મોડેલ શ્રદ્ધા દુબેની નાગપુરથી ધરપકડ, બહેન અને ડ્રાઈવર પણ ઝડપાયા',
      slug: 'shiva-sharma-case',
      content:
          '<p>ચકચારી શિવા શર્મા હત્યા કેસમાં પોલીસને મોટી સફળતા મળી છે. મુખ્ય આરોપી મોડેલ શ્રદ્ધા દુબે અને તેની બહેન તથા ડ્રાઈવરની નાગપુરથી ધરપકડ કરવામાં આવી છે.</p><p>પોલીસ કમિશનરે જણાવ્યું કે ત્રણેય આરોપીઓ ભાગી છૂટવાની ફિરાકમાં હતા ત્યારે ટેકનિકલ સર્વેલન્સની મદદથી તેમને ઝડપી લેવામાં આવ્યા છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/shiva-case.jpg',
      category: 'National',
      categorySlug: 'national',
      timeAgo: '1 day ago',
      authorName: 'ક્રાઇમ બ્યુરો',
    ),
    const Article(
      id: 'adalaj-car-accident-3',
      title:
          'અડાલજ પાસે કાર પલટી જતાં મેડિકલ વિદ્યાર્થિની સહિત 3 લોકોનાં મોત, ભરૂચ એક્સપ્રેસ-વે પર મૂળ ...',
      slug: 'adalaj-accident',
      content:
          '<p>ગાંધીનગર નજીક અડાલજ ત્રિમંદિર પાસે વહેલી સવારે કાર ડિવાઈડર સાથે અથડાઈને પલટી મારી ગઈ હતી. આ ગમખ્વાર અકસ્માતમાં મેડિકલ વિદ્યાર્થિની સહિત 3 લોકોનાં ઘટનાસ્થળે જ કમકમાટીભર્યા મોત નીપજ્યાં હતાં.</p>',
      imageUrl: 'https://gujaratpost.in/news/police.jpg',
      category: 'Gujarat',
      categorySlug: 'gujarat',
      timeAgo: '1 day ago',
      authorName: 'ગાંધીનગર બ્યુરો',
    ),
    const Article(
      id: 'ahmedabad-murder-4',
      title:
          'અમદાવાદમાં વૃદ્ધાની ક્રૂર રીતે હત્યા.. લાશ બેગમાં ન આવતા ફ્લેટમાં મૂકીને હત્યારો ફરાર, 3 દિવસ બા...',
      slug: 'ahmedabad-murder',
      content:
          '<p>અમદાવાદના બોપલ વિસ્તારમાં 72 વર્ષીય વૃદ્ધાની હત્યાનો ચકચારી બનાવ સામે આવ્યો છે. લૂંટના ઇરાદે ઘૂસેલા હત્યારાએ વૃદ્ધાનું ગળું દબાવી હત્યા કરી હતી અને લાશને બેગમાં પેક કરવાનો પ્રયાસ કર્યો હતો.</p>',
      imageUrl: 'https://gujaratpost.in/news/building.jpg',
      category: 'Gujarat',
      categorySlug: 'gujarat',
      timeAgo: '2 days ago',
      authorName: 'અમદાવાદ બ્યુરો',
    ),
    const Article(
      id: 'aniruddh-sharma-statement-5',
      title:
          'ફાયરિંગમાં ગોળી નથી વાગી છતાં અનિરુદ્ધ શર્માએ જણાવ્યું કે હું ડરી ગયો નહોતો',
      slug: 'aniruddh-statement',
      content:
          '<p>મુંબઈમાં થયેલા શૂટઆઉટની ઘટના અંગે પ્રત્યક્ષદર્શી અનિરુદ્ધ શર્માએ નિવેદન આપ્યું છે. તેમણે કહ્યું કે અવાજ સાંભળીને સૌ દોડ્યા હતા પરંતુ તેમણે તરત જ પોલીસ કંટ્રોલ રૂમમાં ફોન કરીને જાણ કરી હતી.</p>',
      imageUrl: 'https://gujaratpost.in/news/tiger1.jpg',
      category: 'Entertainment',
      categorySlug: 'entertainment',
      timeAgo: '2 days ago',
      authorName: 'મનોરંજન ડેસ્ક',
    ),
    const Article(
      id: 'sabarmati-vande-bharat-6',
      title:
          'સાબરમતી ખાતે વંદે ભારત ટ્રેન મેન્ટેનન્સ હબ બનશે, અમદાવાદ રેલવે ડિવિઝન રૂ. 307 કરોડનો પ્રોજેક્ટ મંજૂર',
      slug: 'sabarmati-train',
      content:
          '<p>પશ્ચિમ રેલવે દ્વારા સાબરમતી ખાતે અદ્યતન વંદે ભારત ટ્રેન મેન્ટેનન્સ ડેપો બનાવવાની જાહેરાત કરવામાં આવી છે. આ પ્રોજેક્ટ પાછળ રૂ. 307 કરોડનો ખર્ચ કરવામાં આવશે.</p>',
      imageUrl: 'https://gujaratpost.in/news/vande-bharat.jpg',
      category: 'Gujarat',
      categorySlug: 'gujarat',
      timeAgo: '2 days ago',
      authorName: 'રેલવે બ્યુરો',
    ),
  ];

  static final List<NewsCategory> defaultCategories = const [
    NewsCategory(id: 'all', name: 'Home', slug: 'all'),
    NewsCategory(id: 'cat-videos', name: 'Videos', slug: 'videos'),
    NewsCategory(id: 'cat-gujarat', name: 'Gujarat', slug: 'gujarat'),
    NewsCategory(id: 'cat-national', name: 'National', slug: 'national'),
    NewsCategory(id: 'cat-world', name: 'World', slug: 'world'),
    NewsCategory(id: 'cat-politics', name: 'Politics', slug: 'politics'),
    NewsCategory(id: 'cat-crime', name: 'Crime', slug: 'crime'),
    NewsCategory(id: 'cat-health', name: 'Health', slug: 'health'),
    NewsCategory(id: 'cat-entertainment', name: 'Entertainment', slug: 'entertainment'),
    NewsCategory(id: 'cat-technology', name: 'Technology', slug: 'technology'),
    NewsCategory(id: 'cat-sports', name: 'Sports', slug: 'sports'),
    NewsCategory(id: 'cat-business', name: 'Business', slug: 'business'),
  ];

  static Future<List<Article>> fetchArticles({
    String? categorySlug,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (categorySlug != null && categorySlug != 'all' && categorySlug.isNotEmpty) {
        queryParams['categorySlug'] = categorySlug;
      }
      if (query != null && query.trim().isNotEmpty) {
        queryParams['query'] = query.trim();
      }

      final uri = Uri.parse('$baseUrl/articles').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded['data'] != null && decoded['data']['articles'] != null) {
          final list = (decoded['data']['articles'] as List)
              .map((e) => Article.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) {
            return list;
          }
        }
      }
    } catch (_) {}
    return fallbackArticles;
  }

  static Future<List<Article>> fetchBreakingNews() async {
    try {
      final uri = Uri.parse('$baseUrl/articles?isBreaking=true&limit=5');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded['data'] != null && decoded['data']['articles'] != null) {
          final list = (decoded['data']['articles'] as List)
              .map((e) => Article.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}
    return [
      fallbackArticles.first,
    ];
  }

  /// Fetches active advertisements from https://api.gujaratpost.in/api/public/ads
  static Future<List<Advertisement>> fetchAds() async {
    try {
      final uri = Uri.parse('$baseUrl/ads');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded['data'] != null && decoded['data']['ads'] != null) {
          final list = (decoded['data']['ads'] as List)
              .map((e) => Advertisement.fromJson(e as Map<String, dynamic>))
              .where((a) =>
                  a.isActive &&
                  a.resolvedImageUrl != null &&
                  a.resolvedImageUrl!.isNotEmpty)
              .toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}
    return [];
  }

  /// Builds home categorized section groups matching Android HomeFragment.kt
  static List<CategorySectionGroup> buildHomeGroups(List<Article> allArticles) {
    if (allArticles.isEmpty) return [];

    final sectionsDef = [
      {'slug': 'latest-news', 'title': 'Latest News', 'isCarousel': false},
      {'slug': 'gujarat', 'title': 'Gujarat', 'isCarousel': false},
      {'slug': 'national', 'title': 'National', 'isCarousel': true},
      {'slug': 'world', 'title': 'World', 'isCarousel': false},
      {'slug': 'politics', 'title': 'Politics', 'isCarousel': false},
      {'slug': 'crime', 'title': 'Crime', 'isCarousel': false},
      {'slug': 'health', 'title': 'Health', 'isCarousel': false},
      {'slug': 'entertainment', 'title': 'Entertainment/Life Style', 'isCarousel': true},
      {'slug': 'technology', 'title': 'Technology', 'isCarousel': false},
    ];

    final groups = <CategorySectionGroup>[];

    for (int i = 0; i < sectionsDef.length; i++) {
      final item = sectionsDef[i];
      final slug = item['slug'] as String;
      final title = item['title'] as String;
      final isCarousel = item['isCarousel'] as bool;

      List<Article> matched = [];
      if (slug == 'latest-news') {
        matched = allArticles;
      } else {
        matched = allArticles.where((a) {
          final cat = (a.categorySlug ?? a.category ?? '').toLowerCase();
          return cat.contains(slug) || slug.contains(cat);
        }).toList();

        // If not enough matched articles, create offset subset from allArticles so section is populated
        if (matched.isEmpty) {
          final offset = (i * 2) % allArticles.length;
          matched = allArticles.skip(offset).toList();
          if (matched.isEmpty) matched = allArticles;
        }
      }

      if (matched.isNotEmpty) {
        groups.add(
          CategorySectionGroup(
            title: title,
            slug: slug,
            articles: matched,
            isCarousel: isCarousel,
          ),
        );
      }
    }

    return groups;
  }
}
