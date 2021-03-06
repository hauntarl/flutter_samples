import 'package:flutter/material.dart';
import 'package:flutter_samples/download_simulator/download_controller.dart';
import 'package:flutter_samples/lottie_transition/lottie_transition.dart';
import 'package:lottie/lottie.dart';

class Info {
  // Lottie file - https://lottiefiles.com/834-download-icon#
  // 0 - 145 start download animation
  // 145 - 188 download progress animation
  // 188 - 240 download complete animation
  // 240 - 320 reset download animation
  Info._();

  static const filePath = 'assets/lottie_download_button.json';
  static const frameTotal = 320; // total frames
  static const frameProgB = 145; // progress start frame
  static const frameProgE = 188; // progress end frame
  static const frameProgT = frameProgE - frameProgB; // total progress frames
  static const frameFinal = 240; // download complete frame
}

class LottieDownloadButton extends StatefulWidget {
  final Size size;
  final DownloadStatus status;
  final double progress;
  final VoidCallback onStart, onCancel, onOpen, onReset;

  const LottieDownloadButton({
    Key? key,
    this.size = const Size(300, 300),
    required this.status,
    required this.progress,
    required this.onStart,
    required this.onCancel,
    required this.onOpen,
    required this.onReset,
  }) : super(key: key);

  @override
  _LottieDownloadButtonState createState() => _LottieDownloadButtonState();
}

class _LottieDownloadButtonState extends State<LottieDownloadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void didUpdateWidget(LottieDownloadButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    switch (widget.status) {
      case DownloadStatus.fetching:
        var progress = Info.frameProgB + Info.frameProgT * widget.progress;
        _controller.animateTo(progress / Info.frameTotal);
        break;
      case DownloadStatus.downloaded:
        _controller.animateTo(Info.frameFinal / Info.frameTotal);
        break;
      default:
    }
  }

  void onPressed() async {
    switch (widget.status) {
      case DownloadStatus.cancelled:
        _controller.animateTo(Info.frameProgB / Info.frameTotal);
        widget.onStart();
        break;
      case DownloadStatus.preparing:
      case DownloadStatus.fetching:
        _controller.reverse();
        widget.onCancel();
        break;
      case DownloadStatus.downloaded:
        widget.onOpen();
        break;
    }
  }

  void onLongPressed() async {
    widget.onReset();
    await _controller.animateTo(1);
    _controller.reset();
  }

  Widget _buildButton(LottieComposition composition) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPressed,
      child: LottieTransition(
        animation: _controller,
        composition: composition,
        size: widget.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LottieComposition>(
      future: AssetLottie(Info.filePath).load(),
      builder: (_, snapshot) {
        final composition = snapshot.data;
        return composition != null ? _buildButton(composition) : Container();
      },
    );
  }
}
