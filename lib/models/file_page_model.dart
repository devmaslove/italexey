import 'package:directus/directus.dart';
import 'package:italexey/resources/env.dart';

/// Fit of the thumbnail
///
/// The fit of the thumbnail while always preserving the aspect ratio,
/// can be any of the following options
enum DirectusThumbnailFit {
  /// Covers both width/height by cropping/clipping to fit
  cover,

  /// Contain within both width/height using "letterboxing" as needed
  contain,

  /// Resize to be as large as possible, ensuring dimensions are less
  /// than or equal to the requested width and height
  inside,

  /// Resize to be as small as possible, ensuring dimensions are greater
  /// than or equal to the requested width and height
  outside,
}

/// File format to return the thumbnail in
///
/// What file format to return the thumbnail in. One of jpg, png, webp, tiff
enum DirectusThumbnailFormat {
  jpg,
  png,
  webp,
  tiff,
}

extension FilePageModel on DirectusFile {
  String thumbnailUrl({
    required int width,
    required int height,
    DirectusThumbnailFit fit = DirectusThumbnailFit.cover,
    int? quality,
    DirectusThumbnailFormat? format,
  }) {
    if (id == null) return '';
    // Remove trailing / if exists.
    String baseUrl = AppEnv.link;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    String url =
        '$baseUrl/assets/$id?fit=${fit.name}&width=$width&height=$height';
    if (quality != null) {
      assert(
        quality >= 1 && quality <= 100,
        'quality of the thumbnail should be from 1 to 100',
      );
      url += '&quality=$quality';
    }
    if (format != null) {
      url += '&format=${format.name}';
    }
    return url;
  }

  String getFileExt() {
    if (filenameDisk == null) return '';
    final fileNameParts = filenameDisk!.split('.');
    if (fileNameParts.length < 2) return '';
    return fileNameParts.last.toUpperCase();
  }

  String getFileSize() {
    if (filesize == null || filesize == 0) return '';
    if (filesize! < 1024) return '$filesize B';
    if (filesize! < 1024 * 1024) {
      return '${(filesize! / 1024).toStringAsFixed(1).replaceAll('.0', '')} kB';
    }
    final fileSizeMB = filesize! / (1024 * 1024);
    return '${fileSizeMB.toStringAsFixed(1).replaceAll('.0', '')} MB';
  }

  String getFileTitle() {
    return title ?? 'null';
  }

  String getFileDescription() {
    return description ?? '';
  }

  double getImageRatio() {
    final imageWidth = width ?? 0;
    final imageHeight = height ?? 0;
    if (imageWidth == 0 || imageHeight == 0) return 0.0;
    return imageWidth / imageHeight;
  }

  bool get isImage =>
      type != null && type!.startsWith('image/') && type! != 'image/svg+xml';
}
