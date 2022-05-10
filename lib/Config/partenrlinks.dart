import 'package:url_launcher/url_launcher.dart';

const String partnerSiteLink = 'https://www.netmeds.com/';

LaunchPartenerSite() async {
  print("here");
  Uri link = Uri.parse(partnerSiteLink);
  if (!await launchUrl(link, mode: LaunchMode.externalApplication))
    print('Could not launch');
}
