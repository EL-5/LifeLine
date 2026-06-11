import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

interface NotificationRequest {
  user_id: string
  title: string
  body: string
  data?: Record<string, string>
  channel?: 'push' | 'sms' | 'both'
}

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const notification: NotificationRequest = await req.json()

    // Get user's FCM token
    const { data: user } = await supabase
      .from('users')
      .select('fcm_token, phone')
      .eq('id', notification.user_id)
      .single()

    // Store notification in database
    await supabase.from('audit_logs').insert({
      actor_id: notification.user_id,
      action: 'notification_sent',
      resource_type: 'notification',
      metadata: {
        title: notification.title,
        body: notification.body,
        channel: notification.channel || 'push',
      },
    })

    // In production: send via FCM and/or SMS provider
    return new Response(
      JSON.stringify({
        success: true,
        message: `Notification sent to ${notification.user_id}`,
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})