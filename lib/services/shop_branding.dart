import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ebill/database/company_info_service.dart';
import 'package:ebill/database/settings_service.dart';
import 'package:ebill/models/company_info.dart';
import 'package:ebill/services/pdf/pdf_service.dart';

/// Default CellTek shop identity for offline printable bills.
class ShopBranding {
  static const name = 'CELL TEK';
  static const gstin = '37HNXPS3506L2ZY';
  static const address = '';
  static const phone = '';
  static const email = '';
  static const website = '';
  static const country = 'India';
  static const logoAsset = 'assets/images/celltek_logo.png';

  static Future<Uint8List> loadDefaultLogoBytes() async {
    final data = await rootBundle.load(logoAsset);
    return data.buffer.asUint8List();
  }

  static Future<String> loadDefaultLogoBase64() async {
    final bytes = await loadDefaultLogoBytes();
    return base64Encode(bytes);
  }

  /// Seed company + logo for first run / placeholder installs.
  static Future<void> ensureDefaults() async {
    final existing = await CompanyInfoService.getCompanyInfo();
    final existingWebsite = existing?.website.trim() ?? '';
    final needsCompanySeed = existing == null ||
        existing.name.trim().isEmpty ||
        existing.name == 'Your Company Name' ||
        existing.gstin.trim().isEmpty ||
        existingWebsite.toLowerCase().contains('invoiso');

    if (needsCompanySeed) {
      final seeded = CompanyInfo(
        id: existing?.id,
        name: (existing != null &&
                existing.name.trim().isNotEmpty &&
                existing.name != 'Your Company Name')
            ? existing.name
            : name,
        address: (existing?.address.trim().isNotEmpty ?? false)
            ? existing!.address
            : address,
        phone: (existing?.phone.trim().isNotEmpty ?? false)
            ? existing!.phone
            : phone,
        email: (existing?.email.trim().isNotEmpty ?? false)
            ? existing!.email
            : email,
        website: existingWebsite.toLowerCase().contains('invoiso')
            ? website
            : ((existing?.website.trim().isNotEmpty ?? false)
                ? existing!.website
                : website),
        gstin: (existing?.gstin.trim().isNotEmpty ?? false)
            ? existing!.gstin
            : gstin,
        panNumber: existing?.panNumber ?? '',
        country: existing?.country.isNotEmpty == true
            ? existing!.country
            : country,
      );
      if (existing?.id == null) {
        await CompanyInfoService.insertCompanyInfo(seeded);
      } else {
        await CompanyInfoService.updateCompanyInfo(seeded);
      }
    }

    // Always use the CellTek shop logo (replace any old Invoiso app logo).
    final b64 = await loadDefaultLogoBase64();
    await SettingsService.setCompanyLogo(b64);
    PDFService.clearLogoCache();
  }
}
