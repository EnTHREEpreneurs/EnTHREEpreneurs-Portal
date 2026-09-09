# Supabase Database Structure — EnTHREEpreneurs

## Core tables

### `admins`
- `id` — Supabase Auth user UUID
- `name`
- `email`
- `role` — OWNER / PRESIDENT / VICE_PRESIDENT
- `created_at`
- `updated_at`

### `subjects`
- `id`
- `name`
- `icon`
- `description`
- `active`
- `created_at`
- `updated_at`

### `schedules`
- `id`
- `subject_id`
- `subject_name`
- `professor`
- `day`
- `start_time`
- `end_time`
- `platform`
- `meeting_link`
- `room`
- `notes`
- `created_at`
- `updated_at`

### `resources`
- `id`
- `subject_id`
- `subject_name`
- `title`
- `type`
- `description`
- `resource_url` — external URL or Supabase Storage public URL
- `storage_path` — Supabase Storage object path, when uploaded
- `created_at`
- `updated_at`

### `activities`
- `id`
- `subject_id`
- `subject_name`
- `title`
- `professor`
- `assigned_date`
- `deadline`
- `description`
- `submission_method`
- `submission_link`
- `attachment_url` — external URL or Supabase Storage public URL
- `storage_path` — Supabase Storage object path, when uploaded
- `created_at`
- `updated_at`

### `events`
- `id`
- `title`
- `date`
- `time`
- `location`
- `description`
- `link`
- `image_url` — external URL or Supabase Storage public URL
- `storage_path`
- `created_at`
- `updated_at`

### `pup_calendar`
- `id`
- `title`
- `date`
- `category`
- `description`
- `created_at`
- `updated_at`

### `announcements`
- `id`
- `title`
- `date`
- `message`
- `created_at`
- `updated_at`

### `funds`
- `id`
- `date`
- `description`
- `income`
- `expense`
- `category`
- `receipt_url` — external URL or Supabase Storage public URL
- `storage_path`
- `notes`
- `created_at`
- `updated_at`

### `contacts`
- `id`
- `category` — officer / university
- `name`
- `position`
- `email`
- `office`
- `description`
- `created_at`
- `updated_at`

### `feedback`
- `id`
- `name`
- `rating`
- `message`
- `status`
- `created_at`

### `concerns`
- `id`
- `name`
- `category`
- `urgency`
- `message`
- `status`
- `created_at`

## Storage

Bucket: `class-files`

Suggested folders:
- `resources/`
- `activities/`
- `receipts/`
- `events/`

Files are public-read so students can open published resources. RLS policies restrict uploads, updates, and deletes to authorized admins.
