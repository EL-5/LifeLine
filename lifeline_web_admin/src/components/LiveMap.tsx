import React from 'react';

const LiveMap: React.FC = () => {
  return (
    <div className="tracking-map-container" style={{ height: '100%' }}>
      <div className="map-overlay-label">
        <h4>Global Dispatch Grid</h4>
        <p>Real-time unit tracking</p>
      </div>

      <div className="radar-container">
        <div className="radar">
          {/* Rings */}
          <div className="radar-ring" />
          <div className="radar-ring" />
          <div className="radar-ring" />
          <div className="radar-ring" />

          {/* Crosshair lines */}
          <div className="radar-crosshair" />

          {/* Sweep */}
          <div className="radar-sweep">
            <div className="radar-sweep-gradient" />
          </div>

          {/* Hospital center */}
          <div className="hospital-marker">H</div>

          {/* Unit blips */}
          <div className="radar-blip green" style={{ top: '28%', left: '62%' }} title="Unit 01 — En Route" />
          <div className="radar-blip amber" style={{ top: '68%', left: '38%' }} title="Unit 02 — Standby" />
          <div className="radar-blip red" style={{ top: '22%', left: '35%' }} title="Unit 03 — Critical" />
          <div className="radar-blip blue" style={{ top: '58%', left: '72%' }} title="Unit 04 — Available" />
        </div>
      </div>

      {/* Legend */}
      <div style={{
        position: 'absolute',
        bottom: '16px',
        left: '16px',
        display: 'flex',
        flexDirection: 'column',
        gap: '6px',
        background: 'rgba(13, 17, 23, 0.85)',
        backdropFilter: 'blur(12px)',
        border: '1px solid var(--border-bright)',
        borderRadius: '8px',
        padding: '10px 14px',
      }}>
        {[
          { color: 'var(--accent-green)', label: 'En Route' },
          { color: 'var(--accent-amber)', label: 'Standby' },
          { color: 'var(--accent-red)', label: 'Critical' },
          { color: 'var(--accent-blue)', label: 'Available' },
        ].map(({ color, label }) => (
          <div key={label} style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: color, boxShadow: `0 0 6px ${color}` }} />
            <span style={{ fontSize: '10px', color: 'var(--text-secondary)', fontWeight: 500 }}>{label}</span>
          </div>
        ))}
      </div>

      {/* Coords overlay */}
      <div style={{
        position: 'absolute',
        bottom: '16px',
        right: '16px',
        fontFamily: '"JetBrains Mono", monospace',
        fontSize: '10px',
        color: 'var(--text-dim)',
        lineHeight: '1.8',
        textAlign: 'right',
      }}>
        <div>LAT: 5.6037°N</div>
        <div>LON: 0.1870°W</div>
        <div style={{ color: 'var(--accent-blue)', fontWeight: 600, marginTop: '4px' }}>ACCRA CENTRAL</div>
      </div>
    </div>
  );
};

export default LiveMap;
