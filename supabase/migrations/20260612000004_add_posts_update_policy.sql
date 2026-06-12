-- Allow post authors to update their own posts
CREATE POLICY "Users can update own posts."
  ON "public"."posts"
  FOR UPDATE
  USING ((auth.uid() = author_id));
