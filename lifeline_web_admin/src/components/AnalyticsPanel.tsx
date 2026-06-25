import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

const AnalyticsPanel: React.FC = () => {
  const [totalRaised, setTotalRaised] = useState(0);
  const [totalGoal, setTotalGoal] = useState(0);

  useEffect(() => {
    const fetch = async () => {
      const { data } = await supabase
        .from('emergencies')
        .select('raised_amount, target_amount')
        .neq('status', 'completed')
        .neq('status', 'cancelled');
      if (data) {
        setTotalRaised(data.reduce((acc, e) => acc + (e.raised_amount || 0), 0));
        setTotalGoal(data.reduce((acc, e) => acc + (e.target_amount || 0), 0));
      }
    };
    fetch();
    const sub = supabase
      .channel('analytics')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'emergencies' }, fetch)
      .subscribe();
    return () => { supabase.removeChannel(sub); };
  }, []);

  const fundPct = totalGoal > 0 ? Math.min((totalRaised / totalGoal) * 100, 100) : 0;

  const stats = [
    { label: 'Active Cases', value: '3', cls: 'red' },
    { label: 'Units Online', value: '4', cls: 'blue' },
    { label: 'Resolved Today', value: '12', cls: 'green' },
    { label: 'Avg Response', value: '8m', cls: 'amber' },
  ];

  const events = [
    { dot: 'red', text: <><strong>PREGNANCY EMERGENCY</strong> — New case incoming</>, time: '0:23' },
    { dot: 'green', text: <><strong>Unit 01</strong> dispatched to Dansoman</>, time: '1:45' },
    { dot: 'blue', text: <><strong>GHS 200</strong> contribution received</>, time: '3:10' },
    { dot: 'amber', text: <><strong>Unit 03</strong> requesting backup</>, time: '5:02' },
    { dot: 'green', text: <><strong>CARDIAC EVENT</strong> — Patient stable</>, time: '8:44' },
  ];

  const vitals = [
    { name: 'Heart Rate', value: '122', unit: 'bpm', status: 'warning', statusLabel: 'Elevated' },
    { name: 'SpO2', value: '94', unit: '%', status: 'warning', statusLabel: 'Low-Normal' },
    { name: 'Resp Rate', value: '24', unit: '/min', status: 'critical', statusLabel: 'Tachypnea' },
    { name: 'BP Systolic', value: '158', unit: 'mmHg', status: 'warning', statusLabel: 'Hypertensive' },
  ];

  return (
    <>
      {/* Stats */}
      <div className="analytics-section">
        <div className="analytics-section-header">
          <span>System Overview</span>
          <span style={{ color: 'var(--accent-green)', fontSize: '9px' }}>● LIVE</span>
        </div>
        <div className="analytics-body">
          <div className="stats-grid">
            {stats.map(s => (
              <div className="stat-card" key={s.label}>
                <div className="stat-label">{s.label}</div>
                <div className={`stat-value ${s.cls}`}>{s.value}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Funding */}
      <div className="analytics-section">
        <div className="analytics-section-header">
          <span>Community Funding</span>
          <span style={{ fontFamily: '"JetBrains Mono", monospace', color: 'var(--accent-green)' }}>
            {fundPct.toFixed(1)}%
          </span>
        </div>
        <div className="analytics-body">
          <div className="funding-block">
            <div className="funding-header">
              <div>
                <div style={{ fontSize: '10px', color: 'var(--text-dim)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.1em', marginBottom: '4px' }}>
                  Total Raised (Active)
                </div>
                <div className="funding-total">GHS {totalRaised.toLocaleString()}</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '10px', color: 'var(--text-dim)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.1em', marginBottom: '4px' }}>
                  Target
                </div>
                <div className="funding-goal">GHS {totalGoal.toLocaleString()}</div>
              </div>
            </div>
            <div className="progress-track">
              <div className={`progress-fill ${fundPct < 30 ? 'amber' : ''}`} style={{ width: `${fundPct}%` }} />
            </div>
            <div className="funding-meta">
              <span>Network contribution rate</span>
              <span>{fundPct.toFixed(1)}% funded</span>
            </div>
          </div>
        </div>
      </div>

      {/* Patient Vitals */}
      <div className="analytics-section">
        <div className="analytics-section-header">
          <span>Inbound Patient Vitals</span>
          <span style={{ fontSize: '9px', color: 'var(--accent-red)' }}>● CRITICAL</span>
        </div>
        <div className="analytics-body">
          <div className="vitals-grid">
            {vitals.map(v => (
              <div className="vital-card" key={v.name}>
                <div className="vital-name">{v.name}</div>
                <div>
                  <span className="vital-value">{v.value}</span>
                  <span className="vital-unit">{v.unit}</span>
                </div>
                <div className={`vital-status ${v.status}`}>{v.statusLabel}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Event Log */}
      <div className="analytics-section">
        <div className="analytics-section-header">
          <span>Network Event Log</span>
          <button style={{ fontSize: '9px', background: 'none', border: 'none', color: 'var(--text-dim)', cursor: 'pointer' }}>Clear</button>
        </div>
        <div className="analytics-body" style={{ gap: 0, padding: '0 14px' }}>
          <div className="event-log">
            {events.map((e, i) => (
              <div className="event-item" key={i}>
                <div className={`event-dot ${e.dot}`} />
                <div className="event-text">{e.text}</div>
                <div className="event-time">{e.time}m</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
};

export default AnalyticsPanel;
