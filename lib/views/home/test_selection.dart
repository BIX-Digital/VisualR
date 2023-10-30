/*
 * Copyright 2023 BI X GmbH
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/meta.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/widgets/icons/dotted_line.dart';
import 'package:visualr_app/widgets/icons/ring.dart';
import 'package:visualr_app/widgets/page_indicator.dart';
import 'package:visualr_app/widgets/page_layout.dart';
import 'package:visualr_app/widgets/test_card.dart';

@RoutePage()
class TestSelectionPage extends StatefulWidget {
  const TestSelectionPage({super.key});

  @override
  State<TestSelectionPage> createState() => _TestSelectionPageState();
}

class _TestSelectionPageState extends State<TestSelectionPage> {
  int _currentIndex = 0;
  final PageController _controller = PageController(viewportFraction: 1 / 1.4);
  List<Widget> _cards = [];

  List<Widget> _getPageIndicators(int numberOfPages) {
    final List<Widget> indicators = [];
    for (int i = 0; i < numberOfPages; i++) {
      indicators.add(
        PageIndicator(
          isActive: i == _currentIndex,
        ),
      );
    }
    return indicators;
  }

  @override
  void initState() {
    super.initState();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    HapticFeedback.lightImpact();
  }

  void _onArrowPressed(int navigateTo) {
    _controller.animateToPage(
      _currentIndex + navigateTo,
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    _cards = [
      TestSelectionCard(
        color: const AppColors().orchid,
        testName: AppLocalizations.of(context)!.visualTests_distortion,
        test: UnityView.distortion,
        child: CustomPaint(
          size: const Size(150, 100),
          painter: DottedLinePainter(
            color: const AppColors().turquoise,
          ),
        ),
      ),
      TestSelectionCard(
        color: const AppColors().cornflower,
        testName: AppLocalizations.of(context)!.visualTests_contrast_dark,
        test: UnityView.contrastDark,
        child: CustomPaint(
          size: const Size(100, 100),
          painter: RingPainter(
            color: const AppColors().orchid,
            radius: 50.0,
          ),
        ),
      ),
      TestSelectionCard(
        color: const AppColors().turquoise,
        testName: AppLocalizations.of(context)!.visualTests_contrast_light,
        test: UnityView.contrastLight,
        child: CustomPaint(
          size: const Size(100, 100),
          painter: RingPainter(
            color: const AppColors().orchid,
            radius: 50.0,
          ),
        ),
      ),
      TestSelectionCard(
        color: const AppColors().cornflower,
        testName: AppLocalizations.of(context)!.visualTests_speed,
        test: UnityView.readingSpeed,
        child: SizedBox(
          width: 150.0,
          child: Text(
            AppLocalizations.of(context)!.common_lorem_ipsum,
            style: AppThemes()
                .small
                .merge(AppThemes().bold)
                .merge(AppThemes().orchid),
          ),
        ),
      ),
    ];
    return PageLayout(
      heading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentIndex == 0)
              IconButton(onPressed: null, icon: Container())
            else
              IconButton(
                onPressed: () => _onArrowPressed(-1),
                icon: const Icon(
                  Icons.chevron_left,
                  size: 32.0,
                ),
              ),
            Text(
              (_cards.elementAt(_currentIndex) as TestSelectionCard).testName,
              style: AppThemes().bigger.merge(AppThemes().spacedLetters),
            ),
            if (_currentIndex == _cards.length - 1)
              IconButton(
                onPressed: null,
                icon: Container(),
              )
            else
              IconButton(
                onPressed: () => _onArrowPressed(1),
                icon: const Icon(
                  Icons.chevron_right,
                  size: 32.0,
                ),
              ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                clipBehavior: Clip.none,
                controller: _controller,
                itemBuilder: (context, index) {
                  return _cards.elementAt(index);
                },
                itemCount: _cards.length,
                onPageChanged: _onPageChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _getPageIndicators(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
