--
-- PostgreSQL database dump
--

\restrict bMTZhfsRI6S1JNbM57zcleWoCWqa5iDe8QkPbjlzlwOcKxi8PsC8OSDndO3VyMP

-- Dumped from database version 14.23 (Ubuntu 14.23-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.23 (Ubuntu 14.23-0ubuntu0.22.04.1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: email_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_requests (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    nim character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    email_requested character varying(255) NOT NULL,
    request_type character varying(255) DEFAULT 'aktivasi'::character varying NOT NULL,
    ktm_photo_url character varying(255),
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    otp_code character varying(255),
    otp_sent_at timestamp(0) without time zone,
    admin_notes text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.email_requests OWNER TO postgres;

--
-- Name: intern_complaints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.intern_complaints (
    id uuid NOT NULL,
    participation_id uuid NOT NULL,
    category character varying(255) NOT NULL,
    content text NOT NULL,
    is_resolved boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.intern_complaints OWNER TO postgres;

--
-- Name: internship_openings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.internship_openings (
    id uuid NOT NULL,
    title character varying(255),
    description text,
    department character varying(255),
    quota integer,
    is_active boolean DEFAULT true,
    closing_date date,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.internship_openings OWNER TO postgres;

--
-- Name: internship_participations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.internship_participations (
    id uuid NOT NULL,
    cv_url character varying(255),
    portfolio_url character varying(255),
    surat_pengantar_url character varying(255),
    transkrip_nilai_url character varying(255),
    university character varying(255),
    major character varying(255),
    status character varying(255) DEFAULT 'applied'::character varying NOT NULL,
    start_date date,
    end_date date,
    user_id uuid,
    opening_id uuid,
    mentor_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.internship_participations OWNER TO postgres;

--
-- Name: keluhan_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.keluhan_messages (
    id uuid NOT NULL,
    content text NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    keluhan_id uuid NOT NULL,
    user_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.keluhan_messages OWNER TO postgres;

--
-- Name: keluhans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.keluhans (
    id uuid NOT NULL,
    subject character varying(255) NOT NULL,
    description text NOT NULL,
    status character varying(255) DEFAULT 'baru'::character varying NOT NULL,
    admin_notes text,
    user_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.keluhans OWNER TO postgres;

--
-- Name: participation_audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.participation_audit_logs (
    id uuid NOT NULL,
    participation_id uuid NOT NULL,
    changed_by_id uuid,
    from_status character varying(255),
    to_status character varying(255) NOT NULL,
    notes text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.participation_audit_logs OWNER TO postgres;

--
-- Name: presences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.presences (
    id uuid NOT NULL,
    participation_id uuid NOT NULL,
    date date NOT NULL,
    check_in time(0) without time zone,
    check_out time(0) without time zone,
    status character varying(255) DEFAULT 'present'::character varying NOT NULL,
    notes text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.presences OWNER TO postgres;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    role character varying(255) DEFAULT 'mahasiswa'::character varying NOT NULL,
    google_uid character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    avatar_url character varying(255)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: weekly_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weekly_logs (
    id uuid NOT NULL,
    participation_id uuid NOT NULL,
    week_number integer NOT NULL,
    week_start_date date NOT NULL,
    week_end_date date NOT NULL,
    activity_title character varying(255) NOT NULL,
    activity_description text,
    feedback text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    pdf_url character varying(255)
);


ALTER TABLE public.weekly_logs OWNER TO postgres;

--
-- Data for Name: email_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_requests (id, user_id, nim, full_name, email_requested, request_type, ktm_photo_url, status, otp_code, otp_sent_at, admin_notes, inserted_at, updated_at) FROM stdin;
c0b50d80-304e-40d7-b7a5-1df1076a4522	f6ae4dec-7960-47c8-9563-1cfd6857085b	2323232323	mamamama	admin@gmail.com	reset	/uploads/9PWqpD3SVA9dAbhc3jYcDg.png	disetujui	anjay	2026-06-07 06:51:57	\N	2026-06-07 06:41:35	2026-06-07 06:51:57
bfcf139b-3591-4a1f-bd27-fe77c71edea8	706bf183-60db-4806-aaa5-07502c0c5150	123123123	apaapaapa	admin@gmail.com	reset	http://127.0.0.1:9000/upa-tik-uploads/RTwRh3cwRc1_iQfnHtSINQ.png	disetujui	123123	2026-06-07 13:42:06	\N	2026-06-07 13:41:01	2026-06-07 13:42:06
\.


--
-- Data for Name: intern_complaints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.intern_complaints (id, participation_id, category, content, is_resolved, inserted_at, updated_at) FROM stdin;
19b76226-d015-434f-af43-3e47bd3788a0	2c3c0af9-27b1-4bba-ba05-e40411a827f0	Fasilitas	bagus banget bang	f	2026-06-08 02:50:16	2026-06-08 02:50:16
\.


--
-- Data for Name: internship_openings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.internship_openings (id, title, description, department, quota, is_active, closing_date, inserted_at, updated_at) FROM stdin;
941ab1e1-a808-46ea-9ba1-7b05ad473cc8	Network & Security Support	Membantu maintenance jaringan fiber optic dan pengamanan server kampus.	Infrastruktur Jaringan	4	t	2026-08-01	2026-06-03 08:32:39	2026-06-03 08:32:39
f8c4dd47-8f92-4429-bbe7-b50e9824f03c	Fullstack Web Developer	Membangun sistem informasi internal menggunakan Laravel dan Livewire.	Pusat Data dan Informasi	3	t	2026-06-30	2026-06-03 08:32:39	2026-06-03 08:32:39
5abc102b-e38c-4469-86df-c39df95d744b	Mobile App Developer (Flutter)	Mengembangkan aplikasi presensi mahasiswa berbasis Android dan iOS.	Divisi Mobile Learning	2	t	2026-07-15	2026-06-03 08:32:39	2026-06-03 08:32:39
8c0616e7-9641-4131-8f4b-464de8f5d59b	Data Scientist Intern	Melakukan analisis data akademik dan pembuatan model prediksi kelulusan.	Laboratorium Sains Data	2	t	2026-06-20	2026-06-03 08:32:39	2026-06-03 08:32:39
fc183a8a-faa7-41a2-9c35-e110f5f4b78a	UI/UX Designer	Merancang antarmuka untuk portal layanan mahasiswa baru.	Creative Media Center	1	t	2026-06-25	2026-06-03 08:32:39	2026-06-03 08:32:39
5f70a869-ce28-4368-a018-ab1e420b423a	Menggambar	Menggambar suka suka	Seni	18	t	2026-06-11	2026-06-08 02:33:59	2026-06-08 02:33:59
\.


--
-- Data for Name: internship_participations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.internship_participations (id, cv_url, portfolio_url, surat_pengantar_url, transkrip_nilai_url, university, major, status, start_date, end_date, user_id, opening_id, mentor_id, inserted_at, updated_at, deleted_at) FROM stdin;
2c3c0af9-27b1-4bba-ba05-e40411a827f0	http://localhost:9000/upa-tik-uploads/96a2707b-2690-4a4d-adf8-8220e7c34e5a-ppp.pdf	http://localhost:4000/portal/lowongan/5260bb7b-968e-4403-8cd7-6b14d313897e/ajukan	http://localhost:9000/upa-tik-uploads/210b0134-b2c4-4144-8a27-858a92dcdc64-ppp.pdf	http://localhost:9000/upa-tik-uploads/cd87572f-fbab-49e4-8925-9bd1d3a09da4-ppp.pdf	ppp	ppp	accepted	2026-06-04	2026-10-04	f6ae4dec-7960-47c8-9563-1cfd6857085b	f8c4dd47-8f92-4429-bbe7-b50e9824f03c	0891d6cf-262c-47bc-815e-7a688e3189a7	2026-06-03 08:37:41	2026-06-03 08:53:47	\N
f077dc87-7af2-4f05-acc5-03e7f0849799	http://localhost:9000/upa-tik-uploads/f96732a6-e25b-40bb-9954-cc4396e596f7-ppp.pdf	http://localhost:4000/portal/lowongan/8c0616e7-9641-4131-8f4b-464de8f5d59b/ajukan	http://localhost:9000/upa-tik-uploads/a603c2d0-d764-4bc2-a638-b79037ae7121-ppp.pdf	http://localhost:9000/upa-tik-uploads/b4470d6f-c4eb-4b11-97f1-464a851bc244-ppp.pdf	aaa	aaa	rejected	2026-06-08	2026-10-08	706bf183-60db-4806-aaa5-07502c0c5150	8c0616e7-9641-4131-8f4b-464de8f5d59b	\N	2026-06-07 13:35:23	2026-06-07 13:44:36	\N
b138c977-8de8-4443-a0a9-a72b7fa41001	http://localhost:9000/upa-tik-uploads/f42c5c26-c03b-48c0-afee-10ee87b22ddb-ppp.pdf	http://localhost:4000/portal/lowongan/8c0616e7-9641-4131-8f4b-464de8f5d59b/ajukan	http://localhost:9000/upa-tik-uploads/2dab1077-fe02-46af-81b8-1af0c72e3262-ppp.pdf	http://localhost:9000/upa-tik-uploads/eab53966-4228-4b27-b9a4-32700ee16046-ppp.pdf	aaa	aaa	applied	2026-06-08	2026-10-08	706bf183-60db-4806-aaa5-07502c0c5150	fc183a8a-faa7-41a2-9c35-e110f5f4b78a	\N	2026-06-07 13:58:40	2026-06-07 13:58:40	\N
3ff14e9f-58c1-483b-85f6-f3e9216d8a71	http://localhost:9000/upa-tik-uploads/da06ccaa-2a37-4b4e-81eb-05d01036a68d-ppp.pdf	http://localhost:4000/portal/lowongan/5260bb7b-968e-4403-8cd7-6b14d313897e/ajukan	http://localhost:9000/upa-tik-uploads/5c417de0-be00-4f6f-9fd5-966758818c40-ppp.pdf	http://localhost:9000/upa-tik-uploads/ca4fc36d-c161-423e-b176-827e09c13c8b-ppp.pdf	ppp	ppp	applied	2026-06-04	2026-10-04	f6ae4dec-7960-47c8-9563-1cfd6857085b	f8c4dd47-8f92-4429-bbe7-b50e9824f03c	\N	2026-06-03 08:35:42	2026-06-04 06:53:42	\N
2f91e8b4-dd71-4ac1-aac8-c6882f42447e	http://localhost:9000/upa-tik-uploads/e66ea423-2d61-4176-a45a-8abd8ae117e2-ppp.pdf	http://localhost:9000/upa-tik-uploads/3e2c63da-73dd-4dd3-9af6-daa939e09d90-ppp.pdf	http://localhost:9000/upa-tik-uploads/85edc29a-f864-40ee-9f58-6d827826d282-ppp.pdf	http://localhost:9000/upa-tik-uploads/a79bcdfb-b791-4178-8997-94ef3848ad38-ppp.pdf	Universitas Trunojoyo Madura	Teknik Informatika	accepted	2026-06-10	2026-10-10	706bf183-60db-4806-aaa5-07502c0c5150	5f70a869-ce28-4368-a018-ab1e420b423a	0891d6cf-262c-47bc-815e-7a688e3189a7	2026-06-08 02:37:08	2026-06-08 02:41:46	\N
\.


--
-- Data for Name: keluhan_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.keluhan_messages (id, content, is_admin, keluhan_id, user_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: keluhans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.keluhans (id, subject, description, status, admin_notes, user_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: participation_audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.participation_audit_logs (id, participation_id, changed_by_id, from_status, to_status, notes, inserted_at, updated_at) FROM stdin;
a8bd2587-e872-40cc-9f07-22218bb8e9e9	3ff14e9f-58c1-483b-85f6-f3e9216d8a71	128aecf2-8a6f-4ad0-8501-40d9443326ab	applied	interview	\N	2026-06-04 06:53:36	2026-06-04 06:53:36
ea2149a9-2259-413c-9a6c-a8aeeb139af5	3ff14e9f-58c1-483b-85f6-f3e9216d8a71	128aecf2-8a6f-4ad0-8501-40d9443326ab	interview	applied	\N	2026-06-04 06:53:42	2026-06-04 06:53:42
2abad2cf-3a05-4504-b858-6a5efc0e063b	f077dc87-7af2-4f05-acc5-03e7f0849799	128aecf2-8a6f-4ad0-8501-40d9443326ab	applied	interview	\N	2026-06-07 13:37:24	2026-06-07 13:37:24
3bde1df1-d674-42b5-8f7c-862935da4371	f077dc87-7af2-4f05-acc5-03e7f0849799	128aecf2-8a6f-4ad0-8501-40d9443326ab	interview	applied	\N	2026-06-07 13:40:16	2026-06-07 13:40:16
4ab7b220-02e6-443f-9876-507ba3e4b40d	f077dc87-7af2-4f05-acc5-03e7f0849799	128aecf2-8a6f-4ad0-8501-40d9443326ab	applied	interview	\N	2026-06-07 13:43:59	2026-06-07 13:43:59
7c0f6329-8642-433a-a5be-6ca8984cb81b	f077dc87-7af2-4f05-acc5-03e7f0849799	128aecf2-8a6f-4ad0-8501-40d9443326ab	interview	applied	\N	2026-06-07 13:44:27	2026-06-07 13:44:27
574c592c-86c9-4e9b-9b09-5eeb3b55a8f2	f077dc87-7af2-4f05-acc5-03e7f0849799	128aecf2-8a6f-4ad0-8501-40d9443326ab	applied	rejected	\N	2026-06-07 13:44:36	2026-06-07 13:44:36
564a2cdb-51af-4d78-bc01-227023ced645	2f91e8b4-dd71-4ac1-aac8-c6882f42447e	128aecf2-8a6f-4ad0-8501-40d9443326ab	applied	interview	\N	2026-06-08 02:38:02	2026-06-08 02:38:02
ebb0ea0f-6653-4c58-bdbf-8ea7a9d6b907	2f91e8b4-dd71-4ac1-aac8-c6882f42447e	128aecf2-8a6f-4ad0-8501-40d9443326ab	interview	accepted	\N	2026-06-08 02:41:24	2026-06-08 02:41:24
\.


--
-- Data for Name: presences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.presences (id, participation_id, date, check_in, check_out, status, notes, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20260219150000	2026-06-03 08:28:51
20260219150001	2026-06-03 08:28:51
20260220023540	2026-06-03 08:28:51
20260224061500	2026-06-03 08:28:51
20260420033904	2026-06-03 08:28:51
20260504043849	2026-06-03 08:28:51
20260601075014	2026-06-03 08:28:51
20260601075015	2026-06-03 08:28:51
20260601075016	2026-06-03 08:28:51
20260603081837	2026-06-03 08:28:51
20260604055521	2026-06-04 06:00:43
20260604055702	2026-06-04 06:00:43
20260604055846	2026-06-04 06:00:43
20260604100000	2026-06-04 09:03:00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, role, google_uid, inserted_at, updated_at, avatar_url) FROM stdin;
628fa7d3-a237-4dcf-b977-de249bd1c34d	Administrator UPA TIK	admin@upa-tik.ac.id	admin	\N	2026-06-03 08:28:52	2026-06-03 08:28:52	\N
f6ae4dec-7960-47c8-9563-1cfd6857085b	Maulana Ardiansyah	ardicakep81@gmail.com	mahasiswa	101193149974969018075	2026-06-03 08:29:53	2026-06-04 07:21:47	https://lh3.googleusercontent.com/a/ACg8ocJfsshvUxhr9QqqnRmTbBAHuzVgd6BZy-P-1obO74nr1wqvl60_=s96-c
128aecf2-8a6f-4ad0-8501-40d9443326ab	23-159 Maulana Ardiansyah	230411100159@student.trunojoyo.ac.id	admin	109158342569893039958	2026-06-03 08:29:38	2026-06-05 10:16:50	https://lh3.googleusercontent.com/a/ACg8ocJKcQOTvM42i_X9DqcHK6TZg17N3GG_7uMYALNL_YTyrpejQOw=s96-c
0891d6cf-262c-47bc-815e-7a688e3189a7	アラパカー	tsukiaka313@gmail.com	mentor	112711090454888087356	2026-06-03 08:30:04	2026-06-07 05:51:37	https://lh3.googleusercontent.com/a/ACg8ocJdLkLnGtaDUG8_7hZF08LT_Dy3CR4eY4xWaaaQ7BkY1A2kYw=s96-c
706bf183-60db-4806-aaa5-07502c0c5150	23-159 Maulana Ardiansyah	bosrinaangker@gmail.com	mentor	113018322381242268129	2026-06-07 05:57:45	2026-06-08 02:56:17	https://lh3.googleusercontent.com/a/ACg8ocKeCBzoqGQ3KW36Dx-_K1ydS6TIfzbC4hABCFj-IQ2B9Y02K4Q=s96-c
\.


--
-- Data for Name: weekly_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.weekly_logs (id, participation_id, week_number, week_start_date, week_end_date, activity_title, activity_description, feedback, inserted_at, updated_at, pdf_url) FROM stdin;
af76df86-933e-47c5-8b58-8badb0bf643d	2c3c0af9-27b1-4bba-ba05-e40411a827f0	1	2026-06-01	2026-06-07	ppp	ppp	\N	2026-06-03 09:13:00	2026-06-03 09:13:00	http://localhost:9000/upa-tik-uploads/31a3ce03-077d-413b-83e3-a2c98bdd2a03-ppp.pdf
f6a57df4-84fe-463d-b08a-f06a6ba182fc	2c3c0af9-27b1-4bba-ba05-e40411a827f0	2	2026-06-08	2026-06-12	menggambar gunung	menggambar gunung dengan pensil	\N	2026-06-08 02:47:35	2026-06-08 02:47:35	http://localhost:9000/upa-tik-uploads/6785ed37-fca3-4581-b633-c8076651cee7-Laporan MBKM Magang.pdf
\.


--
-- Name: email_requests email_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_requests
    ADD CONSTRAINT email_requests_pkey PRIMARY KEY (id);


--
-- Name: intern_complaints intern_complaints_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intern_complaints
    ADD CONSTRAINT intern_complaints_pkey PRIMARY KEY (id);


--
-- Name: internship_openings internship_openings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_openings
    ADD CONSTRAINT internship_openings_pkey PRIMARY KEY (id);


--
-- Name: internship_participations internship_participations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_participations
    ADD CONSTRAINT internship_participations_pkey PRIMARY KEY (id);


--
-- Name: keluhan_messages keluhan_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keluhan_messages
    ADD CONSTRAINT keluhan_messages_pkey PRIMARY KEY (id);


--
-- Name: keluhans keluhans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keluhans
    ADD CONSTRAINT keluhans_pkey PRIMARY KEY (id);


--
-- Name: participation_audit_logs participation_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participation_audit_logs
    ADD CONSTRAINT participation_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: presences presences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.presences
    ADD CONSTRAINT presences_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weekly_logs weekly_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_logs
    ADD CONSTRAINT weekly_logs_pkey PRIMARY KEY (id);


--
-- Name: email_requests_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX email_requests_status_index ON public.email_requests USING btree (status);


--
-- Name: email_requests_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX email_requests_user_id_index ON public.email_requests USING btree (user_id);


--
-- Name: intern_complaints_participation_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX intern_complaints_participation_id_index ON public.intern_complaints USING btree (participation_id);


--
-- Name: internship_participations_mentor_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX internship_participations_mentor_id_index ON public.internship_participations USING btree (mentor_id);


--
-- Name: internship_participations_opening_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX internship_participations_opening_id_index ON public.internship_participations USING btree (opening_id);


--
-- Name: internship_participations_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX internship_participations_user_id_index ON public.internship_participations USING btree (user_id);


--
-- Name: keluhan_messages_keluhan_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX keluhan_messages_keluhan_id_index ON public.keluhan_messages USING btree (keluhan_id);


--
-- Name: keluhan_messages_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX keluhan_messages_user_id_index ON public.keluhan_messages USING btree (user_id);


--
-- Name: keluhans_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX keluhans_status_index ON public.keluhans USING btree (status);


--
-- Name: keluhans_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX keluhans_user_id_index ON public.keluhans USING btree (user_id);


--
-- Name: participation_audit_logs_changed_by_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX participation_audit_logs_changed_by_id_index ON public.participation_audit_logs USING btree (changed_by_id);


--
-- Name: participation_audit_logs_participation_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX participation_audit_logs_participation_id_index ON public.participation_audit_logs USING btree (participation_id);


--
-- Name: presences_participation_date_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX presences_participation_date_unique ON public.presences USING btree (participation_id, date);


--
-- Name: presences_participation_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX presences_participation_id_index ON public.presences USING btree (participation_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_google_uid_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_google_uid_index ON public.users USING btree (google_uid);


--
-- Name: weekly_logs_participation_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX weekly_logs_participation_id_index ON public.weekly_logs USING btree (participation_id);


--
-- Name: weekly_logs_participation_week_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX weekly_logs_participation_week_unique ON public.weekly_logs USING btree (participation_id, week_number);


--
-- Name: email_requests email_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_requests
    ADD CONSTRAINT email_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: intern_complaints intern_complaints_participation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intern_complaints
    ADD CONSTRAINT intern_complaints_participation_id_fkey FOREIGN KEY (participation_id) REFERENCES public.internship_participations(id) ON DELETE CASCADE;


--
-- Name: internship_participations internship_participations_mentor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_participations
    ADD CONSTRAINT internship_participations_mentor_id_fkey FOREIGN KEY (mentor_id) REFERENCES public.users(id);


--
-- Name: internship_participations internship_participations_opening_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_participations
    ADD CONSTRAINT internship_participations_opening_id_fkey FOREIGN KEY (opening_id) REFERENCES public.internship_openings(id);


--
-- Name: internship_participations internship_participations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_participations
    ADD CONSTRAINT internship_participations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: keluhan_messages keluhan_messages_keluhan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keluhan_messages
    ADD CONSTRAINT keluhan_messages_keluhan_id_fkey FOREIGN KEY (keluhan_id) REFERENCES public.keluhans(id) ON DELETE CASCADE;


--
-- Name: keluhan_messages keluhan_messages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keluhan_messages
    ADD CONSTRAINT keluhan_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: keluhans keluhans_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keluhans
    ADD CONSTRAINT keluhans_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: participation_audit_logs participation_audit_logs_changed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participation_audit_logs
    ADD CONSTRAINT participation_audit_logs_changed_by_id_fkey FOREIGN KEY (changed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: participation_audit_logs participation_audit_logs_participation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participation_audit_logs
    ADD CONSTRAINT participation_audit_logs_participation_id_fkey FOREIGN KEY (participation_id) REFERENCES public.internship_participations(id) ON DELETE CASCADE;


--
-- Name: presences presences_participation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.presences
    ADD CONSTRAINT presences_participation_id_fkey FOREIGN KEY (participation_id) REFERENCES public.internship_participations(id) ON DELETE CASCADE;


--
-- Name: weekly_logs weekly_logs_participation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_logs
    ADD CONSTRAINT weekly_logs_participation_id_fkey FOREIGN KEY (participation_id) REFERENCES public.internship_participations(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict bMTZhfsRI6S1JNbM57zcleWoCWqa5iDe8QkPbjlzlwOcKxi8PsC8OSDndO3VyMP

