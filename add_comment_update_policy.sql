-- Add RLS policy to allow users to update their own comments
CREATE POLICY "Users can update their own comments"
ON "public"."comments"
FOR UPDATE
USING (auth.uid() = author_id);

-- Verify the policy was created
SELECT policyname, tablename, roles, cmd, permissive
FROM pg_policies
WHERE tablename = 'comments';

-- Also ensure RLS is enabled (should already be enabled based on schema.sql)
ALTER TABLE "public"."comments" ENABLE ROW LEVEL SECURITY;