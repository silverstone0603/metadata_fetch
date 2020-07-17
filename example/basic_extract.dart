import 'package:metadata_fetch/metadata_fetch.dart';

void main() async {
  MetadataFetcher _fetcher = MetadataFetcher(
    url: "https://flutter.dev"
  );
  var data = await _fetcher.extract(); // returns a Metadata object
  print(data); // Metadata.toString()
  print(data.title); // Metadata.title
  print(data.toMap()); // converts Metadata to map
  print(data.toJson()); // converts Metadata to JSON
}
