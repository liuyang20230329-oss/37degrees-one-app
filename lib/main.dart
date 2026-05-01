import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'src/api_client.dart';

void main() {
  runApp(const ThirtySevenDegreesApp());
}

class ThirtySevenDegreesApp extends StatefulWidget {
  const ThirtySevenDegreesApp({super.key});

  @override
  State<ThirtySevenDegreesApp> createState() => _ThirtySevenDegreesAppState();
}

class _ThirtySevenDegreesAppState extends State<ThirtySevenDegreesApp> {
  bool _initialized = false;
  bool _isAuthenticated = false;
  UserProfile _profile = UserProfile.sample();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await ApiClient.init();
      if (ApiClient.isLoggedIn) {
        final data = await ApiClient.getMe();
        final user = data['user'] ?? data;
        if (mounted) {
          setState(() {
            _profile = UserProfile.fromJson(user as Map<String, dynamic>);
            _isAuthenticated = true;
            _initialized = true;
          });
        }
      } else {
        if (mounted) setState(() => _initialized = true);
      }
    } catch (_) {
      await ApiClient.clearToken();
      if (mounted) setState(() => _initialized = true);
    }
  }

  Future<void> _onAuthenticated() async {
    try {
      final data = await ApiClient.getMe();
      final user = data['user'] ?? data;
      if (mounted) {
        setState(() {
          _profile = UserProfile.fromJson(user as Map<String, dynamic>);
          _isAuthenticated = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isAuthenticated = true);
    }
  }

  Future<void> _logout() async {
    await ApiClient.clearToken();
    if (mounted) {
      setState(() {
        _isAuthenticated = false;
        _profile = UserProfile.sample();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '37度',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: !_initialized
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.brandPrimary),
              ),
            )
          : _isAuthenticated
              ? MainShell(
                  profile: _profile,
                  onProfileChanged: (p) => setState(() => _profile = p),
                  onLogout: _logout,
                )
              : AuthScreen(onAuthenticated: _onAuthenticated),
    );
  }
}

final class AppColors {
  static const brandPrimary = Color(0xFFFF4757);
  static const brandPrimaryLight = Color(0xFFFFF0F1);
  static const brandSecondary = Color(0xFF5352ED);
  static const bgPrimary = Color(0xFFFFFFFF);
  static const bgSecondary = Color(0xFFF7F7F7);
  static const bgTertiary = Color(0xFFF2F2F7);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFF999999);
  static const divider = Color(0xFFE5E5EA);
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);
}

final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandPrimary,
        primary: AppColors.brandPrimary,
        secondary: AppColors.brandSecondary,
        surface: AppColors.bgPrimary,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgPrimary,
        selectedItemColor: AppColors.brandPrimary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      textTheme:
          const TextTheme(
            displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            displaySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            headlineMedium: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: TextStyle(fontSize: 17),
            bodyMedium: TextStyle(fontSize: 15),
            bodySmall: TextStyle(fontSize: 14),
            labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ).apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
    );
  }
}

enum Gender {
  undisclosed('未设置'),
  male('男'),
  female('女');

  const Gender(this.label);
  final String label;
}

enum WorkType { voice, video, image }

class UserWork {
  const UserWork({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    this.duration,
    this.isPinned = false,
  });

  final String id;
  final WorkType type;
  final String title;
  final String summary;
  final int? duration;
  final bool isPinned;

  factory UserWork.fromJson(Map<String, dynamic> json) {
    return UserWork(
      id: json['id'] as String? ?? '',
      type: _parseWorkType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      duration: json['duration'] as int?,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  static WorkType _parseWorkType(String? v) {
    switch (v) {
      case 'voice':
        return WorkType.voice;
      case 'video':
        return WorkType.video;
      case 'image':
        return WorkType.image;
      default:
        return WorkType.image;
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    this.handle = '',
    required this.gender,
    required this.birthYear,
    required this.birthMonth,
    required this.city,
    required this.signature,
    required this.avatarKey,
    required this.phoneVerified,
    required this.identityVerified,
    required this.faceVerified,
    this.works = const [],
    this.following = 0,
    this.followers = 0,
    this.likes = 0,
    this.membershipLevel = 'standard',
  });

  final String id;
  final String name;
  final String handle;
  final Gender gender;
  final int birthYear;
  final int birthMonth;
  final String city;
  final String signature;
  final String avatarKey;
  final bool phoneVerified;
  final bool identityVerified;
  final bool faceVerified;
  final List<UserWork> works;
  final int following;
  final int followers;
  final int likes;
  final String membershipLevel;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      gender: _parseGender(json['gender'] as String?),
      birthYear: json['birthYear'] as int? ?? 0,
      birthMonth: json['birthMonth'] as int? ?? 1,
      city: json['city'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
      avatarKey: json['avatarKey'] as String? ?? '',
      phoneVerified: json['phoneStatus'] == 'verified' || json['phoneVerified'] == true,
      identityVerified: json['identityStatus'] == 'verified' || json['identityVerified'] == true,
      faceVerified: json['faceStatus'] == 'verified' || json['faceVerified'] == true,
      works: (json['works'] as List<dynamic>?)
              ?.map((w) => UserWork.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      membershipLevel: json['membershipLevel'] as String? ?? 'standard',
    );
  }

  static Gender _parseGender(String? v) {
    switch (v) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.undisclosed;
    }
  }

  double get profileCompletion {
    var filled = 0;
    if (name.isNotEmpty) filled++;
    if (gender != Gender.undisclosed) filled++;
    if (birthYear > 0) filled++;
    if (city.isNotEmpty) filled++;
    if (signature.isNotEmpty) filled++;
    if (avatarKey.isNotEmpty) filled++;
    return filled / 6;
  }

  double get verificationCompletion {
    var verified = 0;
    if (phoneVerified) verified++;
    if (identityVerified) verified++;
    if (faceVerified) verified++;
    return verified / 3;
  }

  UserProfile copyWith({
    String? id,
    String? name,
    Gender? gender,
    int? birthYear,
    int? birthMonth,
    String? city,
    String? signature,
    String? avatarKey,
    bool? phoneVerified,
    bool? identityVerified,
    bool? faceVerified,
    List<UserWork>? works,
    int? following,
    int? followers,
    int? likes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      birthMonth: birthMonth ?? this.birthMonth,
      city: city ?? this.city,
      signature: signature ?? this.signature,
      avatarKey: avatarKey ?? this.avatarKey,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      identityVerified: identityVerified ?? this.identityVerified,
      faceVerified: faceVerified ?? this.faceVerified,
      works: works ?? this.works,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      likes: likes ?? this.likes,
    );
  }

  static UserProfile sample() {
    return const UserProfile(
      id: '',
      name: '37度用户',
      handle: 'thirtyseven',
      gender: Gender.undisclosed,
      birthYear: 2000,
      birthMonth: 1,
      city: '上海',
      signature: '保持温度，认真认识每一个人。',
      avatarKey: 'aurora',
      phoneVerified: true,
      identityVerified: false,
      faceVerified: false,
      following: 128,
      followers: 256,
      likes: 1024,
      works: [
        UserWork(
          id: 'voice-1',
          type: WorkType.voice,
          title: '声音介绍',
          summary: '一段简单的自我介绍',
          duration: 18,
          isPinned: true,
        ),
        UserWork(
          id: 'image-1',
          type: WorkType.image,
          title: '生活照片',
          summary: '周末的城市散步',
        ),
      ],
    );
  }
}

class FeedPost {
  const FeedPost({
    required this.id,
    required this.username,
    this.handle = '',
    this.timeAgo = '',
    required this.content,
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.location = '',
    this.distance = '',
    this.verificationLabel = '',
  });

