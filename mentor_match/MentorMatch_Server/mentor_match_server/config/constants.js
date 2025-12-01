

const USER_ROLES = Object.freeze({
  STUDENT: 'student',
  TUTOR: 'tutor',
});

const REQUEST_STATUS = Object.freeze({
  PENDING: 'pending',
  ACCEPTED: 'accepted',
  DECLINED: 'declined',
});

const SCHEDULE_STATUS = Object.freeze({
  CONFIRMED: 'confirmed',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
});

const TRANSACTION_TYPES = Object.freeze({
  DEPOSIT: 'deposit',
  WITHDRAWAL: 'withdrawal',
  PAYMENT: 'payment',
  EARNING: 'earning',
});

const SUBJECT_CATEGORIES = Object.freeze({
  PHO_THONG: 'pho_thong',
  TIEU_HOC: 'tieu_hoc',
  TIN_HOC: 'tin_hoc',
  NGOAI_NGU: 'ngoai_ngu',
  KY_NANG_MEM: 'ky_nang_mem',
});

module.exports = {
  USER_ROLES,
  REQUEST_STATUS,
  SCHEDULE_STATUS,
  TRANSACTION_TYPES,
  SUBJECT_CATEGORIES,
};