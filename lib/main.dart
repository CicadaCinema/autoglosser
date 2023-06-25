import 'package:autoglosser/src/widgets/text_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/data_structures.dart';
import 'src/widgets/map_display.dart';
import 'src/widgets/settings_display.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp>
    with SingleTickerProviderStateMixin {
  final fullText =
      FullText.fromString('''老子曰：治身，太上養神，其次養形，神清意平，百節皆寧，養生之本也，肥肌膚，充腹腸，供嗜欲，養生之末也。
治國，太上養化，其次正法，民交讓爭處卑，財利爭受少，事力爭就勞，日化上而遷善，不知其所以然，治之本也，利賞而勸善，畏刑而不敢為非，法令正於上，百姓服於下，治之末也，上世養本，而下世事末。
老子曰：欲治之主不世出，可與治之臣不萬一，以不世出求不萬一，此至治所以千歲不一也。
蓋霸王之功不世立也，順其善意，防其邪心，與民同出一道，則民可善，風俗可美。
所貴聖人者，非貴其隨罪而作刑也，貴其知亂之所生也。
若開其銳端，而縱之放僻淫佚，而棄之以法，隨之以刑，雖殘賊天下不能禁其姦矣。
老子曰：身處江海之上，心在魏闕之下，即重生，重生即輕利矣。
猶不能自勝即從之，神無所害也，不能自勝而強不從，是謂重傷，重傷之人無壽類矣。
故曰：知和曰常，知常曰明，益生曰祥，心使氣曰強，是謂玄同，用其光，復歸其明。
老子曰：天下莫易於為善，莫難於為不善。
所謂為善者，靜而無為，適情辭餘，無所誘惑，循性保真，無變於己，故曰為善易也。
所謂為不善難者，篡弒矯詐，躁而多欲，非人之性也，故曰為不善難也。
今之以為大患者，由無常厭度量生也，故利害之地，禍福之際，不可不察。
聖人無欲也，無避也，事或欲之，適足以失之，事或避之，適足以就之，志有所欲，即忘其所為，是以聖人審動靜之變，而適受與之度，理好憎之情，和喜怒之節。
夫動靜得即患不侵也，受與適即罪不累也，理好憎即憂不近也，和喜怒即怨不犯也。
體道之人不苟得，不讓禍，其有不棄，非其有不制，恒滿而不溢，常虛而易贍。
故自當以道術度量，即食充虛，衣圉寒，足以溫飽七尺之形，無道術度量，而以自要尊貴，即萬乘之勢不足以為快，天下之富不足以為樂，故聖人心平志易，精神內守，物不能惑。
老子曰：勝人者有力，自勝者強。
能強者，必用人力者也，能用人力者，必得人心者也，能得人心者，必自得者也，未有得己而失人者也，未有失己而得人者也。
故為治之本，務在安人，安人之本，在於足用，足用之本，在於不奪時，不奪時之本，在於省事，省事之本，在於節用，節用之本，在於去驕，去驕之本，在於虛無，故知生之情者，不務生之所無以為，知命之情者，不憂命之所無奈何。
目悅五色，口惟滋味，耳淫五聲，七竅交爭，以害一性，日引邪欲竭其天和，身且不能治，奈治天下何，所謂得天下者，非謂其履勢位，稱尊號，言其運天下心，得天下力也，有南面之名，無一人之譽，此失天下也。
故桀紂不為王，湯武不為放，故天下得道，在守四夷，天下失道，守在諸侯，諸侯得道，守在四境，諸侯失道，守在左右。
故曰無恃其不吾奪也，恃吾不可奪也，行可奪之道，而非篡弒之行，無益於持天下矣。
老子曰：善治國者，不變其故，不易其常。
夫怒者逆德也，兵者凶器也，爭者人之所亂也，陰謀逆德，好用凶器，治人之亂，逆之至也。
非禍人不能成禍，不如挫其銳，解其紛，和其光，同其塵。
人之性情皆願賢己而疾不及人，願賢己則爭心生，疾不及人則怨爭生，怨爭生則心亂而氣逆，故古之聖王退爭怨，爭怨不生則心治而氣順，故曰：「不尚賢，使民不爭。
老子曰：治物者，不以物以和，治和者，不以和以人，治人者，不以人以君，治君者，不以君以欲，治欲者，不以欲以性，治性者，不以性以德，治德者，不以德以道。
以道本人之性，無邪穢，久湛於物即忘其本，即合於若性。
衣食禮俗者，非人之性也，所受於外也，故人性欲平，嗜欲害之，唯有道者能遺物反己。
有以自鑒，則不失物之情，無以自鑒，則動而惑營。
夫縱欲失性，動未嘗正，以治生則失身，以治國則亂人，故不聞道者無以反性。
古者聖人得諸己，故令行禁止，凡舉事者，必先平意清神，神清意平，物乃可正。
聽失於非譽，目淫於綵色，而欲得事正即難矣，是以貴虛。
故水激則波起，氣亂則智昏，昏智不可以為正，波水不可以為平，故聖王執一，以理物之情性。
夫一者，至貴無適於天下，聖王託於無適，故為天下命。
老子曰：陰陽陶冶萬物，皆乘一氣而生。
上下離心，氣乃上蒸，君臣不和，五穀不登，春肅秋榮，冬雷夏霜，皆賊氣之所生也。
天地之間，一人之身也，六合之內，一人之形也，故明於性者，天地不能脅也，審於符者，怪物不能惑也。
聖人由近以知遠，以萬里為一同，氣蒸乎天地，禮義廉恥不設，萬民莫不相侵暴虐，由在乎混冥之中也。
廉恥陵哕，及至世之衰，害多而財寡，事力勞而養不足，民貧苦而忿爭生，是以貴仁。
人鄙不齊，比周朋黨，各推其與，懷機巧詐之心，是以貴義。
男女群居，雜而無別，是以貴禮。
性命之情，淫而相迫於不得已，則不和，是以貴樂。
故仁義禮樂者，所以救敗也，非通治之道也。
誠能使神明定於天下，而心反其初，則民性善，民性善則天地陰陽從而包之，則財足而人贍，貪鄙忿爭之心不得生焉。
仁義不害，而道德定而天下，而民不淫於綵色，故德衰然後飾仁義，和失然後調聲，禮淫然後飾容。
故知道德，然後知仁義不足行也，知仁義，然後知禮樂不足脩也。
老子曰：清靜之治者，和順以寂寞，質真而素樸，閑靜而不躁，在內而合乎道，出外而同乎義，其言略而循理，其行悅而順情，其心和而不偽，其事素而不飾，不謀所始，不議所終，安即即留，激即行，通體乎天地，同胃乎陰陽，一和乎四時，明朗乎日月，與道化者為人，機械詐偽莫載乎心。
是以天覆以德，地載以樂，四時不失序，風雨不為虐，日月清靜而揚光，五星不失其行，此清靜之所明也。
老子曰：治世之職易守也，其事易為也，其禮易行也，其責易賞也。
是以人不兼官，官不兼士，士農工商，鄉別州異，故農與農言藏，士與士言行，工與工言巧，商與商言數。
是以士無遺行，工無苦事，農無廢功，商無折貨，各安其性。
異形殊類，易事而不悖，失處而賤，得勢而貴。
夫先知遠見之人，才之盛也，而治世不以責於人，博聞強志，口辯辭給，人知之溢也，而明主不以求於下，敖世賤物，不從流俗，士之伉行也，而治世不以為化民。
故高不可及者，不以為人量，行不可逮者，不可為國俗，故人才不可專用，而度量道術可世傳也。
故國治可與愚守也，而軍旅可以法同也，不待古之英俊，而人自足者，因其所有而並用之。
末世之法，高為量而罪不及也，重為任而罰不勝也，危為其難而誅不敢也，民困於三責，即飾智而詐上，犯邪而行危，雖峻法嚴刑，不能禁其姦。
獸窮即觸，鳥窮即啄，人窮即詐，此之謂也。
老子曰：雷霆之聲可以鐘鼓象也，風雨之變可以音律知也，大可睹者，可得而量也，明可見者，可得而蔽也，聲可聞者，可得而調也，色可察者，可得而別也。
夫至大，天地不能函也，至微，神明不能見也，及至建律曆，別五色，異清濁，味甘苦，即樸散而為器矣。
立仁義，脩禮樂，即德遷而為偽矣。
民飾智以驚愚，設詐以攻上，天下有能持之，而未能有治之者也。
夫智能彌多，而德滋衰，是以至人淳樸而不散。
夫至人之治，虛無寂寞，不見可欲，心與神處，形與性調，靜而體德，動而理通，循自然之道，緣不得已矣。
漠然無為而天下和，淡然無欲而民自樸，不忿爭而財足，求者不得，受者不讓，德反歸焉，而莫之惠。
不言之辯，不道之道，若或通焉，謂之天府。
取焉而不損，酌焉而不竭，莫知其所求由，謂之搖光，搖光者，資糧萬物者也。
老子曰：天愛其精，地愛其平，人愛其情，天之精，日月星辰、雷霆風雨也，地之平，水火金木土也，人之情，思慮聰明喜怒也，故閉其四關，止五道，即與道淪。
神明藏於無形，精氣反於真，目明而不以視，耳聰而不以聽，口當而不以言，心條通而不以思慮，委而不為，知而不矜，直性命之情，而知故不得害。
精存於目即其視明，在於耳即其聽聰，留於口即其言當，集於心即其慮通，故閉四關即終身無患，四支九竅，莫死莫生，是謂真人。
地之生財，大本不過五行，聖人節五行，即治不荒。
老子曰：衡之於左右，無私輕重，故可以為平，繩之於內外，無私曲直，故可以為正，人主之於法，無私好憎，故可以為令，德無所立，怨無所藏，是任道而合人心者也。
故為治者，知不與焉，水戾破舟，木擊折軸，不怨木石而罪巧拙者，智不載也，故道有智則亂，德有心則險，心有眼則眩。
夫權衡規矩，一定而不易，常一而不邪，方行而不留，一日形之，萬世傳之，無為之為也。
人之言曰：國有亡主，世亡亡道，人有窮而理無不通，故無為者，道之宗也。
得道之宗，並應無窮，故不因道理之數，而專己之能，其窮中遠。
夫人君者不出戶以知天下者，因物以識物，因人以知人。
故積力之所舉，即無不勝也，眾智之為，即無不成也。
千人之眾無絕糧，萬人之群無廢功，工無異伎，士無兼官，各守其職，不得相予，人得所宜，物得所安，是以器械不惡，職事不慢也。
夫責少易償也，職寡易守也，任輕易勸也，上操約少之分，下效易為之功，是以居日久而不相厭也。
老子曰：帝者體太一，王者法陰陽，霸者則四時，君者用六律。
體太一者，明於天地之情，通於道德之倫，聰明照於日月，精神通於萬物，動靜調於陰陽，嗔怒和於四時，覆露皆道，溥洽而無私，蜎飛蠕動，莫不依德而生，德流方外，名聲傳乎後世。
法陰陽者，承天地之和，德與天地參，光明與日月並照，精神與鬼神齊靈，圓履方，枹表寢繩，內能理身，外得人心，發施號令，天下從風，則四時者，春生夏長，秋收冬藏，取與有節，出入有量，喜怒剛柔，不離其理，柔而不脆，剛而不折，寬而不肆，肅而不悖，優游委順，以養群類，其德含愚而容不肖，無所私愛也。
用六律者，生之與殺也，賞之與罰也，與之以奪也，非此無道也，伐亂禁暴，興賢廢不肖，匡邪以為正，懷險以為平，矯枉以為直，明於施令，開塞之道，乘時因勢，以服役人心者也。
帝者體陰陽即寢，王者法四時即削，霸者用六律即辱，君者失準繩即廢，故小而行大即窮塞而不親，大而行小即狹隘而不容。
老子曰：地廣民眾，不足以為強，甲堅兵利，不可以恃勝，城高池深，不足以為固，嚴刑峻罰，不足以為威。
為存政者，雖小必存焉，為亡政者，雖大必亡焉。
故善守者無與禦，善戰者無與鬥，乘時勢，因民欲，而天下服。
故善為政者，積其德，善用兵者，畜其怒，德積而民可用也，怒畜而威可立也。
故文之所加者，深則權之所服者大，德之所施者博，則威之所制者廣，廣即我強而適弱。
善用兵者，先弱敵而後戰，故費不半而功十倍。
故千乘之國行文德者王，萬乘之國好用兵者亡，王兵先勝而後戰，敗兵先戰而後求勝，此不明於道也。''');

  final fullMap = FullMap();

  final globalSettings = GlobalSettings(sourceLanguage: SourceLanguage.chinese);

  static const List<Tab> _tabs = <Tab>[
    Tab(text: 'Translate'),
    Tab(text: 'Map'),
    Tab(text: 'Settings'),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);

    // Clear selections when switching between tabs.
    _tabController.addListener(() {
      ref.read(selectedWordProvider.notifier).clear();
      ref.read(selectedMappingProvider.notifier).clear();
    });

    // FIXME: this is an ugly hack, remove these lines to initialise the mapping as empty initially
    fullMap.addMapping(
        mapping:
            Mapping(pronounciation: 'aa', source: '子', translation: ['alpha']),
        section: 'Default');
    fullMap.addMapping(
        mapping: Mapping(
            pronounciation: 'bb', source: '曰', translation: ['beta', 'beta2']),
        section: 'Default');
    fullMap.addMapping(
        mapping: Mapping(
            pronounciation: 'cc1', source: '治', translation: ['gamma1']),
        section: 'Default');
    fullMap.addMapping(
        mapping: Mapping(
            pronounciation: 'cc2',
            source: '治',
            translation: ['gamma2', 'gamma3']),
        section: 'Default');
    fullMap.addMapping(
        mapping:
            Mapping(pronounciation: 'dd', source: '身', translation: ['delta']),
        section: 'Extra');
    fullMap.addMapping(
        mapping: Mapping(
            pronounciation: 'ee', source: '老', translation: ['epsilon']),
        section: 'Extra');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'NotoSansSC'),
      home: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: _tabs,
          ),
          // Do not show app bar, only show tabs.
          toolbarHeight: 0,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Each of these widgets should (atempt to) only modify its first argument, leaving the rest as read-only.
            TextDisplay(text: fullText, map: fullMap),
            MapDisplay(map: fullMap),
            SettingsDisplay(globalSettings: globalSettings),
          ],
        ),
      ),
    );
  }
}