  final String id;
  final String username;
  final String handle;
  final String timeAgo;
  final String content;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final String location;
  final String distance;
  final String verificationLabel;

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: (json['id'] ?? '').toString(),
      username: (json['authorName'] ?? json['author_name'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      likeCount: (json['likes'] ?? json['likes_count'] ?? 0) as int,
      commentCount: (json['comments'] ?? json['comments_count'] ?? 0) as int,
      location: (json['location'] ?? '').toString(),
      distance: (json['distance'] ?? '').toString(),
      verificationLabel: (json['verificationLabel'] ?? json['verification_label'] ?? '').toString(),
      timeAgo: _formatTimeAgo((json['createdAt'] ?? json['created_at'] ?? '').toString()),
      tags: (json['attachments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  static String _formatTimeAgo(String? isoTime) {
    if (isoTime == null) return '';
    try {
      final dt = DateTime.parse(isoTime);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return '刚刚';
      if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
      if (diff.inHours < 24) return '${diff.inHours}小时前';
      return '${diff.inDays}天前';
    } catch (_) {
      return '';
    }
  }
}

class SquareUser {
  const SquareUser({
    required this.id,
    required this.name,
    this.gender = 'undisclosed',
    this.age = 0,
    this.city = '',
    this.distance = '',
    this.signature = '',
    this.tags = const [],
    this.trustLabel = '',
    this.isVerified = false,
    this.isOnline = false,
    this.membershipLevel = 'standard',
  });

  final String id;
  final String name;
  final String gender;
  final int age;
  final String city;
  final String distance;
  final String signature;
  final List<String> tags;
  final String trustLabel;
  final bool isVerified;
  final bool isOnline;
  final String membershipLevel;

  factory SquareUser.fromJson(Map<String, dynamic> json) {
    return SquareUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      gender: (json['gender'] ?? 'undisclosed').toString(),
      age: (json['age'] ?? 0) as int,
      city: (json['city'] ?? '').toString(),
      distance: (json['distance'] ?? '').toString(),
      signature: (json['signature'] ?? '').toString(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      trustLabel: (json['trustLabel'] ?? json['trust_label'] ?? '').toString(),
      isVerified: json['isVerified'] == true || json['is_verified'] == true || json['is_verified'] == 1,
      isOnline: json['isOnline'] == true || json['is_online'] == true || json['is_online'] == 1,
      membershipLevel: (json['membershipLevel'] ?? json['membership_level'] ?? 'standard').toString(),
    );
  }
}

class Conversation {
  const Conversation({
    required this.id,
    required this.username,
    required this.lastMessage,
    required this.timeAgo,
    required this.unreadCount,
    required this.isPinned,
  });

  final String id;
  final String username;
  final String lastMessage;
  final String timeAgo;
  final int unreadCount;
  final bool isPinned;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: (json['id'] ?? '').toString(),
      username: (json['title'] ?? json['username'] ?? '').toString(),
      lastMessage: (json['lastMessagePreview'] ?? json['last_message_preview'] ?? json['subtitle'] ?? '').toString(),
      timeAgo: FeedPost._formatTimeAgo((json['updatedAt'] ?? json['updated_at'] ?? json['createdAt'] ?? json['created_at'] ?? '').toString()),
      unreadCount: (json['unreadCount'] ?? json['unread_count'] ?? 0) as int,
      isPinned: json['isPinned'] == true || json['is_pinned'] == true || json['is_pinned'] == 1,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isOwn,
    required this.time,
    this.type = 'text',
    this.mediaUrl,
  });

  final String id;
  final String text;
  final bool isOwn;
  final String time;
  final String type;
  final String? mediaUrl;

  factory ChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = (json['senderId'] ?? json['sender_id'] ?? '').toString();
    final createdAt = (json['createdAt'] ?? json['created_at'] ?? '').toString();
    String timeStr = '';
    try {
      final dt = DateTime.parse(createdAt);
      timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      timeStr = createdAt;
    }
    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      isOwn: currentUserId != null ? senderId == currentUserId : (json['isOwn'] == true),
      time: timeStr,
      type: (json['type'] ?? 'text').toString(),
      mediaUrl: (json['mediaUrl'] ?? json['media_url'] ?? '').toString(),
    );
  }
}

class Notice {
  const Notice({
    required this.icon,
    required this.iconColor,
    required this.username,
    required this.content,
    required this.timeAgo,
    required this.isRead,
  });

