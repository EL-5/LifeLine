import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import EmergencyTable from './EmergencyTable';
import AnalyticsSection from './AnalyticsSection';
import FundingPanel from './FundingPanel';
import UnitsPanel from './UnitsPanel';
import IncidentsView from '../views/IncidentsView';
import PatientsView from '../views/PatientsView';
import VitalsView from '../views/VitalsView';
import DispatchMapView from '../views/DispatchMapView';
import StaffView from '../views/StaffView';
import ReportsView from '../views/ReportsView';
import SettingsView from '../views/SettingsView';
import { useRealtimeEmergencies } from '../hooks/useRealtimeEmergencies';

/* ========= TYPES ========= */
type NavKey = 'Dashboard' | 'Incidents' | 'Patients' | 'Vitals Monitor' | 'Dispatch Map' | 'Staff' | 'Reports' | 'Settings';

/* ========= SIDEBAR NAV CONFIG ========= */
const NAV: { icon: string; label: NavKey; badge?: string }[] = [
  { icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6', label: 'Dashboard' },
  { icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2', label: 'Incidents' },
  { icon: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7-7h14a7 7 0 00-7-7z', label: 'Patients' },
  { icon: 'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z', label: 'Vitals Monitor' },
  { icon: 'M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z', label: 'Dispatch Map' },
];
const NAV2: { icon: string; label: NavKey }[] = [
  { icon: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z', label: 'Staff' },
  { icon: 'M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z', label: 'Reports' },
  { icon: 'M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4', label: 'Settings' },
];

/* ========= PAGE TITLES ========= */
const PAGE_META: Record<NavKey, { title: string; subtitle: string }> = {
  'Dashboard': { title: 'Welcome back, Dr. Mensah', subtitle: 'Here is what is happening today.' },
  'Incidents': { title: 'All Incidents', subtitle: 'Full history of emergency incidents' },
  'Patients': { title: 'Patient Registry', subtitle: 'All registered patients in the system' },
  'Vitals Monitor': { title: 'Vitals Monitor', subtitle: 'Live vitals for all inbound patients' },
  'Dispatch Map': { title: 'Dispatch Map', subtitle: 'Real-time unit tracking across the network' },
  'Staff': { title: 'Staff Management', subtitle: 'Active staff roster and shift assignments' },
  'Reports': { title: 'Reports & Analytics', subtitle: 'Performance insights and generated reports' },
  'Settings': { title: 'System Settings', subtitle: 'Hospital configuration and preferences' },
};

/* ========= ICON HELPER ========= */
function Svg({ path, size = 15 }: { path: string; size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d={path} />
    </svg>
  );
}

/* ========= DASHBOARD HOME VIEW ========= */
const DashboardHome: React.FC = () => {
  const { emergencies } = useRealtimeEmergencies();

  const activeCount = emergencies.filter(e => !['completed', 'cancelled'].includes(e.status)).length;
  const resolvedCount = emergencies.filter(e => e.status === 'completed').length;
  const dispatchedCount = emergencies.filter(e => e.driver_id).length;
  const communityFunds = emergencies.reduce((acc, e) => acc + (e.raised_amount || 0), 0);

  const STAT_CARDS = [
    { label: 'Active Emergencies', value: activeCount.toString(), change: '', dir: 'up', color: '#EF4444', bg: 'rgba(239,68,68,0.1)', icon: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z', spark: '0,40 15,35 30,42 45,28 60,32 75,20 90,26 100,15' },
    { label: 'Units Dispatched', value: dispatchedCount.toString(), change: '', dir: 'up', color: '#3B82F6', bg: 'rgba(59,130,246,0.1)', icon: 'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z', spark: '0,30 15,25 30,35 45,20 60,28 75,15 90,22 100,18' },
    { label: 'Community Funds', value: `GHS ${communityFunds.toFixed(0)}`, change: '', dir: 'up', color: '#10B981', bg: 'rgba(16,185,129,0.1)', icon: 'M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z', spark: '0,45 20,38 40,42 60,30 80,35 100,28' },
    { label: 'Resolved', value: resolvedCount.toString(), change: '', dir: 'up', color: '#8B5CF6', bg: 'rgba(139,92,246,0.1)', icon: 'M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z', spark: '0,35 20,28 40,32 55,20 70,24 85,15 100,18' },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Stat Cards */}
      <div className="stat-cards">
        {STAT_CARDS.map((card, i) => (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1, duration: 0.5, ease: "easeOut" }}
            className="stat-card" 
            key={card.label}
          >
            <div className="stat-card-icon" style={{ background: card.bg }}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={card.color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d={card.icon} />
              </svg>
            </div>
            <div className="stat-card-content">
              <div className="stat-card-label">{card.label}</div>
              <motion.div 
                initial={{ opacity: 0, scale: 0.5 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.2 + (i * 0.1), type: 'spring' }}
                className="stat-card-value" 
                style={{ color: card.color }}
              >
                {card.value}
              </motion.div>
              {card.change && (
                <div className={`stat-card-change ${card.dir}`}>
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                    <path d={card.dir === 'up' ? 'M5 15l7-7 7 7' : 'M19 9l-7 7-7-7'} />
                  </svg>
                  {card.change} from yesterday
                </div>
              )}
            </div>
            <svg className="stat-card-sparkline" viewBox="0 0 100 50" preserveAspectRatio="none" style={{ stroke: card.color, fill: 'none', strokeWidth: 2 }}>
              <polyline points={card.spark} />
            </svg>
          </motion.div>
        ))}
      </div>

      {/* Emergency Table + Vitals/Map */}
      <div className="content-grid-3">
        <motion.div 
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="card"
        >
          <div className="card-header">
            <div>
              <div className="card-title">Active Emergencies</div>
              <div className="card-subtitle">All incoming cases routed to this facility</div>
            </div>
            <button className="card-header-action">View All</button>
          </div>
          <div className="card-body">
            <EmergencyTable emergencies={emergencies} />
          </div>
        </motion.div>

        <motion.div 
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}
        >
          <div className="card" style={{ flex: 'none' }}>
            <div className="card-header">
              <div className="card-title">Inbound Patient Vitals</div>
              <span style={{ fontSize: '10px', fontWeight: 700, color: '#EF4444', background: 'rgba(239,68,68,0.1)', padding: '2px 8px', borderRadius: '6px' }}>● CRITICAL</span>
            </div>
            <div className="vitals-grid">
              {[
                { name: 'Heart Rate', value: '122', unit: 'bpm', status: 'warn', label: 'Elevated' },
                { name: 'SpO₂', value: '94', unit: '%', status: 'warn', label: 'Low-Normal' },
                { name: 'Resp Rate', value: '24', unit: '/min', status: 'crit', label: 'Tachypnea' },
                { name: 'Sys. BP', value: '158', unit: 'mmHg', status: 'warn', label: 'Hypertensive' },
              ].map(v => (
                <div className="vital-cell" key={v.name}>
                  <div className="vital-name">{v.name}</div>
                  <div className="vital-reading">
                    <span className="vital-value" style={{ color: v.status === 'crit' ? '#EF4444' : v.status === 'warn' ? '#F59E0B' : '#10B981' }}>{v.value}</span>
                    <span className="vital-unit">{v.unit}</span>
                  </div>
                  <div className={`vital-status ${v.status}`}>{v.label}</div>
                </div>
              ))}
            </div>
          </div>

          <div className="card" style={{ flex: 'none' }}>
            <div className="card-header">
              <div className="card-title">Dispatch Radar</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
                <div style={{ width: '6px', height: '6px', borderRadius: '50%', background: '#6366F1', animation: 'pulse-dot 1.5s infinite' }} />
                <span style={{ fontSize: '10px', fontWeight: 600, color: '#6366F1' }}>Streaming</span>
              </div>
            </div>
            <div className="radar-wrap" style={{ height: '180px' }}>
              <div className="radar">
                <div className="radar-ring" /><div className="radar-ring" /><div className="radar-ring" /><div className="radar-ring" />
                <div className="radar-lines" />
                <div className="radar-sweep"><div className="radar-sweep-inner" /></div>
                <div className="radar-center">H</div>
                {[{ top: '28%', left: '65%', cls: 'green' }, { top: '70%', left: '35%', cls: 'amber' }, { top: '25%', left: '30%', cls: 'red' }].map((b, i) => (
                  <div key={i} className={`radar-blip ${b.cls}`} style={{ top: b.top, left: b.left }}>
                    <div className="radar-blip-dot" /><div className="radar-blip-ring" />
                  </div>
                ))}
              </div>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Analytics + Units + Funding */}
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.4 }}
        className="content-grid"
      >
        <div className="card">
          <div className="card-header">
            <div>
              <div className="card-title">Patient Flow Analytics</div>
              <div className="card-subtitle">Emergency volume over the last 7 days</div>
            </div>
            <button className="card-header-action">Export</button>
          </div>
          <div className="card-body" style={{ padding: '16px 20px' }}><AnalyticsSection /></div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <div className="card">
            <div className="card-header"><div className="card-title">Active Units</div><span className="card-header-action">Track All</span></div>
            <div className="card-body"><UnitsPanel /></div>
          </div>
          <div className="card">
            <div className="card-header"><div className="card-title">Community Funding</div><span className="card-header-action">View All</span></div>
            <div className="card-body"><FundingPanel /></div>
          </div>
        </div>
      </motion.div>
    </div>
  );
};

