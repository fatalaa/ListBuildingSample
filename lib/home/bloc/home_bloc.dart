/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import 'dart:async';

import 'package:ListBuildingSample/bloc/bloc_base.dart';
import 'package:ListBuildingSample/home/model/scanned_item.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';

import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_spark_scan.dart';

// There is a Scandit sample license key set below here.
// This license key is enabled for sample evaluation only.
// If you want to build your own application, get your license key by signing up for a trial at https://ssl.scandit.com/dashboard/sign-up?p=test
const String licenseKey = 'Akq0WzL+Fw5TGIN5mHwPMV8h39u5OGnIYzwzkCrAOs4jYNGlwlk9huIac0hHZM9oz3hluLEujWkDT0L1MmAkzlEZ0RN7eytEj0Xi+WRug+fBai5VSUhc+JpSQO7IDkJe2jR6teMZAyzaMcm3RHvXe013pOslXr8D9ne75pZ9KhK8E9XvdEaViWVTtqwxD3mvlxBzNnZoS2jedM/gN3mFLKx/05bJSd/MJ05OaX5zeDRlfF9V00tCgk54wqddXVHkFE3uuXVdIrZ3D1WRkHMTEugtugi4QMG1oUbRcrZlP+2qZf2gR2yvNZ5cBCi6VaYVeXGM8/ByV/DhC6oAD2FZNaVbCY9eV952HygxYkxFLmW3c8vsF1TqojJyrg8dCxTFmmTEx9lHLU3YeTVQsU47y4IQTjsEZGDrV17y/bNXXp/FQhEcVXzH+8pekuOmHzF10EUdhmtjtCphdxuh3Gq5GZdxYBxNRpsLTk6oHKVQ3tvHfyDq31O9uBx7+lhqVNku8TRmsTRI4PrkYXmaJ2MyjaUSb0B4VMrSznhuydExgnVLds3ZvULbzKtBB36kNeKwCkkDkJQXsHLqeglExnbFitRDL+f+Rt8TfU5gnOkhJwZHf5cp9mKqzVpr5UUHe3Xc5CzI6qN9taKbG9TAX1pmIqJ1y3/TajS3QlP3F7J2+RHwUMSUm3PCD0YYUZticKtLXRonDbdqeMPoeKSGCXUf2AtlpDr8C6EFZEDibAR89opHdmk7flGl07E9P2SZQ9cDFXsYHbFY96p5RktuCXwylJxIBgn3Q24jdUz8Zs9ekTTsYGygPXa40ylpxnjWXNfDmXDo9ao88/lCCw5wDV0wEXBnipl1faqFvQ+zdl9y4YBaTez/ViR2ATkBJ5NIY06nvA8K9XNlcHVZa30AWlInc8Yi/itwaqtq/1xJ1oc9x6aCSH8G3k4Hhu8am4E1eJunQ4e51g0vNhV6XLYVp+RTSng5PLGR3QQ3O/vSiq4MAsxSdHKAaBh6oySaggeQcfsljXdRzkAuwlyWu2WN/dYqhbPITmXeT03ILTuuNQH5m/+mwLj4sMh7UUxnzbvIjdzo2BOfmxIKZMW8moJMWoB33/ZZW4vJfp+aIG4dXehN/QThPm1/hu2+GCLgnToYgnLX4RvP/AFtqjvy3931AMjhlUk80da2bspQS+h7umPZRDjLhw7CFUJ/2FrkkRwkWHnS6DyVwkJKoTMXCy1H59qypnrthefrdCjCAHW1grzucUOlv7d4d8X8CXbdZ3Bh9aFC9TI0U2m066w9A3byqKCduiulJelZQnDNWPWEEZthGtJf7raehngDxaNlrIc+d59mkRhqnJnF06b4Q53kmXxZi81PCVZ6EfJR8Qnt3+aVigfwIXUY8Ht56GeXBakIZtDXXUhmy28J8FxYLvX+GLGH6Er63YSle7x7IDEsYrq5r0yS7riL0MjaCkKrhLwnJX4yE/xy2RTtK8tF5030I3kBwQrBnn1QZ1AL+THT2+28ni1lNDi1VrMsi8krzXYpq067RW2hBaln7oYMNpVYD23W73N/P5A/7cv8Qg28etrScWG/KuWFQgkN5xZcDJMK74JBWik7OcuFWIP258Kr1vqGMqDGbDs0/dibLAo=';

