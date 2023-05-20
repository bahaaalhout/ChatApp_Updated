import 'package:app_no9_chat/widgets/message_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class MessageChat extends StatelessWidget {
  const MessageChat({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, chatsnapshot) {
        if (chatsnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatsnapshot.hasData || chatsnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Theres no messages'),
          );
        }
        if (chatsnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        final loadedMessages = chatsnapshot.data!.docs;
        return Container(
          color: Colors.grey.withOpacity(.4),
          child: ListView.builder(
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chatData = loadedMessages[index].data();
              final nextMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserId = chatData['userId'];
              final nextMessageUserId =
                  nextMessage != null ? nextMessage['userId'] : null;
              final isSameUser = currentMessageUserId == nextMessageUserId;
              if (isSameUser) {
                return MessageBubble.next(
                  message: chatData['text'],
                  isMe: currentMessageUserId == authenticatedUser.uid,
                );
              } else {
                return MessageBubble.first(
                  isMe: currentMessageUserId == authenticatedUser.uid,
                  username: chatData['username'],
                  imageUrl: chatData['userImage'],
                  message: chatData['text'],
                );
              }
            },
          ),
        );
      },
    );
  }
}
