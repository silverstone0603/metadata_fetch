import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:http/http.dart' as http;
import 'package:metadata_fetch/src/parsers/jsonld_parser.dart';
import 'package:metadata_fetch/src/parsers/parsers.dart';
import 'package:test/test.dart';

// TODO: Use a Mock Server for testing
// TODO: Improve testing
void main() {
  test('JSON Serialization', () async {
    MetadataFetcher _fetcher = MetadataFetcher();
    var url = 'https://flutter.dev';
    var response = await http.get(url);
    var document = _fetcher.responseToDocument(response);
    var data = await MetadataParser().parse(document);
    print(data.toJson());
    expect(data.toJson().isNotEmpty, true);
  });

  test('Metadata Parser', () async {
    MetadataFetcher _fetcher = MetadataFetcher();
    var url = 'https://flutter.dev';
    var response = await http.get(url);
    var document = _fetcher.responseToDocument(response);

    var data = MetadataParser().parse(document);
    print(data);

    // Just Opengraph
    var og = MetadataParser().openGraph(document);
    print('OG $og');

    // Just Html
    var hm = MetadataParser().htmlMeta(document);
    print('Html $hm');

    // Just Json-ld schema
    var js = MetadataParser().jsonLdSchema(document);
    print('JSON $js');

    var twitter = MetadataParser().twitterCard(document);
    print('Twitter $twitter');
  });
  group('Metadata parsers', () {
    test('JSONLD', () async {
      MetadataFetcher _fetcher = MetadataFetcher();
      var url = 'https://www.epicurious.com/';
      var response = await http.get(url);
      var document = _fetcher.responseToDocument(response);
      // print(response.statusCode);

      print(JsonLdParser(document));
    });

    test('JSONLD II', () async {
      MetadataFetcher _fetcher = MetadataFetcher();
      var url =
          'https://www.epicurious.com/expert-advice/best-soy-sauce-chefs-pick-article';
      var response = await http.get(url);
      var document = _fetcher.responseToDocument(response);
      // print(response.statusCode);

      print(JsonLdParser(document));
    });

    test('JSONLD III', () async {
      MetadataFetcher _fetcher = MetadataFetcher();
      var url =
          'https://medium.com/@quicky316/install-flutter-sdk-on-windows-without-android-studio-102fdf567ce4';
      var response = await http.get(url);
      var document = _fetcher.responseToDocument(response);
      // print(response.statusCode);

      print(JsonLdParser(document));
    });

    test('JSONLD IV', () async {
      MetadataFetcher _fetcher = MetadataFetcher();
      var url = 'https://www.distilled.net/';
      var response = await http.get(url);
      var document = _fetcher.responseToDocument(response);
      // print(response.statusCode);

      print(JsonLdParser(document));
    });
    test('HTML', () async {
      MetadataFetcher _fetcher = MetadataFetcher();
      var url = 'https://flutter.dev';
      var response = await http.get(url);
      var document = _fetcher.responseToDocument(response);
      print(response.statusCode);

      print(HtmlMetaParser(document).title);
      print(HtmlMetaParser(document).description);
      print(HtmlMetaParser(document).image);
    });

    test('OpenGraph Parser', () async {
      MetadataFetcher _fetcher = MetadataFetcher();
      var url = 'https://flutter.dev';
      var response = await http.get(url);
      var document = _fetcher.responseToDocument(response);
      print(response.statusCode);

      print(OpenGraphParser(document));
      print(OpenGraphParser(document).title);
      print(OpenGraphParser(document).description);
      print(OpenGraphParser(document).image);
    });

    test('TwitterCard Parser', () async {
      MetadataFetcher _fetcher = MetadataFetcher();
      var url =
          'https://www.epicurious.com/expert-advice/best-soy-sauce-chefs-pick-article';
      var response = await http.get(url);
      var document = _fetcher.responseToDocument(response);
      print(response.statusCode);

      print(TwitterCardParser(document));
      print(TwitterCardParser(document).title);
      print(TwitterCardParser(document).description);
      print(TwitterCardParser(document).image);
      // Test the url
      print(TwitterCardParser(document).url);
    });

    test('Faulty', () async {
      MetadataFetcher _fetcher = MetadataFetcher();
      var url = 'https://google.ca';
      var response = await http.get(url);
      var document = _fetcher.responseToDocument(response);
      print(response.statusCode);

      print(OpenGraphParser(document).title);
      print(OpenGraphParser(document).description);
      print(OpenGraphParser(document).image);

      print(HtmlMetaParser(document).title);
      print(HtmlMetaParser(document).description);
      print(HtmlMetaParser(document).image);
    });
  });

  group('extract()', () {
    test('First Test', () async {
      MetadataFetcher _fetcher = MetadataFetcher(
        url: "https://flutter.dev/",
      );
      var data = await _fetcher.extract();
      print(data);
      print(data.description);
      expect(data.toMap().isEmpty, false);
    });

    test('FB Test', () async {
      MetadataFetcher _fetcher = MetadataFetcher(
        url: "https://facebook.com/",
      );
      var data = await _fetcher.extract();
      expect(data.toMap().isEmpty, false);
    });

    test('Unicode Test', () async {
      MetadataFetcher _fetcher = MetadataFetcher(
        url: "https://www.jpf.go.jp/",
      );
      var data = await _fetcher.extract();
      expect(data.toMap().isEmpty, false);
    });

    test('Gooogle Test', () async {
      MetadataFetcher _fetcher = MetadataFetcher(
        url: "https://google.ca",
      );
      var data = await _fetcher.extract();
      expect(data.toMap().isEmpty, false);
      expect(data.title, 'google');
    });

    test('Invalid Url Test', () async {
      MetadataFetcher _fetcher = MetadataFetcher(
        url: "https://google",
      );
      var data = await _fetcher.extract();
      expect(data == null, true);
    });
  });
}
