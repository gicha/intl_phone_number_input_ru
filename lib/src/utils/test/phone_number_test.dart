import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:intl_phone_number_input/src/models/country_list.dart';
import 'package:intl_phone_number_input/src/utils/phone_number/phone_number_util.dart';

class PhoneNumberTest {
  PhoneNumberTest({this.phoneNumber, this.dialCode, this.isoCode});
  final String? phoneNumber;
  final String? dialCode;
  final String? isoCode;

  @override
  String toString() => phoneNumber!;

  static Future<PhoneNumberTest> getRegionInfoFromPhoneNumber(
    String phoneNumber, [
    String isoCode = '',
  ]) async {
    final RegionInfo regionInfo = await PhoneNumberUtil.getRegionInfo(
      phoneNumber: phoneNumber,
      isoCode: isoCode,
    );

    final String? internationalPhoneNumber = await PhoneNumberUtil.normalizePhoneNumber(
      phoneNumber: phoneNumber,
      isoCode: regionInfo.isoCode ?? isoCode,
    );

    return PhoneNumberTest(
      phoneNumber: internationalPhoneNumber,
      dialCode: regionInfo.regionPrefix,
      isoCode: regionInfo.isoCode,
    );
  }

  static Future<String> getParsableNumber(PhoneNumberTest phoneNumber) async {
    if (phoneNumber.isoCode != null) {
      final PhoneNumberTest number = await getRegionInfoFromPhoneNumber(
        phoneNumber.phoneNumber!,
        phoneNumber.isoCode!,
      );
      final String? formattedNumber = await PhoneNumberUtil.formatAsYouType(
        phoneNumber: number.phoneNumber!,
        isoCode: number.isoCode!,
      );
      return formattedNumber!.replaceAll(
        RegExp('^([\\+]?${number.dialCode}[\\s]?)'),
        '',
      );
    } else {
      throw Exception('ISO Code is "${phoneNumber.isoCode}"');
    }
  }

  String parseNumber() => phoneNumber!.replaceAll(RegExp('^([\\+]?$dialCode[\\s]?)'), '');

  static String? getISO2CodeByPrefix(String prefix) {
    if (prefix.isNotEmpty) {
      final formattedPrefix = prefix.startsWith('+') ? prefix : '+$prefix';
      final country = Countries.countryList.firstWhereOrNull((country) => country['dial_code'] == formattedPrefix);
      if (country != null && country['alpha_2_code'] != null) {
        return country['alpha_2_code'] as String?;
      }
    }
    return null;
  }
}
