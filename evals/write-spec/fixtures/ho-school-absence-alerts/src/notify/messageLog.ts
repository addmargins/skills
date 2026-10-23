import { db } from '../db';

// Log of messages sent through a messaging provider (BP 1112, section 6).
export interface MessageLogEntry {
  id: string;
  channel: 'VOICE' | 'SMS' | 'EMAIL';
  sender: 'EVENING_CALL' | 'EMERGENCY_NOTIFY' | 'SCHOOL_NEWS';
  studentId?: string;         // set for a message about one student
  recipientName: string;
  recipientAddress: string;   // phone number or email address
  body: string;               // for a voice call, the script of the recording
  sentAt: string;             // UTC
  status: 'QUEUED' | 'SENT' | 'DELIVERED' | 'UNDELIVERED' | 'NO_ANSWER' | 'FAILED';
  providerId?: string;
}

// Only Communications staff can open the message log.
export const MESSAGE_LOG_VIEW_ROLES = ['COMMUNICATIONS_ADMIN'] as const;

export const messageLog = {
  add(entry: Omit<MessageLogEntry, 'id'>): MessageLogEntry {
    return db.messageLog.insert(entry);
  },
  updateStatus(providerId: string, status: MessageLogEntry['status']): void {
    db.messageLog.update({ providerId }, { status });
  },
};

// Daily at 03:00 district time: delete entries sent more than 90 days ago (BP 1112, 6.1).
export function purgeMessageLog(now: Date): number {
  const cutoff = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
  return db.messageLog.deleteWhere({ sentAt: { lt: cutoff.toISOString() } });
}
