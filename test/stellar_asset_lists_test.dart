import 'package:steller_asset_lists/stellar_asset_lists.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('Asset List Resolver Tests', () {
    late StellarAssetListResolver resolver;

    setUp(() {
      resolver = StellarAssetListResolver();
    });

    test('AssetListDescriptor fromJson', () {
      final json = {
        'name': 'Test List',
        'provider': 'Test Provider',
        'description': 'A test asset list',
        'icon': 'test-icon',
        'url': 'https://example.com/test-list'
      };

      final assetListDescriptor = AssetListDescriptor.fromJson(json);
      expect(assetListDescriptor.name, 'Test List');
      expect(assetListDescriptor.provider, 'Test Provider');
      expect(assetListDescriptor.description, 'A test asset list');
      expect(assetListDescriptor.icon, 'test-icon');
      expect(assetListDescriptor.url, 'https://example.com/test-list');
    });

    test('Asset fromJson', () {
      final json = {
        'contract': 'test-contract',
        'code': 'TEST',
        'issuer': 'test-issuer',
        'name': 'Test Asset',
        'org': 'Test Org',
        'domain': 'example.com',
        'icon': 'test-icon',
        'decimals': 8,
        'comment': 'Test comment'
      };

      final asset = Asset.fromJson(json);
      expect(asset.contract, 'test-contract');
      expect(asset.code, 'TEST');
      expect(asset.issuer, 'test-issuer');
      expect(asset.name, 'Test Asset');
      expect(asset.org, 'Test Org');
      expect(asset.domain, 'example.com');
      expect(asset.icon, 'test-icon');
      expect(asset.decimals, 8);
      expect(asset.comment, 'Test comment');
    });

    test('fetchAvailableAssetLists', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode([
              {
                'name': 'Test List',
                'provider': 'Test Provider',
                'description': 'A test asset list',
                'icon': 'test-icon',
                'url': 'https://example.com/test-list'
              }
            ]),
            200);
      });

      mockFetchAndParse(String url) async {
        final response = await mockClient.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
        throw Exception('Failed to fetch');
      }

      final result = await resolver.fetchAvailableAssetLists(mockFetchAndParse);
      expect(result.length, 1);
      expect(result[0].name, 'Test List');
    });

    test('fetchAssetList', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'name': 'Test List',
              'provider': 'Test Provider',
              'description': 'A test asset list',
              'version': '1.0',
              'feedback': 'https://example.com/feedback',
              'assets': [
                {
                  'contract': 'test-contract',
                  'code': 'TEST',
                  'issuer': 'test-issuer',
                  'name': 'Test Asset',
                  'org': 'Test Org',
                  'domain': 'example.com',
                  'icon': 'test-icon',
                  'decimals': 8,
                  'comment': 'Test comment'
                }
              ]
            }),
            200);
      });

      mockFetchAndParse(String url) async {
        final response = await mockClient.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
        throw Exception('Failed to fetch');
      }

      final result = await resolver.fetchAssetList('https://example.com/test-list', mockFetchAndParse);
      expect(result.name, 'Test List');
      expect(result.assets.length, 1);
      expect(result.assets[0].name, 'Test Asset');
    });

    test('setStellarAssetListResolverOptions', () {
      resolver.setAssetListResolverOptions(
        catalogueUrl: 'https://new-catalogue-url.com',
        ipfsGatewayUrl: 'https://new-ipfs-gateway.com',
      );

      expect(resolverOptions.catalogueUrl, 'https://new-catalogue-url.com');
      expect(resolverOptions.ipfsGatewayUrl, 'https://new-ipfs-gateway.com');
    });

    test('resolveIcon', () {
      final assetListDescriptor = AssetListDescriptor(
        name: 'Test List',
        provider: 'Test Provider',
        description: 'A test asset list',
        icon: 'bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2',
        url: 'https://example.com/test-list',
      );

      resolver.resolveIcon(assetListDescriptor);
      expect(assetListDescriptor.icon,
          '${resolverOptions.ipfsGatewayUrl}bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2bA2');
    });
  });
}
