
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL') as string
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') as string
const supabase = createClient(supabaseUrl, supabaseKey)

serve(async (req) => {
  try {
    const payload = await req.json();

    if (!payload.bucket || !payload.path) {
      return new Response(JSON.stringify({ error: 'Invalid payload. Bucket and path are required.' }), {
        status: 400,
        headers: { "Content-Type": "application/json" }
      });
    }

    const { bucket, path } = payload;

    console.log(bucket, path);

    const { data, error } = await supabase
      .storage
      .from(bucket)
      .createSignedUploadUrl(path);

    if (error != null) {
      return new Response(JSON.stringify({ error: `Supabase Error: ${error.message}` }), {
        status: 500,
        headers: { "Content-Type": "application/json" }
      });
    }

    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" }
    });

  } catch (error) {
    console.error('Error:', error.message);
    
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
});
