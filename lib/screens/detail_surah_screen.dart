import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_ku_6a_si/providers/providers.dart';

class DetailSurahScreen extends StatelessWidget {
  final int surahNumber;
  
  const DetailSurahScreen({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SurahProvider>(context, listen: false).fetchSurahDetail(surahNumber);
    });

    return Scaffold(
      appBar: AppBar(
        title: Consumer<SurahProvider>(
          builder: (context, provider, child) {
            if(provider.selectedSurah != null) {
              return Text('${provider.selectedSurah!.nomor}. ${provider.selectedSurah!.nama ?? 'Tidak Diketahui'}');
            }
            return Text('Detail Surah');
          },
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Text('Detail Surah'),
      ),
    );
  }
}