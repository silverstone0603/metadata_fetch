import 'dart:convert';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:metadata_fetch/src/parsers/parsers.dart';
import 'package:metadata_fetch/src/utils/util.dart';
import 'package:string_validator/string_validator.dart';

class MetadataFetcher{
  final String url;

  MetadataFetcher({
    this.url,
  });

  /// Fetches a [url], validates it, and returns [Metadata].
  Future<Metadata> extract() async {
    if (!isURL(url)) {
      return null;
    }

    /// Sane defaults; Always return the Domain name as the [title], and a [description] for a given [url]
    final defaultOutput = Metadata();
    defaultOutput.title = getDomain(url);
    defaultOutput.description = url;

    // Make our network call
    var response = null;
    response = await http.get(url);

    if (response.headers["content-type"].startsWith(r"image/")) {
      defaultOutput.title = "";
      defaultOutput.description = "";
      defaultOutput.image = url;
      return defaultOutput;
    }

    final document = responseToDocument(response);

    if (document == null) {
      return defaultOutput;
    }

    print("주소가 뭐야: ${document.requestUrl} / ${document.head.innerHtml}");

    final data = await _extractMetadata(document);

    print(data.toString());
    if (data == null) {
      return defaultOutput;
    }

    return data;
  }

  /// Takes an [http.Response] and returns a [html.Document]
  Document responseToDocument(http.Response response) {
    if (response.statusCode != 200) {
      return null;
    }

    Document document;
    try {
      document = parser.parse(utf8.decode(response.bodyBytes));
      document.requestUrl = response.request.url.toString();
    } catch (err) {
      return document;
    }

    return document;
  }

  /// Returns instance of [Metadata] with data extracted from the [html.Document]
  ///
  /// Future: Can pass in a strategy i.e: to retrieve only OpenGraph, or OpenGraph and Json+LD only
  Future <Metadata> _extractMetadata(Document document) async {
    return await MetadataParser().parse(document);
  }
}