import 'package:flutter/material.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:flutter_application/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LineAwesomeIcons.angle_left_solid),
        ),
        title: Text(
          "Edit Profile",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(TSizes.tDefaultSize),
            child: Column(
              children: [
                // -- IMAGE with ICON
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const Image(image: AssetImage(TImages.user)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: TColors.tPrimaryColor,
                        ),
                        child: const Icon(
                          LineAwesomeIcons.camera_solid,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // -- Form Fields
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text(TTexts.tFullName),
                          prefixIcon: Icon(LineAwesomeIcons.user),
                        ),
                      ),
                      const SizedBox(height: TSizes.tFormHeight - 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text(TTexts.tEmail),
                          prefixIcon: Icon(LineAwesomeIcons.envelope_solid),
                        ),
                      ),
                      const SizedBox(height: TSizes.tFormHeight - 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text(TTexts.tPhoneNo),
                          prefixIcon: Icon(LineAwesomeIcons.phone_alt_solid),
                        ),
                      ),
                      const SizedBox(height: TSizes.tFormHeight - 20),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          label: const Text(TTexts.tPassword),
                          prefixIcon: const Icon(Icons.fingerprint),
                          suffixIcon: IconButton(
                            icon: const Icon(LineAwesomeIcons.eye_slash),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      const SizedBox(height: TSizes.tFormHeight),

                      // -- Form Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Implement the update profile logic here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.tPrimaryColor,
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            "Edit Profile",
                            style: TextStyle(color: TColors.tDarkColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: TSizes.tFormHeight),

                      // -- Created Date and Delete Button
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: "Joined",
                              style: TextStyle(fontSize: 12),
                              children: [
                                TextSpan(
                                  text: "Joined At",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
