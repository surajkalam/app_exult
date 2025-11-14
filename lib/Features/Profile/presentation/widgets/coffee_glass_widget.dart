import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoffeeGlassWidget extends ConsumerWidget {
  final int filledLayers;
  final double height;
  final double width;
  final VoidCallback? onFreeCoffeeEarned;

  const CoffeeGlassWidget({
    super.key,
    required this.filledLayers,
    required this.height,
    required this.width,
    this.onFreeCoffeeEarned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            offset: Offset(4, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.local_cafe, color: Colors.brown[600], size: 24),
              SizedBox(width: 8),
              Text(
                'Coffee Loyalty',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primaryContainer,
                ),
              ),
              Spacer(),
              Text(
                '$filledLayers/3',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCoffeeGlass(colorScheme),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filledLayers == 3 
                        ? '🎉 Free Coffee Ready!'
                        : 'Order ${3 - filledLayers} more for free coffee',
                      style: textTheme.bodyMedium?.copyWith(
                        color: filledLayers == 3 
                          ? Colors.green[700]
                          : colorScheme.primaryContainer,
                        fontWeight: filledLayers == 3 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      ),
                    ),
                    if (filledLayers == 3) ...[
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: onFreeCoffeeEarned,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Claim Free Coffee'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoffeeGlass(ColorScheme colorScheme) {
    return SizedBox(
      width: 60,
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Glass outline
          Container(
            width: 60,
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown[400]!, width: 3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ),
          // Coffee layers
          ...List.generate(3, (index) => _buildCoffeeLayer(index, colorScheme)),
          // Glass handle
          Positioned(
            right: -8,
            top: 20,
            child: Container(
              width: 16,
              height: 25,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown[400]!, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoffeeLayer(int layerIndex, ColorScheme colorScheme) {
    final isLayerFilled = filledLayers > layerIndex;
    final layerHeight = 25.0;
    final bottomPosition = layerIndex * layerHeight + 5.0;

    return Positioned(
      bottom: bottomPosition,
      left: 3,
      right: 3,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        height: layerHeight,
        decoration: BoxDecoration(
          color: isLayerFilled 
            ? Colors.brown[600 - (layerIndex * 100)]
            : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}