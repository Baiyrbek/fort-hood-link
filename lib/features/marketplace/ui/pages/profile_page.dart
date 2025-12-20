import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/marketplace_bloc.dart';
import '../../bloc/marketplace_event.dart';
import '../../bloc/marketplace_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
      ),
      body: BlocBuilder<MarketplaceBloc, MarketplaceState>(
        builder: (context, state) {
          final myListings = state.allListings
              .where((listing) => listing.ownerId == 'local-user')
              .toList();

          if (myListings.isEmpty) {
            return const Center(
              child: Text('You have no listings yet'),
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
    );
  }
}
