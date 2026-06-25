import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

interface FundingItem {
  id: string;
  category: string;
  raised_amount: number;
  target_amount: number;
  patient_id: string;
}

const FundingPanel: React.FC = () => {
  const [items, setItems] = useState<FundingItem[]>([]);

  useEffect(() => {
    const fetch = async () => {
      const { data } = await supabase
        .from('emergencies')
        .select('id, category, raised_amount, target_amount, patient_id')
        .neq('status', 'completed')
        .gt('target_amount', 0)
        .order('created_at', { ascending: false })
        .limit(3);
      if (data) setItems(data as FundingItem[]);
    };
    fetch();
    const sub = supabase
      .channel('funding-panel')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'emergencies' }, fetch)
      .subscribe();
    return () => { supabase.removeChannel(sub); };
  }, []);

  if (items.length === 0) {
    return (
      <div style={{ padding: '24px 20px', textAlign: 'center', color: 'var(--text-dim)', fontSize: '12px' }}>
        No active funding goals.
      </div>
    );
  }

  return (
    <div>
      {items.map(item => {
        const pct = item.target_amount > 0 ? Math.min((item.raised_amount / item.target_amount) * 100, 100) : 0;
        const barClass = pct >= 75 ? 'green' : pct >= 40 ? 'amber' : 'red';
        return (
          <div className="funding-item" key={item.id}>
            <div className="funding-top">
              <div>
                <div className="funding-category">{item.category.replace(/_/g, ' ')}</div>
                <div className="funding-patient">Patient #{item.patient_id.slice(-4).toUpperCase()}</div>
              </div>
              <div>
                <div className="funding-amount">GHS {item.raised_amount}</div>
                <div className="funding-goal-text">of GHS {item.target_amount}</div>
              </div>
            </div>
            <div className="progress-track">
              <div className={`progress-bar ${barClass}`} style={{ width: `${pct}%` }} />
            </div>
            <div className="funding-pct">{pct.toFixed(0)}% funded</div>
          </div>
        );
      })}
    </div>
  );
};

export default FundingPanel;
