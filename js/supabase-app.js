import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm";

const cfg = window.SUPABASE_CONFIG || {};
const configured = Boolean(
  cfg.url && !String(cfg.url).includes("PASTE_") &&
  cfg.publishableKey && !String(cfg.publishableKey).includes("PASTE_")
);

const supabase = configured ? createClient(cfg.url, cfg.publishableKey) : null;

export { configured, supabase };
