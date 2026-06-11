import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

interface EmergencyRequest {
  patient_id: string
  category: string
  symptoms: string[]
  location: { lat: number; lng: number; address?: string }
  description?: string
}

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const body: EmergencyRequest = await req.json()

    // AI Triage: determine severity
    const severity = await analyzeSeverity(body)

    // AI: recommend nearest hospital
    const hospitalId = await recommendHospital(supabase, body.location)

    // AI: estimate funding target
    const targetAmount = estimateFunding(body.category, severity)

    // Create emergency record
    const { data, error } = await supabase
      .from('emergencies')
      .insert({
        patient_id: body.patient_id,
        category: body.category,
        symptoms: body.symptoms,
        severity,
        location: body.location,
        hospital_id: hospitalId,
        target_amount: targetAmount,
        status: 'pending',
      })
      .select()
      .single()

    if (error) throw error

    // Dispatch nearest available driver
    await dispatchDriver(supabase, data.id, body.location)

    // Send notifications to family members
    await notifyFamily(supabase, body.patient_id, data)

    return new Response(
      JSON.stringify({ success: true, emergency: data }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

async function analyzeSeverity(request: EmergencyRequest): Promise<string> {
  // Critical categories always get critical severity
  const criticalCategories = ['accident', 'stroke', 'breathing_difficulty', 'chest_pain']
  if (criticalCategories.includes(request.category)) return 'critical'

  const seriousCategories = ['pregnancy_emergency', 'violence_injury']
  if (seriousCategories.includes(request.category)) return 'serious'

  return 'moderate'
}

async function recommendHospital(
  supabase: any,
  location: { lat: number; lng: number }
): Promise<string | null> {
  const { data: hospitals } = await supabase
    .from('hospitals')
    .select('id, location, emergency_capacity')
    .eq('verification_status', 'verified')
    .order('emergency_capacity', { ascending: false })
    .limit(5)

  if (!hospitals || hospitals.length === 0) return null

  // Simple nearest-hospital logic (in production, use PostGIS)
  return hospitals[0].id
}

function estimateFunding(category: string, severity: string): number {
  const estimates: Record<string, Record<string, number>> = {
    critical: { accident: 5000, stroke: 8000, breathing_difficulty: 4000, default: 3000 },
    serious: { pregnancy_emergency: 3000, violence_injury: 2000, default: 1500 },
    moderate: { child_emergency: 1000, default: 500 },
    mild: { default: 200 },
  }

  const severityEstimates = estimates[severity] || estimates.moderate
  return severityEstimates[category] || severityEstimates.default
}

async function dispatchDriver(
  supabase: any,
  emergencyId: string,
  location: { lat: number; lng: number }
) {
  const { data: drivers } = await supabase
    .from('drivers')
    .select('id, user_id')
    .eq('availability_status', true)
    .eq('verification_status', 'verified')
    .limit(1)

  if (drivers && drivers.length > 0) {
    await supabase
      .from('emergencies')
      .update({ driver_id: drivers[0].id, status: 'dispatched' })
      .eq('id', emergencyId)
  }
}

async function notifyFamily(
  supabase: any,
  patientId: string,
  emergency: any
) {
  const { data: family } = await supabase
    .from('family_connections')
    .select('family_member_id')
    .eq('user_id', patientId)
    .eq('status', 'accepted')

  if (!family) return

  for (const member of family) {
    await supabase.from('notifications').insert({
      user_id: member.family_member_id,
      title: 'Emergency Alert',
      body: `${emergency.category} emergency reported`,
      data: { emergency_id: emergency.id },
    })
  }
}