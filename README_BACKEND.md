# TuneMate Backend Deployment Guide

This guide details how to link your local configuration and deploy database schemas, security policies, triggers, and Edge Functions to your live Supabase project.

---

## 🛠️ Step 1: Install and Authenticate Supabase CLI

You need the Supabase CLI installed on your machine to manage migrations and edge functions.

1. **Login to your Supabase account**:
   ```bash
   npx supabase login
   ```

2. **Initialize local workspace** (if not already done):
   ```bash
   npx supabase init
   ```

---

## 📦 Step 2: Link and Push Migrations to Live Database

Link your local project with your live cloud instance (`gllisgeyldkwxowfezld`) and deploy the schema migrations (`profiles`, `conversations`, `messages`, `rls_policies`, `triggers`, `indexes`):

1. **Link local project**:
   ```bash
   npx supabase link --project-ref gllisgeyldkwxowfezld
   ```
   *(It will prompt you for your database password, which is the password you set when creating the Supabase project).*

2. **Push migrations to the live cloud database**:
   ```bash
   npx supabase db push
   ```

---

## ⚡ Step 3: Deploy Deno Edge Functions

Deploy the serverless Edge Functions to your live project so that media uploads, WeBRTC signaling, and push notifications work in production:

1. **Deploy all functions**:
   ```bash
   npx supabase functions deploy --project-ref gllisgeyldkwxowfezld
   ```

2. **Set secret environment variables** (e.g. Firebase credentials for FCM notifications) on your live Supabase project if needed:
   ```bash
   npx supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON='{ ... }'
   ```

---

## 📁 Step 4: Storage Buckets Configuration

Ensure that the storage policies are active. Once migrations are pushed, the buckets (`avatars`, `media`, `files`, `voice-notes`) are created automatically via SQL policies. You can verify them on your Supabase web dashboard under the **Storage** section.

---

## 🔔 Step 5: Database Webhook for Push Notifications

To trigger push notifications when a new message is sent:

1. Go to your **Supabase Web Dashboard**.
2. Navigate to **Database** -> **Webhooks**.
3. Create a new webhook:
   - **Name**: `send-notification-webhook`
   - **Table**: `public.messages`
   - **Events**: Check `Insert`
   - **Type**: `Supabase Edge Functions`
   - **Method**: `POST`
   - **Function**: Select `send-notification`
   - **Headers**: Choose authorization as standard JWT (automatically provided).
4. Save the Webhook.
