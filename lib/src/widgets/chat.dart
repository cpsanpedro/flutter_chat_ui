import 'dart:math';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/inherited_replied_message.dart';
import 'package:flutter_chat_ui/src/widgets/input_message.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart' show PhotoViewComputedScale;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

import '../chat_l10n.dart';
import '../chat_theme.dart';
import '../models/bubble_rtl_alignment.dart';
import '../models/date_header.dart';
import '../models/emoji_enlargement_behavior.dart';
import '../models/message_spacer.dart';
import '../models/preview_image.dart';
import '../models/unread_header_data.dart';
import '../util.dart';
import 'chat_list.dart';
import 'image_gallery.dart';
import 'input/input.dart';
import 'message/message.dart';
import 'message/system_message.dart';
import 'message/text_message.dart';
import 'state/inherited_chat_theme.dart';
import 'state/inherited_l10n.dart';
import 'state/inherited_user.dart';
import 'typing_indicator.dart';
import 'unread_header.dart';

/// Entry widget, represents the complete chat. If you wrap it in [SafeArea] and
/// it should be full screen, set [SafeArea]'s `bottom` to `false`.
class Chat extends StatefulWidget {
  /// Creates a chat widget.
  const Chat({
    super.key,
    this.audioMessageBuilder,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.bubbleRtlAlignment = BubbleRtlAlignment.right,
    this.customBottomWidget,
    this.customDateHeaderText,
    this.customInputReplyMessageBuilder,
    this.customMessageBuilder,
    this.customStatusBuilder,
    this.customReplyMessageBuilder,
    this.dateFormat,
    this.dateHeaderBuilder,
    this.dateHeaderThreshold = 900000,
    this.dateIsUtc = false,
    this.dateLocale,
    this.disableImageGallery,
    this.emojiEnlargementBehavior = EmojiEnlargementBehavior.multi,
    this.emptyState,
    this.fileMessageBuilder,
    this.groupMessagesThreshold = 60000,
    this.hideBackgroundOnEmojiMessages = true,
    this.imageGalleryOptions = const ImageGalleryOptions(
      maxScale: PhotoViewComputedScale.covered,
      minScale: PhotoViewComputedScale.contained,
    ),
    this.imageHeaders,
    this.imageMessageBuilder,
    this.inputOptions = const InputOptions(),
    this.isAttachmentUploading,
    this.fileName,
    this.fileSize,
    this.isLastPage,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.l10n = const ChatL10nEn(),
    this.listBottomWidget,
    required this.messages,
    this.nameBuilder,
    this.onAttachmentPressed,
    this.onAvatarTap,
    this.onBackgroundTap,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.onSendPressed,
    this.scrollController,
    this.replySwipeDirection = ReplySwipeDirection.endToStart,
    this.scrollPhysics,
    this.scrollToUnreadOptions = const ScrollToUnreadOptions(),
    this.showUserAvatars = false,
    this.showUserNames = false,
    this.systemMessageBuilder,
    this.textMessageBuilder,
    this.textMessageOptions = const TextMessageOptions(),
    this.theme = const DefaultChatTheme(),
    this.timeFormat,
    this.typingIndicatorOptions = const TypingIndicatorOptions(),
    this.usePreviewData = true,
    this.enableSwipe = true,
    this.enableAttachments = true,
    this.isOtherUserDeleted = false,
    this.isOtherUserBlocked = false,
    this.enableAudio = true,
    this.enableVideo = true,
    required this.user,
    this.userAgent,
    this.useTopSafeAreaInset,
    this.videoMessageBuilder,
    this.onStartAudioRecording,
    this.onAudioRecorded,
    this.onStartVideoRecording,
    this.onVideoRecorded,
    this.onStartAudioVideoPlayback,
    this.bgPath,
    this.roomType = types.RoomType.direct,
    this.messageId = '',
    required this.textController,
    this.onTextfieldChanged,
  });

  final TextEditingController textController;

  final Function(String)? onTextfieldChanged;

  final String? bgPath;