class HomeBloc extends Bloc implements SparkScanListener {
  // Create data capture context using your license key.
  final DataCaptureContext _dataCaptureContext = DataCaptureContext.forLicenseKey(licenseKey);

  DataCaptureContext get dataCaptureContext {
    return _dataCaptureContext;
  }

  late SparkScan _sparkScan;

  SparkScan get sparkScan {
    return _sparkScan;
  }

  late SparkScanViewSettings _sparkScanViewSettings;

  SparkScanViewSettings get sparkScanViewSettings {
    return _sparkScanViewSettings;
  }

  late StreamController<ScannedItem> _streamController;

  Stream<ScannedItem> get scannedItemsStream {
    return _streamController.stream;
  }

  HomeBloc() {
    _init();
  }

  void _init() {
    // The spark scan process is configured through SparkScan settings
    // which are then applied to the spark scan instance that manages the spark scan.
    var sparkScanSettings = new SparkScanSettings();

    // The settings instance initially has all types of barcodes (symbologies) disabled.
    // For the purpose of this sample we enable a very generous set of symbologies.
    // In your own app ensure that you only enable the symbologies that your app requires
    // as every additional enabled symbology has an impact on processing times.
    sparkScanSettings.enableSymbologies({
      Symbology.ean13Upca,
      Symbology.ean8,
      Symbology.upce,
      Symbology.code39,
      Symbology.code128,
      Symbology.interleavedTwoOfFive
    });

    // Some linear/1d barcode symbologies allow you to encode variable-length data.
    // By default, the Scandit Data Capture SDK only scans barcodes in a certain length range.
    // If your application requires scanning of one of these symbologies, and the length is
    // falling outside the default range, you may need to adjust the "active symbol counts"
    // for this symbology. This is shown in the following few lines of code for one of the
    // variable-length symbologies.
    var symbologySettings = sparkScanSettings.settingsForSymbology(Symbology.code39);
    symbologySettings.activeSymbolCounts = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20};

    // Create the spark scan instance.
    // Spark scan will automatically apply and maintain the optimal camera settings.
    _sparkScan = new SparkScan.withSettings(sparkScanSettings);

    // Register self as a listener to get informed of tracked barcodes.
    _sparkScan.addListener(this);

    // You can customize the SparkScanView using SparkScanViewSettings.
    _sparkScanViewSettings = new SparkScanViewSettings();

    // Setup stream controller to notify the UI of new scanned items
    _streamController = StreamController.broadcast();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  int _scannedItems = 0;

  @override
  void didScan(SparkScan sparkScan, SparkScanSession session, Future<FrameData> Function() getFrameData) {
    var barcode = session.newlyRecognizedBarcodes.firstOrNull;

    if (barcode == null) return;

    if (_isValidBarcode(barcode)) {
      _scannedItems += 1;

      var humanReadableSymbology = SymbologyDescription.forSymbology(barcode.symbology);

      _streamController
          .add(new ScannedItem("Item $_scannedItems", "${humanReadableSymbology.readableName}: ${barcode.data}"));
    } else {
      _streamController.addError("This code should not have been scanned");
    }
  }

  bool _isValidBarcode(Barcode barcode) {
    return barcode.data != null && barcode.data != "123456789";
  }

  @override
  void didUpdateSession(SparkScan sparkScan, SparkScanSession session, Future<FrameData> Function() getFrameData) {
    // TODO: implement didUpdateSession
  }

  void clear() {
    _scannedItems = 0;
  }
}
