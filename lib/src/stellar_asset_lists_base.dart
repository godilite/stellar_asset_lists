import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Interface defining methods for asset list resolution.
abstract class IStellarAssetListResolver {
  Future<List<AssetListDescriptor>> fetchAvailableAssetLists([Future<dynamic> Function(String)? fetchAndParse]);
  Future<AssetList> fetchAssetList(String url, [Future<dynamic> Function(String)? fetchAndParse]);
  void setAssetListResolverOptions({String? catalogueUrl, String? ipfsGatewayUrl});
}

/// Class holding configuration options for the asset list resolver.
class ResolverOptions {
  String catalogueUrl = 'https://stellar-asset-lists.github.io/index/';
  String ipfsGatewayUrl = 'https://gateway.ipfs.io/ipfs/';
}

/// Global instance of ResolverOptions.
final resolverOptions = ResolverOptions();

/// Class representing a descriptor for an asset list.
class AssetListDescriptor {
  String? name;
  String? provider;
  String? description;
  String? icon;
  String? url;

  AssetListDescriptor({
    required this.name,
    required this.provider,
    required this.description,
    required this.icon,
    required this.url,
  });

  /// Creates an instance of AssetListDescriptor from a JSON map.
  factory AssetListDescriptor.fromJson(Map<String, dynamic> json) {
    return AssetListDescriptor(
      name: json['name'],
      provider: json['provider'],
      description: json['description'],
      icon: json['icon'],
      url: json['url'],
    );
  }
}

/// Class representing metadata for an individual asset.
class Asset {
  String? contract;
  String? code;
  String? issuer;
  String? name;
  String? org;
  String? domain;
  String? icon;
  int? decimals;
  String? comment;

  Asset({
    this.contract,
    this.code,
    this.issuer,
    required this.name,
    required this.org,
    required this.domain,
    required this.icon,
    this.decimals,
    this.comment,
  });

  /// Creates an instance of Asset from a JSON map.
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      contract: json['contract'],
      code: json['code'],
      issuer: json['issuer'],
      name: json['name'],
      org: json['org'],
      domain: json['domain'],
      icon: json['icon'],
      decimals: json['decimals'],
      comment: json['comment'],
    );
  }
}

/// Class representing a full list of assets.
class AssetList {
  String? name;
  String? provider;
  String? description;
  String? version;
  String? feedback;
  List<Asset> assets;

  AssetList({
    required this.name,
    required this.provider,
    required this.description,
    required this.version,
    required this.feedback,
    required this.assets,
  });

  /// Creates an instance of AssetList from a JSON map.
  factory AssetList.fromJson(Map<String, dynamic> json) {
    var assetList = json['assets'] as List;
    List<Asset> assetObjs = assetList.map((asset) => Asset.fromJson(asset)).toList();

    return AssetList(
      name: json['name'],
      provider: json['provider'],
      description: json['description'],
      version: json['version'],
      feedback: json['feedback'],
      assets: assetObjs,
    );
  }
}

/// Implementation of the IStellarAssetListResolver interface.
class StellarAssetListResolver implements IStellarAssetListResolver {
  @override
  Future<List<AssetListDescriptor>> fetchAvailableAssetLists([Future<dynamic> Function(String)? fetchAndParse]) async {
    fetchAndParse ??= fetchAndParseDefault;
    final response = await fetchAndParse(resolverOptions.catalogueUrl);
    if (response is! List) {
      return [];
    }

    List<AssetListDescriptor> catalogue = response.map((item) => AssetListDescriptor.fromJson(item)).toList();
    for (var list in catalogue) {
      resolveIcon(list);
    }
    return catalogue;
  }

  @override
  Future<AssetList> fetchAssetList(String url, [Future<dynamic> Function(String)? fetchAndParse]) async {
    if (url.isEmpty) {
      throw ArgumentError('Missing asset list URL');
    }
    fetchAndParse ??= fetchAndParseDefault;
    final assetsList = await fetchAndParse(url);
    if (assetsList['assets'] is! List) {
      return AssetList(name: '', provider: '', description: '', version: '', feedback: '', assets: []);
    }

    for (var asset in assetsList['assets']) {
      resolveIcon(asset);
    }
    return AssetList.fromJson(assetsList);
  }

  @override
  void setAssetListResolverOptions({String? catalogueUrl, String? ipfsGatewayUrl}) {
    resolverOptions.catalogueUrl = catalogueUrl ?? resolverOptions.catalogueUrl;
    resolverOptions.ipfsGatewayUrl = ipfsGatewayUrl ?? resolverOptions.ipfsGatewayUrl;
  }

  /// Default function to fetch and parse JSON data from a URL.
  Future<dynamic> fetchAndParseDefault(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch. ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  /// Resolves the icon URL for an asset or asset list descriptor.
  void resolveIcon(dynamic item) {
    final regex = RegExp(r'^(b[A-Za-z2-7]{58,}|B[A-Z2-7]{58,}|z[1-9A-HJ-NP-Za-km-z]{48,}|F[0-9A-F]{50,})$');
    if (item is AssetListDescriptor || item is Asset) {
      if (regex.hasMatch(item.icon)) {
        item.icon = '${resolverOptions.ipfsGatewayUrl}${item.icon}';
      }
    }
  }
}
