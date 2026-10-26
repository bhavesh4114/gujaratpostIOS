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
  final bool isListOnly;

  const CategorySectionGroup({
    required this.title,
    required this.slug,
    required this.articles,
    this.isCarousel = false,
    this.isListOnly = false,
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
      imageUrl: 'https://gujaratpost.in/news/crime.jpg',
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
      imageUrl: 'https://gujaratpost.in/news/crime.jpg',
      category: 'National',
      categorySlug: 'national',
      timeAgo: '1 day ago',
      authorName: 'ક્રાઇમ બ્યુરો',
    ),
    const Article(
      id: 'sc-cjp-bail-national-2',
      title:
          'દિલ્હી સેસન્સ કોર્ટે CJP નેતાઓ સૌરવ દાસ અને આશુતોષ રાંકાને જામીન આપ્યા',
      slug: 'delhi-sem-court-cjp-bail',
      content:
          '<p>દિલ્હી કોર્ટે કથિત કેસમાં સંડોવાયેલા નેતાઓ સૌરવ દાસ અને આશુતોષ રાંકાને શરતી જામીન મંજૂર કર્યા છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/court.jpg',
      category: 'National',
      categorySlug: 'national',
      timeAgo: '2 hours ago',
      authorName: 'રાષ્ટ્રીય બ્યુરો',
    ),
    const Article(
      id: 'chennai-fire-accident-national-3',
      title:
          'ચેન્નાઈમાં ભીષણ આગ: એપાર્ટમેન્ટ-કાર બળીને ખાખ, 8 લોકોના મોત',
      slug: 'chennai-fire-accident',
      content:
          '<p>ચેન્નાઈમાં એક બહુમાળી રહેણાંક ઇમારતમાં આગ ફાટી નીકળતાં 8 લોકોનાં ગૂંગળામણથી મોત નીપજ્યાં હતાં.</p>',
      imageUrl: 'https://gujaratpost.in/news/fire.jpg',
      category: 'National',
      categorySlug: 'national',
      timeAgo: '5 hours ago',
      authorName: 'રાષ્ટ્રીય બ્યુરો',
    ),
    const Article(
      id: 'delhi-air-pollution-national-4',
      title:
          'દિલ્હીમાં પ્રદૂષણનું ગંભીર સંકટ: AQI 400 ને પાર, શાળાઓમાં સાવચેતીનાં પગલાં',
      slug: 'delhi-air-pollution',
      content:
          '<p>રાજધાની દિલ્હી અને તેની આસપાસના વિસ્તારોમાં વાયુ પ્રદૂષણ ખૂબ જ ગંભીર શ્રેણીમાં પહોંચી ગયું છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/delhi.jpg',
      category: 'National',
      categorySlug: 'national',
      timeAgo: '1 day ago',
      authorName: 'દિલ્હી બ્યુરો',
    ),
    const Article(
      id: 'isro-mission-national-5',
      title:
          'ઇસરોનું નવું સેટેલાઇટ મિશન સફળ: અંતરિક્ષમાં ભારતે વધુ એક સીમાચિહ્ન હાંસલ કર્યું',
      slug: 'isro-space-mission-success',
      content:
          '<p>ભારતીય અવકાશ સંશોધન સંસ્થા (ISRO) એ આંધ્રપ્રદેશના શ્રીહરિકોટાથી વધુ એક સેટેલાઇટ સફળતાપૂર્વક લોન્ચ કર્યો છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/isro.jpg',
      category: 'National',
      categorySlug: 'national',
      timeAgo: '1 day ago',
      authorName: 'વિજ્ઞાન બ્યુરો',
    ),
    const Article(
      id: 'railway-festival-special-national-6',
      title:
          'તહેવારો નિમિત્તે ભારતીય રેલવે દ્વારા 100 થી વધુ વિશેષ ટ્રેનો દોડાવવાનો નિર્ણય',
      slug: 'railway-special-trains-festivals',
      content:
          '<p>દિવાળી અને છઠ પૂજા દરમિયાન મુસાફરોની વધારાની ભીડને ધ્યાનમાં રાખીને રેલવે પ્રશાસને વિશેષ વ્યવસ્થા કરી છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/train.jpg',
      category: 'National',
      categorySlug: 'national',
      timeAgo: '2 days ago',
      authorName: 'રેલવે બ્યુરો',
    ),
    const Article(
      id: 'adalaj-car-accident-3',
      title:
          'અડાલજ પાસે કાર પલટી જતાં મેડિકલ વિદ્યાર્થિની સહિત 3 લોકોનાં મોત, ભરૂચ એક્સપ્રેસ-વે પર મૂળ ...',
      slug: 'adalaj-accident',
      content:
          '<p>ગાંધીનગર નજીક અડાલજ ત્રિમંદિર પાસે વહેલી સવારે કાર ડિવાઈડર સાથે અથડાઈને પલટી મારી ગઈ હતી. આ ગમખ્વાર અકસ્માતમાં મેડિકલ વિદ્યાર્થિની સહિત 3 લોકોનાં ઘટનાસ્થળે જ કમકમાટીભર્યા મોત નીપજ્યાં હતાં.</p>',
      imageUrl: 'https://gujaratpost.in/news/accident.jpg',
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
      imageUrl: 'https://gujaratpost.in/news/crime.jpg',
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
      imageUrl: 'https://gujaratpost.in/news/train1.jpg',
      category: 'Gujarat',
      categorySlug: 'gujarat',
      timeAgo: '2 days ago',
      authorName: 'રેલવે બ્યુરો',
    ),
    const Article(
      id: 'gallery-nia-sharma-1',
      title: 'ટીવી ક્વીન નિયા શર્માએ પોતાની બોલ્ડ સ્ટાઇલ અને લુકથી ચાહકોના હોશ ઉડાવી દીધા',
      slug: 'nia-sharma-bold-look-photos',
      content: '<p>ટીવી એક્ટ્રેસ નિયા શર્મા પોતાની ગ્લેમરસ અને બોલ્ડ અદાઓ માટે હંમેશા ચર્ચામાં રહે છે. તાજેતરમાં તેના ફોટોશૂટની તસવીરો સોશિયલ મીડિયા પર વાયરલ થઈ છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/entertainment.jpg',
      category: 'ફોટો ગેલેરી',
      categorySlug: 'gallery',
      timeAgo: '1 day ago',
      authorName: 'ફોટો ડેસ્ક',
    ),
    const Article(
      id: 'gallery-raveena-tandon-2',
      title: 'બ્લેક મીની ડ્રેસમાં રવિના ટંડનનો સ્ટાઇલિશ લૂક',
      slug: 'raveena-tandon-black-mini-dress',
      content: '<p>બોલીવુડ એક્ટ્રેસ રવિના ટંડનનો અંદાજ આજે પણ ફેન્સને દિવાના બનાવી દે છે. તેના નવા સ્ટાઇલિશ આઉટફિટના ફોટોઝ ખૂબ પસંદ કરવામાં આવી રહ્યા છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/court.jpg',
      category: 'ફોટો ગેલેરી',
      categorySlug: 'gallery',
      timeAgo: '2 days ago',
      authorName: 'ફોટો ડેસ્ક',
    ),
    const Article(
      id: 'gallery-punit-pathak-3',
      title: 'કોરિયોગ્રાફર પુનિત પાઠક તેની પત્ની નિધિ સાથે રોમાન્સ કરતો જોવા મળ્યો',
      slug: 'punit-pathak-nidhi-vacation-photos',
      content: '<p>જાણીતા કોરિયોગ્રાફર પુનિત પાઠકે પત્ની સાથે વેકેશનની સુંદર તસવીરો શેર કરી છે, જે ફેન્સનું દિલ જીતી રહી છે.</p>',
      imageUrl: 'https://gujaratpost.in/news/fire.jpg',
      category: 'ફોટો ગેલેરી',
      categorySlug: 'gallery',
      timeAgo: '2 days ago',
      authorName: 'ફોટો ડેસ્ક',
    ),
    const Article(
      id: 'gallery-avneet-kaur-4',
      title: 'અવનીત કૌરના ગ્લેમરસ ફોટો સોશિયલ મીડિયા પર વાયરલ',
      slug: 'avneet-kaur-glamorous-photos',
      content: '<p>અવનીત કૌરના લેટેસ્ટ ફોટોશૂટે ઇન્ટરનેટ પર ધમાલ મચાવી દીધી છે. ફેન્સ તેના લુકના વખાણ કરતાં થાકતા નથી.</p>',
      imageUrl: 'https://gujaratpost.in/news/delhi.jpg',
      category: 'ફોટો ગેલેરી',
      categorySlug: 'gallery',
      timeAgo: '3 days ago',
      authorName: 'ફોટો ડેસ્ક',
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
    NewsCategory(id: 'cat-factcheck', name: 'Fact Check', slug: 'fact-check'),
    NewsCategory(id: 'cat-technology', name: 'Technology', slug: 'technology'),
    NewsCategory(id: 'cat-sports', name: 'Sports', slug: 'sports'),
    NewsCategory(id: 'cat-business', name: 'Business', slug: 'business'),
  ];

  static Future<List<Article>> fetchArticles({
    String? categorySlug,
    String? query,
    int page = 1,
    int limit = 50,
  }) async {
    if (categorySlug == 'videos') {
      return fetchVideos();
    }
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

  static final List<Article> fallbackVideoArticles = [
    const Article(
      id: 'h_jQNj_oKcI',
      title:
          'હથિયારો જોઇને સૌ કોઇ ચોંકી ગયા, ધારાસભ્ય રાજા ભૈયાનું શક્તિ પ્રદર્શન #breakingnews',
      slug: 'h_jQNj_oKcI',
      imageUrl: 'https://img.youtube.com/vi/h_jQNj_oKcI/hqdefault.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=h_jQNj_oKcI',
      category: 'Videos',
      categorySlug: 'videos',
      timeAgo: 'Just now',
    ),
    const Article(
      id: 'vrH0BAxlgxg',
      title: 'વિજયાદશમી પર શસ્ત્ર પૂજા વખતે IPS અધિકારી અંકિતા શર્માનો આક્રમક અંદાજ',
      slug: 'vrH0BAxlgxg',
      imageUrl: 'https://img.youtube.com/vi/vrH0BAxlgxg/hqdefault.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=vrH0BAxlgxg',
      category: 'Videos',
      categorySlug: 'videos',
      timeAgo: 'Just now',
    ),
    const Article(
      id: '5SAI3h1tiKo',
      title: 'ગાંધીનગરમાં ભાજપનો ભવ્ય વિજય #bjp #gandhinagar',
      slug: '5SAI3h1tiKo',
      imageUrl: 'https://img.youtube.com/vi/5SAI3h1tiKo/hqdefault.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=5SAI3h1tiKo',
      category: 'Videos',
      categorySlug: 'videos',
      timeAgo: 'Just now',
    ),
    const Article(
      id: 'fYiCcLj1lNg',
      title: 'પાયલોટ સ્મિત સાથે PM મોદીની વાતચીત #breakingnews',
      slug: 'fYiCcLj1lNg',
      imageUrl: 'https://img.youtube.com/vi/fYiCcLj1lNg/hqdefault.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=fYiCcLj1lNg',
      category: 'Videos',
      categorySlug: 'videos',
      timeAgo: 'Just now',
    ),
    const Article(
      id: '1O10a3Q5oX0',
      title: 'ACB એ એક સાથે ત્રણને ઝડપી લીધા, રૂ. 2,50,000 ની લાંચનો પર્દાફાશ #acb',
      slug: '1O10a3Q5oX0',
      imageUrl: 'https://img.youtube.com/vi/1O10a3Q5oX0/hqdefault.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=1O10a3Q5oX0',
      category: 'Videos',
      categorySlug: 'videos',
      timeAgo: 'Just now',
    ),
    const Article(
      id: 'LB4Q2gMXPfk',
      title: 'સુરેન્દ્રનગર IPS ની બદલી પર લોકો રડી પડ્યા #ips #surendranagar',
      slug: 'LB4Q2gMXPfk',
      imageUrl: 'https://img.youtube.com/vi/LB4Q2gMXPfk/hqdefault.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=LB4Q2gMXPfk',
      category: 'Videos',
      categorySlug: 'videos',
      timeAgo: 'Just now',
    ),
    const Article(
      id: 'WB-S-7YzYlg',
      title:
          'ખતરનાક દુર્ઘટના, પ્લેન બિલ્ડીંગ સાથે અથડાતા બંને પાયલોટના મોત #internationalnews',
      slug: 'WB-S-7YzYlg',
      imageUrl: 'https://img.youtube.com/vi/WB-S-7YzYlg/hqdefault.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=WB-S-7YzYlg',
      category: 'Videos',
      categorySlug: 'videos',
      timeAgo: 'Just now',
    ),
  ];

  /// Loads the YouTube feed used by the app's videos section.
  static Future<List<Article>> fetchVideos() async {
    try {
      final uri = Uri.parse('https://guj-stg.gujaratpost.in/api/youtube-videos');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final rawVideos = decoded is Map<String, dynamic>
            ? decoded['data']
            : null;
        if (rawVideos is List) {
          final list = rawVideos
              .whereType<Map<String, dynamic>>()
              .map((video) {
                final id = (video['youtubeId'] ?? video['id'] ?? '').toString();
                final title = (video['titleGu'] ?? video['title'] ?? '').toString();
                final publishedAt = DateTime.tryParse(
                  (video['publishedAt'] ?? '').toString(),
                );
                final videoUrl = (video['videoUrl'] != null && video['videoUrl'].toString().isNotEmpty)
                    ? video['videoUrl'].toString()
                    : (id.isNotEmpty ? 'https://www.youtube.com/watch?v=$id' : '');
                final thumb = (video['thumbnail'] != null && video['thumbnail'].toString().isNotEmpty)
                    ? video['thumbnail'].toString()
                    : (id.isNotEmpty ? 'https://img.youtube.com/vi/$id/hqdefault.jpg' : '');
                return Article(
                  id: id,
                  title: title,
                  slug: id,
                  excerpt: (video['description'] ?? '').toString(),
                  imageUrl: thumb,
                  videoUrl: videoUrl,
                  category: 'Videos',
                  categorySlug: 'videos',
                  timeAgo: publishedAt == null
                      ? 'Just now'
                      : _timeAgo(publishedAt),
                  publishedAt: publishedAt,
                );
              })
              .where((article) => article.id.isNotEmpty || (article.videoUrl != null && article.videoUrl!.isNotEmpty))
              .toList();
          if (list.isNotEmpty) {
            return list;
          }
        }
      }
    } catch (_) {}
    return fallbackVideoArticles;
  }

  static String _timeAgo(DateTime date) {
    final elapsed = DateTime.now().difference(date);
    if (elapsed.inDays > 0) return '${elapsed.inDays} days ago';
    if (elapsed.inHours > 0) return '${elapsed.inHours} hours ago';
    if (elapsed.inMinutes > 0) return '${elapsed.inMinutes} minutes ago';
    return 'Just now';
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

  /// Fetches single article details by ID or Slug from https://api.gujaratpost.in/api/public/articles/{slugOrId}
  static Future<Article?> fetchArticleDetail(String slugOrId) async {
    if (slugOrId.trim().isEmpty) return null;
    try {
      final uri = Uri.parse('$baseUrl/articles/${Uri.encodeComponent(slugOrId)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded['success'] == true && decoded['data'] != null) {
          final articleMap = decoded['data']['article'] ?? decoded['data'];
          if (articleMap is Map<String, dynamic>) {
            return Article.fromJson(articleMap);
          }
        }
      }
    } catch (_) {}
    return null;
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
      {'slug': 'latest-news', 'title': 'Latest News', 'isCarousel': false, 'isListOnly': false},
      {'slug': 'gujarat', 'title': 'Gujarat', 'isCarousel': false, 'isListOnly': false},
      {'slug': 'national', 'title': 'National', 'isCarousel': true, 'isListOnly': false},
      {'slug': 'world', 'title': 'World', 'isCarousel': false, 'isListOnly': false},
      {'slug': 'politics', 'title': 'Politics', 'isCarousel': false, 'isListOnly': false},
      {'slug': 'crime', 'title': 'Crime', 'isCarousel': false, 'isListOnly': false},
      {'slug': 'health', 'title': 'Health', 'isCarousel': false, 'isListOnly': false},
      {'slug': 'entertainment', 'title': 'Entertainment/Life Style', 'isCarousel': true, 'isListOnly': false},
      {'slug': 'fact-check', 'title': 'Fact Check', 'isCarousel': false, 'isListOnly': true},
      {'slug': 'technology', 'title': 'Technology', 'isCarousel': false, 'isListOnly': true},
    ];

    final groups = <CategorySectionGroup>[];

    for (int i = 0; i < sectionsDef.length; i++) {
      final item = sectionsDef[i];
      final slug = item['slug'] as String;
      final title = item['title'] as String;
      final isCarousel = item['isCarousel'] as bool;
      final isListOnly = item['isListOnly'] as bool;

      List<Article> matched = [];
      if (slug == 'latest-news') {
        matched = allArticles;
      } else if (slug == 'fact-check') {
        matched = allArticles.where((a) {
          final cat = (a.categorySlug ?? a.category ?? '').toLowerCase();
          final t = a.title.toLowerCase();
          return cat.contains('fact') || t.contains('fact') || a.title.contains('ફેક્ટ') || a.title.contains('તપાસ');
        }).toList();
        if (matched.isEmpty) {
          final offset = (i * 2) % allArticles.length;
          matched = allArticles.skip(offset).toList();
        }
      } else if (slug == 'technology') {
        matched = allArticles.where((a) {
          final cat = (a.categorySlug ?? a.category ?? '').toLowerCase();
          final t = a.title.toLowerCase();
          return cat.contains('tech') || t.contains('tech') || a.title.contains('ટેક');
        }).toList();
        if (matched.isEmpty) {
          final offset = (i * 2) % allArticles.length;
          matched = allArticles.skip(offset).toList();
        }
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

        // Guarantee at least 6 articles (1 main hero + 5 sub-articles, or 6 carousel items)
        if (matched.length < 6) {
          final additional = allArticles
              .where((a) => !matched.any((m) => m.id == a.id))
              .take(6 - matched.length);
          matched = [...matched, ...additional];
        }
      }

      if (matched.isNotEmpty) {
        groups.add(
          CategorySectionGroup(
            title: title,
            slug: slug,
            articles: matched,
            isCarousel: isCarousel,
            isListOnly: isListOnly,
          ),
        );
      }
    }

    return groups;
  }
}
