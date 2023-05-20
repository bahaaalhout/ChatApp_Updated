import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.isMe,
    required this.username,
    required this.imageUrl,
    required this.message,
  }) : isFirstInSeq = true;
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSeq = false,
        username = null,
        imageUrl = null;
  final bool isMe;
  final String? username;
  final String? imageUrl;
  final String message;
  final bool isFirstInSeq;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (imageUrl != null)
          Positioned(
            top: 15,
            right: isMe ? 0 : null,
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(imageUrl!),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 2),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isFirstInSeq)
                    const SizedBox(
                      height: 20,
                    ),
                  if (username != null)
                    Text(
                      username!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.white : Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(14),
                        bottomRight: const Radius.circular(14),
                        topRight: isMe
                            ? isFirstInSeq
                                ? Radius.zero
                                : const Radius.circular(14)
                            : const Radius.circular(14),
                        topLeft: isMe
                            ? const Radius.circular(14)
                            : isFirstInSeq
                                ? Radius.zero
                                : const Radius.circular(14),
                      ),
                    ),
                    child: Text(
                      message,
                      style:
                          TextStyle(color: isMe ? Colors.black : Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
