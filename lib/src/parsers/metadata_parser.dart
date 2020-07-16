import 'package:html/dom.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:metadata_fetch/src/parsers/youtube_parser.dart';

/// Does Works with `BaseMetadataParser`
class MetadataParser {

  static List<Metadata> parsers;
  /// This is the default strategy for building our [Metadata]
  ///
  /// It tries [OpenGraphParser], then [TwitterCardParser], then [JsonLdParser], and falls back to [HTMLMetaParser] tags for missing data.
  static Future<Metadata> parse(Document document) async {
    final output = Metadata();

    parsers = [
      openGraph(document),
      twitterCard(document),
      jsonLdSchema(document),
      htmlMeta(document),
    ];

    try{
      parsers.add(await youtubeParser(document));
    }catch (e){
      print("There's no youtube data inside.");
    }

    for (final p in parsers) {
      output.title ??= p.title;
      output.description ??= p.description;
      output.image ??= _imageUrl(p);
      output.url ??= p.url;

      if (output.hasAllMetadata) {
        break;
      }
    }

    return output;
  }

  static String _imageUrl(Metadata data) {
    String imageLink = data.image;
    if (imageLink == null) return null;
    if (imageLink.startsWith("http")) return imageLink;
    var pageUrl = Uri.parse(data.url);
    return pageUrl.scheme + "://" + pageUrl.host + imageLink;
  }

  static Metadata openGraph(Document document) {
    return OpenGraphParser(document).parse();
  }

  static Future<Metadata> youtubeParser(Document document) async {
    return await YoutubeParser(document).toParse();
  }

  static Metadata htmlMeta(Document document) {
    return HtmlMetaParser(document).parse();
  }

  static Metadata jsonLdSchema(Document document) {
    return JsonLdParser(document).parse();
  }

  static Metadata twitterCard(Document document) {
    return TwitterCardParser(document).parse();
  }
}
