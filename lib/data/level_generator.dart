import '../models/level.dart';

class LevelGenerator {
  static List<Level> generateLevels() {
    return [
      // 代数世界关卡
      Level(
        id: 'level_math_1_1',
        title: '方程入门',
        questionIds: ['math_eq_001', 'math_eq_002'],
        unlockRule: 'start',
        reward: {
          'goldCoin': 100,
          'exp': 50,
          'items': ['初级方程解题徽章'],
        },
        worldId: 'world_math_1',
        order: 1,
      ),
      Level(
        id: 'level_math_1_2',
        title: '一次方程',
        questionIds: ['math_eq_003', 'math_eq_004', 'math_eq_005'],
        unlockRule: 'complete_level_math_1_1',
        reward: {
          'goldCoin': 150,
          'exp': 75,
          'items': ['一次方程专家徽章'],
        },
        worldId: 'world_math_1',
        order: 2,
      ),

      // 几何王国关卡
      Level(
        id: 'level_math_2_1',
        title: '三角形的奥秘',
        questionIds: ['math_geo_001', 'math_geo_002'],
        unlockRule: 'complete_world_math_1',
        reward: {
          'goldCoin': 200,
          'exp': 100,
          'items': ['几何探索者徽章'],
        },
        worldId: 'world_math_2',
        order: 1,
      ),

      // 物理世界关卡
      Level(
        id: 'level_physics_1_1',
        title: '力与运动',
        questionIds: ['phys_force_001', 'phys_force_002'],
        unlockRule: 'complete_world_math_2',
        reward: {
          'goldCoin': 200,
          'exp': 100,
          'items': ['力学入门徽章'],
        },
        worldId: 'world_physics_1',
        order: 1,
      ),

      // 化学世界关卡
      Level(
        id: 'level_chemistry_1_1',
        title: '认识元素',
        questionIds: ['chem_elem_001', 'chem_elem_002'],
        unlockRule: 'complete_world_physics_1',
        reward: {
          'goldCoin': 200,
          'exp': 100,
          'items': ['元素收集者徽章'],
        },
        worldId: 'world_chemistry_1',
        order: 1,
      ),
    ];
  }
}
