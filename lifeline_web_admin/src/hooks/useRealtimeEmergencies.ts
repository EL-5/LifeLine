import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

export type Emergency = {
  id: string;
  patient_id: string;
  category: string;
  symptoms: string[];
  severity: string;
  location: { lat: number; lng: number; address: string };
  status: string;
  created_at: string;
  patient_name?: string;
  patient_phone?: string;
  driver_id?: string;
  driver_name?: string;
  target_amount: number;
  raised_amount: number;
  patient_confirmed_pickup?: boolean;
  patient_confirmed_dropoff?: boolean;
  hospital_confirmed_arrival?: boolean;
};

export function useRealtimeEmergencies() {
  const [emergencies, setEmergencies] = useState<Emergency[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;

    async function fetchInitial() {
      // Fetch emergencies
      const { data: ems, error } = await supabase
        .from('emergencies')
        .select(`
          *,
          users!emergencies_patient_id_fkey(full_name, phone)
        `)
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching emergencies:', error);
        return;
      }

      // Format the data
      const formatted = ems.map((em: any) => ({
        ...em,
        patient_name: em.users?.full_name || 'Unknown Patient',
        patient_phone: em.users?.phone,
      }));

      if (mounted) {
        setEmergencies(formatted);
        setLoading(false);
      }
    }

    fetchInitial();

    // Subscribe to realtime changes
    const channel = supabase
      .channel('public:emergencies')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'emergencies' },
        async (payload) => {
          // If insert or update, fetch the related user data
          if (payload.eventType === 'INSERT' || payload.eventType === 'UPDATE') {
            const newRecord = payload.new as any;
            
            // Fetch patient info
            const { data: userData } = await supabase
              .from('users')
              .select('full_name, phone')
              .eq('id', newRecord.patient_id)
              .single();

            const enriched = {
              ...newRecord,
              patient_name: userData?.full_name || 'Unknown Patient',
              patient_phone: userData?.phone,
            };

            setEmergencies((prev) => {
              if (payload.eventType === 'INSERT') {
                return [enriched, ...prev];
              } else {
                return prev.map(e => e.id === enriched.id ? enriched : e);
              }
            });
          } else if (payload.eventType === 'DELETE') {
            setEmergencies((prev) => prev.filter(e => e.id !== payload.old.id));
          }
        }
      )
      .subscribe();

    return () => {
      mounted = false;
      supabase.removeChannel(channel);
    };
  }, []);

  return { emergencies, loading };
}
