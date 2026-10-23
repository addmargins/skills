// Nightly import of people from the HR system (CSV over SFTP, 02:00 Europe/London).
//
// We import: person_id, employment_type, legal_entity, work_email, manager_id,
// cost_centre, payroll_currency, status.
//
// The feed also carries leaving_date and notice_given_on. We don't import them;
// nothing has needed them so far. It also carries personal_email and
// home_address, which we must not import (LEG-07 5.2).
//
// status becomes 'LEFT' on the day after a person's last working day, so
// Person.active is false from then on. Someone serving notice is still 'ACTIVE'.
//
// Contractors come through with employment_type 'CONTRACTOR' and an empty
// payroll_currency. They can submit claims like anyone else.

import { Person } from '../model';

interface HrRow {
  person_id: string;
  employment_type: 'EMPLOYEE' | 'CONTRACTOR';
  legal_entity: 'FERNHILL_LTD' | 'FERNHILL_GMBH';
  work_email: string;
  manager_id: string;
  cost_centre: string;
  payroll_currency: 'GBP' | 'EUR' | '';
  status: 'ACTIVE' | 'LEFT';
}

export function toPerson(row: HrRow): Person {
  return {
    id: row.person_id,
    kind: row.employment_type,
    entity: row.legal_entity === 'FERNHILL_LTD' ? 'UK' : 'DE',
    workEmail: row.work_email,
    managerId: row.manager_id || null,
    costCentre: row.cost_centre,
    payrollCurrency: row.payroll_currency === '' ? null : row.payroll_currency,
    active: row.status === 'ACTIVE',
  };
}
