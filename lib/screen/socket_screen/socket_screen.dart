import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtech_transmitter_app/screen/socket_screen/bloc/socket_bloc.dart';
import 'package:playtech_transmitter_app/screen/socket_screen/bloc/socket_state.dart';
import 'package:playtech_transmitter_app/screen/socket_screen/model/infomation_broadcast_model.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController jackpotIdController = TextEditingController();
    return  Scaffold(
      body: Container(
          alignment: Alignment.center,
          width:MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<SocketBloc, SocketState>(
            builder: (context, state) {
              return Text(
                    '${state.latestBroadcasts} Connection Status: ${state.isConnected ? 'Connected' : 'Disconnected'}',
                    style: TextStyle(
                      color: state.isConnected ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  );
            },
          ),
      ),
    );
  }

  Widget _buildBroadcastData(InformationBroadcast broadcast) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log ID: ${broadcast.logId}'),
            Text('Timestamp: ${broadcast.timestamp.toString()}'),
            Text('ID: ${broadcast.id}'),
            const SizedBox(height: 8),
            const Text(
              'Jackpots:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...broadcast.jackpots.map((jackpot) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text('Jackpot ID: ${jackpot.jackpotId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${jackpot.jackpotName ?? 'N/A'}'),
                        Text('Value: ${jackpot.value.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
