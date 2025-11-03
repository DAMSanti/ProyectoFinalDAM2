import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

/// Widget para grabar mensajes de audio
class AudioRecorderWidget extends StatefulWidget {
  final Function(String path, int duration) onRecordingComplete;
  final VoidCallback onCancel;

  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Obtener directorio temporal para guardar el audio
        final tempDir = await getTemporaryDirectory();
        final audioPath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        // Configuración para grabar audio
        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: audioPath);
        
        setState(() {
          _isRecording = true;
          _recordDuration = 0;
          _audioPath = audioPath;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration++;
          });

          // Límite de 5 minutos
          if (_recordDuration >= 300) {
            _stopRecording();
          }
        });
      } else {
        _showError('No se tienen permisos para grabar audio');
      }
    } catch (e) {
      _showError('Error al iniciar grabación: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      _timer?.cancel();
      
      if (_audioPath != null) {
        setState(() {
          _isRecording = false;
        });
        widget.onRecordingComplete(_audioPath!, _recordDuration);
      }
    } catch (e) {
      _showError('Error al detener grabación: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _timer?.cancel();
      widget.onCancel();
    } catch (e) {
      _showError('Error al cancelar grabación: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón cancelar
          IconButton(
            onPressed: _cancelRecording,
            icon: const Icon(Icons.close),
            color: Colors.red,
            tooltip: 'Cancelar',
          ),
          
          const SizedBox(width: 8),
          
          // Animación de grabación
          if (_isRecording) ...[
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          // Duración
          Text(
            _formatDuration(_recordDuration),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          
          const Spacer(),
          
          // Texto de instrucción
          Text(
            'Grabando audio...',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          
          const Spacer(),
          
          // Botón enviar
          IconButton(
            onPressed: _isRecording ? _stopRecording : null,
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            iconSize: 28,
            tooltip: 'Enviar',
          ),
        ],
      ),
    );
  }
}
