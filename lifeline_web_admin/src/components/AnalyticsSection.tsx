import React from 'react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const data = [
  { name: 'Mon', emergencies: 18, prev: 10 },
  { name: 'Tue', emergencies: 32, prev: 20 },
  { name: 'Wed', emergencies: 25, prev: 18 },
  { name: 'Thu', emergencies: 40, prev: 28 },
  { name: 'Fri', emergencies: 28, prev: 22 },
  { name: 'Sat', emergencies: 15, prev: 10 },
  { name: 'Sun', emergencies: 34, prev: 20 },
];

const AnalyticsSection: React.FC = () => {
  return (
    <div>
      <div className="chart-legend" style={{ display: 'flex', gap: '16px', marginBottom: '16px' }}>
        <div className="legend-item" style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '11px', color: 'var(--text-secondary)' }}>
          <div className="legend-dot" style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#6366F1' }} />
          New Emergencies
        </div>
        <div className="legend-item" style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '11px', color: 'var(--text-secondary)' }}>
          <div className="legend-dot" style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#E0E7FF' }} />
          Previous Period
        </div>
      </div>

      <div style={{ height: '160px', width: '100%' }}>
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ top: 10, right: 0, left: -20, bottom: 0 }}>
            <defs>
              <linearGradient id="colorNew" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#6366F1" stopOpacity={0.3}/>
                <stop offset="95%" stopColor="#6366F1" stopOpacity={0}/>
              </linearGradient>
              <linearGradient id="colorPrev" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#94A3B8" stopOpacity={0.2}/>
                <stop offset="95%" stopColor="#94A3B8" stopOpacity={0}/>
              </linearGradient>
            </defs>
            <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 10, fill: 'var(--text-dim)' }} dy={10} />
            <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 10, fill: 'var(--text-dim)' }} />
            <Tooltip 
              contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: 'var(--shadow-md)', fontSize: '12px', fontWeight: 600 }}
              itemStyle={{ fontSize: '11px' }}
            />
            <Area type="monotone" dataKey="prev" stroke="#CBD5E1" strokeWidth={2} fillOpacity={1} fill="url(#colorPrev)" />
            <Area type="monotone" dataKey="emergencies" stroke="#6366F1" strokeWidth={3} fillOpacity={1} fill="url(#colorNew)" activeDot={{ r: 6, strokeWidth: 0, fill: '#6366F1' }} />
          </AreaChart>
        </ResponsiveContainer>
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
