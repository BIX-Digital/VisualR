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
import 'package:provider/provider.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/routes/router.gr.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/views/onboarding/slides/identification_slide.dart';
import 'package:visualr_app/views/onboarding/slides/ipda_slide.dart';
import 'package:visualr_app/views/onboarding/slides/permissions_slide.dart';
import 'package:visualr_app/views/onboarding/slides/welcome_slide.dart';
import 'package:visualr_app/widgets/page_indicator.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

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

  void _openIPDATask(BuildContext context) {
    AutoRouter.of(context).replace(const IPDATaskRoute());
  }

  void _navigateForward() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 0.0,
        backgroundColor: const AppColors().transparent,
        elevation: 0.0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
          ),
          child: Column(
            children: [
              Flexible(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    WelcomeSlide(
                      action: _navigateForward,
                    ),
                    PermissionsSlide(action: _navigateForward),
                    Consumer<Prefs>(
                      builder: (context, prefs, child) => IdentificationSlide(
                        action: _navigateForward,
                        prefs: prefs,
                        scrollController: _scrollController,
                      ),
                    ),
                    Consumer<Prefs>(
                      builder: (context, prefs, child) => IPDASlide(
                        action: () => _openIPDATask(context),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getPageIndicators(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
