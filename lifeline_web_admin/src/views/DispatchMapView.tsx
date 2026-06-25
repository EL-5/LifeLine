import React, { useState } from 'react';

const UNITS = [
  { id: 'UNIT-01', driver: 'Kwame Asante', status: 'En Route', patient: 'Abena Mensah', destination: 'Korle Bu Hospital', eta: '8 min', coords: { top: '28%', left: '62%' }, color: '#10B981' },
  { id: 'UNIT-02', driver: 'Ama Osei', status: 'Standby', patient: '—', destination: 'Base Station', eta: '—', coords: { top: '60%', left: '45%' }, color: '#6B7280' },
  { id: 'UNIT-03', driver: 'Abena Mensah', status: 'En Route', patient: 'Yaa Boateng', destination: '37 Military Hospital', eta: '14 min', coords: { top: '22%', left: '35%' }, color: '#EF4444' },
  { id: 'UNIT-04', driver: 'Kofi Boateng', status: 'Standby', patient: '—', destination: 'Base Station', eta: '—', coords: { top: '72%', left: '68%' }, color: '#6B7280' },
  { id: 'UNIT-05', driver: 'Nana Ofori', status: 'En Route', patient: 'Ama Osei', destination: 'Ridge Hospital', eta: '6 min', coords: { top: '48%', left: '78%' }, color: '#3B82F6' },
];

