import React from 'react';

const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const NEW = [18, 32, 25, 40, 28, 15, 34];
const OLD = [10, 20, 18, 28, 22, 10, 20];
const MAX = 50;

const AnalyticsSection: React.FC = () => {
  return (
    <div>
      <div className="chart-legend">
        <div className="legend-item">
          <div className="legend-dot" style={{ background: '#6366F1' }} />
          New Emergencies
        </div>
        <div className="legend-item">
          <div className="legend-dot" style={{ background: '#E0E7FF' }} />
          Previous Period
        </div>
      </div>

      <div style={{ display: 'flex', alignItems: 'flex-end', gap: '10px', height: '120px', paddingBottom: '24px', position: 'relative' }}>
        {/* Y-axis lines */}
        {[0, 25, 50].map(v => (
          <div key={v} style={{
            position: 'absolute',
            left: 0,
            right: 0,
            bottom: `${(v / MAX) * 96 + 24}px`,
            borderTop: '1px dashed var(--border)',
            display: 'flex',
            alignItems: 'center',
          }}>
            <span style={{ fontSize: '9px', color: 'var(--text-dim)', position: 'absolute', left: 0, top: '-8px' }}>{v}</span>
          </div>
        ))}

        {DAYS.map((day, i) => (
          <div key={day} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '3px' }}>
            <div style={{ display: 'flex', gap: '3px', alignItems: 'flex-end', width: '100%' }}>
              {/* Old bar */}
              <div
                style={{
                  flex: 1,
                  height: `${(OLD[i] / MAX) * 96}px`,
                  background: '#E0E7FF',
                  borderRadius: '3px 3px 0 0',
                  transition: 'height 0.8s ease',
                  minHeight: '4px',
                }}
              />
              {/* New bar */}
              <div
                style={{
                  flex: 1,
                  height: `${(NEW[i] / MAX) * 96}px`,
                  background: 'linear-gradient(180deg, #818CF8, #6366F1)',
                  borderRadius: '3px 3px 0 0',
                  transition: 'height 0.8s ease',
                  minHeight: '4px',
                  boxShadow: '0 2px 8px rgba(99,102,241,0.3)',
                }}
              />
            </div>
            <span style={{ fontSize: '9px', color: 'var(--text-dim)', marginTop: '4px' }}>{day}</span>
          </div>
        ))}
      </div>

      <div style={{ display: 'flex', gap: '20px', marginTop: '12px', paddingTop: '12px', borderTop: '1px solid var(--border)' }}>
        {[
          { label: 'Total This Week', value: '192', color: '#6366F1' },
          { label: 'Avg Daily', value: '27', color: '#10B981' },
          { label: 'Peak Day', value: 'Thu (40)', color: '#F59E0B' },
          { label: 'Resolution Rate', value: '94%', color: '#3B82F6' },
        ].map(s => (
          <div key={s.label} style={{ flex: 1 }}>
            <div style={{ fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', color: 'var(--text-dim)', marginBottom: '4px' }}>{s.label}</div>
            <div style={{ fontSize: '18px', fontWeight: 800, color: s.color, fontFamily: '"JetBrains Mono", monospace' }}>{s.value}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default AnalyticsSection;
