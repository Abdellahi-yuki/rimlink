
CREATE OR REPLACE FUNCTION public.get_verified_user_ids()
RETURNS uuid[]
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  result uuid[];
BEGIN
  SELECT array_agg(id) INTO result
  FROM auth.users
  WHERE email_confirmed_at IS NOT NULL;
  RETURN result;
END;
$$;

GRANT ALL ON FUNCTION public.get_verified_user_ids() TO anon;
GRANT ALL ON FUNCTION public.get_verified_user_ids() TO authenticated;
GRANT ALL ON FUNCTION public.get_verified_user_ids() TO service_role;

