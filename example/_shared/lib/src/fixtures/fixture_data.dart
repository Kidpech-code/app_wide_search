import 'package:app_wide_search/app_wide_search.dart';
import 'package:faker/faker.dart';

/// Realistic test data across multiple domains.
///
/// Provides pre-generated fixtures for:
/// - E-commerce products
/// - User contacts
/// - Documentation pages
/// - Media files
/// - Generic items
class FixtureData {
  FixtureData._();

  static final _faker = Faker();

  /// Generates realistic items mixing different domains.
  static List<SearchItem> generateRealisticItems(int count) {
    final items = <SearchItem>[];
    final categories = ['products', 'contacts', 'docs', 'media', 'settings'];

    for (var i = 0; i < count; i++) {
      final category = categories[i % categories.length];
      items.add(_generateItemForCategory(i, category));
    }

    return items;
  }

  static SearchItem _generateItemForCategory(int index, String category) {
    switch (category) {
      case 'products':
        return _generateProduct(index);
      case 'contacts':
        return _generateContact(index);
      case 'docs':
        return _generateDocPage(index);
      case 'media':
        return _generateMediaFile(index);
      case 'settings':
        return _generateSetting(index);
      default:
        return _generateGeneric(index);
    }
  }

  static SearchItem _generateProduct(int index) {
    final product = _faker.food.dish();
    final price = _faker.randomGenerator.decimal(scale: 100, min: 1);

    return SearchItem(
      id: 'product_$index',
      title: product,
      subtitle: '\$${price.toStringAsFixed(2)}',
      groupId: 'products',
      description:
          '${_faker.lorem.sentence()} Available in ${_faker.randomGenerator.integer(10, min: 1)} stores.',
      imageUrl: 'https://picsum.photos/seed/$index/200',
      metadata: {
        'price': price,
        'category': _faker.food.cuisine(),
        'inStock': _faker.randomGenerator.boolean(),
      },
    );
  }

  static SearchItem _generateContact(int index) {
    final name = _faker.person.name();
    final email = _faker.internet.email();

    return SearchItem(
      id: 'contact_$index',
      title: name,
      subtitle: email,
      groupId: 'contacts',
      description: '${_faker.company.name()} - ${_faker.job.title()}',
      metadata: {
        'phone': _faker.phoneNumber.us(),
        'company': _faker.company.name(),
      },
    );
  }

  static SearchItem _generateDocPage(int index) {
    final title = _faker.lorem.words(3).join(' ');

    return SearchItem(
      id: 'doc_$index',
      title: title.substring(0, 1).toUpperCase() + title.substring(1),
      subtitle: 'Documentation',
      groupId: 'docs',
      description: _faker.lorem.sentence(),
      route: '/docs/${title.replaceAll(' ', '-').toLowerCase()}',
      metadata: {
        'section': [
          'Getting Started',
          'API Reference',
          'Examples',
          'FAQ',
        ][_faker.randomGenerator.integer(4)],
        'lastUpdated': _faker.date.dateTime().toIso8601String(),
      },
    );
  }

  static SearchItem _generateMediaFile(int index) {
    final extensions = ['jpg', 'png', 'mp4', 'pdf', 'doc'];
    final ext = extensions[_faker.randomGenerator.integer(extensions.length)];
    final fileName = '${_faker.lorem.word()}_$index.$ext';

    return SearchItem(
      id: 'media_$index',
      title: fileName,
      subtitle: '${_faker.randomGenerator.integer(1000)} KB',
      groupId: 'media',
      description:
          'Uploaded ${_faker.date.dateTime().toString().split(' ')[0]}',
      metadata: {'size': _faker.randomGenerator.integer(1000000), 'type': ext},
    );
  }

  static SearchItem _generateSetting(int index) {
    final settings = [
      ('Notifications', 'Manage app notifications'),
      ('Privacy', 'Control your privacy settings'),
      ('Theme', 'Change app appearance'),
      ('Language', 'Select your language'),
      ('Account', 'Manage your account'),
      ('Security', 'Security and passwords'),
      ('Storage', 'Manage app storage'),
      ('About', 'App information'),
    ];

    final setting = settings[index % settings.length];

    return SearchItem(
      id: 'setting_$index',
      title: setting.$1,
      subtitle: setting.$2,
      groupId: 'settings',
      route: '/settings/${setting.$1.toLowerCase()}',
    );
  }

  static SearchItem _generateGeneric(int index) {
    return SearchItem(
      id: 'item_$index',
      title: 'Item $index',
      subtitle: 'Subtitle $index',
      groupId: 'general',
      description: 'Description for item $index',
    );
  }

  /// Pre-defined groups for testing.
  static List<SearchGroup> get groups => [
    SearchGroup(id: 'products', name: 'Products', priority: 1),
    SearchGroup(id: 'contacts', name: 'Contacts', priority: 2),
    SearchGroup(id: 'docs', name: 'Documentation', priority: 3),
    SearchGroup(id: 'media', name: 'Media Files', priority: 4),
    SearchGroup(id: 'settings', name: 'Settings', priority: 5),
  ];
}
