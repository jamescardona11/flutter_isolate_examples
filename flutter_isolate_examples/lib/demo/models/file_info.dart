class FileInfo {
  final int maxSize;
  final ImageResolution? maxResolution;
  final String fileLocation;

  FileInfo({
    required this.maxSize,
    required this.fileLocation,
    this.maxResolution,
  });
}

enum ImageResolution {
  sd(640, 480),
  hd(1280, 720),
  fhd(1920, 1080),
  qhd(2560, 1440),
  uhd(3840, 2160);

  final int width;
  final int height;

  const ImageResolution(this.width, this.height);

  static const List<ImageResolution> all = [sd, hd, fhd, qhd, uhd];

  ImageResolution? prev() {
    final index = all.indexOf(this);
    if (index > 0) {
      return all[index - 1];
    }
    return null;
  }
}
