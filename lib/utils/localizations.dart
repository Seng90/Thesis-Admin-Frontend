import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/settings/controllers/settings_controller.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'Dashboard': 'Dashboard',
      'Companies': 'Companies',
      'Investors': 'Investors',
      'Members': 'Members',
      'Packages': 'Packages',
      'Settings': 'Settings',
      'Logout': 'Logout',
      'Add Company': 'Add Company',
      'Edit Company': 'Edit Company',
      'Add Investor': 'Add Investor',
      'Edit Investor': 'Edit Investor',
      'Add Package': 'Add Package',
      'Edit Package': 'Edit Package',
      'Manage Member': 'Manage Member',
      'Confirm Logout': 'Confirm Logout',
      'Are you sure you want to logout?': 'Are you sure you want to logout?',
      'Cancel': 'Cancel',
      'Delete': 'Delete',
      'Save Changes': 'Save Changes',
      'Update Investor': 'Update Investor',
      'COMPANY': 'COMPANY',
      'INDUSTRY': 'INDUSTRY',
      'LOCATION': 'LOCATION',
      'STATUS': 'STATUS',
      'VIEWS': 'VIEWS',
      'ACTIONS': 'ACTIONS',
      'INVESTOR': 'INVESTOR',
      'TYPE': 'TYPE',
      'WEBSITE': 'WEBSITE',
      'MEMBER': 'MEMBER',
      'EMAIL': 'EMAIL',
      'EXPIRY': 'EXPIRY',
      'PACKAGE': 'PACKAGE',
      'PRICE': 'PRICE',
      'PURCHASES': 'PURCHASES',
      'View Details': 'View Details',
      'Approve': 'Approve',
      'Block': 'Block',
      'Audit Logs': 'Audit Logs',
      'Action History': 'Action History',
      'Admin': 'Admin',
      'Action': 'Action',
      'Date & Time': 'Date & Time',
      'No logs found': 'No logs found',
      'Search logs...': 'Search logs...',
      'Sync Expiry': 'Sync Expiry',
      'Expirations checked and synced successfully!':
          'Expirations checked and synced successfully!',
      'Failed to sync expirations.': 'Failed to sync expirations.',
    },
    'lo': {
      'Dashboard': 'ແຜງຄວບຄຸມ',
      'Companies': 'ບໍລິສັດ',
      'Investors': 'ນັກລົງທຶນ',
      'Members': 'ສະມາຊິກ',
      'Packages': 'ແພັກເກດ',
      'Settings': 'ຕັ້ງຄ່າ',
      'Logout': 'ອອກຈາກລະບົບ',
      'Add Company': 'ເພີ່ມບໍລິສັດ',
      'Edit Company': 'ແກ້ໄຂບໍລິສັດ',
      'Add Investor': 'ເພີ່ມນັກລົງທຶນ',
      'Edit Investor': 'ແກ້ໄຂນັກລົງທຶນ',
      'Add Package': 'ເພີ່ມແພັກເກດ',
      'Edit Package': 'ແກ້ໄຂແພັກເກດ',
      'Manage Member': 'ຈັດການສະມາຊິກ',
      'Confirm Logout': 'ຢືນຢັນການອອກຈາກລະບົບ',
      'Are you sure you want to logout?': 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?',
      'Cancel': 'ຍົກເລີກ',
      'Delete': 'ລຶບ',
      'Save Changes': 'ບັນທຶກການປ່ຽນແປງ',
      'Update Investor': 'ອັບເດດນັກລົງທຶນ',
      'COMPANY': 'ບໍລິສັດ',
      'INDUSTRY': 'ອຸດສາຫະກຳ',
      'LOCATION': 'ສະຖານທີ່',
      'STATUS': 'ສະຖານະ',
      'VIEWS': 'ຍອດເຂົ້າຊົມ',
      'ACTIONS': 'ຈັດການ',
      'INVESTOR': 'ນັກລົງທຶນ',
      'TYPE': 'ປະເພດ',
      'WEBSITE': 'ເວັບໄຊທ໌',
      'MEMBER': 'ສະມາຊິກ',
      'EMAIL': 'ອີເມວ',
      'EXPIRY': 'ວັນໝົດອາຍຸ',
      'PACKAGE': 'ແພັກເກດ',
      'PRICE': 'ລາຄາ',
      'PURCHASES': 'ຍອດສັ່ງຊື້',
      'View Details': 'ເບິ່ງລາຍລະອຽດ',
      'Approve': 'ອະນຸມັດ',
      'Block': 'ບລັອກ',
      'Audit Logs': 'ປະຫວັດການຈັດການ',
      'Action History': 'ປະຫວັດການເຄື່ອນໄຫວ',
      'Admin': 'ຜູ້ດູແລ',
      'Action': 'ການກະທຳ',
      'Date & Time': 'ວັນທີ & ເວລາ',
      'No logs found': 'ບໍ່ພົບປະຫວັດການເຄື່ອນໄຫວ',
      'Search logs...': 'ຄົ້ນຫາປະຫວັດ...',
      'Sync Expiry': 'ຊິງຄ໌ວັນໝົດອາຍຸ',
      'Expirations checked and synced successfully!':
          'ກວດສອບ ແລະ ຊິງຄ໌ຂໍ້ມູນໝົດອາຍຸສຳເລັດແລ້ວ!',
      'Failed to sync expirations.': 'ບໍ່ສາມາດຊິງຄ໌ຂໍ້ມູນໝົດອາຍຸໄດ້',
    },
  };

  static String translate(
    BuildContext context,
    String key, {
    bool listen = true,
  }) {
    try {
      final lang = Provider.of<SettingsController>(
        context,
        listen: listen,
      ).languageCode;
      return _localizedValues[lang]?[key] ??
          _localizedValues['en']?[key] ??
          key;
    } catch (_) {
      return key;
    }
  }
}

extension StringLocalization on String {
  String tr(BuildContext context, {bool listen = true}) {
    return AppLocalizations.translate(context, this, listen: listen);
  }
}
