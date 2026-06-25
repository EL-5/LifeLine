import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://gkhlrqlgmkreubsruzej.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdraGxycWxnbWtyZXVic3J1emVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMjc5MTgsImV4cCI6MjA5NjcwMzkxOH0.YHYs6yD9gPEOrA7FwY36N26M3jPotrn4f70bh5FnDiA';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
