-- Create the storage bucket for identity documents
INSERT INTO storage.buckets (id, name, public) 
VALUES ('identity_documents', 'identity_documents', false)
ON CONFLICT (id) DO NOTHING;

-- Set up row-level security for the bucket
CREATE POLICY "Users can upload their own identity documents"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'identity_documents' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own identity documents"
ON storage.objects FOR UPDATE
WITH CHECK (
    bucket_id = 'identity_documents' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can read their own identity documents"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'identity_documents' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Add verification details to the users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS id_type TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS id_number TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS identity_document_url TEXT;
