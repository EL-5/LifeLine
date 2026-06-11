import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { emergency_id } = await req.json()

    // Get emergency details
    const { data: emergency } = await supabase
      .from('emergencies')
      .select('*, patient:patient_id(*)')
      .eq('id', emergency_id)
      .single()

    if (!emergency) {
      return new Response(JSON.stringify({ flagged: false }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    let fraudScore = 0
    const reasons: string[] = []

    // Check 1: Multiple emergencies from same patient recently
    const { data: recentEmergencies } = await supabase
      .from('emergencies')
      .select('id')
      .eq('patient_id', emergency.patient_id)
      .gte('created_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())

    if (recentEmergencies && recentEmergencies.length > 3) {
      fraudScore += 30
      reasons.push('Multiple emergencies in 24 hours')
    }

    // Check 2: Location anomalies
    if (emergency.location && emergency.patient?.location) {
      const dist = calculateDistance(
        emergency.location.lat,
        emergency.location.lng,
        emergency.patient.location?.lat,
        emergency.patient.location?.lng
      )
      if (dist > 100) {
        fraudScore += 20
        reasons.push('Location mismatch with user profile')
      }
    }

    // Check 3: Unverified user
    if (emergency.patient?.verification_status !== 'verified') {
      fraudScore += 15
      reasons.push('Unverified patient')
    }

    const flagged = fraudScore >= 30

    // Update emergency if flagged
    if (flagged) {
      await supabase
        .from('emergencies')
        .update({ fraud_flag: true, status: 'flagged' })
        .eq('id', emergency_id)

      // Create trust event
      await supabase.from('trust_events').insert({
        emergency_id,
        validator_id: emergency.patient_id,
        validation_type: 'ai',
        status: 'pending',
        notes: reasons.join('; '),
      })
    }

    return new Response(
      JSON.stringify({ flagged, score: fraudScore, reasons }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

function calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371 // km
  const dLat = ((lat2 - lat1) * Math.PI) / 180
  const dLng = ((lng2 - lng1) * Math.PI) / 180
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
}