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

const AVATARS = ['#EF4444', '#3B82F6', '#8B5CF6', '#10B981', '#F59E0B'];
const initials = (id: string) => id.slice(0, 2).toUpperCase();

const categoryClass = (cat: string) => {
  if (cat.includes('CARDIAC') || cat.includes('HEART')) return 'cardiac';
  if (cat.includes('TRAUMA') || cat.includes('ACCIDENT')) return 'trauma';
  if (cat.includes('RESPIR') || cat.includes('BREATH')) return 'respiratory';
  if (cat.includes('PREG') || cat.includes('OBSTET') || cat.includes('BIRTH')) return 'obstetric';
  return 'general';
};

const categoryLabel = (cat: string) => cat.replace(/_/g, ' ');

const timeAgo = (ts: string) => {
  const d = Math.floor((Date.now() - new Date(ts).getTime()) / 1000);
  if (d < 60) return `${d}s ago`;
  if (d < 3600) return `${Math.floor(d / 60)}m ago`;
  return `${Math.floor(d / 3600)}h ago`;
};

const EmergencyTable: React.FC = () => {
  const [emergencies, setEmergencies] = useState<Emergency[]>([]);

  useEffect(() => {
    const fetch = async () => {
      const { data } = await supabase
        .from('emergencies')
        .select('*')
        .neq('status', 'completed')
        .neq('status', 'cancelled')
        .order('created_at', { ascending: false });
      if (data) setEmergencies(data as Emergency[]);
    };
    fetch();
    const sub = supabase
      .channel('em-table')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'emergencies' }, fetch)
      .subscribe();
    return () => { supabase.removeChannel(sub); };
  }, []);

  if (emergencies.length === 0) {
    return (
      <div style={{ padding: '40px 20px', textAlign: 'center', color: 'var(--text-dim)' }}>
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" style={{ margin: '0 auto 12px', display: 'block', opacity: 0.3 }}>
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
        </svg>
        <p style={{ fontWeight: 600, color: 'var(--text-secondary)', fontSize: '13px' }}>No Active Emergencies</p>
        <p style={{ fontSize: '11px', marginTop: '4px' }}>All clear. No inbound cases at this time.</p>
      </div>
    );
  }

  return (
    <table className="em-table">
      <thead>
        <tr>
          <th>Patient</th>
          <th>Category</th>
          <th>Severity</th>
          <th>Status</th>
          <th>Funding</th>
          <th>Time</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        {emergencies.map((em, i) => {
          const pct = em.target_amount > 0 ? Math.min((em.raised_amount / em.target_amount) * 100, 100) : 0;
          const statusClass = em.driver_id ? 'en-route' : 'awaiting';
          const statusLabel = em.driver_id ? 'En Route' : 'Awaiting';
          return (
            <tr key={em.id}>
              <td>
                <div className="patient-cell">
                  <div className="patient-avatar" style={{ background: AVATARS[i % AVATARS.length] }}>
                    {initials(em.patient_id)}
                  </div>
                  <div>
                    <div className="patient-name">Patient #{em.patient_id.slice(-4).toUpperCase()}</div>
                    <div className="patient-meta">{em.symptoms.slice(0, 1).join(', ')}</div>
                  </div>
                </div>
              </td>
              <td>
                <span className={`category-pill ${categoryClass(em.category)}`}>
                  {categoryLabel(em.category)}
                </span>
              </td>
              <td><span className={`sev-pill ${em.severity}`}>{em.severity}</span></td>
              <td><span className={`status-pill ${statusClass}`}>{statusLabel}</span></td>
              <td>
                <div style={{ width: '80px' }}>
                  <div className="progress-track">
                    <div className="progress-bar green" style={{ width: `${pct}%` }} />
                  </div>
                  <div style={{ fontSize: '10px', color: 'var(--text-dim)', marginTop: '3px' }}>
                    GHS {em.raised_amount}/{em.target_amount}
                  </div>
                </div>
              </td>
              <td style={{ color: 'var(--text-secondary)', fontSize: '11px', whiteSpace: 'nowrap' }}>{timeAgo(em.created_at)}</td>
              <td>
                <div className="row-actions">
                  <button className="row-btn" title="View Details">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                  </button>
                  <button className="row-btn" title="Track Unit">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <polygon points="3 11 22 2 13 21 11 13 3 11" />
                    </svg>
                  </button>
                </div>
              </td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
};

export default EmergencyTable;
