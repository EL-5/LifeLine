import React, { useState } from 'react';
import AnalyticsSection from '../components/AnalyticsSection';

const MONTHLY = [42, 58, 51, 73, 65, 80, 71, 92, 88, 76, 95, 84];
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const MAX_M = 100;

const RECENT_REPORTS = [
  { title: 'Monthly Emergency Summary — June 2026', type: 'PDF', date: '2026-06-01', size: '1.2 MB' },
  { title: 'Community Funding Analysis Q2 2026', type: 'Excel', date: '2026-05-30', size: '890 KB' },
  { title: 'Response Time Performance Report', type: 'PDF', date: '2026-05-15', size: '2.1 MB' },
  { title: 'Staff Capacity Report — May 2026', type: 'PDF', date: '2026-05-01', size: '750 KB' },
];

const RANGES = ['7 Days', '30 Days', '3 Months', '12 Months'];

const ReportsView: React.FC = () => {
  const [range, setRange] = useState('7 Days');

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* KPI Row */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '12px' }}>
        {[
          { label: 'Avg Response Time', value: '8.2m', change: '–1.3m', color: '#10B981', up: true },
          { label: 'Resolution Rate', value: '94%', change: '+2%', color: '#6366F1', up: true },
          { label: 'Funding Success Rate', value: '68%', change: '+5%', color: '#F59E0B', up: true },
          { label: 'Repeat Patients', value: '12%', change: '+1%', color: '#EF4444', up: false },
        ].map(s => (
          <div key={s.label} style={{ background: `${s.color}0D`, border: `1px solid ${s.color}22`, borderRadius: '10px', padding: '14px 16px' }}>
            <div style={{ fontSize: '10px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', color: s.color, marginBottom: '6px' }}>{s.label}</div>
            <div style={{ fontSize: '28px', fontWeight: 800, color: s.color, fontFamily: '"JetBrains Mono", monospace', marginBottom: '4px' }}>{s.value}</div>
            <div style={{ fontSize: '11px', fontWeight: 600, color: s.up ? '#10B981' : '#EF4444' }}>{s.change} vs last period</div>
          </div>
        ))}
      </div>

      {/* Range Tabs + Charts */}
      <div className="card">
        <div className="card-header">
          <div>
            <div className="card-title">Emergency Volume Trends</div>
            <div className="card-subtitle">Case volume over selected period</div>
          </div>
          <div style={{ display: 'flex', gap: '4px', background: 'var(--bg)', borderRadius: '8px', padding: '3px' }}>
            {RANGES.map(r => (
              <button key={r} onClick={() => setRange(r)} style={{
                padding: '5px 12px', borderRadius: '6px', border: 'none', fontSize: '11px', fontWeight: 600, cursor: 'pointer',
                background: range === r ? 'white' : 'transparent',
                color: range === r ? 'var(--text-primary)' : 'var(--text-secondary)',
                boxShadow: range === r ? '0 1px 4px rgba(0,0,0,0.08)' : 'none',
              }}>{r}</button>
            ))}
          </div>
          <button style={{ padding: '6px 14px', borderRadius: '7px', border: '1px solid var(--border)', background: 'white', fontSize: '11px', fontWeight: 600, color: 'var(--text-secondary)', cursor: 'pointer' }}>Export CSV</button>
        </div>
        <div style={{ padding: '16px 20px' }}>
          {range === '12 Months' ? (
            <div>
              <div style={{ display: 'flex', alignItems: 'flex-end', gap: '8px', height: '120px' }}>
                {MONTHLY.map((v, i) => (
                  <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px' }}>
                    <div style={{ width: '100%', height: `${(v / MAX_M) * 100}px`, background: `linear-gradient(180deg, #818CF8, #6366F1)`, borderRadius: '4px 4px 0 0', boxShadow: '0 2px 8px rgba(99,102,241,0.3)' }} />
                    <span style={{ fontSize: '9px', color: 'var(--text-dim)' }}>{MONTHS[i]}</span>
                  </div>
                ))}
              </div>
            </div>
          ) : <AnalyticsSection />}
        </div>
      </div>

      {/* Recent Reports */}
      <div className="card">
        <div className="card-header">
          <div className="card-title">Generated Reports</div>
          <button className="card-header-action">Generate New Report</button>
        </div>
        <table className="em-table">
          <thead>
            <tr>
              <th>Report Title</th>
              <th>Type</th>
              <th>Date</th>
              <th>Size</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {RECENT_REPORTS.map((r, i) => (
              <tr key={i}>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <div style={{ width: '28px', height: '28px', borderRadius: '6px', background: r.type === 'PDF' ? 'rgba(239,68,68,0.1)' : 'rgba(16,185,129,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '9px', fontWeight: 800, color: r.type === 'PDF' ? '#EF4444' : '#10B981', flexShrink: 0 }}>{r.type}</div>
                    <span style={{ fontSize: '12px', fontWeight: 600, color: 'var(--text-primary)' }}>{r.title}</span>
                  </div>
                </td>
                <td><span style={{ fontSize: '11px', fontWeight: 600, color: r.type === 'PDF' ? '#EF4444' : '#10B981' }}>{r.type}</span></td>
                <td style={{ fontSize: '11px', color: 'var(--text-secondary)', fontFamily: '"JetBrains Mono", monospace' }}>{r.date}</td>
                <td style={{ fontSize: '11px', color: 'var(--text-dim)', fontFamily: '"JetBrains Mono", monospace' }}>{r.size}</td>
                <td>
                  <div className="row-actions">
                    <button className="row-btn" title="Download"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3" /></svg></button>
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

export default ReportsView;
