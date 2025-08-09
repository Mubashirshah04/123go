import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../services/vpn_service.dart';
import '../widgets/connect_button.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_logo.dart';
import '../auth/login_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(freeAccessServiceProvider).initBackground();
  }

  @override
  Widget build(BuildContext context) {
    final vpn = ref.watch(vpnServiceProvider);
    final auth = ref.watch(authServiceProvider);

    return StreamBuilder<VpnStatus>(
      stream: vpn.statusStream,
      initialData: vpn.status,
      builder: (context, snap) {
        final status = snap.data ?? VpnStatus.disconnected;
        final isConnected = status == VpnStatus.connected;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const AppLogo(),
                const SizedBox(height: 24),
                Text(
                  isConnected ? 'Connected' : (status == VpnStatus.connecting ? 'Connecting…' : 'Disconnected'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ConnectButton(
                  isConnected: isConnected,
                  onPressed: () async {
                    if (isConnected) {
                      await vpn.disconnect();
                      return;
                    }

                    final user = auth.currentUser;
                    if (user != null) {
                      final profile = await ref.read(firestoreServiceProvider).getUserProfile(user.uid);
                      if (profile.isSubscribed) {
                        await vpn.connect();
                        return;
                      }
                    }

                    _showAccessOptions();
                  },
                ),
                const SizedBox(height: 16),
                const Spacer(),
                Column(
                  children: const [
                    Text('Start Free Trial NOW'),
                    SizedBox(height: 8),
                    AdBanner(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAccessOptions() async {
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: const Text('Buy Subscription Plan'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  if (user == null) {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                  }
                  if (mounted) {
                    final scaffold = ScaffoldMessenger.of(context);
                    scaffold.showSnackBar(const SnackBar(content: Text('Open Plans tab to subscribe.')));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.ondemand_video),
                title: const Text('Free 1 Hour Access With Ad'),
                subtitle: const Text('Available once per day'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  if (auth.currentUser == null) {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                  }
                  try {
                    final ok = await ref.read(freeAccessServiceProvider).startDailyFreeAccess();
                    if (!ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Free access already used today.')));
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}