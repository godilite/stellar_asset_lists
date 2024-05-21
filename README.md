# API Documentation for Stellar Asset Lists Package

## Overview

The Stellar Asset Lists package is designed to facilitate the integration of curated Stellar asset lists into Stellar applications and services. This package adheres to the Stellar Ecosystem Proposal (SEP-42) standard, providing a standardized mechanism for defining, validating, and sharing lists of Stellar assets. This helps to enhance user experiences and trust by ensuring consistency and ease of integration across the Stellar network.

It is compatible with Flutter Desktop (Windows, Linux, MacOS), IOS, Android, and Web.
[![pub](https://img.shields.io/pub/v/stellar_asset_lists.svg?style=flat)](https://pub.dev/packages/stellar_asset_lists)

### Key Features:
- Fetch and parse available asset lists from a central catalogue.
- Retrieve specific asset lists using their URL.
- Configurable resolver options for catalogue and IPFS gateway URLs.
- Automatic resolution of asset icons.

## Usage in your project

1. Fetch asset lists from the community-managed catalogue:
  `fetchAvailableAssetLists()`

2. Show available lists fetched from the catalogue to your users, so they could select one or more lists from providers they trust. Save selected lists in user settings.

3. Load selected list and cache the result:
  `fetchAssetList('list_url')`

4. Utilize a user-selected list to show only relevant assets in transfer/trade/swap interfaces. This helps to combat various fraudulent schemes while delegating all the power of decision-making to end-users in a truly decentralized manner.

5. Profit! Safer, more streamlined UX.

## Usage Example

```dart
void main() async {
  final assetListResolver = StellarAssetListResolver();

  try {
    // Fetch available asset lists
    List<AssetListDescriptor> assetLists = await assetListResolver.fetchAvailableAssetLists();
    for (var list in assetLists) {
      print('Asset List: ${list.name}, Provider: ${list.provider}');
    }

    // Fetch a specific asset list
    if (assetLists.isNotEmpty) {
      AssetList assetList = await assetListResolver.fetchAssetList(assetLists[0].url);
      print('Fetched Asset List: ${assetList.name}');
    }

    // Update resolver options
    assetListResolver.setAssetListResolverOptions(
      catalogueUrl: 'https://new-catalogue-url.example.com',
      ipfsGatewayUrl: 'https://new-ipfs-gateway.example.com',
    );
  } catch (e) {
    print('Error: $e');
  }
}
```


## Classes and Interfaces

### IStellarAssetListResolver

The `IStellarAssetListResolver` interface defines the methods that must be implemented by any class that provides asset list resolution functionality.

#### Methods

- **fetchAvailableAssetLists**: Fetches all available asset lists from the catalogue.
  - **Parameters**:
    - `fetchAndParse` (optional): A function to fetch and parse JSON data from a URL.
  - **Returns**: `Future<List<AssetListDescriptor>>`

- **fetchAssetList**: Fetches the asset list from the given URL.
  - **Parameters**:
    - `url`: The full URL to the asset list.
    - `fetchAndParse` (optional): A function to fetch and parse JSON data from a URL.
  - **Returns**: `Future<AssetList>`

- **setAssetListResolverOptions**: Configures resolver options for the asset list provider.
  - **Parameters**:
    - `options`: A map of options to set, including `catalogueUrl` and `ipfsGatewayUrl`.
  - **Returns**: `void`

### ResolverOptions

The `ResolverOptions` class holds configuration options for the Stellar Asset Lists.

#### Properties

- **catalogueUrl**: URL of the asset list catalogue.
- **ipfsGatewayUrl**: URL of the IPFS gateway.

### AssetListDescriptor

The `AssetListDescriptor` class represents a descriptor for an asset list.

#### Properties

- **name**: Short descriptive title of the list.
- **provider**: Organization or entity that put together the list.
- **description**: Text description provided by the organization.
- **icon**: URL of the list icon.
- **url**: URL of the asset list.

#### Methods

- **fromJson**: Creates an instance of `AssetListDescriptor` from a JSON map.

### Asset

The `Asset` class represents metadata for an individual asset.

#### Properties

- **contract** (optional): Contract address of the asset (for Soroban assets).
- **code** (optional): Asset code (for Classic assets).
- **issuer** (optional): Asset issuer account address (for Classic assets).
- **name**: Display name.
- **org**: Issuer organization/company.
- **domain**: FQDN of the site that hosts asset-related stellar.toml.
- **icon**: Icon URL.
- **decimals** (optional): Number of decimals to display.
- **comment** (optional): Alerts, messages, or other additional information specified by the provider.

#### Methods

- **fromJson**: Creates an instance of `Asset` from a JSON map.

### AssetList

The `AssetList` class represents a full list of assets.

#### Properties

- **name**: Short descriptive title of the list.
- **provider**: Organization or entity that put together the list.
- **description**: Text description provided by the organization.
- **version**: Current list revision.
- **feedback**: URL or GitHub repository address where users can report bad actors or request addition of new assets.
- **assets**: List of `Asset` instances.

#### Methods

- **fromJson**: Creates an instance of `AssetList` from a JSON map.

### StellarAssetListResolver

The `StellarAssetListResolver` class implements the `IStellarAssetListResolver` interface, providing methods to fetch and parse asset lists.

#### Methods

- **fetchAvailableAssetLists**: Fetches all available asset lists from the catalogue.
  - **Parameters**:
    - `fetchAndParse` (optional): A function to fetch and parse JSON data from a URL.
  - **Returns**: `Future<List<AssetListDescriptor>>`

- **fetchAssetList**: Fetches the asset list from the given URL.
  - **Parameters**:
    - `url`: The full URL to the asset list.
    - `fetchAndParse` (optional): A function to fetch and parse JSON data from a URL.
  - **Returns**: `Future<AssetList>`

- **setAssetListResolverOptions**: Configures resolver options for the asset list provider.
  - **Parameters**:
    - `options`: A map of options to set, including `catalogueUrl` and `ipfsGatewayUrl`.
  - **Returns**: `void`

- **fetchAndParseDefault**: Fetches and parses JSON data from a URL.
  - **Parameters**:
    - `url`: The URL to fetch data from.
  - **Returns**: `Future<dynamic>`
  - **Throws**: `Exception` if the fetch fails.

- **resolveIcon**: Resolves the icon URL for an asset or asset list descriptor.
  - **Parameters**:
    - `item`: The item (either `AssetListDescriptor` or `Asset`) to resolve the icon for.
  - **Returns**: `void`


## Contributing

Contributions to the Stellar Asset Lists package are welcome. If you find a bug or want to add a feature, please open an issue or submit a pull request on GitHub.

## License

This package is licensed under the MIT License. See the LICENSE file for details.