  final IconData icon;
  final Color iconColor;
  final String username;
  final String content;
  final String timeAgo;
  final bool isRead;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  int _smsCountdown = 0;
  String? _error;
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 11) return;
    setState(() => _error = null);
    try {
      await ApiClient.sendSms(phone, purpose: _isSignUp ? 'register' : 'general');
      setState(() => _smsCountdown = 60);
      while (_smsCountdown > 0 && mounted) {
        await Future<void>.delayed(const Duration(seconds: 1));
        if (mounted) setState(() => _smsCountdown--);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    if (phone.isEmpty || password.isEmpty) {
      setState(() => _error = '请填写手机号和密码');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (_isSignUp) {
        final code = _codeController.text.trim();
        final name = _nicknameController.text.trim();
        if (code.isEmpty) {
          setState(() { _isLoading = false; _error = '请填写验证码'; });
          return;
        }
        if (name.isEmpty) {
          setState(() { _isLoading = false; _error = '请填写昵称'; });
          return;
        }
        await ApiClient.register(
          name: name,
          phone: phone,
          smsCode: code,
          password: password,
        );
      } else {
        await ApiClient.login(phone, password);
      }
      if (mounted) widget.onAuthenticated();
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 96, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '37°',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '温度与信任',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14)),
                ),
                const SizedBox(height: 12),
              ],
              AppTextField(
                controller: _phoneController,
                hintText: '手机号',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              if (_isSignUp) ...[
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _codeController,
                        hintText: '验证码',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 112,
                      child: SecondaryButton(
                        text: _smsCountdown > 0 ? '${_smsCountdown}s' : '获取验证码',
                        onPressed: _smsCountdown > 0 ? () {} : _sendSms,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              AppTextField(
                controller: _passwordController,
                hintText: '密码',
                obscureText: true,
              ),
              const SizedBox(height: 12),
              if (_isSignUp) ...[
                AppTextField(controller: _nicknameController, hintText: '昵称'),
                const SizedBox(height: 12),
              ],
              PrimaryButton(
                text: _isSignUp ? '注册' : '登录',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              if (!_isSignUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const PasswordResetScreen()),
                    ),
                    child: const Text('忘记密码？'),
                  ),
                ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp ? '已有账号？' : '没有账号？',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => setState(() { _isSignUp = !_isSignUp; _error = null; }),
                    child: Text(_isSignUp ? '去登录' : '立即注册'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '其他登录方式',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(icon: Icons.wechat, label: '微信'),
                  const SizedBox(width: 36),
                  _SocialButton(icon: Icons.phone_iphone, label: 'Apple'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.onLogout,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;
  final VoidCallback onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const FeedScreen(),
      const ChatListScreen(),
      const DiscoverScreen(),
      ProfileScreen(
        profile: widget.profile,
        onProfileChanged: widget.onProfileChanged,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: '消息'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 32),
            label: '发布',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '发现'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const CreationScreen()));
      return;
    }
    setState(() => _selectedIndex = index > 2 ? index - 1 : index);
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _segment = 0;
  List<FeedPost> _posts = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  int _total = 0;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) _page = 1;
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiClient.getCirclePosts(page: _page);
      final list = (data['posts'] as List<dynamic>?)
              ?.map((p) => FeedPost.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [];
      if (mounted) {
        setState(() {
          _posts = refresh ? list : [..._posts, ...list];
          _total = data['total'] as int? ?? 0;
          _hasMore = _posts.length < _total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _toggleLike(FeedPost post, int index) async {
    try {
      if (post.isLiked) {
        await ApiClient.unlikeCirclePost(post.id);
      } else {
        await ApiClient.likeCirclePost(post.id);
      }
      setState(() {
        _posts[index] = FeedPost(
          id: post.id,
          username: post.username,
          handle: post.handle,
          timeAgo: post.timeAgo,
          content: post.content,
          tags: post.tags,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
          commentCount: post.commentCount,
          isLiked: !post.isLiked,
          location: post.location,
          distance: post.distance,
          verificationLabel: post.verificationLabel,
        );
      });
     } catch (_) {}
  }

  Future<void> _reportPost(String postId) async {
    final reasons = ['内容不适', '骚扰或冒充', '虚假信息', '其他原因'];
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('举报原因'),
        children: reasons.map((r) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, r),
          child: Text(r),
        )).toList(),
      ),
    );
    if (reason == null) return;
    try {
      await ApiClient.reportCirclePost(postId, reason);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('举报成功')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('举报失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: Column(
        children: [
          SegmentedHeader(
            selectedIndex: _segment,
            labels: const ['推荐', '关注'],
            onChanged: (index) => setState(() => _segment = index),
          ),
          SizedBox(
            height: 92,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: 9,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return StoryItem(
                  label: index == 0 ? '我的' : '用户$index',
                  isMine: index == 0,
                  isViewed: index > 4,
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: _isLoading && _posts.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
                : _error != null && _posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppColors.textTertiary)),
                            const SizedBox(height: 12),
                            SecondaryButton(text: '重试', onPressed: () => _loadPosts(refresh: true)),
                          ],
                        ),
                      )
                    : _posts.isEmpty
                        ? const Center(child: Text('暂无动态', style: TextStyle(color: AppColors.textTertiary)))
                        : RefreshIndicator(
                            color: AppColors.brandPrimary,
                            onRefresh: () => _loadPosts(refresh: true),
                            child: ListView.separated(
                              itemCount: _posts.length + (_hasMore ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, color: AppColors.divider),
                              itemBuilder: (context, index) {
                                if (index == _posts.length) {
                                  _loadPosts();
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                }
                                return PostCard(
                                  post: _posts[index],
                                  onLike: () => _toggleLike(_posts[index], index),
                                  onComment: () => showModalBottomSheet<void>(
                                    context: context,
                                    showDragHandle: true,
                                    builder: (_) => CommentSheet(postId: _posts[index].id),
                                  ),
                                  onReport: () => _reportPost(_posts[index].id),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiClient.getConversations();
      final list = (data['conversations'] as List<dynamic>?)
              ?.map((c) => Conversation.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [];
      if (mounted) setState(() { _conversations = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _createConversation() async {
    final titleController = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建会话'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: '会话名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, titleController.text.trim()), child: const Text('创建')),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;
    try {
      final data = await ApiClient.createConversation({'title': title});
      final conv = data['conversation'] as Map<String, dynamic>?;
      if (conv != null && mounted) {
        setState(() => _conversations.insert(0, Conversation.fromJson(conv)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('创建失败: $e')));
    }
  }

  Future<void> _deleteConversation(int index) async {
    final conv = _conversations[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除会话'),
        content: Text('确定删除与 ${conv.username} 的会话？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient.deleteConversation(conv.id);
      if (mounted) setState(() => _conversations.removeAt(index));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败: $e')));
    }
  }

  Future<void> _togglePin(int index) async {
    try {
      await ApiClient.pinConversation(_conversations[index].id);
      _load();
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await ApiClient.readAllConversations();
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'new') _createConversation();
              if (value == 'readAll') _markAllRead();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'new', child: Text('新建会话')),
              if (_conversations.any((c) => c.unreadCount > 0))
                const PopupMenuItem(value: 'readAll', child: Text('全部已读')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen())),
              child: const SearchPill(text: '搜索'),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppColors.textTertiary)),
                            const SizedBox(height: 12),
                            SecondaryButton(text: '重试', onPressed: _load),
                          ],
                        ),
                      )
                    : _conversations.isEmpty
                        ? const Center(child: Text('暂无会话', style: TextStyle(color: AppColors.textTertiary)))
                        : RefreshIndicator(
                            color: AppColors.brandPrimary,
                            onRefresh: _load,
                            child: ListView.separated(
                              itemCount: _conversations.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, color: AppColors.divider),
                              itemBuilder: (context, index) {
                                final item = _conversations[index];
                                return Dismissible(
                                  key: ValueKey(item.id),
                                  background: Container(
                                    color: AppColors.brandPrimary,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: const Icon(Icons.push_pin, color: Colors.white),
                                  ),
                                  secondaryBackground: Container(
                                    color: AppColors.error,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.startToEnd) {
                                      _togglePin(index);
                                    } else {
                                      _deleteConversation(index);
                                    }
                                    return false;
                                  },
                                  child: ConversationTile(
                                    conversation: item,
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => ChatDetailScreen(conversation: item),
                                        ),
                                      );
                                      if (mounted) _load();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.conversation});

  final Conversation conversation;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  List<ChatMessage> _messages = [];
  bool _isSending = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiClient.getMessages(widget.conversation.id);
      final list = (data['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
      if (mounted) {
        setState(() { _messages = list; _isLoading = false; });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMedia(String type) async {
    try {
      XFile? xFile;
      if (type == 'image') {
        xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
      }
      if (xFile == null) return;

      setState(() => _isSending = true);
      final res = await ApiClient.uploadFile('file', xFile.path);
      final fileData = res['file'] as Map<String, dynamic>?;
      final mediaUrl = fileData?['url']?.toString() ?? '';

      await ApiClient.sendMessage(
        conversationId: widget.conversation.id,
        text: type == 'image' ? '[图片]' : '[媒体]',
        type: type,
      );

      setState(() {
        _messages = [
          ..._messages,
          ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            text: type == 'image' ? '[图片]' : '[媒体]',
            isOwn: true,
            time: '刚刚',
            type: type,
            mediaUrl: mediaUrl,
          ),
        ];
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发送失败: $e')));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.username)),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppColors.textTertiary)),
                            const SizedBox(height: 12),
                            SecondaryButton(text: '重试', onPressed: _loadMessages),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) => ChatBubble(
                          message: _messages[index],
                          senderName: widget.conversation.username,
                        ),
                      ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isSending ? null : () => _sendMedia('image'),
                    icon: const Icon(Icons.image),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '输入消息...',
                        filled: true,
                        fillColor: AppColors.bgTertiary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSending ? null : _send,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _controller.text.isEmpty
                                ? Icons.add_circle_outline
                                : Icons.arrow_circle_up,
                            color: _controller.text.isEmpty
                                ? AppColors.textTertiary
                                : AppColors.brandPrimary,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages = [
        ..._messages,
        ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: text,
          isOwn: true,
          time: '刚刚',
        ),
      ];
    });
    _scrollToBottom();
    try {
      final data = await ApiClient.sendMessage(
        conversationId: widget.conversation.id,
        text: text,
      );
      final sentMsg = data['sentMessage'] as Map<String, dynamic>?;
      final reply = data['reply'] as Map<String, dynamic>?;
      if (mounted && (sentMsg != null || reply != null)) {
        setState(() {
          if (reply != null) {
            _messages = [
              ..._messages,
              ChatMessage.fromJson(reply),
            ];
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发送失败: $e')));
      }
    }
  }
}

class CreationScreen extends StatefulWidget {
  const CreationScreen({super.key});

  @override
  State<CreationScreen> createState() => _CreationScreenState();
}

class _CreationScreenState extends State<CreationScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  List<Map<String, String>> _attachments = [];
  bool _isSubmitting = false;
  String _location = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(source: source, maxWidth: 1200, imageQuality: 85);
      if (xFile == null) return;
      setState(() {
        _attachments.add({'type': 'image', 'url': xFile.path, 'label': '图片'});
      });
    } catch (_) {}
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty && _attachments.isEmpty) return;
    setState(() => _isSubmitting = true);

    try {
      final uploadedAttachments = <Map<String, dynamic>>[];
      for (final att in _attachments) {
        if (att['url'] != null && !att['url']!.startsWith('http')) {
          final res = await ApiClient.uploadFile('file', att['url']!);
          final fileData = res['file'] as Map<String, dynamic>?;
          uploadedAttachments.add({
            'type': att['type'] ?? 'image',
            'url': fileData?['url'] ?? att['url'],
            'label': att['label'] ?? '',
          });
        } else {
          uploadedAttachments.add(att);
        }
      }

      await ApiClient.createCirclePost({
        'content': content,
        if (_location.isNotEmpty) 'location': _location,
        'visibility': 'public',
        'attachments': uploadedAttachments,
      });

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布动态'),
        leading: TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        leadingWidth: 72,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: '分享你的想法...',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_attachments.isNotEmpty)
              SizedBox(
                height: 92,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachments.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == _attachments.length) {
                      return MediaAddButton(onTap: () => _pickImage(ImageSource.gallery));
                    }
                    final att = _attachments[index];
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: att['type'] == 'image'
                              ? const Icon(Icons.image, color: AppColors.textTertiary, size: 30)
                              : const Icon(Icons.videocam, color: AppColors.textTertiary, size: 30),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () => setState(() => _attachments.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.error,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              SizedBox(
                height: 92,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [MediaAddButton(onTap: () => _pickImage(ImageSource.gallery))],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CreationTool(icon: Icons.photo_library, label: '相册', onTap: () => _pickImage(ImageSource.gallery)),
                  CreationTool(icon: Icons.camera_alt, label: '拍照', onTap: () => _pickImage(ImageSource.camera)),
                  CreationTool(icon: Icons.mic, label: '语音', onTap: () {}),
                  CreationTool(
                    icon: Icons.location_on,
                    label: '位置',
                    onTap: () {
                      setState(() => _location = _location.isEmpty ? '上海' : '');
                    },
                  ),
                ],
              ),
            ),
            if (_location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.brandPrimary),
                    const SizedBox(width: 4),
                    Text(_location, style: const TextStyle(color: AppColors.brandPrimary, fontSize: 13)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _location = ''),
                      child: const Icon(Icons.close, size: 16, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(
                text: '发布',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedTag = '全部';
  static const _tags = ['全部', '热门', '附近', '话题', '用户', '视频'];
  List<SquareUser> _users = [];
  bool _isLoading = true;
  String? _error;
  String? _filterGender;
  String? _filterRegion;
  bool _filterOnlineOnly = false;
  List<Map<String, dynamic>> _savedFilters = [];
  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadSavedFilters();
    _loadBanners();
    _loadNotices();
  }

  Future<void> _loadBanners() async {
    try {
      final data = await ApiClient.getBanner();
      final list = (data['items'] as List<dynamic>?)
              ?.map((b) => b as Map<String, dynamic>)
              .toList() ??
          [];
      if (mounted) setState(() => _banners = list);
    } catch (_) {}
  }

  Future<void> _loadNotices() async {
    try {
      final data = await ApiClient.getNotices();
      final list = (data['notices'] as List<dynamic>?)
              ?.map((n) => n as Map<String, dynamic>)
              .toList() ??
          [];
      if (mounted) setState(() => _notices = list);
    } catch (_) {}
  }

  Future<void> _loadSavedFilters() async {
    try {
      final data = await ApiClient.getFilters();
      final list = (data['filters'] as List<dynamic>?)
              ?.map((f) => f as Map<String, dynamic>)
              .toList() ??
          [];
      if (mounted) setState(() => _savedFilters = list);
    } catch (_) {}
  }

  Future<void> _loadUsers() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiClient.getSquareUsers(
        gender: _filterGender,
        region: _filterRegion,
        onlineOnly: _filterOnlineOnly ? true : null,
      );
      final list = (data['users'] as List<dynamic>?)
              ?.map((u) => SquareUser.fromJson(u as Map<String, dynamic>))
              .toList() ??
          [];
      if (mounted) setState(() { _users = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _saveCurrentFilter() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('保存筛选条件'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: '筛选名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, nameController.text.trim()), child: const Text('保存')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      await ApiClient.saveFilters({
        'name': name,
        if (_filterGender != null) 'gender': _filterGender,
        if (_filterRegion != null) 'region': _filterRegion,
        'onlineOnly': _filterOnlineOnly,
      });
      _loadSavedFilters();
    } catch (_) {}
  }

  void _applyFilter(Map<String, dynamic> filter) {
    setState(() {
      _filterGender = filter['gender']?.toString();
      _filterRegion = filter['region']?.toString();
      _filterOnlineOnly = filter['onlineOnly'] == true;
    });
    _loadUsers();
  }

  void _clearFilters() {
    setState(() {
      _filterGender = null;
      _filterRegion = null;
      _filterOnlineOnly = false;
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'save') {
                _saveCurrentFilter();
              } else if (value == 'clear') {
                _clearFilters();
              } else if (value.startsWith('filter:')) {
                final idx = int.parse(value.substring(7));
                if (idx < _savedFilters.length) _applyFilter(_savedFilters[idx]);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'save', child: Text('保存当前筛选')),
              if (_filterGender != null || _filterRegion != null || _filterOnlineOnly)
                const PopupMenuItem(value: 'clear', child: Text('清除筛选')),
              if (_savedFilters.isNotEmpty) const PopupMenuDivider(),
              ..._savedFilters.asMap().entries.map(
                (e) => PopupMenuItem(value: 'filter:${e.key}', child: Text('📋 ${e.value['name'] ?? '筛选'}')),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.brandPrimary,
        onRefresh: _loadUsers,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen())),
              child: const SearchPill(text: '搜索用户、话题、内容...'),
            ),
            if (_banners.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _banners.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final b = _banners[index];
                    return Container(
                      width: 260,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.brandPrimary, AppColors.brandSecondary]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text((b['title'] ?? '').toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text((b['description'] ?? '').toString(), style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_notices.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._notices.take(3).map((n) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign, size: 20, color: AppColors.brandPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (n['title'] ?? n['content'] ?? '').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            if (_filterGender != null || _filterRegion != null || _filterOnlineOnly) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (_filterGender != null)
                    FilterChip(
                      label: Text('性别: ${_filterGender == 'male' ? '男' : '女'}'),
                      onDeleted: () { setState(() => _filterGender = null); _loadUsers(); },
                      onSelected: (_) {},
                    ),
                  if (_filterRegion != null)
                    FilterChip(
                      label: Text('地区: $_filterRegion'),
                      onDeleted: () { setState(() => _filterRegion = null); _loadUsers(); },
                      onSelected: (_) {},
                    ),
                  if (_filterOnlineOnly)
                    FilterChip(
                      label: const Text('仅在线'),
                      onDeleted: () { setState(() => _filterOnlineOnly = false); _loadUsers(); },
                      onSelected: (_) {},
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final tag = _tags[index];
                  return FilterChip(
                    selected: tag == _selectedTag,
                    label: Text(tag),
                    onSelected: (_) => setState(() => _selectedTag = tag),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _tags.length,
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: '附近的人',
              child: SizedBox(
                height: 96,
                child: _isLoading
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : _users.isEmpty
                        ? const Center(child: Text('暂无', style: TextStyle(color: AppColors.textTertiary)))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _users.length > 10 ? 10 : _users.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final u = _users[index];
                              return Column(
                                children: [
                                  AppAvatar(label: u.name, size: 54),
                                  const SizedBox(height: 6),
                                  Text(u.name, overflow: TextOverflow.ellipsis),
                                  Text(
                                    u.distance.isNotEmpty ? u.distance : u.city,
                                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                                  ),
                                ],
                              );
                            },
                          ),
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: '推荐用户',
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator(color: AppColors.brandPrimary)),
                    )
                  : _error != null
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(_error!, style: const TextStyle(color: AppColors.textTertiary)),
                              const SizedBox(height: 8),
                              SecondaryButton(text: '重试', onPressed: _loadUsers),
                            ],
                          ),
                        )
                      : _users.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: Text('暂无推荐用户', style: TextStyle(color: AppColors.textTertiary))),
                            )
                          : Column(
                              children: _users.take(10).map((u) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: AppAvatar(label: u.name, size: 42),
                                  title: Row(
                                    children: [
                                      Flexible(child: Text(u.name)),
                                      if (u.isVerified) ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, size: 16, color: AppColors.brandPrimary),
                                      ],
                                      if (u.isOnline) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Text(
                                    u.signature.isNotEmpty ? u.signature : u.city,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    u.distance.isNotEmpty ? u.distance : '',
                                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                                  ),
                                );
                              }).toList(),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.onLogout,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  static const _tabs = ['动态', '相册', '收藏'];
  bool _isRefreshing = false;

  Future<void> _refreshProfile() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final data = await ApiClient.getProfileComplete();
      final user = data['user'] ?? data;
      if (mounted) {
        widget.onProfileChanged(
          UserProfile.fromJson(user as Map<String, dynamic>),
        );
      }
    } catch (_) {}
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            onPressed: _isRefreshing ? null : _refreshProfile,
            icon: _isRefreshing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SettingsScreen(onLogout: widget.onLogout),
              ),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 20),
          Center(child: AppAvatar(label: profile.name, size: 88)),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                if (profile.gender != Gender.undisclosed) ...[
                  const SizedBox(width: 6),
                  Icon(
                    profile.gender == Gender.male ? Icons.male : Icons.female,
                    color: profile.gender == Gender.male
                        ? Colors.blue
                        : Colors.pink,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '@${profile.handle}',
              style: const TextStyle(color: AppColors.textTertiary),
            ),
          ),
          if (profile.city.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  Text(
                    profile.city,
                    style: const TextStyle(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
            child: Text(
              profile.signature,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatItem(count: profile.following, label: '关注'),
                StatItem(count: profile.followers, label: '粉丝'),
                StatItem(count: profile.likes, label: '获赞'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ProgressLine(
                  label: '资料完成度',
                  value: profile.profileCompletion,
                  color: AppColors.brandPrimary,
                ),
                const SizedBox(height: 10),
                ProgressLine(
                  label: '认证完成度',
                  value: profile.verificationCompletion,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.of(context).push<UserProfile>(
                  MaterialPageRoute<UserProfile>(
                    builder: (_) => VerificationScreen(
                      profile: widget.profile,
                      onProfileChanged: widget.onProfileChanged,
                    ),
                  ),
                );
                if (result != null) widget.onProfileChanged(result);
              },
              child: Row(
                children: [
                  VerificationBadge(
                    icon: Icons.phone_android,
                    label: '手机',
                    verified: profile.phoneVerified,
                  ),
                  VerificationBadge(
                    icon: Icons.badge,
                    label: '实名',
                    verified: profile.identityVerified,
                  ),
                  VerificationBadge(
                    icon: Icons.face,
                    label: '本人头像',
                    verified: profile.faceVerified,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: '编辑资料',
                    onPressed: () async {
                      final updated = await Navigator.of(context)
                          .push<UserProfile>(
                            MaterialPageRoute<UserProfile>(
                              builder: (_) =>
                                  EditProfileScreen(profile: widget.profile),
                            ),
                          );
                      if (updated != null) widget.onProfileChanged(updated);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GhostButton(text: '分享', onPressed: () {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SegmentedHeader(
            selectedIndex: _selectedTab,
            labels: _tabs,
            onChanged: (index) => setState(() => _selectedTab = index),
          ),
          if (_selectedTab == 0)
            WorksList(works: profile.works)
          else
            MediaPlaceholderGrid(tab: _tabs[_selectedTab]),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _signatureController;
  late Gender _gender;
  late int _birthYear;
  late int _birthMonth;
  late String _avatarKey;

  static const _avatars = [
    'aurora',
    'sunset',
    'ocean',
    'forest',
    'flame',
    'crystal',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _cityController = TextEditingController(text: widget.profile.city);
    _signatureController = TextEditingController(
      text: widget.profile.signature,
    );
    _gender = widget.profile.gender;
    _birthYear = widget.profile.birthYear;
    _birthMonth = widget.profile.birthMonth;
    _avatarKey = widget.profile.avatarKey;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [_isSaving
            ? const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : TextButton(onPressed: _save, child: const Text('保存'))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text('头像主题', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _avatars.map((key) {
              final selected = key == _avatarKey;
              return ChoiceChip(
                selected: selected,
                avatar: CircleAvatar(backgroundColor: avatarColor(key)),
                label: Text(key),
                onSelected: (_) => setState(() => _avatarKey = key),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          AppTextField(controller: _nameController, hintText: '昵称'),
          const SizedBox(height: 12),
          DropdownButtonFormField<Gender>(
            initialValue: _gender,
            decoration: fieldDecoration('性别'),
            items: Gender.values
                .map(
                  (gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _gender = value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _birthYear,
                  decoration: fieldDecoration('出生年份'),
                  items: List.generate(51, (index) => 1960 + index).reversed
                      .map(
                        (year) => DropdownMenuItem(
                          value: year,
                          child: Text('$year年'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _birthYear = value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _birthMonth,
                  decoration: fieldDecoration('出生月份'),
                  items: List.generate(12, (index) => index + 1)
                      .map(
                        (month) => DropdownMenuItem(
                          value: month,
                          child: Text('$month月'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _birthMonth = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(controller: _cityController, hintText: '城市'),
          const SizedBox(height: 12),
          TextField(
            controller: _signatureController,
            minLines: 3,
            maxLines: 5,
            decoration: fieldDecoration('个性签名'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final updated = widget.profile.copyWith(
      name: _nameController.text.trim(),
      gender: _gender,
      birthYear: _birthYear,
      birthMonth: _birthMonth,
      city: _cityController.text.trim(),
      signature: _signatureController.text.trim(),
      avatarKey: _avatarKey,
    );
    try {
      await ApiClient.updateProfile({
        'name': updated.name,
        'gender': updated.gender.name,
        'birthYear': updated.birthYear,
        'birthMonth': updated.birthMonth,
        'city': updated.city,
        'signature': updated.signature,
        'avatarKey': updated.avatarKey,
      });
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(updated);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _friendsOnly = false;
  bool _squareExposure = true;
  bool _preferVerified = true;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsResp = await ApiClient.getSettings();
      final privacyResp = await ApiClient.getChatPrivacy();
      final settingsPrivacy = settingsResp['privacy'] ?? settingsResp;
      final chatPrivacy = privacyResp['privacy'] ?? privacyResp;
      if (mounted) {
        setState(() {
          _friendsOnly = _boolVal(chatPrivacy['friends_only'] ?? chatPrivacy['friendsOnly']);
          _squareExposure = _boolVal(settingsPrivacy['allow_square_exposure'] ?? settingsPrivacy['allowSquareExposure'], fallback: true);
          _preferVerified = _boolVal(settingsPrivacy['prefer_verified_users'] ?? settingsPrivacy['preferVerifiedUsers'], fallback: true);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static bool _boolVal(dynamic v, {bool fallback = false}) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    return fallback;
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() => _error = null);
    try {
      if (key == 'friendsOnly') {
        await ApiClient.updateChatPrivacy({'friendsOnly': value});
      } else if (key == 'allowSquareExposure') {
        await ApiClient.updateSettings({'allowSquareExposure': value});
      } else if (key == 'preferVerifiedUsers') {
        await ApiClient.updateSettings({'preferVerifiedUsers': value});
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        _loadSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14)),
            ),
            const SizedBox(height: 12),
          ],
          SettingsGroup(
            title: '隐私设置',
            children: [
              SwitchListTile(
                title: const Text('仅好友可聊'),
                subtitle: const Text('开启后只有好友能发起私聊'),
                value: _friendsOnly,
                onChanged: (value) {
                  setState(() => _friendsOnly = value);
                  _updateSetting('friendsOnly', value);
                },
              ),
              SwitchListTile(
                title: const Text('广场曝光'),
                subtitle: const Text('允许你的资料在广场被推荐'),
                value: _squareExposure,
                onChanged: (value) {
                  setState(() => _squareExposure = value);
                  _updateSetting('allowSquareExposure', value);
                },
              ),
              SwitchListTile(
                title: const Text('优先已认证用户'),
                subtitle: const Text('推荐列表优先展示已认证用户'),
                value: _preferVerified,
                onChanged: (value) {
                  setState(() => _preferVerified = value);
                  _updateSetting('preferVerifiedUsers', value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            title: '通知设置',
            children: [
              SettingsTile(
                icon: Icons.notifications,
                title: '通知中心',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
              SettingsTile(icon: Icons.devices, title: '设备管理', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DeviceManagementScreen()))),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            title: '账号安全',
            children: [
              SettingsTile(icon: Icons.block, title: '黑名单', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BlacklistScreen()))),
              SettingsTile(icon: Icons.lock, title: '修改密码', onTap: () {}),
            ],
          ),
          const SizedBox(height: 28),
          SecondaryButton(
            text: '退出登录',
            onPressed: () {
              Navigator.of(context).pop();
              widget.onLogout();
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AccountCancelScreen(onLogout: widget.onLogout),
              ),
            ),
            child: const Text('注销账号', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiClient.getNotifications();
      final list = (data['notifications'] as List<dynamic>?)
              ?.map((n) => n as Map<String, dynamic>)
              .toList() ??
          [];
      if (mounted) setState(() { _notifications = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _markRead(int index) async {
    final n = _notifications[index];
    final isRead = n['isRead'] == true || n['is_read'] == true || n['is_read'] == 1;
    if (isRead) return;
    final nId = (n['id'] ?? n['notification_id'] ?? '').toString();
    if (nId.isEmpty) return;
    try {
      await ApiClient.markNotificationRead(nId);
      setState(() {
        _notifications[index]['isRead'] = true;
        _notifications[index]['is_read'] = 1;
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await ApiClient.markAllNotificationsRead();
      setState(() {
        for (final n in _notifications) {
          n['isRead'] = true;
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        actions: [
          if (_notifications.any((n) => n['isRead'] != true))
            TextButton(
              onPressed: _markAllRead,
              child: const Text('全部已读'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
          : _error != null && _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.textTertiary)),
                      const SizedBox(height: 12),
                      SecondaryButton(text: '重试', onPressed: _load),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? const Center(child: Text('暂无通知', style: TextStyle(color: AppColors.textTertiary)))
                  : RefreshIndicator(
                      color: AppColors.brandPrimary,
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: AppColors.divider),
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          final isRead = n['isRead'] == true || n['is_read'] == true || n['is_read'] == 1;
                          final title = (n['title'] ?? n['type'] ?? '通知').toString();
                          final content = (n['content'] ?? n['message'] ?? n['body'] ?? '').toString();
                          final nType = (n['type'] ?? n['notification_type'] ?? '').toString();
                          final createdAt = (n['createdAt'] ?? n['created_at'] ?? '').toString();
                          return ListTile(
                            tileColor: isRead ? AppColors.bgPrimary : AppColors.brandPrimaryLight,
                            leading: AppAvatar(label: title, size: 42),
                            title: Row(
                              children: [
                                Expanded(child: Text(title)),
                                Text(
                                  _formatTime(createdAt),
                                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                                ),
                              ],
                            ),
                            subtitle: Text(content),
                            trailing: Icon(
                              _iconForType(nType),
                              color: _colorForType(nType),
                              size: 20,
                            ),
                            onTap: () => _markRead(index),
                          );
                        },
                      ),
                    ),
    );
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'like':
        return AppColors.brandPrimary;
      case 'comment':
        return AppColors.brandSecondary;
      case 'follow':
        return AppColors.brandPrimary;
      default:
        return AppColors.warning;
    }
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return '刚刚';
      if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
      if (diff.inHours < 24) return '${diff.inHours}小时前';
      return '${diff.inDays}天前';
    } catch (_) {
      return '';
    }
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: fieldDecoration(hintText),
    );
  }
}

InputDecoration fieldDecoration(String label) {
  return InputDecoration(
    hintText: label,
    filled: true,
    fillColor: AppColors.bgSecondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: AppColors.brandPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(text),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandPrimary,
        side: const BorderSide(color: AppColors.brandPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: Text(text));
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.bgTertiary,
          child: Icon(icon, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.textTertiary)),
      ],
    );
  }
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.label, required this.size});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandPrimary, AppColors.brandSecondary],
        ),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Text(
        label.characters.first,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.brandPrimary,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class SegmentedHeader extends StatelessWidget {
  const SegmentedHeader({
    super.key,
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (index) {
        final selected = index == selectedIndex;
        return Expanded(
          child: InkWell(
            onTap: () => onChanged(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 28,
                    height: 2,
                    color: selected
                        ? AppColors.brandPrimary
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class StoryItem extends StatelessWidget {
  const StoryItem({
    super.key,
    required this.label,
    required this.isMine,
    required this.isViewed,
  });

  final String label;
  final bool isMine;
  final bool isViewed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isViewed
                        ? AppColors.divider
                        : AppColors.brandPrimary,
                    width: 2,
                  ),
                ),
                child: AppAvatar(label: label, size: 50),
              ),
              if (isMine)
                const CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.brandPrimary,
                  child: Icon(Icons.add, size: 14, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onLike, required this.onComment, this.onReport});

  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback onComment;
  final VoidCallback? onReport;

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag, color: AppColors.error),
              title: const Text('举报'),
              onTap: () {
                Navigator.pop(ctx);
                onReport?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(label: post.username, size: 46),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '@${post.handle} · ${post.timeAgo}',
                      style: const TextStyle(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () => _showPostMenu(context), icon: const Icon(Icons.more_horiz)),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.content, maxLines: 6, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: post.tags
                .map(
                  (tag) => Text(
                    '#$tag',
                    style: const TextStyle(color: AppColors.brandPrimary),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                count: post.likeCount,
                color: post.isLiked
                    ? AppColors.brandPrimary
                    : AppColors.textTertiary,
                onTap: onLike ?? () {},
              ),
              ActionButton(
                icon: Icons.chat_bubble_outline,
                count: post.commentCount,
                color: AppColors.textTertiary,
                onTap: onComment,
              ),
              ActionButton(
                icon: Icons.ios_share,
                color: AppColors.textTertiary,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    this.count,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final int? count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 26, top: 10, bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 21, color: color),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: const TextStyle(color: AppColors.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CommentSheet extends StatefulWidget {
  const CommentSheet({super.key, required this.postId});

  final String postId;

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final data = await ApiClient.getCirclePostDetail(widget.postId);
      final list = (data['comments'] as List<dynamic>?)
              ?.map((c) => c as Map<String, dynamic>)
              .toList() ??
          [];
      if (mounted) setState(() { _comments = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await ApiClient.commentCirclePost(widget.postId, text);
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('评论失败: $e')));
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '${_comments.length} 条评论',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2))
          else if (_comments.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Text('暂无评论', style: TextStyle(color: AppColors.textTertiary)))
          else
            ..._comments.map((c) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: AppAvatar(label: (c['author_name'] ?? c['authorName'] ?? '').toString(), size: 36),
              title: Text((c['author_name'] ?? c['authorName'] ?? '').toString()),
              subtitle: Text((c['content'] ?? '').toString()),
            )),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '写评论...',
                      filled: true,
                      fillColor: AppColors.bgTertiary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSubmitting ? null : _submitComment,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send, color: AppColors.brandPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPill extends StatelessWidget {
  const SearchPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: conversation.isPinned
          ? AppColors.bgSecondary
          : AppColors.bgPrimary,
      leading: AppAvatar(label: conversation.username, size: 46),
      title: Row(
        children: [
          Expanded(child: Text(conversation.username)),
          Text(
            conversation.timeAgo,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ],
      ),
      subtitle: Text(conversation.lastMessage, overflow: TextOverflow.ellipsis),
      trailing: conversation.unreadCount > 0
          ? CountBadge(count: conversation.unreadCount)
          : null,
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.senderName,
  });

  final ChatMessage message;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.7,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: message.isOwn ? AppColors.brandPrimary : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContent(context),
          const SizedBox(height: 4),
          Text(
            message.time,
            style: TextStyle(
              color: message.isOwn ? Colors.white70 : AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isOwn
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isOwn) ...[
            AppAvatar(label: senderName, size: 30),
            const SizedBox(width: 8),
          ],
          bubble,
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textColor = message.isOwn ? Colors.white : AppColors.textPrimary;

    switch (message.type) {
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty)
              Container(
                width: 180,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.image, size: 40, color: AppColors.textTertiary),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('图片', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image, size: 20, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text('[图片]', style: TextStyle(color: textColor)),
                ],
              ),
          ],
        );
      case 'voice':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq, size: 20, color: textColor),
            const SizedBox(width: 6),
            Text('[语音消息]', style: TextStyle(color: textColor)),
          ],
        );
      case 'video':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, size: 20, color: textColor),
            const SizedBox(width: 6),
            Text('[视频]', style: TextStyle(color: textColor)),
          ],
        );
      case 'location':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 20, color: textColor),
            const SizedBox(width: 6),
            Text(message.text.isNotEmpty ? message.text : '[位置]', style: TextStyle(color: textColor)),
          ],
        );
      default:
        return Text(message.text, style: TextStyle(color: textColor));
    }
  }
}

class MediaAddButton extends StatelessWidget {
  const MediaAddButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: AppColors.textTertiary, size: 30),
      ),
    );
  }
}

class CreationTool extends StatelessWidget {
  const CreationTool({super.key, required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  const StatItem({super.key, required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: const TextStyle(color: AppColors.textTertiary)),
      ],
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            color: color,
            backgroundColor: AppColors.bgTertiary,
          ),
        ),
      ],
    );
  }
}

class VerificationBadge extends StatelessWidget {
  const VerificationBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.verified,
  });

  final IconData icon;
  final String label;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: verified
                ? AppColors.success.withValues(alpha: 0.16)
                : AppColors.bgTertiary,
            child: Icon(
              verified ? Icons.check_circle : icon,
              color: verified ? AppColors.success : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class WorksList extends StatelessWidget {
  const WorksList({super.key, required this.works});

  final List<UserWork> works;

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text('暂无作品', style: TextStyle(color: AppColors.textTertiary)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: works.map((work) => WorkTile(work: work)).toList(),
      ),
    );
  }
}

class WorkTile extends StatelessWidget {
  const WorkTile({super.key, required this.work});

  final UserWork work;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(workIcon(work.type), color: AppColors.brandPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        work.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (work.isPinned)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '置顶',
                          style: TextStyle(
                            color: AppColors.brandPrimary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  work.summary,
                  style: const TextStyle(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          if (work.duration != null)
            Text(
              '${work.duration}s',
              style: const TextStyle(color: AppColors.textTertiary),
            ),
        ],
      ),
    );
  }
}

IconData workIcon(WorkType type) {
  switch (type) {
    case WorkType.voice:
      return Icons.graphic_eq;
    case WorkType.video:
      return Icons.play_circle_outline;
    case WorkType.image:
      return Icons.photo;
  }
}

class MediaPlaceholderGrid extends StatelessWidget {
  const MediaPlaceholderGrid({super.key, required this.tab});

  final String tab;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 9,
      itemBuilder: (context, index) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          tab,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(color: AppColors.textTertiary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.brandPrimary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiClient.getDevices();
      final list = (data['devices'] as List<dynamic>?)
              ?.map((d) => d as Map<String, dynamic>)
              .toList() ??
          [];
      if (mounted) setState(() { _devices = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _revoke(String deviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('撤销设备'),
        content: const Text('确定要撤销该设备的登录状态？撤销后该设备需要重新登录。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient.revokeDevice(deviceId);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设备管理')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.textTertiary)),
                      const SizedBox(height: 12),
                      SecondaryButton(text: '重试', onPressed: _load),
                    ],
                  ),
                )
              : _devices.isEmpty
                  ? const Center(child: Text('暂无设备记录', style: TextStyle(color: AppColors.textTertiary)))
                  : RefreshIndicator(
                      color: AppColors.brandPrimary,
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _devices.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                        itemBuilder: (context, index) {
                          final d = _devices[index];
                          final isCurrent = d['isCurrent'] == true || d['is_current'] == 1;
                          final deviceName = (d['deviceName'] ?? d['device_name'] ?? d['deviceInfo'] ?? d['device_info'] ?? '未知设备').toString();
                          final lastLogin = (d['lastLoginAt'] ?? d['last_seen_at'] ?? d['createdAt'] ?? d['created_at'] ?? '').toString();
                          return ListTile(
                            leading: Icon(
                              _deviceIcon((d['deviceType'] ?? d['device_type'] ?? '').toString()),
                              color: isCurrent ? AppColors.brandPrimary : AppColors.textTertiary,
                              size: 32,
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(deviceName)),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandPrimaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('当前', style: TextStyle(color: AppColors.brandPrimary, fontSize: 11)),
                                  ),
                              ],
                            ),
                            subtitle: Text(lastLogin),
                            trailing: isCurrent
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                    onPressed: () => _revoke(d['id'].toString()),
                                  ),
                          );
                        },
                      ),
                    ),
    );
  }

  IconData _deviceIcon(String? type) {
    switch (type) {
      case 'ios':
      case 'android':
        return Icons.phone_android;
      case 'web':
        return Icons.language;
      default:
        return Icons.devices;
    }
  }
}

