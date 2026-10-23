// Schools and how each one takes attendance.
// Times are local to the school. The two Westbrook schools sit west of the county line and
// keep Central Time; the rest of the district, and Ledger's scheduled jobs, run on Eastern Time.

export type TimeZone = 'America/New_York' | 'America/Chicago';

export type AttendanceMode =
  | 'PERIOD'   // grades 6-12: one roll for each class period
  | 'SESSION'; // grades K-5: one roll for the morning session, one for the afternoon session

export interface School {
  id: string;
  name: string;
  grades: [number, number];  // 0 = kindergarten
  timeZone: TimeZone;
  attendanceMode: AttendanceMode;
  firstBell: string;         // 'HH:MM', local
  rollsPerDay: number;       // 7 class periods, or 2 sessions
  pmSessionStart?: string;   // SESSION schools only, 'HH:MM' local
  mainPhone: string;         // loaded from config/schools.json
  attendanceLine: string;
  attendanceEmail: string;
}

const ET: TimeZone = 'America/New_York';
const CT: TimeZone = 'America/Chicago';

function school(id: string, name: string, grades: [number, number], timeZone: TimeZone, firstBell: string): School {
  const elementary = grades[1] <= 5;
  return {
    id,
    name,
    grades,
    timeZone,
    firstBell,
    attendanceMode: elementary ? 'SESSION' : 'PERIOD',
    rollsPerDay: elementary ? 2 : 7,
    pmSessionStart: elementary ? '12:20' : undefined,
    ...contactsFor(id),
  };
}

export const SCHOOLS: School[] = [
  school('mvhs', 'Merrow Valley High School',    [9, 12], ET, '07:25'),
  school('nghs', 'Northgate High School',        [9, 12], ET, '07:25'),
  school('mvms', 'Merrow Valley Middle School',  [6, 8],  ET, '08:10'),
  school('rsms', 'Riverside Middle School',      [6, 8],  ET, '08:10'),
  school('wbms', 'Westbrook Middle School',      [6, 8],  CT, '08:10'),
  school('ales', 'Alder Elementary School',      [0, 5],  ET, '08:50'),
  school('bwes', 'Birchwood Elementary School',  [0, 5],  ET, '08:50'),
  school('ches', 'Cedar Hill Elementary School', [0, 5],  ET, '08:50'),
  school('dmes', 'Dunmore Elementary School',    [0, 5],  ET, '08:50'),
  school('eses', 'Elm Street Elementary School', [0, 5],  ET, '08:50'),
  school('fles', 'Fairlawn Elementary School',   [0, 5],  ET, '08:50'),
  school('gves', 'Glenview Elementary School',   [0, 5],  ET, '08:50'),
  school('hoes', 'Hollis Elementary School',     [0, 5],  ET, '08:50'),
  school('wbes', 'Westbrook Elementary School',  [0, 5],  CT, '08:50'),
];