/* ========= MAIN DASHBOARD SHELL ========= */
const Dashboard: React.FC = () => {
  const [time, setTime] = useState(new Date());
  const [activeNav, setActiveNav] = useState<NavKey>('Dashboard');

  useEffect(() => {
    const t = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(t);
  }, []);

  const meta = PAGE_META[activeNav];
  const dateStr = time.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
  const timeStr = time.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false });

  const renderView = () => {
    switch (activeNav) {
      case 'Dashboard':     return <DashboardHome />;
      case 'Incidents':     return <IncidentsView />;
      case 'Patients':      return <PatientsView />;
      case 'Vitals Monitor': return <VitalsView />;
      case 'Dispatch Map':  return <DispatchMapView />;
      case 'Staff':         return <StaffView />;
      case 'Reports':       return <ReportsView />;
      case 'Settings':      return <SettingsView />;
    }
  };

  return (
    <div className="app">
      {/* ===== SIDEBAR ===== */}
      <aside className="sidebar">
        <div className="sidebar-logo">
          <div className="sidebar-logo-mark">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              <path d="M9 12h6M12 9v6" />
            </svg>
          </div>
          <div>
            <div className="sidebar-app-name">Lifeline Mesh</div>
            <div className="sidebar-app-sub">Hospital Command</div>
          </div>
        </div>

        <div className="sidebar-scroll">
          <div className="sidebar-section">
            <div className="sidebar-section-label">Main</div>
            {NAV.map(item => (
              <button key={item.label} className={`sidebar-item ${activeNav === item.label ? 'active' : ''}`} onClick={() => setActiveNav(item.label)}>
                <Svg path={item.icon} />
                {item.label}
                {item.badge && <span className="sidebar-badge">{item.badge}</span>}
              </button>
            ))}
          </div>
          <div className="sidebar-section">
            <div className="sidebar-section-label">Management</div>
            {NAV2.map(item => (
              <button key={item.label} className={`sidebar-item ${activeNav === item.label ? 'active' : ''}`} onClick={() => setActiveNav(item.label)}>
                <Svg path={item.icon} />
                {item.label}
              </button>
            ))}
          </div>
        </div>

        <div className="sidebar-footer">
          <div className="sidebar-user">
            <div className="sidebar-avatar">DM</div>
            <div>
              <div className="sidebar-user-name">Dr. Mensah</div>
              <div className="sidebar-user-role">Head of Emergency</div>
            </div>
          </div>
        </div>
      </aside>

      {/* ===== MAIN ===== */}
      <div className="main">
        {/* Topbar */}
        <header className="topbar">
          <div className="topbar-greeting">
            <h1>{meta.title}</h1>
            <p>{meta.subtitle}</p>
          </div>
          <div className="topbar-status-pill">
            <div className="live-dot" />
            All Systems Live
          </div>
          <div className="topbar-date">{dateStr} · {timeStr}</div>
          <div className="topbar-search">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="8" /><path d="m21 21-4.35-4.35" /></svg>
            <input type="text" placeholder="Search patient, unit, incident..." />
          </div>
          <div style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
            <button className="topbar-icon-btn">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>
              <div className="topbar-notif-dot" />
            </button>
            <button className="topbar-icon-btn" onClick={() => setActiveNav('Settings')}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" /><circle cx="12" cy="12" r="3" /></svg>
            </button>
            <div className="topbar-user-avatar">DM</div>
          </div>
        </header>

        {/* ===== PAGE BODY ===== */}
        <div className="dashboard-body">
          <motion.div
            key={activeNav}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.2 }}
            style={{ display: 'flex', flexDirection: 'column', flex: 1 }}
          >
            {renderView()}
          </motion.div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
