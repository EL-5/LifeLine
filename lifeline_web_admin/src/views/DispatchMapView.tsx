import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { useRealtimeEmergencies, Emergency } from '../hooks/useRealtimeEmergencies';

// Fake coordinate bounds for Accra (just to map generic coordinates to % visually for demo)
const mapBounds = {
  latMin: 5.5, latMax: 5.7,
  lngMin: -0.3, lngMax: 0.0
};

const getCoords = (em: Emergency) => {
  if (!em.location || !em.location.lat) return { top: '50%', left: '50%' };
  // Simple linear interpolation to fit on the CSS map box
  const top = Math.max(10, Math.min(90, 100 - ((em.location.lat - mapBounds.latMin) / (mapBounds.latMax - mapBounds.latMin)) * 100));
  const left = Math.max(10, Math.min(90, ((em.location.lng - mapBounds.lngMin) / (mapBounds.lngMax - mapBounds.lngMin)) * 100));
  return { top: `${top}%`, left: `${left}%` };
};

const DispatchMapView: React.FC = () => {
  const { emergencies } = useRealtimeEmergencies();
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const activeUnits = emergencies.filter(e => e.driver_id).map(e => ({
    id: `UNIT-${e.driver_id!.slice(0, 4).toUpperCase()}`,
    driver: e.driver_name || 'Assigned Driver',
    status: e.status === 'en_route_hospital' ? 'En Route' : 'Responding',
    patient: e.patient_name || 'Unknown Patient',
    destination: 'Korle Bu Hospital',
    eta: '8 min',
    coords: getCoords(e),
    color: e.status === 'en_route_hospital' ? '#EF4444' : '#10B981',
    raw: e
  }));

  const selected = activeUnits.find(u => u.id === selectedId);
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
          {activeUnits.map(u => (
            <motion.button
              key={u.id}
              onClick={() => setSelectedId(selected?.id === u.id ? null : u.id)}
              animate={{ top: u.coords.top, left: u.coords.left }}
              transition={{ type: 'spring', stiffness: 50 }}
              style={{
                position: 'absolute',
                transform: 'translate(-50%, -50%)',
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                zIndex: selected?.id === u.id ? 30 : 20,
              }}
            >
              <div style={{ position: 'relative' }}>
                <div style={{ width: '12px', height: '12px', borderRadius: '50%', background: u.color, boxShadow: `0 0 10px ${u.color}` }} />
                {u.status === 'En Route' && (
                  <div style={{ position: 'absolute', inset: '-6px', borderRadius: '50%', border: `1.5px solid ${u.color}`, opacity: 0.5, animation: 'pulse-dot 1.5s infinite' }} />
                )}
                {selected?.id === u.id && (
                  <motion.div 
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    style={{ position: 'absolute', top: '-24px', left: '50%', transform: 'translateX(-50%)', background: 'white', padding: '4px 8px', borderRadius: '6px', fontSize: '10px', fontWeight: 800, color: '#111827', boxShadow: '0 4px 12px rgba(0,0,0,0.15)' }}
                  >
                    {u.id}
                  </motion.div>
                )}
                <div style={{ position: 'absolute', top: '14px', left: '50%', transform: 'translateX(-50%)', background: 'rgba(13,17,23,0.9)', border: `1px solid ${u.color}44`, borderRadius: '4px', padding: '2px 6px', whiteSpace: 'nowrap', fontSize: '9px', fontWeight: 700, color: u.color }}>
                  {u.id}
                </div>
              </div>
            </motion.button>
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
          <motion.div 
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="card"
          >
            <div className="card-header">
              <div className="card-title">{selected.id} Detail</div>
              <button onClick={() => setSelectedId(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-secondary)', fontSize: '16px' }}>✕</button>
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
          </motion.div>
        )}

        {/* All Units */}
        <div className="card" style={{ flex: 1 }}>
          <div className="card-header"><div className="card-title">All Units</div></div>
          <div>
            {activeUnits.length === 0 && (
              <div style={{ padding: '30px 20px', textAlign: 'center', color: 'var(--text-dim)', fontSize: '11px' }}>
                No active units responding.
              </div>
            )}
            {activeUnits.map(u => (
              <div key={u.id} onClick={() => setSelectedId(selected?.id === u.id ? null : u.id)}
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
