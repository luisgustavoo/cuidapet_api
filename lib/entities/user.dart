class User {
  User(
      {this.id,
      this.email,
      this.password,
      this.registerType,
      this.iosToken,
      this.androidToken,
      this.refreshToken,
      this.socialKey,
      this.imageAvatar,
      this.supplierId});

  final int? id;
  final String? email;
  final String? password;
  final String? registerType;
  final String? iosToken;
  final String? androidToken;
  final String? refreshToken;
  final String? socialKey;
  final String? imageAvatar;
  final int? supplierId;

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? registerType,
    String? iosToken,
    String? androidToken,
    String? refreshToken,
    String? socialKey,
    String? imageAvatar,
    int? supplierId,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (email == null || identical(email, this.email)) &&
        (password == null || identical(password, this.password)) &&
        (registerType == null || identical(registerType, this.registerType)) &&
        (iosToken == null || identical(iosToken, this.iosToken)) &&
        (androidToken == null || identical(androidToken, this.androidToken)) &&
        (refreshToken == null || identical(refreshToken, this.refreshToken)) &&
        (socialKey == null || identical(socialKey, this.socialKey)) &&
        (imageAvatar == null || identical(imageAvatar, this.imageAvatar)) &&
        (supplierId == null || identical(supplierId, this.supplierId))) {
      return this;
    }

    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      registerType: registerType ?? this.registerType,
      iosToken: iosToken ?? this.iosToken,
      androidToken: androidToken ?? this.androidToken,
      refreshToken: refreshToken ?? this.refreshToken,
      socialKey: socialKey ?? this.socialKey,
      imageAvatar: imageAvatar ?? this.imageAvatar,
      supplierId: supplierId ?? this.supplierId,
    );
  }
}