  final String messageId;

  final types.RoomType roomType;

  /// See [Messase.audioMessageBuilder].
  final Widget Function(types.AudioMessage, {required int messageWidth})?
      audioMessageBuilder;

  /// See [Message.avatarBuilder].
  final Widget Function(String userId)? avatarBuilder;

  /// See [Message.bubbleBuilder].
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// See [Message.bubbleRtlAlignment].
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// Allows you to replace the default Input widget e.g. if you want to create
  /// a channel view. If you're looking for the bottom widget added to the chat
  /// list, see [listBottomWidget] instead.
  final Widget? customBottomWidget;

  /// If [dateFormat], [dateLocale] and/or [timeFormat] is not enough to
  /// customize date headers in your case, use this to return an arbitrary
  /// string based on a [DateTime] of a particular message. Can be helpful to
  /// return "Today" if [DateTime] is today. IMPORTANT: this will replace
  /// all default date headers, so you must handle all cases yourself, like
  /// for example today, yesterday and before. Or you can just return the same
  /// date header for any message.
  final String Function(DateTime)? customDateHeaderText;

  /// See [Message.customMessageBuilder].
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// See [Message.customStatusBuilder].
  final Widget Function(types.Message message, {required BuildContext context})?
      customStatusBuilder;

  /// Allows you to replace the default ReplyMessage widget inside Input widget
  final Widget Function(types.Message)? customInputReplyMessageBuilder;

  /// Allows you to replace the default ReplyMessage widget inside Message widget
  final Widget Function(types.Message)? customReplyMessageBuilder;

  /// Allows you to customize the date format. IMPORTANT: only for the date,
  /// do not return time here. See [timeFormat] to customize the time format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized date
  /// make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText]
  /// for more customization.
  final DateFormat? dateFormat;

  /// Custom date header builder gives ability to customize date header widget.
  final Widget Function(DateHeader)? dateHeaderBuilder;

  /// Time (in ms) between two messages when we will render a date header.
  /// Default value is 15 minutes, 900000 ms. When time between two messages
  /// is higher than this threshold, date header will be rendered. Also,
  /// not related to this value, date header will be rendered on every new day.
  final int dateHeaderThreshold;

  /// Use utc time to convert message milliseconds to date.
  final bool dateIsUtc;

  /// Locale will be passed to the `Intl` package. Make sure you initialized
  /// date formatting in your app before passing any locale here, otherwise
  /// an error will be thrown. Also see [customDateHeaderText], [dateFormat], [timeFormat].
  final String? dateLocale;

  /// Disable automatic image preview on tap.
  final bool? disableImageGallery;

  /// See [Message.emojiEnlargementBehavior].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Allows you to change what the user sees when there are no messages.
  /// `emptyChatPlaceholder` and `emptyChatPlaceholderTextStyle` are ignored
  /// in this case.
  final Widget? emptyState;

  /// See [Message.fileMessageBuilder].
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Time (in ms) between two messages when we will visually group them.
  /// Default value is 1 minute, 60000 ms. When time between two messages
  /// is lower than this threshold, they will be visually grouped.
  final int groupMessagesThreshold;

  /// See [Message.hideBackgroundOnEmojiMessages].
  final bool hideBackgroundOnEmojiMessages;

  /// See [ImageGallery.options].
  final ImageGalleryOptions imageGalleryOptions;

  /// Headers passed to all network images used in the chat.
  final Map<String, String>? imageHeaders;

  /// See [Message.imageMessageBuilder].
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// See [Input.options].
  final InputOptions inputOptions;

  /// See [Input.isAttachmentUploading].
  final bool? isAttachmentUploading;

  final String? fileName;

  final int? fileSize;

  /// See [ChatList.isLastPage].
  final bool? isLastPage;

  /// See [ChatList.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// See [Input.onStartAudioRecording]
  final Future<bool> Function()? onStartAudioRecording;

