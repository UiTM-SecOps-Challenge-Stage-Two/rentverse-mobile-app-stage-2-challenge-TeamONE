import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/banner/cubit.dart';
import '../../cubit/banner/state.dart';

class CarouselCustom extends StatelessWidget {
  const CarouselCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BannerCubit(),
      child: BlocBuilder<BannerCubit, BannerState>(
        builder: (context, state) {
          final cubit = context.read<BannerCubit>();
          return Column(
            children: [
              CarouselSlider.builder(
                itemCount: state.images.length,
                itemBuilder: (context, index, realIndex) {
                  final imagePath = state.images[index];


                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                  );
                },
                options: CarouselOptions(
                  aspectRatio: 30 / 12,
                  viewportFraction: 1,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  onPageChanged: (index, reason) {
                    cubit.onPageChanged(index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
