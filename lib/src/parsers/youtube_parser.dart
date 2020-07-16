import 'dart:convert';

import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:metadata_fetch/src/utils/util.dart';

import 'base_parser.dart';

/// Takes a [http.document] and parses [Metadata] from ["title", thumbnail_url"] of Json Array
class YoutubeParser with BaseMetadataParser {
  /// The [document] to be parse
  Document document;

  /// Get the [Metadata.title] from the [<title>] tag
  @override
  String title;

  /// Get the [Metadata.description] from the <meta name="description" content=""> tag
  @override
  String description;

  /// Get the [Metadata.image] from the first <img> tag in the body;s
  @override
  String image;

  /// Get the [Document.url] from the Document extension.
  @override
  String url;

  YoutubeParser(this.document) {
    this.url = document?.requestUrl;
  }

  Future<Metadata> toParse() async {
    try{
      var data = await getDetail(this.url);
      if(data != null){
        this.title = data["title"];
        this.image = data["thumbnail_url"];
      }
      return this.parse();
    }catch(e){
      print("It isn't a youtube site or youtube data.");
      return null;
    }
  }

  Future<dynamic> getDetail(String userUrl) async {
    String embedUrl = "https://www.youtube.com/oembed?url=$userUrl&format=json";

    // Store http request response to res variable
    var res = await http.get(embedUrl);
    print("Get youtube detail status code: " + res.statusCode.toString());

    try {
      if (res.statusCode == 200) {
        // Return the json from the response
        return json.decode(res.body);
      } else {
        // Return null if status code other than 200
        return null;
      }
    } on FormatException catch (e) {
      print('invalid JSON: '+ e.toString());
      // Return null if error
      return null;
    }
  }
}
