// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$typingIndicatorHash() => r'd68611423926799c1f9e6a6cd70ac85c5ffdbb3c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [typingIndicator].
@ProviderFor(typingIndicator)
const typingIndicatorProvider = TypingIndicatorFamily();

/// See also [typingIndicator].
class TypingIndicatorFamily extends Family<AsyncValue<List<String>>> {
  /// See also [typingIndicator].
  const TypingIndicatorFamily();

  /// See also [typingIndicator].
  TypingIndicatorProvider call(String convId) {
    return TypingIndicatorProvider(convId);
  }

  @override
  TypingIndicatorProvider getProviderOverride(
    covariant TypingIndicatorProvider provider,
  ) {
    return call(provider.convId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'typingIndicatorProvider';
}

/// See also [typingIndicator].
class TypingIndicatorProvider extends AutoDisposeStreamProvider<List<String>> {
  /// See also [typingIndicator].
  TypingIndicatorProvider(String convId)
    : this._internal(
        (ref) => typingIndicator(ref as TypingIndicatorRef, convId),
        from: typingIndicatorProvider,
        name: r'typingIndicatorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$typingIndicatorHash,
        dependencies: TypingIndicatorFamily._dependencies,
        allTransitiveDependencies:
            TypingIndicatorFamily._allTransitiveDependencies,
        convId: convId,
      );

  TypingIndicatorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.convId,
  }) : super.internal();

  final String convId;

  @override
  Override overrideWith(
    Stream<List<String>> Function(TypingIndicatorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TypingIndicatorProvider._internal(
        (ref) => create(ref as TypingIndicatorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        convId: convId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<String>> createElement() {
    return _TypingIndicatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TypingIndicatorProvider && other.convId == convId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, convId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TypingIndicatorRef on AutoDisposeStreamProviderRef<List<String>> {
  /// The parameter `convId` of this provider.
  String get convId;
}

class _TypingIndicatorProviderElement
    extends AutoDisposeStreamProviderElement<List<String>>
    with TypingIndicatorRef {
  _TypingIndicatorProviderElement(super.provider);

  @override
  String get convId => (origin as TypingIndicatorProvider).convId;
}

String _$onlineStatusHash() => r'6c54f3910aacf291f85aff6a1ebf4619ac66eb60';

/// See also [onlineStatus].
@ProviderFor(onlineStatus)
const onlineStatusProvider = OnlineStatusFamily();

/// See also [onlineStatus].
class OnlineStatusFamily extends Family<AsyncValue<bool>> {
  /// See also [onlineStatus].
  const OnlineStatusFamily();

  /// See also [onlineStatus].
  OnlineStatusProvider call(String userId) {
    return OnlineStatusProvider(userId);
  }

  @override
  OnlineStatusProvider getProviderOverride(
    covariant OnlineStatusProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'onlineStatusProvider';
}

/// See also [onlineStatus].
class OnlineStatusProvider extends AutoDisposeStreamProvider<bool> {
  /// See also [onlineStatus].
  OnlineStatusProvider(String userId)
    : this._internal(
        (ref) => onlineStatus(ref as OnlineStatusRef, userId),
        from: onlineStatusProvider,
        name: r'onlineStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$onlineStatusHash,
        dependencies: OnlineStatusFamily._dependencies,
        allTransitiveDependencies:
            OnlineStatusFamily._allTransitiveDependencies,
        userId: userId,
      );

  OnlineStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<bool> Function(OnlineStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OnlineStatusProvider._internal(
        (ref) => create(ref as OnlineStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _OnlineStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OnlineStatusProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OnlineStatusRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _OnlineStatusProviderElement
    extends AutoDisposeStreamProviderElement<bool>
    with OnlineStatusRef {
  _OnlineStatusProviderElement(super.provider);

  @override
  String get userId => (origin as OnlineStatusProvider).userId;
}

String _$chatHash() => r'fedc4f1796616d78daaed0f9c7dc3bee2917ef36';

abstract class _$Chat extends BuildlessAutoDisposeAsyncNotifier<List<Message>> {
  late final String convId;

  FutureOr<List<Message>> build(String convId);
}

/// See also [Chat].
@ProviderFor(Chat)
const chatProvider = ChatFamily();

/// See also [Chat].
class ChatFamily extends Family<AsyncValue<List<Message>>> {
  /// See also [Chat].
  const ChatFamily();

  /// See also [Chat].
  ChatProvider call(String convId) {
    return ChatProvider(convId);
  }

  @override
  ChatProvider getProviderOverride(covariant ChatProvider provider) {
    return call(provider.convId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatProvider';
}

/// See also [Chat].
class ChatProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Chat, List<Message>> {
  /// See also [Chat].
  ChatProvider(String convId)
    : this._internal(
        () => Chat()..convId = convId,
        from: chatProvider,
        name: r'chatProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatHash,
        dependencies: ChatFamily._dependencies,
        allTransitiveDependencies: ChatFamily._allTransitiveDependencies,
        convId: convId,
      );

  ChatProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.convId,
  }) : super.internal();

  final String convId;

  @override
  FutureOr<List<Message>> runNotifierBuild(covariant Chat notifier) {
    return notifier.build(convId);
  }

  @override
  Override overrideWith(Chat Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatProvider._internal(
        () => create()..convId = convId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        convId: convId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<Chat, List<Message>> createElement() {
    return _ChatProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatProvider && other.convId == convId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, convId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatRef on AutoDisposeAsyncNotifierProviderRef<List<Message>> {
  /// The parameter `convId` of this provider.
  String get convId;
}

class _ChatProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Chat, List<Message>>
    with ChatRef {
  _ChatProviderElement(super.provider);

  @override
  String get convId => (origin as ChatProvider).convId;
}

String _$replyTargetHash() => r'be00cae35880de2d6535152b87548c71b4cdeb33';

/// See also [ReplyTarget].
@ProviderFor(ReplyTarget)
final replyTargetProvider =
    AutoDisposeNotifierProvider<ReplyTarget, Message?>.internal(
      ReplyTarget.new,
      name: r'replyTargetProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$replyTargetHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReplyTarget = AutoDisposeNotifier<Message?>;
String _$recordingStateHash() => r'd4cf36872f388ec6008cba40683775ebbac297f9';

/// See also [RecordingState].
@ProviderFor(RecordingState)
final recordingStateProvider =
    AutoDisposeNotifierProvider<RecordingState, AudioRecordingState>.internal(
      RecordingState.new,
      name: r'recordingStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recordingStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecordingState = AutoDisposeNotifier<AudioRecordingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
