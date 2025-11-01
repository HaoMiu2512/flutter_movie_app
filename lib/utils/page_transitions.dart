import 'package:flutter/material.dart';

/// Custom Page Transitions for smooth navigation
/// Use these instead of MaterialPageRoute for better UX

class PageTransitions {
  
  /// Fade transition - smooth opacity change
  static Route<T> fade<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Slide from right transition - like iOS
  static Route<T> slideFromRight<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Slide from bottom transition - like modal
  static Route<T> slideFromBottom<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Scale transition - zoom in effect
  static Route<T> scale<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        var scaleTween = Tween<double>(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  /// Rotation + Fade transition - creative effect
  static Route<T> rotationFade<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        var rotateTween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: RotationTransition(
            turns: animation.drive(rotateTween),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  /// Size transition - expand effect
  static Route<T> size<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Align(
          alignment: Alignment.center,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  /// Slide and Fade combo - smooth and elegant
  static Route<T> slideAndFade<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        var slideTween = Tween(begin: begin, end: Offset.zero).chain(
          CurveTween(curve: curve),
        );
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  /// No transition - instant navigation (for tabs)
  static Route<T> none<T>({required Widget page}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
    );
  }

  /// Hero transition wrapper - for image transitions
  static Route<T> hero<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}

/// Extension methods for easier navigation
extension NavigatorExtensions on BuildContext {
  
  /// Navigate with fade transition
  Future<T?> fadeToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageTransitions.fade(page: page),
    );
  }

  /// Navigate with slide from right
  Future<T?> slideToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageTransitions.slideFromRight(page: page),
    );
  }

  /// Navigate with slide from bottom (modal style)
  Future<T?> slideUpToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageTransitions.slideFromBottom(page: page),
    );
  }

  /// Navigate with scale transition
  Future<T?> scaleToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageTransitions.scale(page: page),
    );
  }

  /// Navigate with slide and fade
  Future<T?> smoothToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageTransitions.slideAndFade(page: page),
    );
  }

  /// Replace current page with fade
  Future<T?> fadeReplacePage<T>(Widget page) {
    return Navigator.pushReplacement<T, dynamic>(
      this,
      PageTransitions.fade(page: page),
    );
  }

  /// Replace all pages with fade
  Future<T?> fadeResetToPage<T>(Widget page) {
    return Navigator.pushAndRemoveUntil<T>(
      this,
      PageTransitions.fade(page: page),
      (route) => false,
    );
  }
}
