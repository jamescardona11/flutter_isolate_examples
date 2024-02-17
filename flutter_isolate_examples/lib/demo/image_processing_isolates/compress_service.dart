import 'package:flutter/services.dart';
import 'package:flutter_isolate_examples/demo/utils/file_info.dart';
import 'package:image/image.dart';

class CompressImageService {
  final FileInfo data;

  CompressImageService(this.data);

  Future<Uint8List> executeCompression(Uint8List bytes) async {
    final decoder = findDecoderForData(bytes);

    if (decoder is JpegDecoder || decoder is PngDecoder) {
      bytes = decoder is PngDecoder ? await _compressPngImage(bytes) : await _compressJpegImage(bytes);
    }

    return bytes;
  }

  ImageResolution get _maxResolution => data.maxResolution ?? ImageResolution.uhd;
  int get _maxSize => data.maxSize;

  Future<Uint8List> _compressJpegImage(Uint8List bytes) async {
    const minQuality = 0;
    const maxQuality = 100;
    const step = 10;

    ImageResolution? resolution = _maxResolution;
    Image? image = decodeImage(bytes);

    if (image == null) {
      return bytes;
    } else if (bytes.length > _maxSize) {
      List<int>? data;
      do {
        if (resolution != null) {
          image = _resizeWithResolution(image!, resolution);
          print('resizeWithResolution: ${resolution.width} - ${resolution.height}');
        }

        data = encodeJpg(image!, quality: maxQuality);
        print('encodeJpg - _maxQuality: ${data.length}');

        if (data.length > _maxSize) {
          data = encodeJpg(image, quality: minQuality);
          print('encodeJpg - _minQuality: ${data.length}');

          if (data.length < _maxSize) {
            int quality = maxQuality;
            do {
              quality -= step;
              data = encodeJpg(image, quality: quality);
              print('encodeJpg - _quality - $quality: ${data.length}');
            } while (data.length > _maxSize && quality > minQuality);

            break;
          }
        }

        resolution = resolution?.prev();
      } while (resolution != null);

      return Uint8List.fromList(data);
    }

    return bytes;
  }

  Future<Uint8List> _compressPngImage(Uint8List bytes) async {
    const minLevel = 0;
    const maxLevel = 9;
    const step = 1;

    ImageResolution? resolution = _maxResolution;
    Image? image = decodeImage(bytes);

    if (image == null) {
      return bytes;
    } else if (bytes.length > _maxSize) {
      List<int>? data;
      do {
        if (resolution != null) {
          image = _resizeWithResolution(image!, resolution);
          print('resizeWithResolution: ${resolution.width} - ${resolution.height}');
        }

        data = encodePng(image!, level: minLevel);
        print('encodePNG - _minLevel: ${data.length}');

        if (data.length > _maxSize) {
          data = encodePng(image, level: maxLevel);
          print('encodePNG - _maxLevel: ${data.length}');

          if (data.length < _maxSize) {
            int level = minLevel;
            do {
              level += step;
              data = encodePng(image, level: level);
              print('encodePNG - _level - $level: ${data.length}');
            } while (data.length > _maxSize && level < maxLevel);

            break;
          }
        }
        resolution = resolution?.prev();
      } while (resolution != null);

      return Uint8List.fromList(data);
    }

    return bytes;
  }

  Image _resizeWithResolution(Image image, ImageResolution resolution) {
    int? newWidth, newHeight;
    if (image.width < image.height) {
      if (image.height > resolution.height) {
        newHeight = resolution.height;
      }
    } else {
      if (image.width > resolution.width) {
        newWidth = resolution.width;
      }
    }
    if (newWidth != null || newHeight != null) {
      return copyResize(image, width: newWidth, height: newHeight);
    }

    return image;
  }
}
