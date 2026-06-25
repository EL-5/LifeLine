import React, { useState } from 'react';

const PATIENTS = [
  { id: 'P-001', name: 'Abena Mensah', age: 34, blood: 'O+', phone: '+233 24 456 7890', condition: 'Obstetric Emergency', status: 'In Transit', avatar: '#EC4899', allergies: ['Penicillin'], lastVisit: '2026-06-20' },
  { id: 'P-002', name: 'Kwame Asante', age: 52, blood: 'A+', phone: '+233 20 123 4567', condition: 'Cardiac Event', status: 'At Hospital', avatar: '#3B82F6', allergies: ['Aspirin', 'Ibuprofen'], lastVisit: '2026-06-19' },
  { id: 'P-003', name: 'Yaa Boateng', age: 28, blood: 'B-', phone: '+233 55 789 0123', condition: 'Respiratory Distress', status: 'Dispatched', avatar: '#8B5CF6', allergies: [], lastVisit: '2026-06-18' },
  { id: 'P-004', name: 'Kofi Darko', age: 61, blood: 'AB+', phone: '+233 26 345 6789', condition: 'Trauma', status: 'Resolved', avatar: '#10B981', allergies: ['Morphine'], lastVisit: '2026-06-17' },
  { id: 'P-005', name: 'Ama Osei', age: 19, blood: 'O-', phone: '+233 24 901 2345', condition: 'Seizure', status: 'In Transit', avatar: '#F59E0B', allergies: ['Codeine'], lastVisit: '2026-06-22' },
  { id: 'P-006', name: 'Nana Ofori', age: 45, blood: 'A-', phone: '+233 20 567 8901', condition: 'Stroke', status: 'Dispatched', avatar: '#EF4444', allergies: [], lastVisit: '2026-06-22' },
];

const statusColor = (s: string) => ({ 'In Transit': '#3B82F6', 'At Hospital': '#10B981', 'Dispatched': '#6366F1', 'Resolved': '#9CA3AF' }[s] || '#6B7280');

