import 'package:stellar_asset_lists/stellar_asset_lists.dart';

void main() {
  final resolver = StellarAssetListResolver();

  resolver.fetchAvailableAssetLists().then((assetLists) {
    for (final assetList in assetLists) {
      print(assetList.url);
    }
  });

  resolver.fetchAssetList('https://lobstr.co/api/v1/sep/assets/curated.json').then((assetList) {
    for (final asset in assetList.assets) {
      print(asset.icon);
    }
  });
}
