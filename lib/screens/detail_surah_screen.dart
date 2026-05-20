import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import '../providers/providers.dart';

class DetailSurahScreen extends StatefulWidget {
  final int surahNumber;

  const DetailSurahScreen({super.key, required this.surahNumber});

  @override
  State<DetailSurahScreen> createState() => _DetailSurahScreenState();
}

class _DetailSurahScreenState extends State<DetailSurahScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingUrl;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SurahProvider>(context, listen: false)
          .fetchSurahDetail(widget.surahNumber);
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.completed) {
            _playingUrl = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    if (_playingUrl == url && _isPlaying) {
      await _audioPlayer.pause();
    } else if (_playingUrl == url && !_isPlaying) {
      await _audioPlayer.resume();
    } else {
      setState(() => _playingUrl = url);
      await _audioPlayer.play(UrlSource(url));
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _playingUrl = null;
      _isPlaying = false;
    });
  }

  Widget _buildAudioButton(String? url, {bool isSurah = false}) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    final isThisPlaying = _playingUrl == url && _isPlaying;
    return Row(
      mainAxisAlignment: isSurah ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(
            isThisPlaying ? Icons.pause_circle : Icons.play_circle_outline,
            color: isSurah ? Colors.green : Colors.green[700],
            size: isSurah ? 32 : 28,
          ),
          onPressed: () => _playAudio(url),
        ),
        if (_playingUrl == url)
          IconButton(
            icon: Icon(Icons.stop_circle_outlined, color: Colors.red[400], size: isSurah ? 32 : 28),
            onPressed: _stopAudio,
          ),
        Text(
          isSurah ? 'Dengarkan Surat' : 'Audio',
          style: TextStyle(
            color: isSurah ? Colors.green : Colors.grey,
            fontWeight: isSurah ? FontWeight.w500 : FontWeight.normal,
            fontSize: isSurah ? 14 : 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SurahProvider>(
          builder: (context, provider, child) {
            if (provider.selectedSurah != null) {
              return Text('${provider.selectedSurah!.nomor}. ${provider.selectedSurah!.nama}');
            }
            return const Text('Detail Surah');
          },
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Consumer<SurahProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedSurah == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchSurahDetail(widget.surahNumber);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.selectedSurah == null) {
            return const Center(
              child: Text('Tidak ada data surah'),
            );
          }

          final surah = provider.selectedSurah!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Surah Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    surah.nomor.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surah.nama,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      surah.namaLatin,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfoChip(surah.jumlahAyat.toString(), 'Ayat'),
                              const SizedBox(width: 8),
                              _buildInfoChip(surah.tempatTurun, 'Turun'),
                              const SizedBox(width: 8),
                              _buildInfoChip(surah.arti, 'Arti'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (surah.audioFull.isNotEmpty)
                            _buildAudioButton(surah.audioFull['01'], isSurah: true),
                          const SizedBox(height: 16),
                          ExpansionTile(
                            title: const Text(
                              'Deskripsi Surat',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Html(
                                  data: surah.deskripsi,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(14),
                                      color: Colors.grey[700],
                                    ),
                                    "i": Style(
                                      fontStyle: FontStyle.italic,
                                    ),
                                    "br": Style(
                                      margin: Margins.only(top: 8.0),
                                    ),
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ayat List
                  const Text(
                    'Daftar Ayat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...surah.ayat.map((ayah) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      ayah.nomorAyat.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ayah.teksArab,
                              style: const TextStyle(
                                fontSize: 24,
                                height: 2,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ayah.teksLatin,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ayah.teksIndonesia,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (ayah.audio.isNotEmpty)
                              _buildAudioButton(ayah.audio['01']),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(String label, String description) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            description,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}