export const LEARNIST_SYLLABUS = {
  subjects: [
    {
      id: 'math',
      name: 'Mathematics',
      grades: ['G9', 'G10', 'G11', 'G12'],
      topics: {
        'G9': ['Algebra I', 'Geometry Basics', 'Linear Equations', 'Inequalities'],
        'G10': ['Geometry', 'Quadratic Functions', 'Probability', 'Circles'],
        'G11': ['Algebra II', 'Trigonometry', 'Exponents & Logs', 'Polynomials'],
        'G12': ['Pre-Calculus', 'Calculus AB', 'Statistics', 'Vectors'],
      },
    },
    {
      id: 'physics',
      name: 'Physics',
      grades: ['G9', 'G10', 'G11', 'G12'],
      topics: {
        'G9': ['Motion & Forces', 'Energy'],
        'G10': ['Heat & Thermo', 'Electricity'],
        'G11': ['Waves & Optics', 'Magnetism', 'Modern Physics'],
        'G12': ['Mechanics', 'Electromagnetism', 'Quantum Physics'],
      },
    },
    {
      id: 'chemistry',
      name: 'Chemistry',
      grades: ['G10', 'G11', 'G12'],
      topics: {
        'G10': ['Atomic Structure', 'Periodic Table', 'Chemical Bonding'],
        'G11': ['Stoichiometry', 'Thermochemistry', 'Solutions'],
        'G12': ['Organic Chemistry', 'Electrochemistry', 'Kinetics'],
      },
    },
    {
      id: 'olympiad',
      name: 'Olympiad (AMC/AIME)',
      grades: ['All'],
      topics: {
        'All': ['Number Theory', 'Combinatorics', 'Advanced Geometry', 'Functional Equations', 'Inequalities'],
      },
    },
  ],
};
