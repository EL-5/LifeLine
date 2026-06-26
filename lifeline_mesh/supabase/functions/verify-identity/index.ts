import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
import { GoogleGenerativeAI } from 'npm:@google/generative-ai'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const authHeader = req.headers.get('Authorization')!
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(token)

    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { user_id } = await req.json()
    
    // Safety check
    if (user_id !== user.id) {
       return new Response(JSON.stringify({ error: 'Forbidden' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 1. Fetch user document details
    const { data: profile, error: profileError } = await supabaseClient
      .from('users')
      .select('full_name, id_type, id_number, identity_document_url')
      .eq('id', user_id)
      .single()

    if (profileError || !profile || !profile.identity_document_url) {
      throw new Error('User profile or document not found')
    }

    // 2. Download the image from storage
    const { data: fileData, error: downloadError } = await supabaseClient
      .storage
      .from('identity_documents')
      .download(profile.identity_document_url)

    if (downloadError || !fileData) {
      throw new Error('Could not download identity document')
    }

    // Convert file to base64
    const arrayBuffer = await fileData.arrayBuffer()
    const base64Data = btoa(String.fromCharCode(...new Uint8Array(arrayBuffer)))
    const mimeType = fileData.type || 'image/jpeg'

    // 3. Initialize Gemini
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      throw new Error('GEMINI_API_KEY is not configured in edge function environment')
    }

    const genAI = new GoogleGenerativeAI(geminiApiKey)
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' })

    const prompt = `
You are a highly accurate, strict identity verification KYC system.
I am providing you with an image of an identity document.
Please verify if the following details match exactly what is clearly written on the document:

Expected Name: ${profile.full_name}
Expected Document Number: ${profile.id_number}
Expected Document Type: ${profile.id_type}

Instructions:
1. Check if the image contains a valid identity document.
2. Check if the name matches (allow minor differences like middle names being omitted, but the primary names must match).
3. Check if the document number matches exactly.
4. Reply with a strict JSON format:
{
  "is_verified": true or false,
  "reason": "Explain briefly why it was verified or rejected"
}
`

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          data: base64Data,
          mimeType: mimeType,
        },
      },
    ])

    const responseText = result.response.text()
    // Parse the JSON block from the response
    const jsonStr = responseText.replace(/```json/g, '').replace(/```/g, '').trim()
    const aiResult = JSON.parse(jsonStr)

    // 4. Update the database
    const newStatus = aiResult.is_verified ? 'verified' : 'suspended'
    
    await supabaseClient
      .from('users')
      .update({ verification_status: newStatus })
      .eq('id', user_id)

    // Log the event
    await supabaseClient.from('audit_logs').insert({
      actor_id: user_id,
      action: 'ai_identity_verification',
      metadata: { ai_result: aiResult }
    })

    return new Response(JSON.stringify({ success: true, aiResult }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error: any) {
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
