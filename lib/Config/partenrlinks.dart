import 'package:url_launcher/url_launcher.dart';

const String partnerSiteLink = 'https://www.netmeds.com/';
const String partnerSearchLink =
    'https://www.netmeds.com/catalogsearch/result?q=';

LaunchPartenerSite([String? medName = '']) async {
  if (medName == '' || medName == null) {
    Uri link = Uri.parse(partnerSiteLink);
    if (!await launchUrl(link, mode: LaunchMode.externalApplication)) {
      print('Could not launch');
    }
  } else {
    Uri link = Uri.parse(partnerSearchLink + medName);
    if (!await launchUrl(link, mode: LaunchMode.externalApplication)) {
      print('Could not launch');
    }
  }
}
