import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const supabaseUrl = Deno.env.get('SUPABASE_URL') as string
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') as string
const supabase = createClient(supabaseUrl, supabaseKey)

async function deleteFromStorage(bucket_id: string, path: string) {
  const { data, error } = await supabase
      .storage
      .from(bucket_id)
      .remove([path]);

  if (error) {
      throw new Error(error.message);
  }
}

serve(async (req) => {
  const body = await req.json();

  if (body.old_record) {
      const { bucket_id, path } = body.old_record;

      try {
          await deleteFromStorage(bucket_id, path);

          return new Response(
              JSON.stringify({ message: "File deleted successfully" }),
              { headers: { "Content-Type": "application/json" } }
          );
      } catch (error) {
          return new Response(
              JSON.stringify({ error: error.message }),
              { headers: { "Content-Type": "application/json" }, status: 500 }
          );
      }
  } else {
      return new Response(
          JSON.stringify({ error: "Old record not provided" }),
          { headers: { "Content-Type": "application/json" }, status: 400 }
      );
  }
});