const PatientsView: React.FC = () => {
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState<typeof PATIENTS[0] | null>(null);

  const filtered = PATIENTS.filter(p =>
    p.name.toLowerCase().includes(search.toLowerCase()) ||
    p.id.toLowerCase().includes(search.toLowerCase()) ||
    p.condition.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div style={{ display: 'flex', gap: '16px', height: '100%' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '16px', minWidth: 0 }}>
        {/* Summary */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '12px' }}>
          {[
            { label: 'Total Patients', value: PATIENTS.length, color: '#6366F1' },
            { label: 'In Transit', value: PATIENTS.filter(p => p.status === 'In Transit').length, color: '#3B82F6' },
            { label: 'Dispatched', value: PATIENTS.filter(p => p.status === 'Dispatched').length, color: '#F59E0B' },
            { label: 'Resolved', value: PATIENTS.filter(p => p.status === 'Resolved').length, color: '#10B981' },
          ].map(s => (
            <div key={s.label} style={{ background: `${s.color}11`, border: `1px solid ${s.color}22`, borderRadius: '10px', padding: '14px 16px' }}>
              <div style={{ fontSize: '10px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', color: s.color, marginBottom: '6px' }}>{s.label}</div>
              <div style={{ fontSize: '28px', fontWeight: 800, color: s.color, fontFamily: '"JetBrains Mono", monospace' }}>{s.value}</div>
            </div>
          ))}
        </div>

        {/* Search */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', background: 'white', border: '1px solid var(--border)', borderRadius: '8px', padding: '8px 12px' }}>
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="var(--text-dim)" strokeWidth="2"><circle cx="11" cy="11" r="8" /><path d="m21 21-4.35-4.35" /></svg>
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search patients by name, ID, or condition..." style={{ border: 'none', outline: 'none', fontSize: '12px', color: 'var(--text-primary)', width: '100%', background: 'none' }} />
        </div>

        {/* Table */}
        <div className="card" style={{ flex: 1, overflow: 'auto' }}>
          <table className="em-table">
            <thead>
              <tr>
                <th>Patient</th>
                <th>Age</th>
                <th>Blood Type</th>
                <th>Condition</th>
                <th>Status</th>
                <th>Phone</th>
                <th>Last Visit</th>
                <th>Allergies</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(p => (
                <tr key={p.id} onClick={() => setSelected(selected?.id === p.id ? null : p)} style={{ background: selected?.id === p.id ? 'rgba(99,102,241,0.06)' : undefined }}>
                  <td>
                    <div className="patient-cell">
                      <div className="patient-avatar" style={{ background: p.avatar }}>{p.name.split(' ').map(n => n[0]).join('')}</div>
                      <div>
                        <div className="patient-name">{p.name}</div>
                        <div className="patient-meta">{p.id}</div>
                      </div>
                    </div>
                  </td>
                  <td style={{ fontSize: '12px', fontFamily: '"JetBrains Mono", monospace' }}>{p.age}</td>
                  <td><span style={{ fontFamily: '"JetBrains Mono", monospace', fontSize: '12px', fontWeight: 700, color: '#EF4444', background: 'rgba(239,68,68,0.08)', padding: '2px 8px', borderRadius: '5px', border: '1px solid rgba(239,68,68,0.15)' }}>{p.blood}</span></td>
                  <td><span className={`category-pill ${p.condition.toLowerCase().includes('cardiac') ? 'cardiac' : p.condition.toLowerCase().includes('obstet') ? 'obstetric' : p.condition.toLowerCase().includes('respir') ? 'respiratory' : p.condition.toLowerCase().includes('trauma') ? 'trauma' : 'general'}`}>{p.condition}</span></td>
                  <td><span style={{ fontSize: '11px', fontWeight: 600, color: statusColor(p.status) }}>{p.status}</span></td>
                  <td style={{ fontSize: '11px', color: 'var(--text-secondary)', fontFamily: '"JetBrains Mono", monospace' }}>{p.phone}</td>
                  <td style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{p.lastVisit}</td>
                  <td>
                    {p.allergies.length === 0
                      ? <span style={{ fontSize: '10px', color: 'var(--text-dim)' }}>None</span>
                      : p.allergies.map((a, i) => <span key={i} style={{ fontSize: '9px', background: 'rgba(239,68,68,0.08)', color: '#EF4444', border: '1px solid rgba(239,68,68,0.2)', padding: '1px 6px', borderRadius: '4px', marginRight: '3px' }}>{a}</span>)
                    }
                  </td>
                  <td>
                    <div className="row-actions">
                      <button className="row-btn" onClick={e => { e.stopPropagation(); setSelected(p); }}>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Detail */}
      {selected && (
        <div className="card" style={{ width: '280px', flexShrink: 0, height: 'fit-content' }}>
          <div className="card-header">
            <div className="card-title">Patient Profile</div>
            <button onClick={() => setSelected(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-secondary)', fontSize: '16px' }}>✕</button>
          </div>
          <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <div style={{ width: '52px', height: '52px', borderRadius: '50%', background: selected.avatar, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '16px', fontWeight: 700, color: 'white' }}>{selected.name.split(' ').map(n => n[0]).join('')}</div>
              <div>
                <div style={{ fontWeight: 700, fontSize: '15px' }}>{selected.name}</div>
                <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{selected.id} · Age {selected.age}</div>
              </div>
            </div>
            {[
              { label: 'Blood Type', value: selected.blood, color: '#EF4444' },
              { label: 'Phone', value: selected.phone, color: 'var(--text-primary)' },
              { label: 'Condition', value: selected.condition, color: 'var(--text-primary)' },
              { label: 'Status', value: selected.status, color: statusColor(selected.status) },
              { label: 'Last Visit', value: selected.lastVisit, color: 'var(--text-secondary)' },
            ].map(f => (
              <div key={f.label}>
                <div style={{ fontSize: '10px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', color: 'var(--text-dim)', marginBottom: '3px' }}>{f.label}</div>
                <div style={{ fontSize: '13px', fontWeight: 600, color: f.color }}>{f.value}</div>
              </div>
            ))}
            <div>
              <div style={{ fontSize: '10px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', color: 'var(--text-dim)', marginBottom: '6px' }}>Allergies</div>
              {selected.allergies.length === 0
                ? <span style={{ fontSize: '12px', color: 'var(--text-dim)' }}>No known allergies</span>
                : <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>{selected.allergies.map((a, i) => <span key={i} style={{ fontSize: '10px', background: 'rgba(239,68,68,0.08)', color: '#EF4444', border: '1px solid rgba(239,68,68,0.2)', padding: '2px 8px', borderRadius: '5px' }}>{a}</span>)}</div>
              }
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default PatientsView;