  /// See [Input.onAudioRecorded]
  final Future<bool> Function({
    required Duration length,
    required String filePath,
    required List<double> waveForm,
    required String mimeType,
    types.Message? repliedMessage,
  })? onAudioRecorded;

  /// See [Input.onStartVideoRecording]
  final Future<bool> Function()? onStartVideoRecording;

  /// See [Input.onVideoRecorded]
  final Future<bool> Function({
    required Duration length,
    required String filePath,
    required String mimeType,
    types.Message? repliedMessage,
  })? onVideoRecorded;

  /// Localized copy. Extend [ChatL10n] class to create your own copy or use
  /// existing one, like the default [ChatL10nEn]. You can customize only
  /// certain properties, see more here [ChatL10nEn].
  final ChatL10n l10n;

  /// See [ChatList.bottomWidget]. For a custom chat input
  /// use [customBottomWidget] instead.
  final Widget? listBottomWidget;

  /// List of [types.Message] to render in the chat widget.
  final List<types.Message> messages;

  /// See [Message.nameBuilder].
  final Widget Function(String userId)? nameBuilder;

  /// See [Input.onAttachmentPressed].
  // final VoidCallback? onAttachmentPressed;
  final void Function({types.Message? repliedMessage})? onAttachmentPressed;

  /// See [Message.onAvatarTap].
  final void Function(types.User)? onAvatarTap;

  /// Called when user taps on background.
  final VoidCallback? onBackgroundTap;

  /// See [ChatList.onEndReached].
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold].
  final double? onEndReachedThreshold;

  /// See [Message.onMessageDoubleTap].
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// See [Message.onMessageLongPress].
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// See [Message.onMessageStatusLongPress].
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// See [Message.onMessageStatusTap].
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// See [Message.onMessageTap].
  final void Function(BuildContext context, types.Message)? onMessageTap;

  /// See [Message.onMessageVisibilityChanged].
  final void Function(types.Message, bool visible)? onMessageVisibilityChanged;

  /// See [Message.onPreviewDataFetched].
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText, {types.Message? repliedMessage})
      onSendPressed;

  /// See [ChatList.scrollController].
  /// If provided, you cannot use the scroll to message functionality.
  final AutoScrollController? scrollController;

  /// See [ChatList.scrollPhysics].
  final ScrollPhysics? scrollPhysics;

  /// See [ReplySwipeDirection]
  final ReplySwipeDirection replySwipeDirection;

  /// Controls if and how the chat should scroll to the newest unread message.
  final ScrollToUnreadOptions scrollToUnreadOptions;

  /// See [Message.showUserAvatars].
  final bool showUserAvatars;

  /// Show user names for received messages. Useful for a group chat. Will be
  /// shown only on text messages.
  final bool showUserNames;

  /// Builds a system message outside of any bubble.
  final Widget Function(types.SystemMessage)? systemMessageBuilder;

  /// See [Message.textMessageBuilder].
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [Message.textMessageOptions].
  final TextMessageOptions textMessageOptions;

  /// Chat theme. Extend [ChatTheme] class to create your own theme or use
  /// existing one, like the [DefaultChatTheme]. You can customize only certain
  /// properties, see more here [DefaultChatTheme].
  final ChatTheme theme;

  /// Allows you to customize the time format. IMPORTANT: only for the time,
  /// do not return date here. See [dateFormat] to customize the date format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized time
  /// make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText]
  /// for more customization.
  final DateFormat? timeFormat;

  /// Used to show typing users with indicator. See [TypingIndicatorOptions].
  final TypingIndicatorOptions typingIndicatorOptions;

  /// See [Message.usePreviewData].
  final bool usePreviewData;

  /// See [InheritedUser.user].
  final types.User user;

  /// See [Message.userAgent].
  final String? userAgent;

  /// See [ChatList.useTopSafeAreaInset].
  final bool? useTopSafeAreaInset;

  /// See [Message.videoMessageBuilder].
  final Widget Function(types.VideoMessage, {required int messageWidth})?
      videoMessageBuilder;
  final bool enableSwipe;
  final bool enableAttachments;
  final bool enableAudio;
  final bool enableVideo;
  final bool isOtherUserDeleted;
  final bool isOtherUserBlocked;
  final void Function(types.Message)? onStartAudioVideoPlayback;

  @override
  State<Chat> createState() => ChatState();
}

