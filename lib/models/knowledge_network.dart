class KnowledgeNetwork {
  final Map<String, List<String>> adjacencyList;
  final Map<String, KnowledgePoint> points;
  final Map<String, double> nodeWeights;

  KnowledgeNetwork({
    required this.adjacencyList,
    required this.points,
    required this.nodeWeights,
  });

  // 获取知识点的所有前置知识
  List<String> getPrerequisites(String pointId) {
    List<String> prerequisites = [];
    Set<String> visited = {};

    void dfs(String current) {
      if (visited.contains(current)) return;
      visited.add(current);

      if (adjacencyList.containsKey(current)) {
        for (String neighbor in adjacencyList[current]!) {
          prerequisites.add(neighbor);
          dfs(neighbor);
        }
      }
    }

    dfs(pointId);
    return prerequisites;
  }

  // 获取知识点的所有后续知识
  List<String> getDependents(String pointId) {
    List<String> dependents = [];
    Set<String> visited = {};

    void dfs(String current) {
      if (visited.contains(current)) return;
      visited.add(current);

      for (var entry in adjacencyList.entries) {
        if (entry.value.contains(current) && !visited.contains(entry.key)) {
          dependents.add(entry.key);
          dfs(entry.key);
        }
      }
    }

    dfs(pointId);
    return dependents;
  }

  // 计算知识点的重要度
  double calculateImportance(String pointId) {
    double inDegree = 0;
    double outDegree = 0;

    // 计算入度
    adjacencyList.forEach((key, values) {
      if (values.contains(pointId)) inDegree++;
    });

    // 计算出度
    outDegree = adjacencyList[pointId]?.length.toDouble() ?? 0;

    // 重要度 = 入度 * 0.6 + 出度 * 0.4
    return inDegree * 0.6 + outDegree * 0.4;
  }

  // 获取推荐的学习路径
  List<String> getLearningPath(String startPoint, String endPoint) {
    // 使用Dijkstra算法找到最短路径
    Map<String, double> distances = {};
    Map<String, String> previous = {};
    Set<String> unvisited = {};

    // 初始化
    points.keys.forEach((pointId) {
      distances[pointId] = double.infinity;
      unvisited.add(pointId);
    });
    distances[startPoint] = 0;

    while (unvisited.isNotEmpty) {
      // 获取距离最小的节点
      String? current = null;
      double minDistance = double.infinity;

      for (var pointId in unvisited) {
        if (distances[pointId]! < minDistance) {
          current = pointId;
          minDistance = distances[pointId]!;
        }
      }

      if (current == null || current == endPoint) break;

      unvisited.remove(current);

      // 更新邻居节点的距离
      for (var neighbor in adjacencyList[current] ?? []) {
        if (!unvisited.contains(neighbor)) continue;

        double weight = nodeWeights[neighbor] ?? 1.0;
        double newDistance = distances[current]! + weight;

        if (newDistance < distances[neighbor]!) {
          distances[neighbor] = newDistance;
          previous[neighbor] = current;
        }
      }
    }

    // 构建路径
    List<String> path = [];
    String? current = endPoint;

    while (current != null) {
      path.insert(0, current);
      current = previous[current];
    }

    return path;
  }

  // 计算知识点的掌握度影响因子
  Map<String, double> calculateMasteryImpact() {
    Map<String, double> impact = {};

    for (var pointId in points.keys) {
      var prerequisites = getPrerequisites(pointId);
      var dependents = getDependents(pointId);

      // 影响因子 = (前置知识数 * 0.4 + 后续知识数 * 0.6) / 总知识点数
      double factor =
          (prerequisites.length * 0.4 + dependents.length * 0.6) /
          points.length;
      impact[pointId] = factor;
    }

    return impact;
  }
}