class BlacklistScreen extends StatefulWidget {
  const BlacklistScreen({super.key});

  @override
  State<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends State<BlacklistScreen> {
  List<Map<String, dynamic>> _blocked = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiClient.getBlacklist();
      final rawList = data['entries'] ?? data['blacklist'] ?? [];
      final list = (rawList as List<dynamic>)
              .map((b) => b as Map<String, dynamic>)
              .toList();
      if (mounted) setState(() { _blocked = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _remove(String userId) async {
    try {
      await ApiClient.removeFromBlacklist(userId);
      setState(() => _blocked.removeWhere((b) =>
          (b['targetUserId'] ?? b['target_user_id'] ?? b['id'])?.toString() == userId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('黑名单')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.textTertiary)),
                      const SizedBox(height: 12),
                      SecondaryButton(text: '重试', onPressed: _load),
                    ],
                  ),
                )
              : _blocked.isEmpty
                  ? const Center(child: Text('黑名单为空', style: TextStyle(color: AppColors.textTertiary)))
                  : RefreshIndicator(
                      color: AppColors.brandPrimary,
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _blocked.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                        itemBuilder: (context, index) {
                          final b = _blocked[index];
                          final name = (b['name'] ?? b['target_name'] ?? b['targetName'] ?? '用户').toString();
                          final userId = (b['targetUserId'] ?? b['target_user_id'] ?? b['id'] ?? '').toString();
                          return ListTile(
                            leading: AppAvatar(label: name, size: 46),
                            title: Text(name),
                            trailing: OutlinedButton(
                              onPressed: () => _remove(userId),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('移出'),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class AccountCancelScreen extends StatefulWidget {
  const AccountCancelScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<AccountCancelScreen> createState() => _AccountCancelScreenState();
}

class _AccountCancelScreenState extends State<AccountCancelScreen> {
  bool _isLoading = false;

  Future<void> _submit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('最后确认'),
        content: const Text('注销后账号将进入 7 天冷静期，冷静期内可联系客服恢复。冷静期后账号将被永久删除，所有数据不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('再想想')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认注销', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final data = await ApiClient.cancelAccount();
      if (mounted) {
        final cooldown = data['cooldownEndsAt']?.toString() ?? '';
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('注销申请已提交'),
            content: Text(cooldown.isNotEmpty
                ? '账号将在 $cooldown 后被永久注销。\n冷静期内如需恢复，请联系客服。'
                : '注销申请已提交，请等待处理。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  widget.onLogout();
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注销账号')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.warning_amber_rounded, size: 56, color: AppColors.warning),
          const SizedBox(height: 20),
          Text('注销账号', style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('请注意以下事项：', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text('• 注销后进入 7 天冷静期'),
                Text('• 冷静期内可联系客服恢复账号'),
                Text('• 冷静期后账号及所有数据将被永久删除'),
                Text('• 删除后无法恢复任何信息'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: '申请注销账号',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiClient.getUser(widget.userId);
      if (mounted) setState(() { _user = data['user'] ?? data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_user?['name']?.toString() ?? '用户详情')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.textTertiary)),
                      const SizedBox(height: 12),
                      SecondaryButton(text: '重试', onPressed: _load),
                    ],
                  ),
                )
              : _user != null
                  ? RefreshIndicator(
                      color: AppColors.brandPrimary,
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Center(child: AppAvatar(label: (_user!['name'] ?? '?').toString(), size: 88)),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              (_user!['name'] ?? '').toString(),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                          ),
                          if (_user!['city'] != null) ...[
                            const SizedBox(height: 6),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textTertiary),
                                  Text(_user!['city'].toString(), style: const TextStyle(color: AppColors.textTertiary)),
                                ],
                              ),
                            ),
                          ],
                          if (_user!['signature'] != null && _user!['signature'].toString().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                _user!['signature'].toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          if (_user!['membershipLevel'] != null)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.brandPrimaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _user!['membershipLevel'].toString(),
                                  style: const TextStyle(color: AppColors.brandPrimary, fontSize: 12),
                                ),
                              ),
                            ),
                          if (_user!['phoneStatus'] != null) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _VerificationChip(label: '手机', verified: _user!['phoneStatus'] == 'verified'),
                                _VerificationChip(label: '实名', verified: _user!['identityStatus'] == 'verified'),
                                _VerificationChip(label: '人脸', verified: _user!['faceStatus'] == 'verified'),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: PrimaryButton(text: '发消息', onPressed: () {})),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Text('用户不存在', style: TextStyle(color: AppColors.textTertiary))),
    );
  }
}

