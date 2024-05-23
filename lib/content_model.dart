class UnboardingContent{
  String image;
  String title;
  String description;

  UnboardingContent({required this.image, required this.title, required this.description});
}

List<UnboardingContent> contents = [
  UnboardingContent(
    image: 'assets/ob1.png', 
    title: "Select from our Menu", 
    description: "Pick your food from our menu\n        Satisfy your cravings"),
  UnboardingContent(
    image: "assets/ob2.png", 
    title: "Easy Payment", 
    description: "  You can pay cash on delivery\nCard payment is also available"),
  UnboardingContent(
    image: "assets/ob3.png", 
    title: "Quick Delivery", 
    description: "Deliver your food at your Doorsteps")
];