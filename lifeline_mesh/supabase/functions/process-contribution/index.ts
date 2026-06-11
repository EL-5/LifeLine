import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

interface ContributionRequest {
  emergency_id: string
  contributor_id: string
  amount: number
  payment_method: string
}

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const body: ContributionRequest = await req.json()

    // Create contribution record
    const { data: contribution, error } = await supabase
      .from('contributions')
      .insert({
        emergency_id: body.emergency_id,
        contributor_id: body.contributor_id,
        amount: body.amount,
        payment_method: body.payment_method,
        payment_status: 'processing',
      })
      .select()
      .single()

    if (error) throw error

    // Process payment via Moolre API (placeholder)
    const moolreRef = await processMoolrePayment(body)

    // Update contribution status
    await supabase
      .from('contributions')
      .update({
        payment_status: 'completed',
        moolre_transaction_id: moolreRef,
      })
      .eq('id', contribution.id)

    // Update emergency raised_amount is handled by DB trigger

    return new Response(
      JSON.stringify({ success: true, contribution_id: contribution.id, reference: moolreRef }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

async function processMoolrePayment(body: ContributionRequest): Promise<string> {
  // Placeholder for Moolre API integration
  // In production: call Moolre payment API with body.amount, body.contributor_id
  return `MOOLRE-${Date.now()}`
}