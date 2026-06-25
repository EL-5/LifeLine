import React, { useState } from 'react';

const SECTIONS = [
  {
    title: 'Hospital Information',
    fields: [
      { label: 'Hospital Name', value: 'Korle Bu Teaching Hospital', type: 'text' },
      { label: 'Facility Code', value: 'KBTH-ACC-001', type: 'text' },
      { label: 'Emergency Contact', value: '+233 302 674 323', type: 'text' },
      { label: 'Address', value: 'Guggisberg Avenue, Accra, Ghana', type: 'text' },
      { label: 'Capacity (Beds)', value: '2000', type: 'number' },
    ],
  },
  {
    title: 'Notification Settings',
    fields: [
      { label: 'Alert Sound', value: 'Medical Alarm', type: 'select', options: ['Medical Alarm', 'Urgent Beep', 'Siren', 'Bell'] },
      { label: 'Alert Volume', value: '80', type: 'range' },
      { label: 'Email Alerts', value: 'enabled', type: 'toggle' },
      { label: 'SMS Alerts', value: 'enabled', type: 'toggle' },
      { label: 'Push Notifications', value: 'enabled', type: 'toggle' },
    ],
  },
  {
    title: 'Dispatch Configuration',
    fields: [
      { label: 'Auto-Dispatch', value: 'enabled', type: 'toggle' },
      { label: 'Response Time Target', value: '10', type: 'number', suffix: 'minutes' },
      { label: 'Max Units Per Emergency', value: '2', type: 'number' },
      { label: 'Default Funding Target', value: '500', type: 'number', suffix: 'GHS' },
    ],
  },
];

const SettingsView: React.FC = () => {
  const [values, setValues] = useState<Record<string, string>>(() => {
    const init: Record<string, string> = {};
    SECTIONS.forEach(s => s.fields.forEach(f => { init[f.label] = f.value; }));
    return init;
  });

  const toggleValue = (key: string) => setValues(v => ({ ...v, [key]: v[key] === 'enabled' ? 'disabled' : 'enabled' }));

  return (
    <div style={{ display: 'flex', gap: '16px', height: '100%' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '16px', overflow: 'auto', maxWidth: '700px' }}>
        {SECTIONS.map(section => (
          <div className="card" key={section.title}>
            <div className="card-header">
              <div className="card-title">{section.title}</div>
            </div>
            <div style={{ padding: '8px 0' }}>
              {section.fields.map(field => (
                <div key={field.label} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 20px', borderBottom: '1px solid var(--border)' }}>
                  <div>
                    <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-primary)' }}>{field.label}</div>
                  </div>
                  <div>
                    {field.type === 'toggle' && (
                      <button
                        onClick={() => toggleValue(field.label)}
                        style={{
                          width: '44px', height: '24px', borderRadius: '12px', border: 'none', cursor: 'pointer',
                          background: values[field.label] === 'enabled' ? '#6366F1' : '#D1D5DB',
                          position: 'relative', transition: 'background 0.2s',
                        }}
                      >
                        <div style={{
                          position: 'absolute', top: '3px', width: '18px', height: '18px', borderRadius: '50%', background: 'white',
                          boxShadow: '0 1px 3px rgba(0,0,0,0.2)',
                          left: values[field.label] === 'enabled' ? '23px' : '3px',
                          transition: 'left 0.2s',
                        }} />
                      </button>
                    )}
                    {field.type === 'text' && (
                      <input defaultValue={field.value} style={{ padding: '7px 12px', borderRadius: '7px', border: '1px solid var(--border)', fontSize: '12px', color: 'var(--text-primary)', outline: 'none', width: '220px', background: 'var(--bg)' }} onFocus={e => e.target.style.borderColor = '#6366F1'} onBlur={e => e.target.style.borderColor = 'var(--border)'} />
                    )}
                    {field.type === 'number' && (
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <input type="number" defaultValue={field.value} style={{ padding: '7px 12px', borderRadius: '7px', border: '1px solid var(--border)', fontSize: '12px', color: 'var(--text-primary)', outline: 'none', width: '100px', background: 'var(--bg)', textAlign: 'right' }} />
                        {(field as any).suffix && <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>{(field as any).suffix}</span>}
                      </div>
                    )}
                    {field.type === 'select' && (
                      <select defaultValue={field.value} style={{ padding: '7px 12px', borderRadius: '7px', border: '1px solid var(--border)', fontSize: '12px', color: 'var(--text-primary)', outline: 'none', background: 'var(--bg)', cursor: 'pointer' }}>
                        {(field as any).options?.map((o: string) => <option key={o}>{o}</option>)}
                      </select>
                    )}
                    {field.type === 'range' && (
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        <input type="range" min="0" max="100" defaultValue={field.value} style={{ width: '140px', accentColor: '#6366F1' }} />
                        <span style={{ fontFamily: '"JetBrains Mono", monospace', fontSize: '12px', color: 'var(--text-secondary)', width: '30px' }}>{field.value}%</span>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}

        <div style={{ display: 'flex', gap: '8px', paddingBottom: '20px' }}>
          <button style={{ padding: '10px 24px', borderRadius: '8px', border: 'none', background: '#6366F1', color: 'white', fontSize: '13px', fontWeight: 600, cursor: 'pointer' }}>Save Changes</button>
          <button style={{ padding: '10px 24px', borderRadius: '8px', border: '1px solid var(--border)', background: 'white', color: 'var(--text-secondary)', fontSize: '13px', fontWeight: 600, cursor: 'pointer' }}>Reset to Defaults</button>
        </div>
      </div>

      {/* Info sidebar */}
      <div style={{ width: '240px', flexShrink: 0 }}>
        <div className="card">
          <div className="card-header"><div className="card-title">System Info</div></div>
          <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {[
              { label: 'App Version', value: '2.1.0', color: '#6366F1' },
              { label: 'Database', value: 'Supabase Prod', color: '#10B981' },
              { label: 'Uptime', value: '99.98%', color: '#10B981' },
              { label: 'Last Backup', value: '2h ago', color: 'var(--text-secondary)' },
              { label: 'Active Sessions', value: '3', color: 'var(--text-primary)' },
            ].map(f => (
              <div key={f.label} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{f.label}</span>
                <span style={{ fontSize: '12px', fontWeight: 700, color: f.color, fontFamily: '"JetBrains Mono", monospace' }}>{f.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default SettingsView;
