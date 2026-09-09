# EnTHREEpreneurs Class Portal — Supabase Edition

A responsive class portal for **EnTHREEpreneurs — BS Entrepreneurship, Section 1-3**.

## Architecture

- **Supabase Auth** — admin login
- **Supabase Postgres** — subjects, schedules, resources, activities, events, PUP calendar, announcements, class funds, contacts, feedback, concerns, and admin roles
- **Supabase Storage** — uploaded learning materials, activity attachments, receipts, and event posters/images
- **Static hosting** — deploy the frontend to Netlify, Vercel, GitHub Pages, or another static host when ready

The browser uses only the Supabase **Project URL + Publishable key**. Never place a Supabase secret/service-role key in the website.

## Current subjects

1. Panitikang Filipino
2. Opportunity Seeking
3. Innovation Management
4. Ethics
5. Science, Technology and Society
6. Life and Works of Rizal
7. Physical Activity Towards Health and Fitness 3

## Admin roles

- OWNER — full content access + admin roster management
- PRESIDENT — content management
- VICE_PRESIDENT — content management
- Students/public — read published content and submit feedback/concerns

## File uploads

The admin dashboard supports direct uploads to the `class-files` Supabase Storage bucket. It also supports external links as an alternative.

For browser uploads, the project uses the standard Supabase Storage upload API. Supabase recommends standard uploads for smaller files and resumable uploads for larger files (roughly above 6 MB). See the official Supabase Storage docs for details.

