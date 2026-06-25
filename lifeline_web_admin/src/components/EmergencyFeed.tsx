import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import icons from '../lib/icons';

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

const getSeverityClass = (s: string) => {
  if (s === 'critical') return 'critical';
  if (s === 'high') return 'high';
  if (s === 'medium') return 'medium';
  return 'low';
};

const timeAgo = (ts: string) => {
  const diff = Math.floor((Date.now() - new Date(ts).getTime()) / 1000);
  if (diff < 60) return `${diff}s ago`;
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  return `${Math.floor(diff / 3600)}h ago`;
};

const EmergencyFeed: React.FC = () => {
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
      .channel('emergency-feed')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'emergencies' }, fetch)
      .subscribe();

    return () => { supabase.removeChannel(sub); };
  }, []);

  if (emergencies.length === 0) {
    return (
      <div className="empty-state">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
        </svg>
        <p className="empty-state-title">System Clear</p>
        <p className="empty-state-sub">No inbound emergencies at this time. All units standing by.</p>
      </div>
    );
  }

  return (
    <>
      {emergencies.map((em, i) => {
        const sc = getSeverityClass(em.severity);
        const fundPct = em.target_amount > 0 ? Math.min((em.raised_amount / em.target_amount) * 100, 100) : 0;
        return (
          <div className={`emergency-card ${sc}`} key={em.id} style={{ animationDelay: `${i * 60}ms` }}>
            <div className="emergency-card-header">
              <div className={`severity-dot ${sc}`} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div className="emergency-card-title">
                  {em.category.replace(/_/g, ' ')}
                </div>
                <div style={{ fontSize: '10px', color: 'var(--text-dim)', marginTop: '2px' }}>
                  {timeAgo(em.created_at)}
                </div>
              </div>
              <span className={`severity-pill ${sc}`}>{em.severity}</span>
            </div>

            <div className="emergency-card-body">
              <div className="emergency-symptoms">
                {em.symptoms.slice(0, 3).map((s, j) => (
                  <span className="symptom-tag" key={j}>{s}</span>
                ))}
                {em.symptoms.length > 3 && (
                  <span className="symptom-tag">+{em.symptoms.length - 3}</span>
                )}
              </div>

              <div className="emergency-eta-bar">
                <div>
                  <div className="eta-label">Status</div>
                  {em.driver_id ? (
                    <div className="dispatch-status" style={{ marginTop: '2px' }}>
                      <div className="dispatch-dot" />
                      <span className="dispatch-text">Unit En Route</span>
                    </div>
                  ) : (
                    <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px', fontWeight: 600 }}>
                      Awaiting Dispatch
                    </div>
                  )}
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div className="eta-label">ETA</div>
                  <div className="eta-value">12:00</div>
                </div>
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10px', color: 'var(--text-dim)', marginBottom: '4px' }}>
                  <span>Community Funding</span>
                  <span style={{ color: 'var(--accent-green)', fontWeight: 700 }}>GHS {em.raised_amount} / {em.target_amount}</span>
                </div>
                <div className="progress-track">
                  <div className="progress-fill" style={{ width: `${fundPct}%` }} />
                </div>
              </div>
            </div>

            <div className="emergency-card-actions">
              <button className="btn-sm">View File</button>
              <button className="btn-sm primary">Track Unit</button>
            </div>
          </div>
        );
      })}
    </>
  );
};

export default EmergencyFeed;
