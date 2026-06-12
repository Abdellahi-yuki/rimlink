-- Allow users to cancel their own pending connection requests
CREATE POLICY "Users can cancel their own pending requests."
  ON "public"."connections"
  FOR DELETE
  USING ((auth.uid() = requester_id) AND (status = 'pending'::text));
