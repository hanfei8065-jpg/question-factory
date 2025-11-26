import '../models/world.dart';

class WorldGenerator {
  static List<World> generateWorlds() {
    return [
      // 数学世界
      World(
        id: 'world_math_1',
        title: '代数世界',
        subject: 'math',
        grade: 7,
        description: '在这里，你将掌握方程的奥秘，学会用代数解决实际问题',
        order: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb',
        unlockRequirement: {'level': 0, 'stars': 0},
      ),
      World(
        id: 'world_math_2',
        title: '几何王国',
        subject: 'math',
        grade: 7,
        description: '探索平面和空间的奥秘，发现几何之美',
        order: 2,
        imageUrl:
            'https://images.unsplash.com/photo-1509228468518-180dd4864904',
        unlockRequirement: {'level': 5, 'stars': 10},
      ),
      World(
        id: 'world_math_3',
        title: '函数大陆',
        subject: 'math',
        grade: 8,
        description: '理解函数关系，掌握变化规律',
        order: 3,
        imageUrl:
            'https://images.unsplash.com/photo-1453733190371-0a9bedd82893',
        unlockRequirement: {'level': 10, 'stars': 25},
      ),

      // 物理世界
      World(
        id: 'world_physics_1',
        title: '力学之城',
        subject: 'physics',
        grade: 8,
        description: '探索运动和力的规律，理解物理世界的基本法则',
        order: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa',
        unlockRequirement: {'level': 15, 'stars': 35},
      ),
      World(
        id: 'world_physics_2',
        title: '电磁领域',
        subject: 'physics',
        grade: 9,
        description: '揭开电与磁的神秘面纱',
        order: 2,
        imageUrl: 'assets/images/worlds/electricity.png',
        unlockRequirement: {'level': 20, 'stars': 45},
      ),

      // 化学世界
      World(
        id: 'world_chemistry_1',
        title: '元素王国',
        subject: 'chemistry',
        grade: 9,
        description: '认识化学元素，了解物质的基本组成',
        order: 1,
        imageUrl: 'assets/images/worlds/elements.png',
        unlockRequirement: {'level': 25, 'stars': 55},
      ),
      World(
        id: 'world_chemistry_2',
        title: '反应之谷',
        subject: 'chemistry',
        grade: 9,
        description: '探索化学变化的奥秘',
        order: 2,
        imageUrl: 'assets/images/worlds/reaction.png',
        unlockRequirement: {'level': 30, 'stars': 65},
      ),
    ];
  }
}
