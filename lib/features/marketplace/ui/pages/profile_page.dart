import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/marketplace_bloc.dart';
import '../../bloc/marketplace_event.dart';
import '../../bloc/marketplace_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? _previousListingCount;

  void _handleDelete(BuildContext context, String listingId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listing'),
        content: const Text('Delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MarketplaceBloc>().add(DeleteListing(listingId));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MarketplaceBloc, MarketplaceState>(
      listenWhen: (previous, current) {
        final previousMyCount = previous.allListings
            .where((l) => l.ownerId == 'local-user')
            .length;
        final currentMyCount = current.allListings
            .where((l) => l.ownerId == 'local-user')
            .length;
        return previousMyCount != currentMyCount && _previousListingCount != null;
      },
      listener: (context, state) {
        final previousMyCount = _previousListingCount ?? 0;
        final currentMyCount = state.allListings
            .where((l) => l.ownerId == 'local-user')
            .length;

        if (currentMyCount < previousMyCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing deleted')),
          );
        }
        _previousListingCount = currentMyCount;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Me'),
          actions: [
            TextButton(
              onPressed: () {
                context.read<MarketplaceBloc>().add(const ClearLocalListings());
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        body: BlocBuilder<MarketplaceBloc, MarketplaceState>(
          builder: (context, state) {
            final myListings = state.allListings
                .where((listing) => listing.ownerId == 'local-user')
                .toList();

            if (_previousListingCount == null) {
              _previousListingCount = myListings.length;
            }

            if (!state.loading && myListings.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No listings yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Items you post will appear here.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: myListings.length,
            itemBuilder: (context, index) {
              final listing = myListings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: listing.images.isNotEmpty
                      ? Image.network(
                          listing.images.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                  title: Text(listing.title),
                  subtitle: Text('\$${listing.price} • ${listing.location}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _handleDelete(context, listing.id),
                  ),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}
