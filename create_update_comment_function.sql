-- Create a function to update comment content (bypasses RLS)
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
  -- Verify the user owns the comment
  IF NOT EXISTS (
    SELECT 1 FROM public.comments
    WHERE id = comment_id AND author_id = user_id
  ) THEN
    RAISE EXCEPTION 'User does not own this comment';
  END IF;
  
  -- Update the comment
  UPDATE public.comments
  SET content = new_content
  WHERE id = comment_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.update_comment_content(uuid, text, uuid) TO authenticated;

-- Test the function
-- SELECT public.update_comment_content('comment-id-here', 'New content', 'user-id-here');