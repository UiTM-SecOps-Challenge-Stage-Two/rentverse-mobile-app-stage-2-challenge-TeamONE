import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/core/utils/error_utils.dart';
import 'package:rentverse/features/auth/domain/usecase/send_otp_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/verify_otp_usecase.dart';
import 'package:rentverse/core/resources/data_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String target;
  final String channel;

  const OtpVerificationScreen({
    super.key,
    required this.target,
    required this.channel,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isSending = false;

  bool get _isEmail => widget.channel.toUpperCase() == 'EMAIL';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtp();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() => _isSending = true);
    final usecase = sl<SendOtpUseCase>();
    final params = SendOtpParams(
      target: widget.target,
      channel: widget.channel,
    );
    try {
      final result = await usecase.call(param: params);
      if (result is DataSuccess<bool>) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully')),
          );
        }
      } else if (result is DataFailed) {
        if (mounted) {
          final msg = resolveApiErrorMessage(
            result.error,
            fallback: 'Failed to send OTP',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    final code = _controller.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP must be 6 digits')));
      return;
    }

    setState(() => _isLoading = true);
    final usecase = sl<VerifyOtpUseCase>();
    final verifyParams = VerifyOtpParams(
      target: widget.target,
      channel: widget.channel,
      code: code,
    );
    try {
      final result = await usecase.call(param: verifyParams);
      if (result is DataSuccess<bool>) {
        if (mounted) {
          final updated = result.data == true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  updated ? 'Verification successful' : 'OTP verified'),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else if (result is DataFailed) {
        if (mounted) {
          final msg = resolveApiErrorMessage(
            result.error,
            fallback: 'Verification failed',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEmail ? 'Email Verification' : 'Verify Phone Number',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),


              if (_isEmail) ...[
                const Text(
                  'Email Verification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black12,
                  ),
                ),
                const SizedBox(height: 30),


                Container(
                  padding: const EdgeInsets.all(20),
                  child: Icon(LucideIcons.mail,
                    size: 80,
                    color: Colors.redAccent,
                  ),
                ),
              ] else ...[
                 const Text(
                  'Phone Number Verification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black12,
                  ),
                ),
                const SizedBox(height: 30),
                Icon(LucideIcons.phone,
                  size: 80,
                  color: Color(0xFF1E232C),
                ),
              ],

              const SizedBox(height: 30),


              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6A707C),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: _isEmail
                          ? 'We have sent an OTP code to your email address '
                          : 'We have sent an OTP code to number ',
                    ),
                    TextSpan(
                      text: widget.target,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: _isEmail
                          ? ''
                          : ', please check your SMS.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),


              _buildPinCodeInput(),

              const SizedBox(height: 20),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the OTP code? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSending ? null : _sendOtp,
                    child: Text(
                      _isSending ? "Resending..." : "Resend",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00CED1),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),


              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CED1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Get In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinCodeInput() {
    return Stack(
      alignment: Alignment.center,
      children: [

        SizedBox(
          height: 50,
          child: Opacity(
            opacity: 0.0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final code = _controller.text;
              final isFilled = index < code.length;
              final digit = isFilled ? code[index] : '';
              final isFocused = index == code.length && _focusNode.hasFocus;

              return Container(
                width: 45,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isFocused
                        ? const Color(0xFF00CED1)
                        : const Color(0xFFE8ECF4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
