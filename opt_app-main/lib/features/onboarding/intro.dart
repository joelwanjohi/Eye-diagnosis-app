// import 'package:opt_app/library/opt_app.dart';

// class IntroPage extends StatelessWidget {
//   const IntroPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const HomePage(),
//             ),
//           );
//         },
//         backgroundColor: AppColors.primary,
//         child: const Icon(Icons.arrow_forward, color: Colors.white),
//       ),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
//         color: AppColors.white,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Center(
//                 child: Hero(
//                   tag: 'intro_animation',
//                   child: Lottie.asset(
//                     AppLottie.logo,
//                     width: MediaQuery.of(context).size.width * 0.8,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 12,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               child: Text(
//                 "Welcome to EyeCheck \nEye Diagnosis with AI😊",
//                 style: AppTypography().xxlMedium,
//               ),
//             ),
//             const SizedBox(
//               height: 12,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