const DispatchMapView: React.FC = () => {
  const [selected, setSelected] = useState<typeof UNITS[0] | null>(null);

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 300px', gap: '16px', height: '100%' }}>
      {/* Map Area */}
      <div className="card" style={{ overflow: 'hidden', position: 'relative' }}>
        <div className="card-header">
          <div className="card-title">Live Dispatch Map</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
            <div style={{ width: '6px', height: '6px', borderRadius: '50%', background: '#6366F1', animation: 'pulse-dot 1.5s infinite' }} />
            <span style={{ fontSize: '10px', fontWeight: 600, color: '#6366F1' }}>Streaming</span>
          </div>
        </div>
        <div style={{ flex: 1, background: '#0D1117', position: 'relative', overflow: 'hidden', height: 'calc(100% - 53px)' }}>
          {/* Grid background */}
          <div style={{ position: 'absolute', inset: 0, backgroundImage: 'radial-gradient(rgba(99,102,241,0.1) 1px, transparent 1px)', backgroundSize: '30px 30px' }} />
          {/* Gradient overlay */}
          <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(ellipse at center, transparent 40%, rgba(8,11,16,0.8) 100%)' }} />

          {/* City labels */}
          {[
            { name: 'Accra CBD', top: '50%', left: '50%' },
            { name: 'Korle Bu', top: '65%', left: '38%' },
            { name: '37 Military', top: '30%', left: '55%' },
            { name: 'Ridge Hospital', top: '42%', left: '75%' },
          ].map(l => (
            <div key={l.name} style={{ position: 'absolute', top: l.top, left: l.left, transform: 'translate(-50%, -50%)', fontSize: '9px', fontWeight: 600, color: 'rgba(255,255,255,0.2)', letterSpacing: '0.1em', textTransform: 'uppercase', whiteSpace: 'nowrap' }}>
              {l.name}
            </div>
          ))}

          {/* Hospital marker */}
          <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', width: '24px', height: '24px', background: 'rgba(239,68,68,0.2)', border: '2px solid #EF4444', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '10px', fontWeight: 800, color: '#EF4444', zIndex: 10, boxShadow: '0 0 20px rgba(239,68,68,0.3)' }}>H</div>

          {/* Unit blips */}
          {UNITS.map(u => (
            <button
              key={u.id}
              onClick={() => setSelected(selected?.id === u.id ? null : u)}
              style={{
                position: 'absolute',
                top: u.coords.top,
                left: u.coords.left,
                transform: 'translate(-50%, -50%)',
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                zIndex: 20,
              }}
            >
              <div style={{ position: 'relative' }}>
                <div style={{ width: '12px', height: '12px', borderRadius: '50%', background: u.color, boxShadow: `0 0 10px ${u.color}` }} />
                {u.status === 'En Route' && (
                  <div style={{ position: 'absolute', inset: '-6px', borderRadius: '50%', border: `1.5px solid ${u.color}`, opacity: 0.5, animation: 'pulse-dot 1.5s infinite' }} />
                )}
                <div style={{ position: 'absolute', top: '14px', left: '50%', transform: 'translateX(-50%)', background: 'rgba(13,17,23,0.9)', border: `1px solid ${u.color}44`, borderRadius: '4px', padding: '2px 6px', whiteSpace: 'nowrap', fontSize: '9px', fontWeight: 700, color: u.color }}>
                  {u.id}
                </div>
              </div>
            </button>
          ))}

          {/* Legend */}
          <div style={{ position: 'absolute', bottom: '16px', left: '16px', background: 'rgba(13,17,23,0.9)', backdropFilter: 'blur(8px)', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '8px', padding: '10px 14px', display: 'flex', flexDirection: 'column', gap: '6px' }}>
            {[{ color: '#10B981', label: 'En Route' }, { color: '#EF4444', label: 'Critical ETA' }, { color: '#3B82F6', label: 'Fast Response' }, { color: '#6B7280', label: 'Standby' }].map(l => (
              <div key={l.label} style={{ display: 'flex', alignItems: 'center', gap: '7px' }}>
                <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: l.color, boxShadow: `0 0 5px ${l.color}` }} />
                <span style={{ fontSize: '10px', color: 'rgba(255,255,255,0.6)', fontWeight: 500 }}>{l.label}</span>
              </div>
            ))}
          </div>

          {/* Coords */}
          <div style={{ position: 'absolute', bottom: '16px', right: '16px', fontFamily: '"JetBrains Mono", monospace', fontSize: '10px', color: 'rgba(255,255,255,0.25)', lineHeight: '1.8', textAlign: 'right' }}>
            <div>LAT: 5.6037°N</div>
            <div>LON: 0.1870°W</div>
            <div style={{ color: '#6366F1', fontWeight: 600, marginTop: '2px' }}>ACCRA METRO</div>
          </div>
        </div>
      </div>

      {/* Right Panel */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', overflow: 'auto' }}>
        {/* Selected Unit Detail */}
        {selected && (
          <div className="card">
            <div className="card-header">
              <div className="card-title">{selected.id} Detail</div>
              <button onClick={() => setSelected(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-secondary)', fontSize: '16px' }}>✕</button>
            </div>
            <div style={{ padding: '14px 16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {[
                { label: 'Driver', value: selected.driver },
                { label: 'Status', value: selected.status, color: selected.color },
                { label: 'Patient', value: selected.patient },
                { label: 'Destination', value: selected.destination },
                { label: 'ETA', value: selected.eta, color: '#F59E0B', mono: true },
              ].map(f => (
                <div key={f.label}>
                  <div style={{ fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.1em', color: 'var(--text-dim)', marginBottom: '2px' }}>{f.label}</div>
                  <div style={{ fontSize: '13px', fontWeight: 600, color: f.color || 'var(--text-primary)', fontFamily: f.mono ? '"JetBrains Mono", monospace' : 'inherit' }}>{f.value}</div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* All Units */}
        <div className="card" style={{ flex: 1 }}>
          <div className="card-header"><div className="card-title">All Units</div></div>
          <div>
            {UNITS.map(u => (
              <div key={u.id} onClick={() => setSelected(selected?.id === u.id ? null : u)}
                style={{ padding: '12px 16px', borderBottom: '1px solid var(--border)', cursor: 'pointer', background: selected?.id === u.id ? 'rgba(99,102,241,0.06)' : 'white', display: 'flex', alignItems: 'center', gap: '10px', transition: 'background 0.12s' }}>
                <div style={{ width: '32px', height: '32px', borderRadius: '8px', background: `${u.color}18`, border: `1px solid ${u.color}44`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={u.color} strokeWidth="2"><rect x="1" y="3" width="15" height="13" rx="1" /><polygon points="16 8 20 8 23 11 23 16 16 16 16 8" /><circle cx="5.5" cy="18.5" r="2.5" /><circle cx="18.5" cy="18.5" r="2.5" /></svg>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontWeight: 600, fontSize: '12px', color: 'var(--text-primary)' }}>{u.id}</div>
                  <div style={{ fontSize: '10px', color: 'var(--text-secondary)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{u.driver} · {u.status === 'En Route' ? u.patient : 'Standby'}</div>
                </div>
                <span style={{ fontSize: '11px', fontWeight: 700, color: u.eta === '—' ? 'var(--text-dim)' : '#F59E0B', fontFamily: '"JetBrains Mono", monospace' }}>{u.eta}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default DispatchMapView;
