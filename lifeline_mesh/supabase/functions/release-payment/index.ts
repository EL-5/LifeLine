import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { emergency_id, payment_type, recipient_id, amount } = await req.json()

    // Verify emergency status requires payment release
    const { data: emergency } = await supabase
      .from('emergencies')
      .select('status, raised_amount')
      .eq('id', emergency_id)
      .single()

    if (!emergency) {
      throw new Error('Emergency not found')
    }

    // Verify sufficient funds
    if (emergency.raised_amount < amount) {
      throw new Error('Insufficient funds')
    }

    // Create payment record
    const { data: payment, error } = await supabase
      .from('payments')
      .insert({
        emergency_id,
        payment_type,
        amount,
        recipient_id,
        status: 'completed',
        released_at: new Date().toISOString(),
        moolre_reference: `MOOLRE-${Date.now()}`,
      })
      .select()
      .single()

    if (error) throw error

    // Log the payment release
    await supabase.from('audit_logs').insert({
      actor_id: recipient_id,
      action: 'payment_released',
      resource_type: 'payment',
      resource_id: payment.id,
      metadata: { emergency_id, payment_type, amount },
    })

    return new Response(
      JSON.stringify({ success: true, payment }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})