-- Create the update_comment_content function
CREATE OR REPLACE FUNCTION public.update_comment_content(
  comment_id uuid,
  new_content text,
  user_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Security check: verify the user owns the comment
  IF NOT EXISTS (
    SELECT 1 FROM public.comments
    WHERE id = comment_id AND author_id = user_id
  ) THEN
    RAISE EXCEPTION 'User does not own this comment';
  END IF;
  
  -- Update the comment content
  UPDATE public.comments
  SET content = new_content
  WHERE id = comment_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.update_comment_content(uuid, text, uuid) TO authenticated;

-- Test the function (replace with actual values)
-- SELECT public.update_comment_content(
--   '3eff011c-261f-4708-a161-983d8cb0e195',
--   'Test edited content',
--   'dc820c6a-19d3-485d-8b3a-b00b4eb29c78'
-- );

-- Verify the function was created
SELECT proname, proargtypes, prokind
FROM pg_proc
WHERE proname = 'update_comment_content';

-- Verify the grant was applied
SELECT grantee, privilege_type
FROM information_schema.role_routine_grants
WHERE routine_name = 'update_comment_content';