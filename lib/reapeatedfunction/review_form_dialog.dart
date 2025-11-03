import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/custom_snackbar.dart';

class ReviewFormDialog extends StatefulWidget {
  final String mediaType;
  final int mediaId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final Review? existingReview;

  const ReviewFormDialog({
    Key? key,
    required this.mediaType,
    required this.mediaId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.existingReview,
  }) : super(key: key);

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  
  String _selectedSentiment = 'good';
  bool _containsSpoilers = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.existingReview != null) {
      _selectedSentiment = widget.existingReview!.sentiment;
      _titleController.text = widget.existingReview!.title;
      _textController.text = widget.existingReview!.text;
      _containsSpoilers = widget.existingReview!.containsSpoilers;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      Map<String, dynamic> result;

      if (widget.existingReview != null) {
        // Update existing review
        result = await ReviewService.updateReview(
          reviewId: widget.existingReview!.id,
          userId: widget.userId,
          sentiment: _selectedSentiment,
          title: _titleController.text.trim(),
          text: _textController.text.trim(),
          containsSpoilers: _containsSpoilers,
        );
      } else {
        // Create new review
        result = await ReviewService.createReview(
          mediaType: widget.mediaType,
          mediaId: widget.mediaId,
          userId: widget.userId,
          userName: widget.userName,
          userPhotoUrl: widget.userPhotoUrl,
          sentiment: _selectedSentiment,
          title: _titleController.text.trim(),
          text: _textController.text.trim(),
          containsSpoilers: _containsSpoilers,
        );
      }

      setState(() => _isSubmitting = false);

      if (result['success']) {
        Navigator.pop(context, true); // Return true to indicate success
        
        CustomSnackBar.showSuccess(context, result['message'] ?? 'Review saved');
      } else {
        CustomSnackBar.showError(context, result['message'] ?? 'Error saving review');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      
      CustomSnackBar.showError(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0A1929),
              Color(0xFF0F1922),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.cyan.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyan.withValues(alpha: 0.2),
                    Colors.cyan.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.cyan.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.existingReview != null ? Icons.edit_rounded : Icons.rate_review_rounded,
                    color: Colors.cyan,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.existingReview != null
                        ? 'Edit Review'
                        : 'Write Review',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan.shade100,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sentiment selector
                      Row(
                        children: [
                          Icon(Icons.sentiment_satisfied_alt, color: Colors.cyan, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Your Rating',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SentimentDisplay.allSentiments.map((sentiment) {
                          final info = SentimentDisplay.info[sentiment]!;
                          final isSelected = _selectedSentiment == sentiment;

                          return InkWell(
                            onTap: () {
                              setState(() => _selectedSentiment = sentiment);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          Color(int.parse('0xFF${info.color.substring(1)}')),
                                          Color(int.parse('0xFF${info.color.substring(1)}')).withValues(alpha: 0.7),
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : const Color(0xFF1A2332),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(int.parse('0xFF${info.color.substring(1)}'))
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Color(int.parse('0xFF${info.color.substring(1)}')).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    info.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    info.english,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Title (optional)
                      Row(
                        children: [
                          Icon(Icons.title, color: Colors.cyan, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Title (Optional)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2332),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Summarize your review...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            filled: false,
                            contentPadding: const EdgeInsets.all(16),
                            border: InputBorder.none,
                            counterStyle: TextStyle(color: Colors.grey.shade400),
                          ),
                          maxLength: 200,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Review text
                      Row(
                        children: [
                          Icon(Icons.edit_note, color: Colors.cyan, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Review Content *',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2332),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: TextFormField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white, height: 1.5),
                          decoration: InputDecoration(
                            hintText: 'Share your thoughts about this movie...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            filled: false,
                            contentPadding: const EdgeInsets.all(16),
                            border: InputBorder.none,
                            counterStyle: TextStyle(color: Colors.grey.shade400),
                          ),
                          maxLines: 8,
                          maxLength: 5000,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter review content';
                            }
                            if (value.trim().length < 10) {
                              return 'Review must be at least 10 characters';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Spoilers checkbox
                      InkWell(
                        onTap: () {
                          setState(() => _containsSpoilers = !_containsSpoilers);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _containsSpoilers
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _containsSpoilers
                                  ? Colors.orange.withValues(alpha: 0.5)
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _containsSpoilers
                                      ? Colors.orange
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _containsSpoilers
                                        ? Colors.orange
                                        : Colors.grey.withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                ),
                                child: _containsSpoilers
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.warning_amber_rounded,
                                color: _containsSpoilers ? Colors.orange : Colors.grey.shade400,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'This review contains spoilers',
                                style: TextStyle(
                                  color: _containsSpoilers ? Colors.orange.shade200 : Colors.white,
                                  fontWeight: _containsSpoilers ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with submit button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyan.withValues(alpha: 0.05),
                    Colors.cyan.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.cyan.withValues(alpha: 0.3),
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan.shade400,
                          Colors.cyan.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.existingReview != null 
                                      ? Icons.check_circle_outline 
                                      : Icons.send_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.existingReview != null ? 'Update' : 'Post',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
