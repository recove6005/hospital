class SubscribeModel {
  final int blog;
  final int discount;
  final int draft;
  final int homepage;
  final int logo;
  final int signage;
  final String email;
  final String uid;
  final String type;
  final int instagram;
  final int naverplace;
  final int banner;
  final int video;

  SubscribeModel({
    required this.blog,
    required this.discount,
    required this.draft,
    required this.homepage,
    required this.logo,
    required this.signage,
    required this.email,
    required this.uid,
    required this.type,
    required this.instagram,
    required this.naverplace,
    required this.banner,
    required this.video,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'blog': blog,
      'discount': discount,
      'draft': draft,
      'homepage': homepage,
      'logo': logo,
      'signage': signage,
      'email': email,
      'uid': uid,
      'type': type,
      'instagram': instagram,
      'naverplace': naverplace,
      'banner': banner,
      'video': video,
    };
  }

  factory SubscribeModel.fromFirestore(Map<String, dynamic> data) {
    return SubscribeModel(
        blog: data['blog'],
        discount: data['discount'],
        draft: data['draft'],
        homepage: data['homepage'],
        logo: data['logo'],
        signage: data['signage'],
        email: data['email'],
        uid: data['uid'],
        type: data['type'],
        instagram: data['instagram'],
        naverplace: data['naverplace'],
        banner: data['banner'],
        video: data['video'],
    );
  }
}