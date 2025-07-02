class Course {
  final String code;
  final String title;
  final String imageUrl;
  final String description;
  final String youtube;
  final String website;
  final String instagram;
  final String requirementJAE;
  final String requirementPFP;
  final String hook;
  final String interest;
  final String callToAction;
  bool isFav = false;

  Course({
    required this.code,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.youtube,
    required this.website,
    required this.instagram,
    required this.requirementJAE,
    required this.requirementPFP,
    required this.hook,
    required this.interest,
    required this.callToAction,
    this.isFav = false,
  });

  void toggleFav() => {isFav = !isFav};
}
