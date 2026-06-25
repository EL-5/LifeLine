import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

interface Emergency {
  id: string;
  category: string;
  severity: string;
  status: string;
  patient_id: string;
  driver_id: string | null;
  target_amount: number;
  raised_amount: number;
  symptoms: string[];
  created_at: string;
}

const AVATARS = ['#EF4444', '#3B82F6', '#8B5CF6', '#10B981', '#F59E0B', '#EC4899'];
const ALL_STATUSES = ['All', 'pending', 'dispatched', 'in_progress', 'completed', 'cancelled'];
const ALL_SEVERITIES = ['All', 'critical', 'high', 'medium', 'low'];

const categoryClass = (cat: string) => {
  if (cat.includes('CARDIAC') || cat.includes('HEART')) return 'cardiac';
  if (cat.includes('TRAUMA') || cat.includes('ACCIDENT')) return 'trauma';
  if (cat.includes('RESPIR') || cat.includes('BREATH')) return 'respiratory';
  if (cat.includes('PREG') || cat.includes('OBSTET') || cat.includes('BIRTH')) return 'obstetric';
  return 'general';
};

const timeAgo = (ts: string) => {
  const d = Math.floor((Date.now() - new Date(ts).getTime()) / 1000);
  if (d < 60) return `${d}s ago`;
  if (d < 3600) return `${Math.floor(d / 60)}m ago`;
  return `${Math.floor(d / 3600)}h ago`;
};

