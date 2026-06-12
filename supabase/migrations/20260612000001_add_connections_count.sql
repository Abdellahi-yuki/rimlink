-- Add connections count column to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS connections integer DEFAULT 0;

-- Function to auto-update connections count
CREATE OR REPLACE FUNCTION public.update_connections_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'accepted' THEN
    UPDATE public.profiles SET connections = connections + 1 WHERE id = NEW.requester_id;
    UPDATE public.profiles SET connections = connections + 1 WHERE id = NEW.receiver_id;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status != 'accepted' AND NEW.status = 'accepted' THEN
      UPDATE public.profiles SET connections = connections + 1 WHERE id = NEW.requester_id;
      UPDATE public.profiles SET connections = connections + 1 WHERE id = NEW.receiver_id;
    ELSIF OLD.status = 'accepted' AND NEW.status != 'accepted' THEN
      UPDATE public.profiles SET connections = connections - 1 WHERE id = NEW.requester_id;
      UPDATE public.profiles SET connections = connections - 1 WHERE id = NEW.receiver_id;
    END IF;
  ELSIF TG_OP = 'DELETE' AND OLD.status = 'accepted' THEN
    UPDATE public.profiles SET connections = connections - 1 WHERE id = OLD.requester_id;
    UPDATE public.profiles SET connections = connections - 1 WHERE id = OLD.receiver_id;
  END IF;
  RETURN NULL;
END;
$$;

-- Trigger on connections table
CREATE TRIGGER connections_count_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.connections
  FOR EACH ROW EXECUTE FUNCTION public.update_connections_count();

-- Backfill existing accepted connections
UPDATE public.profiles SET connections = (
  SELECT COUNT(*) FROM public.connections
  WHERE (requester_id = profiles.id OR receiver_id = profiles.id) AND status = 'accepted'
);
