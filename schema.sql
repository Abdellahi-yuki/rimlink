


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."decrement_likes"("post_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE posts
  SET likes_count = likes_count - 1
  WHERE id = post_id;
END;
$$;


ALTER FUNCTION "public"."decrement_likes"("post_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_verified_user_ids"() RETURNS "uuid"[]
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
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


ALTER FUNCTION "public"."get_verified_user_ids"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.profiles (id, name, title, location)
  VALUES (new.id, new.raw_user_meta_data->>'name', 'New Member', 'Not set');
  RETURN new;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_likes"("post_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE posts
  SET likes_count = likes_count + 1
  WHERE id = post_id;
END;
$$;


ALTER FUNCTION "public"."increment_likes"("post_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_comment_content"("comment_id" "uuid", "new_content" "text", "user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Security check
  IF NOT EXISTS (
    SELECT 1 FROM public.comments
    WHERE id = comment_id AND author_id = user_id
  ) THEN
    RAISE EXCEPTION 'User does not own this comment';
  END IF;

  -- Update comment
  UPDATE public.comments
  SET content = new_content
  WHERE id = comment_id;
END;
$$;


ALTER FUNCTION "public"."update_comment_content"("comment_id" "uuid", "new_content" "text", "user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_connections_count"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- When a connection is accepted, increment connections count for both users
  IF NEW.status = 'accepted' THEN
    UPDATE "public"."profiles"
    SET connections = connections + 1
    WHERE id = NEW.requester_id;

    UPDATE "public"."profiles"
    SET connections = connections + 1
    WHERE id = NEW.receiver_id;
  END IF;

  -- When a connection is deleted, decrement connections count for both users
  IF TG_OP = 'DELETE' AND OLD.status = 'accepted' THEN
    UPDATE "public"."profiles"
    SET connections = connections - 1
    WHERE id = OLD.requester_id;

    UPDATE "public"."profiles"
    SET connections = connections - 1
    WHERE id = OLD.receiver_id;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_connections_count"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."comments" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "post_id" "uuid" NOT NULL,
    "author_id" "uuid" NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."comments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."connections" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "requester_id" "uuid" NOT NULL,
    "receiver_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "connections_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'accepted'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."connections" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."contact_info" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "email" "text",
    "phone" "text",
    "is_email_public" boolean DEFAULT false,
    "is_phone_public" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."contact_info" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."educations" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "school" "text" NOT NULL,
    "degree" "text",
    "field_of_study" "text",
    "start_date" "text" NOT NULL,
    "end_date" "text",
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."educations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."experiences" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "company" "text" NOT NULL,
    "location" "text",
    "start_date" "text" NOT NULL,
    "end_date" "text",
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."experiences" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jobs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "title" "text" NOT NULL,
    "company" "text" NOT NULL,
    "location" "text" NOT NULL,
    "is_promoted" boolean DEFAULT false,
    "is_easy_apply" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "poster_id" "uuid",
    "apply_link" "text",
    "description" "text"
);


ALTER TABLE "public"."jobs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."post_likes" (
    "post_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."post_likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."posts" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "author_id" "uuid" NOT NULL,
    "content" "text" NOT NULL,
    "likes_count" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "image_urls" "text"[] DEFAULT '{}'::"text"[],
    "repost_of_id" "uuid"
);


ALTER TABLE "public"."posts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "title" "text",
    "location" "text",
    "about" "text",
    "experience" "text",
    "education" "text",
    "skills" "text",
    "is_open_to_work" boolean DEFAULT false,
    "is_hiring" boolean DEFAULT false,
    "is_providing_services" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "avatar_url" "text",
    "banner_url" "text",
    "connections" integer DEFAULT 0
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."saved_jobs" (
    "user_id" "uuid" NOT NULL,
    "job_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."saved_jobs" OWNER TO "postgres";


ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "connections_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "connections_requester_id_receiver_id_key" UNIQUE ("requester_id", "receiver_id");



ALTER TABLE ONLY "public"."contact_info"
    ADD CONSTRAINT "contact_info_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."contact_info"
    ADD CONSTRAINT "contact_info_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."experiences"
    ADD CONSTRAINT "experiences_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_pkey" PRIMARY KEY ("post_id", "user_id");



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."saved_jobs"
    ADD CONSTRAINT "saved_jobs_pkey" PRIMARY KEY ("user_id", "job_id");



CREATE INDEX "idx_contact_info_user_id" ON "public"."contact_info" USING "btree" ("user_id");



CREATE INDEX "idx_experiences_user_id" ON "public"."experiences" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "update_connections_count_on_delete" AFTER DELETE ON "public"."connections" FOR EACH ROW EXECUTE FUNCTION "public"."update_connections_count"();



CREATE OR REPLACE TRIGGER "update_connections_count_on_update" AFTER UPDATE ON "public"."connections" FOR EACH ROW EXECUTE FUNCTION "public"."update_connections_count"();



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "connections_receiver_id_fkey" FOREIGN KEY ("receiver_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "connections_requester_id_fkey" FOREIGN KEY ("requester_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."contact_info"
    ADD CONSTRAINT "contact_info_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."educations"
    ADD CONSTRAINT "educations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."experiences"
    ADD CONSTRAINT "experiences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_poster_id_fkey" FOREIGN KEY ("poster_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_repost_of_id_fkey" FOREIGN KEY ("repost_of_id") REFERENCES "public"."posts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."saved_jobs"
    ADD CONSTRAINT "saved_jobs_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."saved_jobs"
    ADD CONSTRAINT "saved_jobs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



CREATE POLICY "Comments are viewable by everyone." ON "public"."comments" FOR SELECT USING (true);



CREATE POLICY "Jobs are viewable by everyone." ON "public"."jobs" FOR SELECT USING (true);



CREATE POLICY "Likes are viewable by everyone." ON "public"."post_likes" FOR SELECT USING (true);



CREATE POLICY "Posts are viewable by everyone." ON "public"."posts" FOR SELECT USING (true);



CREATE POLICY "Public profiles are viewable by everyone." ON "public"."profiles" FOR SELECT USING (true);



CREATE POLICY "Users can accept/reject requests sent to them." ON "public"."connections" FOR UPDATE USING (("auth"."uid"() = "receiver_id"));



CREATE POLICY "Users can cancel their own pending requests." ON "public"."connections" FOR DELETE USING ((("auth"."uid"() = "requester_id") AND ("status" = 'pending'::"text")));



CREATE POLICY "Users can delete own posts." ON "public"."posts" FOR DELETE USING (("auth"."uid"() = "author_id"));



CREATE POLICY "Users can delete their own comments." ON "public"."comments" FOR DELETE USING (("auth"."uid"() = "author_id"));



CREATE POLICY "Users can insert their own comments." ON "public"."comments" FOR INSERT WITH CHECK (("auth"."uid"() = "author_id"));



CREATE POLICY "Users can insert their own posts." ON "public"."posts" FOR INSERT WITH CHECK (("auth"."uid"() = "author_id"));



CREATE POLICY "Users can insert their own profile." ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can like/unlike posts." ON "public"."post_likes" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their jobs" ON "public"."jobs" USING (("auth"."uid"() = "poster_id"));



CREATE POLICY "Users can manage their saved jobs." ON "public"."saved_jobs" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can see their own connections." ON "public"."connections" FOR SELECT USING ((("auth"."uid"() = "requester_id") OR ("auth"."uid"() = "receiver_id")));



CREATE POLICY "Users can send connection requests." ON "public"."connections" FOR INSERT WITH CHECK (("auth"."uid"() = "requester_id"));



CREATE POLICY "Users can update own posts." ON "public"."posts" FOR UPDATE USING (("auth"."uid"() = "author_id"));



CREATE POLICY "Users can update own profile." ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can view all educations." ON "public"."educations" FOR SELECT USING (true);



CREATE POLICY "Users can view all experiences." ON "public"."experiences" FOR SELECT USING (true);



CREATE POLICY "Users can view public contact info." ON "public"."contact_info" FOR SELECT USING ((("auth"."uid"() = "user_id") OR ("is_email_public" = true) OR ("is_phone_public" = true)));



CREATE POLICY "Users manage their contact info." ON "public"."contact_info" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their educations." ON "public"."educations" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage their experiences." ON "public"."experiences" USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."comments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."connections" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."contact_info" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."educations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."experiences" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."jobs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."post_likes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."posts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."saved_jobs" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































GRANT ALL ON FUNCTION "public"."decrement_likes"("post_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."decrement_likes"("post_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."decrement_likes"("post_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_verified_user_ids"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_verified_user_ids"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_verified_user_ids"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_likes"("post_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_likes"("post_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_likes"("post_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_comment_content"("comment_id" "uuid", "new_content" "text", "user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_comment_content"("comment_id" "uuid", "new_content" "text", "user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_comment_content"("comment_id" "uuid", "new_content" "text", "user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_connections_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_connections_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_connections_count"() TO "service_role";


















GRANT ALL ON TABLE "public"."comments" TO "anon";
GRANT ALL ON TABLE "public"."comments" TO "authenticated";
GRANT ALL ON TABLE "public"."comments" TO "service_role";



GRANT ALL ON TABLE "public"."connections" TO "anon";
GRANT ALL ON TABLE "public"."connections" TO "authenticated";
GRANT ALL ON TABLE "public"."connections" TO "service_role";



GRANT ALL ON TABLE "public"."contact_info" TO "anon";
GRANT ALL ON TABLE "public"."contact_info" TO "authenticated";
GRANT ALL ON TABLE "public"."contact_info" TO "service_role";



GRANT ALL ON TABLE "public"."educations" TO "anon";
GRANT ALL ON TABLE "public"."educations" TO "authenticated";
GRANT ALL ON TABLE "public"."educations" TO "service_role";



GRANT ALL ON TABLE "public"."experiences" TO "anon";
GRANT ALL ON TABLE "public"."experiences" TO "authenticated";
GRANT ALL ON TABLE "public"."experiences" TO "service_role";



GRANT ALL ON TABLE "public"."jobs" TO "anon";
GRANT ALL ON TABLE "public"."jobs" TO "authenticated";
GRANT ALL ON TABLE "public"."jobs" TO "service_role";



GRANT ALL ON TABLE "public"."post_likes" TO "anon";
GRANT ALL ON TABLE "public"."post_likes" TO "authenticated";
GRANT ALL ON TABLE "public"."post_likes" TO "service_role";



GRANT ALL ON TABLE "public"."posts" TO "anon";
GRANT ALL ON TABLE "public"."posts" TO "authenticated";
GRANT ALL ON TABLE "public"."posts" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."saved_jobs" TO "anon";
GRANT ALL ON TABLE "public"."saved_jobs" TO "authenticated";
GRANT ALL ON TABLE "public"."saved_jobs" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