const IncidentsView: React.FC = () => {
  const [emergencies, setEmergencies] = useState<Emergency[]>([]);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('All');
  const [severityFilter, setSeverityFilter] = useState('All');
  const [selected, setSelected] = useState<Emergency | null>(null);

  useEffect(() => {
    const fetch = async () => {
      const { data } = await supabase
        .from('emergencies')
        .select('*')
        .order('created_at', { ascending: false });
      if (data) setEmergencies(data as Emergency[]);
    };
    fetch();
    const sub = supabase.channel('incidents-view')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'emergencies' }, fetch)
      .subscribe();
    return () => { supabase.removeChannel(sub); };
  }, []);

  const filtered = emergencies.filter(e => {
    const matchSearch = e.category.toLowerCase().includes(search.toLowerCase()) ||
      e.patient_id.toLowerCase().includes(search.toLowerCase());
    const matchStatus = statusFilter === 'All' || e.status === statusFilter;
    const matchSeverity = severityFilter === 'All' || e.severity === severityFilter;
    return matchSearch && matchStatus && matchSeverity;
  });

  const counts = {
    total: emergencies.length,
    active: emergencies.filter(e => !['completed', 'cancelled'].includes(e.status)).length,
    critical: emergencies.filter(e => e.severity === 'critical').length,
    resolved: emergencies.filter(e => e.status === 'completed').length,
  };

  return (
    <div style={{ display: 'flex', height: '100%', gap: '16px' }}>
      {/* Main List */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '16px', minWidth: 0 }}>
        {/* Summary Strips */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '12px' }}>
          {[
            { label: 'Total Incidents', value: counts.total, color: '#6366F1', bg: 'rgba(99,102,241,0.08)' },
            { label: 'Active Now', value: counts.active, color: '#EF4444', bg: 'rgba(239,68,68,0.08)' },
            { label: 'Critical Cases', value: counts.critical, color: '#F59E0B', bg: 'rgba(245,158,11,0.08)' },
            { label: 'Resolved Today', value: counts.resolved, color: '#10B981', bg: 'rgba(16,185,129,0.08)' },
          ].map(s => (
            <div key={s.label} style={{ background: s.bg, border: `1px solid ${s.color}22`, borderRadius: '10px', padding: '14px 16px' }}>
              <div style={{ fontSize: '10px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', color: s.color, marginBottom: '6px' }}>{s.label}</div>
              <div style={{ fontSize: '28px', fontWeight: 800, color: s.color, fontFamily: '"JetBrains Mono", monospace' }}>{s.value}</div>
            </div>
          ))}
        </div>

        {/* Filters */}
        <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: '8px', background: 'white', border: '1px solid var(--border)', borderRadius: '8px', padding: '8px 12px' }}>
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="var(--text-dim)" strokeWidth="2"><circle cx="11" cy="11" r="8" /><path d="m21 21-4.35-4.35" /></svg>
            <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by category or patient ID..." style={{ border: 'none', outline: 'none', fontSize: '12px', color: 'var(--text-primary)', width: '100%', background: 'none' }} />
          </div>
          <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)} style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border)', fontSize: '12px', background: 'white', color: 'var(--text-primary)', outline: 'none', cursor: 'pointer' }}>
            {ALL_STATUSES.map(s => <option key={s}>{s}</option>)}
          </select>
          <select value={severityFilter} onChange={e => setSeverityFilter(e.target.value)} style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border)', fontSize: '12px', background: 'white', color: 'var(--text-primary)', outline: 'none', cursor: 'pointer' }}>
            {ALL_SEVERITIES.map(s => <option key={s}>{s}</option>)}
          </select>
          <div style={{ fontSize: '11px', color: 'var(--text-secondary)', whiteSpace: 'nowrap', padding: '0 8px' }}>{filtered.length} records</div>
        </div>

        {/* Table */}
        <div className="card" style={{ flex: 1, overflow: 'auto' }}>
          <table className="em-table" style={{ width: '100%' }}>
            <thead>
              <tr>
                <th>Patient</th>
                <th>Category</th>
                <th>Severity</th>
                <th>Status</th>
                <th>Unit</th>
                <th>Funding</th>
                <th>Symptoms</th>
                <th>Time</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={9} style={{ textAlign: 'center', padding: '40px', color: 'var(--text-dim)' }}>No incidents match your filters.</td></tr>
              ) : filtered.map((em, i) => {
                const pct = em.target_amount > 0 ? Math.min((em.raised_amount / em.target_amount) * 100, 100) : 0;
                const statusColor = em.status === 'completed' ? '#10B981' : em.status === 'cancelled' ? '#6B7280' : em.status === 'dispatched' ? '#3B82F6' : '#F59E0B';
                const isSelected = selected?.id === em.id;
                return (
                  <tr key={em.id} onClick={() => setSelected(isSelected ? null : em)} style={{ background: isSelected ? 'rgba(99,102,241,0.06)' : undefined }}>
                    <td>
                      <div className="patient-cell">
                        <div className="patient-avatar" style={{ background: AVATARS[i % AVATARS.length] }}>P{(i + 1).toString().padStart(2, '0')}</div>
                        <div>
                          <div className="patient-name">#{em.patient_id.slice(-6).toUpperCase()}</div>
                          <div className="patient-meta">{new Date(em.created_at).toLocaleDateString()}</div>
                        </div>
                      </div>
                    </td>
                    <td><span className={`category-pill ${categoryClass(em.category)}`}>{em.category.replace(/_/g, ' ')}</span></td>
                    <td><span className={`sev-pill ${em.severity}`}>{em.severity}</span></td>
                    <td><span style={{ fontSize: '11px', fontWeight: 600, color: statusColor }}>{em.status.replace(/_/g, ' ').toUpperCase()}</span></td>
                    <td style={{ fontSize: '11px', fontFamily: '"JetBrains Mono", monospace', color: em.driver_id ? '#3B82F6' : 'var(--text-dim)' }}>{em.driver_id ? 'UNIT-ASG' : '—'}</td>
                    <td>
                      <div style={{ width: '80px' }}>
                        <div className="progress-track"><div className="progress-bar green" style={{ width: `${pct}%` }} /></div>
                        <div style={{ fontSize: '10px', color: 'var(--text-dim)', marginTop: '2px' }}>GHS {em.raised_amount}/{em.target_amount}</div>
                      </div>
                    </td>
                    <td>
                      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '3px' }}>
                        {em.symptoms.slice(0, 2).map((s, j) => <span key={j} className="symptom-tag" style={{ fontSize: '9px', padding: '1px 5px', borderRadius: '3px', background: 'var(--bg)', border: '1px solid var(--border)', color: 'var(--text-secondary)' }}>{s}</span>)}
                      </div>
                    </td>
                    <td style={{ color: 'var(--text-secondary)', fontSize: '11px', whiteSpace: 'nowrap' }}>{timeAgo(em.created_at)}</td>
                    <td>
                      <div className="row-actions">
                        <button className="row-btn" title="View"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg></button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Detail Drawer */}
      {selected && (
        <div style={{ width: '300px', flexShrink: 0, display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <div className="card">
            <div className="card-header">
              <div className="card-title">Incident Detail</div>
              <button onClick={() => setSelected(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-secondary)', fontSize: '16px' }}>✕</button>
            </div>
            <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div><div style={{ fontSize: '10px', color: 'var(--text-dim)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: '4px' }}>Category</div><div style={{ fontWeight: 700, fontSize: '14px' }}>{selected.category.replace(/_/g, ' ')}</div></div>
              <div><div style={{ fontSize: '10px', color: 'var(--text-dim)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: '4px' }}>Severity</div><span className={`sev-pill ${selected.severity}`}>{selected.severity}</span></div>
              <div><div style={{ fontSize: '10px', color: 'var(--text-dim)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: '4px' }}>Status</div><span style={{ fontSize: '12px', fontWeight: 600 }}>{selected.status.replace(/_/g, ' ')}</span></div>
              <div><div style={{ fontSize: '10px', color: 'var(--text-dim)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: '6px' }}>Symptoms</div><div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>{selected.symptoms.map((s, i) => <span key={i} style={{ fontSize: '10px', padding: '2px 7px', borderRadius: '4px', background: 'var(--bg)', border: '1px solid var(--border)', color: 'var(--text-secondary)' }}>{s}</span>)}</div></div>
              <div>
                <div style={{ fontSize: '10px', color: 'var(--text-dim)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: '6px' }}>Community Funding</div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', marginBottom: '6px' }}>
                  <span style={{ color: 'var(--text-secondary)' }}>GHS {selected.raised_amount} raised</span>
                  <span style={{ fontWeight: 700, color: '#10B981' }}>of GHS {selected.target_amount}</span>
                </div>
                <div className="progress-track"><div className="progress-bar green" style={{ width: `${selected.target_amount > 0 ? Math.min((selected.raised_amount / selected.target_amount) * 100, 100) : 0}%` }} /></div>
              </div>
              <div style={{ fontSize: '10px', color: 'var(--text-dim)' }}>Created: {new Date(selected.created_at).toLocaleString()}</div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default IncidentsView;
