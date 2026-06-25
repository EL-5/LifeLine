import React, { useState } from 'react';

const STAFF = [
  { id: 'S-001', name: 'Dr. Kweku Mensah', role: 'Emergency Physician', dept: 'A&E', status: 'On Duty', shift: '08:00–20:00', cases: 8, avatar: '#6366F1' },
  { id: 'S-002', name: 'Nurse Abena Oti', role: 'Senior Nurse', dept: 'Triage', status: 'On Duty', shift: '08:00–20:00', cases: 15, avatar: '#EC4899' },
  { id: 'S-003', name: 'Dr. Yaw Darkwa', role: 'Surgeon', dept: 'Theatre', status: 'In Surgery', shift: '07:00–19:00', cases: 3, avatar: '#EF4444' },
  { id: 'S-004', name: 'Paramedic Kofi Asare', role: 'Paramedic', dept: 'Field', status: 'En Route', shift: '06:00–18:00', cases: 5, avatar: '#10B981' },
  { id: 'S-005', name: 'Dr. Ama Boateng', role: 'Gynaecologist', dept: 'Obs & Gynae', status: 'On Call', shift: '20:00–08:00', cases: 2, avatar: '#F59E0B' },
  { id: 'S-006', name: 'Nurse Kwame Ofori', role: 'ICU Nurse', dept: 'ICU', status: 'On Duty', shift: '08:00–20:00', cases: 4, avatar: '#8B5CF6' },
  { id: 'S-007', name: 'Dr. Nana Acheampong', role: 'Cardiologist', dept: 'Cardiology', status: 'Off Duty', shift: '08:00–20:00', cases: 0, avatar: '#3B82F6' },
];

const statusColor = (s: string) => ({ 'On Duty': '#10B981', 'In Surgery': '#EF4444', 'En Route': '#3B82F6', 'On Call': '#F59E0B', 'Off Duty': '#9CA3AF' }[s] || '#6B7280');

const StaffView: React.FC = () => {
  const [search, setSearch] = useState('');
  const filtered = STAFF.filter(s => s.name.toLowerCase().includes(search.toLowerCase()) || s.role.toLowerCase().includes(search.toLowerCase()) || s.dept.toLowerCase().includes(search.toLowerCase()));

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '12px' }}>
        {[
          { label: 'Total Staff', value: STAFF.length, color: '#6366F1' },
          { label: 'On Duty', value: STAFF.filter(s => ['On Duty', 'In Surgery', 'En Route'].includes(s.status)).length, color: '#10B981' },
          { label: 'On Call', value: STAFF.filter(s => s.status === 'On Call').length, color: '#F59E0B' },
          { label: 'Off Duty', value: STAFF.filter(s => s.status === 'Off Duty').length, color: '#9CA3AF' },
        ].map(s => (
          <div key={s.label} style={{ background: `${s.color}11`, border: `1px solid ${s.color}22`, borderRadius: '10px', padding: '14px 16px' }}>
            <div style={{ fontSize: '10px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', color: s.color, marginBottom: '6px' }}>{s.label}</div>
            <div style={{ fontSize: '28px', fontWeight: 800, color: s.color, fontFamily: '"JetBrains Mono", monospace' }}>{s.value}</div>
          </div>
        ))}
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', background: 'white', border: '1px solid var(--border)', borderRadius: '8px', padding: '8px 12px' }}>
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="var(--text-dim)" strokeWidth="2"><circle cx="11" cy="11" r="8" /><path d="m21 21-4.35-4.35" /></svg>
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search staff by name, role, or department..." style={{ border: 'none', outline: 'none', fontSize: '12px', color: 'var(--text-primary)', width: '100%', background: 'none' }} />
      </div>

      <div className="card">
        <table className="em-table">
          <thead>
            <tr>
              <th>Staff Member</th>
              <th>Role</th>
              <th>Department</th>
              <th>Status</th>
              <th>Shift</th>
              <th>Cases Today</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {filtered.map(s => (
              <tr key={s.id}>
                <td>
                  <div className="patient-cell">
                    <div className="patient-avatar" style={{ background: s.avatar }}>{s.name.split(' ').slice(-1)[0][0]}{s.name.split(' ')[0][0]}</div>
                    <div>
                      <div className="patient-name">{s.name}</div>
                      <div className="patient-meta">{s.id}</div>
                    </div>
                  </div>
                </td>
                <td style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>{s.role}</td>
                <td><span style={{ fontSize: '11px', fontWeight: 600, background: 'rgba(99,102,241,0.08)', color: '#6366F1', padding: '2px 8px', borderRadius: '5px', border: '1px solid rgba(99,102,241,0.15)' }}>{s.dept}</span></td>
                <td><span style={{ fontSize: '11px', fontWeight: 600, color: statusColor(s.status) }}>● {s.status}</span></td>
                <td style={{ fontFamily: '"JetBrains Mono", monospace', fontSize: '11px', color: 'var(--text-secondary)' }}>{s.shift}</td>
                <td style={{ fontFamily: '"JetBrains Mono", monospace', fontSize: '14px', fontWeight: 700, color: s.cases > 0 ? 'var(--text-primary)' : 'var(--text-dim)' }}>{s.cases}</td>
                <td>
                  <div className="row-actions">
                    <button className="row-btn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.07 9.81a19.79 19.79 0 01-3.07-8.72A2 2 0 012 .9h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L6.09 8.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z" /></svg></button>
                    <button className="row-btn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" /><polyline points="22,6 12,13 2,6" /></svg></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default StaffView;
