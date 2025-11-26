class Subject {
  final String id;
  final String name;
  final List<String> grades;
  final Map<String, List<String>> topics;

  const Subject({
    required this.id,
    required this.name,
    required this.grades,
    required this.topics,
  });
}

const List<Subject> LEARNIST_SYLLABUS = [
  Subject(
    id: 'math',
    name: 'Mathematics',
    grades: ['G9', 'G10', 'G11', 'G12'],
    topics: {
      'G9': [
        'Algebra I',
        'Geometry Basics',
        'Linear Equations',
        'Inequalities',
      ],
      'G10': ['Geometry', 'Quadratic Functions', 'Probability', 'Circles'],
      'G11': ['Algebra II', 'Trigonometry', 'Exponents & Logs', 'Polynomials'],
      'G12': ['Pre-Calculus', 'Calculus AB', 'Statistics', 'Vectors'],
    },
  ),
  Subject(
    id: 'physics',
    name: 'Physics',
    grades: ['G9', 'G10', 'G11', 'G12'],
    topics: {
      'G9': ['Motion & Forces', 'Energy'],
      'G10': ['Heat & Thermo', 'Electricity'],
      'G11': ['Waves & Optics', 'Magnetism', 'Modern Physics'],
      'G12': ['Mechanics', 'Electromagnetism', 'Quantum Physics'],
    },
  ),
  Subject(
    id: 'chemistry',
    name: 'Chemistry',
    grades: ['G10', 'G11', 'G12'],
    topics: {
      'G10': ['Atomic Structure', 'Periodic Table', 'Chemical Bonding'],
      'G11': ['Stoichiometry', 'Thermochemistry', 'Solutions'],
      'G12': ['Organic Chemistry', 'Electrochemistry', 'Kinetics'],
    },
  ),
  Subject(
    id: 'olympiad',
    name: 'Olympiad (AMC/AIME)',
    grades: ['All'],
    topics: {
      'All': [
        'Number Theory',
        'Combinatorics',
        'Advanced Geometry',
        'Functional Equations',
        'Inequalities',
      ],
    },
  ),
];
