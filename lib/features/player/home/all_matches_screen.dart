import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class AllMatchesScreen extends StatefulWidget {
  const AllMatchesScreen({super.key});

  @override
  State<AllMatchesScreen> createState() => _AllMatchesScreenState();
}

class _AllMatchesScreenState extends State<AllMatchesScreen> {
  final List<Map<String, dynamic>> allMatches = [
    {
      "team": "Green Field Team",
      "date": "Today, 8:00 PM",
      "location": "Downtown, Cairo",
      "type": "5v5",
      "status": "Confirmed",
      "price": "150 EGP",
      "spots": "2 Spots Left",
    },
    {
      "team": "The Warriors",
      "date": "Tomorrow, 7:00 PM",
      "location": "Nasr City, Cairo",
      "type": "7v7",
      "status": "Confirmed",
      "price": "200 EGP",
      "spots": "1 Spot Left",
    },
    {
      "team": "El Masr FC",
      "date": "11 May, 8:00 PM",
      "location": "Maadi, Cairo",
      "type": "5v5",
      "status": "Pending",
      "price": "150 EGP",
      "spots": "4 Spots Left",
    },
    {
      "team": "Falcons FC",
      "date": "15 May, 9:00 PM",
      "location": "Giza, Egypt",
      "type": "6v6",
      "status": "Confirmed",
      "price": "180 EGP",
      "spots": "3 Spots Left",
    },
    {
      "team": "Champions Team",
      "date": "20 May, 10:00 PM",
      "location": "Heliopolis, Cairo",
      "type": "7v7",
      "status": "Confirmed",
      "price": "220 EGP",
      "spots": "Full",
    },
  ];

  List<Map<String, dynamic>> filteredMatches = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredMatches = List.from(allMatches);
  }

  void searchMatches(String value) {
    setState(() {
      searchQuery = value;
      filteredMatches = allMatches.where((match) {
        final team = match["team"].toString().toLowerCase();
        final location = match["location"].toString().toLowerCase();
        return team.contains(value.toLowerCase()) ||
            location.contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // استدعاء واشتقاق مترجم اللغة من الـ Provider
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        // دعم زر الرجوع الذكي للتوافق مع الـ RTL والـ LTR
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: const Color(0xff1E1446),
          ),
        ),
        title: Text(
          t('all_matches'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xffEEF5E5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: TextField(
                  onChanged: searchMatches,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: t('search_matches'),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: filteredMatches.isEmpty
                  ? buildEmptyState(t)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredMatches.length,
                      itemBuilder: (context, index) {
                        final match = filteredMatches[index];
                        final isPending = match["status"] == "Pending";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            shadowColor: Colors.black.withOpacity(0.2),
                            elevation: 3,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CircleAvatar(
                                          radius: 28,
                                          backgroundImage: AssetImage(
                                            "assets/images/stadium.jpg",
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                match["team"]!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                  color: Color(0xff1E1446),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    match["date"]!,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      match["location"]!,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      match["type"]!,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    match["spots"]!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          match["spots"] ==
                                                              "Full"
                                                          ? Colors.red
                                                          : const Color(
                                                              0xff7CC000,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isPending
                                                ? const Color(0xffFFF3CD)
                                                : const Color(0xffD1E7DD),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text(
                                            match["status"]!,
                                            style: TextStyle(
                                              color: isPending
                                                  ? const Color(0xff856404)
                                                  : const Color(0xff0f5132),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Divider(
                                        height: 1,
                                        color: Colors.black12,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          match["price"]!,
                                          style: const TextStyle(
                                            color: Color(0xff1E1446),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 36,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xff7CC000,
                                              ),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                  ),
                                            ),
                                            onPressed: match["spots"] == "Full"
                                                ? null
                                                : () {},
                                            child: Text(
                                              t('join_match'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState(String Function(String) t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                size: 45,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t('no_matches_available'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff1E1446),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t('check_back_later_or_search') ??
                  "Check back later or try adjusting your search terms.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
