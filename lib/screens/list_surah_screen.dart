import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_ku_6a_si/models/surah.dart';
import 'package:quran_ku_6a_si/providers/providers.dart';

class ListSurahScreen extends StatelessWidget {
  const ListSurahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Surah'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),

      body: Consumer<SurahProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),

                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchSurahList();
                    },
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.surahList.length,
            itemBuilder: (context, index) {
              Surah surah = provider.surahList[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        surah.nomor.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    surah.nama,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${surah.namaLatin} . ${surah.jumlahAyat} Ayat . ${surah.tempatTurun} . ${surah.arti}',
                    style: TextStyle(fontSize: 16),
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