class _VerificationChip extends StatelessWidget {
  const _VerificationChip({required this.label, required this.verified});

  final String label;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: verified ? AppColors.success.withValues(alpha: 0.1) : AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(verified ? Icons.check_circle : Icons.circle_outlined, size: 16, color: verified ? AppColors.success : AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: verified ? AppColors.success : AppColors.textTertiary, fontSize: 13)),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<SquareUser> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() { _isLoading = true; _hasSearched = true; });
    try {
      final data = await ApiClient.searchUsers(q);
      final list = (data['users'] as List<dynamic>?)
              ?.map((u) => SquareUser.fromJson(u as Map<String, dynamic>))
              .toList() ??
          [];
      if (mounted) setState(() { _results = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: const InputDecoration(
            hintText: '搜索用户',
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(onPressed: _search, child: const Text('搜索')),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
          : _hasSearched && _results.isEmpty
              ? const Center(child: Text('未找到用户', style: TextStyle(color: AppColors.textTertiary)))
              : !_hasSearched
                  ? const Center(child: Text('输入关键词搜索用户', style: TextStyle(color: AppColors.textTertiary)))
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, index) {
                        final u = _results[index];
                        return ListTile(
                          leading: AppAvatar(label: u.name, size: 46),
                          title: Row(
                            children: [
                              Flexible(child: Text(u.name)),
                              if (u.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 16, color: AppColors.brandPrimary),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            u.signature.isNotEmpty ? u.signature : u.city,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(u.distance, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => UserDetailScreen(userId: u.id),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  int _step = 0;
  int _smsCountdown = 0;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 11) return;
    setState(() => _error = null);
    try {
      await ApiClient.sendSms(phone, purpose: 'password-reset');
      setState(() => _smsCountdown = 60);
      while (_smsCountdown > 0 && mounted) {
        await Future<void>.delayed(const Duration(seconds: 1));
        if (mounted) setState(() => _smsCountdown--);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _reset() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final pwd = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (phone.isEmpty || code.isEmpty || pwd.isEmpty) {
      setState(() => _error = '请填写所有字段');
      return;
    }
    if (pwd != confirm) {
      setState(() => _error = '两次密码不一致');
      return;
    }
    if (pwd.length < 6) {
      setState(() => _error = '密码至少6位');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    try {
      await ApiClient.confirmPasswordReset(
        phone: phone,
        smsCode: code,
        newPassword: pwd,
      );
      if (mounted) {
        setState(() { _isLoading = false; _step = 1; });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 1) {
      return Scaffold(
        appBar: AppBar(title: const Text('重置密码')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 56, color: AppColors.success),
                const SizedBox(height: 16),
                const Text('密码重置成功', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: '返回登录',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('找回密码')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14)),
              ),
              const SizedBox(height: 12),
            ],
            AppTextField(controller: _phoneController, hintText: '手机号', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AppTextField(controller: _codeController, hintText: '验证码', keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 112,
                  child: SecondaryButton(
                    text: _smsCountdown > 0 ? '${_smsCountdown}s' : '获取验证码',
                    onPressed: _smsCountdown > 0 ? () {} : _sendSms,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _passwordController, hintText: '新密码', obscureText: true),
            const SizedBox(height: 12),
            AppTextField(controller: _confirmController, hintText: '确认新密码', obscureText: true),
            const SizedBox(height: 24),
            PrimaryButton(text: '重置密码', isLoading: _isLoading, onPressed: _reset),
          ],
        ),
      ),
    );
  }
}

Color avatarColor(String key) {
  switch (key) {
    case 'aurora':
      return Colors.purple;
    case 'sunset':
      return Colors.orange;
    case 'ocean':
      return Colors.blue;
    case 'forest':
      return Colors.green;
    case 'flame':
      return Colors.red;
    case 'crystal':
      return Colors.cyan;
    default:
      return Colors.grey;
  }
}

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, required this.profile, required this.onProfileChanged});

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = true;
  String? _error;
  String _phoneStatus = 'pending';
  String _identityStatus = 'pending';
  String _faceStatus = 'pending';

  final _legalNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  bool _isSubmittingIdentity = false;
  bool _isSubmittingFace = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiClient.getReviewSummary();
      final summary = data['summary'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _phoneStatus = (summary['phoneStatus'] ?? 'pending').toString();
          _identityStatus = (summary['identityStatus'] ?? 'pending').toString();
          _faceStatus = (summary['faceStatus'] ?? 'pending').toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _submitIdentity() async {
    final name = _legalNameController.text.trim();
    final idNum = _idNumberController.text.trim();
    if (name.isEmpty || idNum.isEmpty) {
      setState(() => _error = '请填写真实姓名和身份证号');
      return;
    }
    setState(() { _isSubmittingIdentity = true; _error = null; });
    try {
      final data = await ApiClient.submitIdentityReview(name, idNum);
      final user = data['user'] as Map<String, dynamic>?;
      if (user != null && mounted) {
        widget.onProfileChanged(UserProfile.fromJson(user));
      }
      await _loadSummary();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _isSubmittingIdentity = false);
  }

  Future<void> _submitFace() async {
    setState(() { _isSubmittingFace = true; _error = null; });
    try {
      final data = await ApiClient.submitFaceReview();
      final user = data['user'] as Map<String, dynamic>?;
      if (user != null && mounted) {
        widget.onProfileChanged(UserProfile.fromJson(user));
      }
      await _loadSummary();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _isSubmittingFace = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('实名认证')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _statusCard('手机认证', _phoneStatus, Icons.phone_android),
                  const SizedBox(height: 16),
                  _statusCard('实名认证', _identityStatus, Icons.badge),
                  if (_identityStatus != 'verified') ...[
                    const SizedBox(height: 16),
                    AppTextField(controller: _legalNameController, hintText: '真实姓名'),
                    const SizedBox(height: 12),
                    AppTextField(controller: _idNumberController, hintText: '身份证号', keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: '提交实名认证',
                      isLoading: _isSubmittingIdentity,
                      onPressed: _submitIdentity,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _statusCard('人脸认证', _faceStatus, Icons.face),
                  if (_faceStatus != 'verified') ...[
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: '提交人脸认证',
                      isLoading: _isSubmittingFace,
                      onPressed: _submitFace,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _statusCard(String title, String status, IconData icon) {
    final verified = status == 'verified';
    final pending = status == 'pending';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: verified ? AppColors.success.withValues(alpha: 0.1) : AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: verified ? AppColors.success : AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: verified ? AppColors.success : pending ? AppColors.warning : AppColors.textTertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              verified ? '已认证' : pending ? '待认证' : '未通过',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
