-- Add repost support to posts table
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS repost_of_id uuid;

-- Foreign key: if original post is deleted, set repost reference to null
ALTER TABLE ONLY public.posts
  ADD CONSTRAINT posts_repost_of_id_fkey
  FOREIGN KEY (repost_of_id)
  REFERENCES public.posts(id)
  ON DELETE SET NULL;
