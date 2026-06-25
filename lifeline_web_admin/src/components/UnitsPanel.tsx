import React from 'react';

const UNITS = [
  { id: 'UNIT-01', driver: 'Kwame Asante', patient: 'P-8821', status: 'En Route', eta: '8m', statusColor: '#10B981', iconBg: 'rgba(16,185,129,0.1)' },
  { id: 'UNIT-03', driver: 'Abena Mensah', patient: 'P-8822', status: 'Critical ETA', eta: '14m', statusColor: '#EF4444', iconBg: 'rgba(239,68,68,0.1)' },
  { id: 'UNIT-04', driver: 'Kofi Boateng', patient: '—', status: 'Standby', eta: '—', statusColor: '#6B7280', iconBg: 'rgba(107,114,128,0.1)' },
];

const UnitsPanel: React.FC = () => {
  return (
    <div className="unit-list">
      {UNITS.map(u => (
        <div className="unit-item" key={u.id}>
          <div className="unit-icon" style={{ background: u.iconBg }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={u.statusColor} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="1" y="3" width="15" height="13" rx="1" />
              <polygon points="16 8 20 8 23 11 23 16 16 16 16 8" />
              <circle cx="5.5" cy="18.5" r="2.5" />
              <circle cx="18.5" cy="18.5" r="2.5" />
            </svg>
          </div>
          <div className="unit-info">
            <div className="unit-name">{u.id} — {u.driver}</div>
            <div className="unit-detail" style={{ color: u.statusColor, fontWeight: 600 }}>{u.status} · Patient {u.patient}</div>
          </div>
          <div className="unit-eta">{u.eta}</div>
        </div>
      ))}
    </div>
  );
};

export default UnitsPanel;
