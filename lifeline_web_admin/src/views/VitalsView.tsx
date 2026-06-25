import React, { useState, useEffect } from 'react';

const PATIENTS = [
  { id: 'P-001', name: 'Abena Mensah', condition: 'Obstetric Emergency', severity: 'critical', unit: 'UNIT-01', avatar: '#EC4899',
    vitals: { hr: 138, spo2: 91, rr: 28, sbp: 162, temp: 38.4 } },
  { id: 'P-003', name: 'Yaa Boateng', condition: 'Respiratory Distress', severity: 'high', unit: 'UNIT-03', avatar: '#8B5CF6',
    vitals: { hr: 112, spo2: 87, rr: 32, sbp: 148, temp: 37.1 } },
  { id: 'P-005', name: 'Ama Osei', condition: 'Seizure', severity: 'high', unit: 'UNIT-02', avatar: '#F59E0B',
    vitals: { hr: 124, spo2: 95, rr: 20, sbp: 140, temp: 37.8 } },
];

const vitalColor = (name: string, val: number) => {
  const thresholds: Record<string, [number, number]> = {
    hr: [60, 100], spo2: [95, 100], rr: [12, 20], sbp: [90, 140], temp: [36.1, 37.5]
  };
  const [lo, hi] = thresholds[name] || [0, Infinity];
  if (val < lo || val > hi * 1.15) return { color: '#EF4444', label: 'Critical' };
  if (val < lo * 1.05 || val > hi) return { color: '#F59E0B', label: 'Warning' };
  return { color: '#10B981', label: 'Normal' };
};

const VitalsView: React.FC = () => {
  const [tick, setTick] = useState(0);
  // Simulate live changes
  useEffect(() => {
    const t = setInterval(() => setTick(n => n + 1), 2000);
    return () => clearInterval(t);
  }, []);

  const jitter = (base: number, range: number) => base + Math.floor((Math.sin(tick * 0.7 + base) * range));

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <h2 style={{ fontSize: '16px', fontWeight: 700, color: 'var(--text-primary)' }}>Live Vitals Monitor</h2>
          <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>Real-time vitals for all inbound patients — updates every 2s</p>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 12px', background: 'rgba(16,185,129,0.1)', border: '1px solid rgba(16,185,129,0.25)', borderRadius: '20px' }}>
          <div style={{ width: '7px', height: '7px', borderRadius: '50%', background: '#10B981', animation: 'pulse-dot 1.5s infinite' }} />
          <span style={{ fontSize: '11px', fontWeight: 600, color: '#10B981' }}>Live Monitoring · {PATIENTS.length} Patients</span>
        </div>
      </div>

      {PATIENTS.map(p => {
        const liveVitals = {
          hr: jitter(p.vitals.hr, 5),
          spo2: Math.min(100, jitter(p.vitals.spo2, 2)),
          rr: jitter(p.vitals.rr, 2),
          sbp: jitter(p.vitals.sbp, 8),
          temp: +(p.vitals.temp + Math.sin(tick * 0.5 + p.vitals.temp) * 0.2).toFixed(1),
        };

        const vitalFields = [
          { key: 'hr', label: 'Heart Rate', value: liveVitals.hr, unit: 'bpm' },
          { key: 'spo2', label: 'SpO₂', value: liveVitals.spo2, unit: '%' },
          { key: 'rr', label: 'Resp Rate', value: liveVitals.rr, unit: '/min' },
          { key: 'sbp', label: 'Systolic BP', value: liveVitals.sbp, unit: 'mmHg' },
          { key: 'temp', label: 'Temperature', value: liveVitals.temp, unit: '°C' },
        ];

        return (
          <div className="card" key={p.id}>
            <div className="card-header">
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <div style={{ width: '38px', height: '38px', borderRadius: '50%', background: p.avatar, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '13px', fontWeight: 700, color: 'white' }}>
                  {p.name.split(' ').map(n => n[0]).join('')}
                </div>
                <div>
                  <div className="card-title">{p.name}</div>
                  <div className="card-subtitle">{p.id} · {p.condition} · Unit: {p.unit}</div>
                </div>
              </div>
              <span className={`sev-pill ${p.severity}`}>{p.severity}</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: '5px', marginLeft: '8px' }}>
                <div style={{ width: '6px', height: '6px', borderRadius: '50%', background: '#10B981', animation: 'pulse-dot 1s infinite' }} />
                <span style={{ fontSize: '10px', fontWeight: 600, color: '#10B981' }}>LIVE</span>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '0px' }}>
              {vitalFields.map((v, i) => {
                const { color, label } = vitalColor(v.key, v.value);
                return (
                  <div key={v.key} style={{ padding: '16px 20px', borderRight: i < 4 ? '1px solid var(--border)' : 'none', transition: 'background 0.3s' }}>
                    <div style={{ fontSize: '10px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.1em', color: 'var(--text-dim)', marginBottom: '8px' }}>{v.label}</div>
                    <div style={{ display: 'flex', alignItems: 'baseline', gap: '3px' }}>
                      <span style={{ fontFamily: '"JetBrains Mono", monospace', fontSize: '28px', fontWeight: 700, color, lineHeight: 1, transition: 'color 0.3s' }}>{v.value}</span>
                      <span style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{v.unit}</span>
                    </div>
                    <div style={{ marginTop: '6px', fontSize: '10px', fontWeight: 600, color }}>{label}</div>
                    {/* Mini sparkline */}
                    <svg width="100%" height="24" viewBox="0 0 80 24" style={{ display: 'block', marginTop: '6px' }}>
                      <polyline
                        fill="none"
                        stroke={color}
                        strokeWidth="1.5"
                        strokeOpacity="0.5"
                        points={Array.from({ length: 8 }, (_, k) => {
                          const base = 12;
                          const amp = 8;
                          const y = base - Math.sin((tick + k) * 0.7 + v.value) * amp;
                          return `${k * 11.4},${Math.max(2, Math.min(22, y))}`;
                        }).join(' ')}
                      />
                    </svg>
                  </div>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default VitalsView;