/// [Chat] widget state.
class ChatState extends State<Chat> {
  late int maxWidth = 0;

  /// Used to get the correct auto scroll index from [_autoScrollIndexById].
  static const String _unreadHeaderId = 'unread_header_id';

  List<Object> _chatMessages = [];
  List<PreviewImage> _gallery = [];
  PageController? _galleryPageController;
  bool _hadScrolledToUnreadOnOpen = false;
  bool _isImageViewVisible = false;
  types.Message? _repliedMessage;
  final focusNode = FocusNode();

  /// Keep track of all the auto scroll indices by their respective message's id to allow animating to them.
  final Map<String, int> _autoScrollIndexById = {};
  late final AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = widget.scrollController ?? AutoScrollController();

    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(covariant Chat oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.isNotEmpty) {
      final result = calculateChatMessages(
        widget.messages,
        widget.user,
        customDateHeaderText: widget.customDateHeaderText,
        dateFormat: widget.dateFormat,
        dateHeaderThreshold: widget.dateHeaderThreshold,
        dateIsUtc: widget.dateIsUtc,
        dateLocale: widget.dateLocale,
        groupMessagesThreshold: widget.groupMessagesThreshold,
        lastReadMessageId: widget.scrollToUnreadOptions.lastReadMessageId,
        showUserNames: widget.showUserNames,
        timeFormat: widget.timeFormat,
      );

      _chatMessages = result[0] as List<Object>;
      _gallery = result[1] as List<PreviewImage>;

      _refreshAutoScrollMapping();
      _maybeScrollToFirstUnread();
      if (widget.messageId.isNotEmpty) {
        scrollToMessage(widget.messageId);
      }
    }
  }

  @override
  void dispose() {
    _galleryPageController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to the unread header.
  void scrollToUnreadHeader() {
    final unreadHeaderIndex = _autoScrollIndexById[_unreadHeaderId];
    if (unreadHeaderIndex != null) {
      _scrollController.scrollToIndex(
        unreadHeaderIndex,
        duration: widget.scrollToUnreadOptions.scrollDuration,
      );
    }
  }

  /// Scroll to the message with the specified [id].
  void scrollToMessage(String id, {Duration? duration}) =>
      _scrollController.scrollToIndex(
        _autoScrollIndexById[id]!,
        duration: duration ?? scrollAnimationDuration,
      );

  @override
  Widget build(BuildContext context) => InheritedUser(
        user: widget.user,
        child: InheritedRepliedMessage(
          repliedMessage: _repliedMessage,
          child: InheritedChatTheme(
            theme: widget.theme,
            child: InheritedL10n(
              l10n: widget.l10n,
              child: Stack(
                children: [
                  Container(
                    color: widget.bgPath != null
                        ? null
                        : widget.theme.backgroundColor,
                    decoration: widget.bgPath != null
                        ? BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(widget.bgPath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    child: Column(
                      children: [
                        Flexible(
                          child: widget.messages.isEmpty
                              ? SizedBox.expand(
                                  child: _emptyStateBuilder(),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    widget.onBackgroundTap?.call();
                                  },
                                  child: ChatList(
                                    bottomWidget: widget.listBottomWidget,
                                    bubbleRtlAlignment:
                                        widget.bubbleRtlAlignment!,
                                    isLastPage: widget.isLastPage,
                                    itemBuilder: (Object item, int? index) =>
                                        _messageBuilder(item, index),
                                    items: _chatMessages,
                                    keyboardDismissBehavior:
                                        widget.keyboardDismissBehavior,
                                    onEndReached: widget.onEndReached,
                                    onEndReachedThreshold:
                                        widget.onEndReachedThreshold,
                                    scrollController: _scrollController,
                                    scrollPhysics: widget.scrollPhysics,
                                    typingIndicatorOptions:
                                        widget.typingIndicatorOptions,
                                    useTopSafeAreaInset:
                                        widget.useTopSafeAreaInset ?? isMobile,
                                  ),
                                ),
                        ),
                        (widget.isAttachmentUploading ?? false)
                            ? Container(
                                alignment: AlignmentDirectional.centerEnd,
                                margin: EdgeInsetsDirectional.only(
                                  bottom: 20,
                                  end: MediaQuery.of(context).padding.right,
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: maxWidth.toDouble(),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const IconButton(
                                        onPressed: null,
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                      Flexible(
                                        child: Bubble(
                                          style: const BubbleStyle(
                                            nip: BubbleNip.rightTop,
                                            color: Color(0xFFDCF8C6),
                                            elevation: 1,
                                            margin: BubbleEdges.only(
                                                top: 8, left: 0),
                                          ),
                                          child: Builder(builder: (context) {
                                            final color = InheritedChatTheme.of(
                                                    context)
                                                .theme
                                                .sentMessageDocumentIconColor;

                                            return Semantics(
                                              label: InheritedL10n.of(context)
                                                  .l10n
                                                  .fileButtonAccessibilityLabel,
                                              child: Container(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                  InheritedChatTheme.of(context)
                                                      .theme
                                                      .messageInsetsVertical,
                                                  InheritedChatTheme.of(context)
                                                      .theme
                                                      .messageInsetsVertical,
                                                  InheritedChatTheme.of(context)
                                                      .theme
                                                      .messageInsetsHorizontal,
                                                  InheritedChatTheme.of(context)
                                                      .theme
                                                      .messageInsetsVertical,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: color
                                                                .withOpacity(
                                                                    0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        21),
                                                          ),
                                                          height: 42,
                                                          width: 42,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              if (widget
                                                                      .isAttachmentUploading ??
                                                                  false)
                                                                Positioned.fill(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color:
                                                                        color,
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                                ),
                                                              InheritedChatTheme
                                                                              .of(
                                                                        context,
                                                                      )
                                                                          .theme
                                                                          .documentIcon !=
                                                                      null
                                                                  ? InheritedChatTheme
                                                                          .of(
                                                                      context,
                                                                    )
                                                                      .theme
                                                                      .documentIcon!
                                                                  : Image.asset(
                                                                      'assets/icon-document.png',
                                                                      color:
                                                                          color,
                                                                      package:
                                                                          'flutter_chat_ui',
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsetsDirectional
                                                                    .only(
                                                              start: 16,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  widget.fileName ??
                                                                      '',
                                                                  style: InheritedChatTheme.of(
                                                                          context)
                                                                      .theme
                                                                      .sentMessageBodyTextStyle,
                                                                  textWidthBasis:
                                                                      TextWidthBasis
                                                                          .longestLine,
                                                                ),
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    top: 4,
                                                                  ),
                                                                  child: Text(
                                                                    formatBytes(
                                                                      widget.fileSize
                                                                              ?.truncate() ??
                                                                          0,
                                                                    ),
                                                                    style: InheritedChatTheme
                                                                            .of(
                                                                      context,
                                                                    )
                                                                        .theme
                                                                        .sentMessageCaptionTextStyle,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Image.asset(
                                          'assets/icon-delivered-2.png',
                                          color: const Color(0xFF0A81FF),
                                          package: 'flutter_chat_ui',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        InputMessage(
                          textController: widget.textController,
                          isOtherUserDeleted: widget.isOtherUserDeleted,
                          isOtherUserBlocked: widget.isOtherUserBlocked,
                          enableAttachments: widget.enableAttachments,
                          enableAudio: widget.enableAudio,
                          enableVideo: widget.enableVideo,
                          focusNode: focusNode,
                          replyMessage: _repliedMessage,
                          onCancelReply: _onCancelReplyPressed,
                          onSendMessage: _onSendPressed,
                          onAttachmentPressed: ({repliedMessage}) {
                            setState(() {
                              _repliedMessage = null;
                            });
                            return widget.onAttachmentPressed!(
                              repliedMessage: repliedMessage,
                            );
                          },
                          isAttachmentUploading: widget.isAttachmentUploading,
                          onStartAudioRecording: widget.onStartAudioRecording,
                          onAudioRecorded: ({
                            required filePath,
                            required length,
                            required mimeType,
                            repliedMessage,
                            required waveForm,
                          }) {
                            setState(() {
                              _repliedMessage = null;
                            });
                            return widget.onAudioRecorded!(
                              filePath: filePath,
                              length: length,
                              mimeType: mimeType,
                              repliedMessage: repliedMessage,
                              waveForm: waveForm,
                            );
                          },
                          onStartVideoRecording: widget.onStartVideoRecording,
                          onVideoRecorded: ({
                            required filePath,
                            required length,
                            required mimeType,
                            repliedMessage,
                          }) {
                            setState(() {
                              _repliedMessage = null;
                            });
                            return widget.onVideoRecorded!(
                              filePath: filePath,
                              length: length,
                              mimeType: mimeType,
                              repliedMessage: repliedMessage,
                            );
                          },
                          onTextfieldChanged: widget.onTextfieldChanged,
                        ),
                      ],
                    ),
                  ),
                  if (_isImageViewVisible)
                    ImageGallery(
                      imageHeaders: widget.imageHeaders,
                      images: _gallery,
                      pageController: _galleryPageController!,
                      onClosePressed: _onCloseGalleryPressed,
                      options: widget.imageGalleryOptions,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _emptyStateBuilder() =>
      widget.emptyState ??
      Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Text(
          widget.l10n.emptyChatPlaceholder,
          style: widget.theme.emptyChatPlaceholderTextStyle,
          textAlign: TextAlign.center,
        ),
      );

  /// Only scroll to first unread if there are messages and it is the first open.
  void _maybeScrollToFirstUnread() {
    if (widget.scrollToUnreadOptions.scrollOnOpen &&
        _chatMessages.isNotEmpty &&
        !_hadScrolledToUnreadOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await Future.delayed(widget.scrollToUnreadOptions.scrollDelay);
          scrollToUnreadHeader();
        }
      });
      _hadScrolledToUnreadOnOpen = true;
    }
  }

  /// We need the index for auto scrolling because it will scroll until it reaches an index higher or equal that what it is scrolling towards. Index will be null for removed messages. Can just set to -1 for auto scroll.
  Widget _messageBuilder(
    Object object,
    int? index,
  ) {
    if (object is DateHeader) {
      return widget.dateHeaderBuilder?.call(object) ??
          Container(
            alignment: Alignment.center,
            margin: widget.theme.dateDividerMargin,
            child: Text(
              object.text,
              style: widget.theme.dateDividerTextStyle,
            ),
          );
    } else if (object is MessageSpacer) {
      return SizedBox(
        height: object.height,
      );
    } else if (object is UnreadHeaderData) {
      return AutoScrollTag(
        controller: _scrollController,
        index: index ?? -1,
        key: const Key('unread_header'),
        child: UnreadHeader(
          marginTop: object.marginTop,
        ),
      );
    } else {
      final map = object as Map<String, Object>;
      final message = map['message']! as types.Message;

      final Widget messageWidget;

      if (message is types.SystemMessage) {
        messageWidget = widget.systemMessageBuilder?.call(message) ??
            SystemMessage(message: message.text);
      } else {
        final size = MediaQuery.of(context).size.width;
        final messageWidth =
            widget.showUserAvatars && message.author.id != widget.user.id
                ? min(size * 0.72, 440).floor()
                : min(size * 0.78, 440).floor();
        maxWidth = min(size * 0.78, 440).floor();
        messageWidget = Message(
          roomType: widget.roomType,
          onStartAudioVideoPlayback: widget.onStartAudioVideoPlayback,
          enableSwipe: widget.enableSwipe,
          replySwipeDirection: message.author.id != widget.user.id
              ? SwipeDirection.startToEnd
              : SwipeDirection.endToStart,
          audioMessageBuilder: widget.audioMessageBuilder,
          avatarBuilder: widget.avatarBuilder,
          bubbleBuilder: widget.bubbleBuilder,
          bubbleRtlAlignment: widget.bubbleRtlAlignment,
          customMessageBuilder: widget.customMessageBuilder,
          onMessageReply: _onMessageReply,
          showUserNameForRepliedMessage: widget.showUserNames,
          customStatusBuilder: widget.customStatusBuilder,
          emojiEnlargementBehavior: widget.emojiEnlargementBehavior,
          fileMessageBuilder: widget.fileMessageBuilder,
          hideBackgroundOnEmojiMessages: widget.hideBackgroundOnEmojiMessages,
          imageHeaders: widget.imageHeaders,
          imageMessageBuilder: widget.imageMessageBuilder,
          message: message,
          messageWidth: messageWidth,
          nameBuilder: widget.nameBuilder,
          onAvatarTap: widget.onAvatarTap,
          onMessageDoubleTap: widget.onMessageDoubleTap,
          onMessageLongPress: widget.onMessageLongPress,
          onMessageStatusLongPress: widget.onMessageStatusLongPress,
          onMessageStatusTap: widget.onMessageStatusTap,
          onMessageTap: (context, tappedMessage) {
            if (tappedMessage is types.ImageMessage &&
                widget.disableImageGallery != true) {
              _onImagePressed(tappedMessage);
            }

            widget.onMessageTap?.call(context, tappedMessage);
          },
          onMessageVisibilityChanged: widget.onMessageVisibilityChanged,
          onPreviewDataFetched: _onPreviewDataFetched,
          roundBorder: map['nextMessageInGroup'] == true,
          showAvatar: map['nextMessageInGroup'] == false,
          showName: map['showName'] == true,
          showStatus: map['showStatus'] == true,
          showUserAvatars: widget.showUserAvatars,
          textMessageBuilder: widget.textMessageBuilder,
          textMessageOptions: widget.textMessageOptions,
          usePreviewData: widget.usePreviewData,
          userAgent: widget.userAgent,
          videoMessageBuilder: widget.videoMessageBuilder,
        );
      }

      return AutoScrollTag(
        controller: _scrollController,
        index: index ?? -1,
        key: Key('scroll-${message.id}'),
        child: messageWidget,
      );
    }
  }

  void _onSendPressed(
    types.PartialText message, {
    types.Message? repliedMessage,
  }) {
    setState(() {
      _repliedMessage = null;
    });
    widget.onSendPressed(message, repliedMessage: repliedMessage);
  }

  void _onCancelReplyPressed() {
    setState(() {
      _repliedMessage = null;
    });
  }

  void _onCloseGalleryPressed() {
    setState(() {
      _isImageViewVisible = false;
    });
    _galleryPageController?.dispose();
    _galleryPageController = null;
  }

  void _onImagePressed(types.ImageMessage message) {
    final initialPage = _gallery.indexWhere(
      (element) => element.id == message.id && element.uri == message.uri,
    );
    _galleryPageController = PageController(initialPage: initialPage);
    setState(() {
      _isImageViewVisible = true;
    });
  }

  void _onMessageReply(BuildContext context, types.Message? message) {
    setState(() {
      _repliedMessage = message?.copyWith();
    });
    focusNode.requestFocus();
  }

  void _onPreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    widget.onPreviewDataFetched?.call(message, previewData);
  }

  /// Updates the [_autoScrollIndexById] mapping with the latest messages.
  void _refreshAutoScrollMapping() {
    _autoScrollIndexById.clear();
    var i = 0;
    for (final object in _chatMessages) {
      if (object is UnreadHeaderData) {
        _autoScrollIndexById[_unreadHeaderId] = i;
      } else if (object is Map<String, Object>) {
        final message = object['message']! as types.Message;
        _autoScrollIndexById[message.id] = i;
      }
      i++;
    }
  }
}
