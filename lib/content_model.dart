class UnboardingContent{
  String image;
  String title;
  String description;

  UnboardingContent({required this.image, required this.title, required this.description});
}

List<UnboardingContent> contents = [
  UnboardingContent(
    image: 'assets/ob1.png', 
    title: "Welcome to KNote!", 
    description: "Get organized effortlessly!"),
  UnboardingContent(
    image: "assets/ob2.png", 
    title: "Create & Customize Tasks", 
    description: "Tailor your to-do list to fit your unique workflow."),
  UnboardingContent(
    image: "assets/ob3.png", 
    title: "Track & Achieve Goals", 
    description: " Reach your milestones with Knote!")
];