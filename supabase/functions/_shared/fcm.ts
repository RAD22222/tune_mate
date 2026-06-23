// FILE: supabase/functions/_shared/fcm.ts

import { createAdminClient } from "./supabase_admin.ts";

interface FcmPayload {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

function base64url(arr: Uint8Array | ArrayBuffer): string {
  const buf = new Uint8Array(arr);
  let bin = "";
  for (let i = 0; i < buf.length; i++) {
    bin += String.fromCharCode(buf[i]);
  }
  return btoa(bin)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "");
}

function base64ToArrayBuffer(b64: string): ArrayBuffer {
  const bin = atob(b64);
  const buf = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) {
    buf[i] = bin.charCodeAt(i);
  }
  return buf.buffer;
}

async function getAccessToken(serviceAccountJsonStr: string): Promise<string> {
  const sa = JSON.parse(serviceAccountJsonStr);
  const header = { alg: "RS256", typ: "JWT" };
  
  const now = Math.floor(Date.now() / 1000);
  const claimSet = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  const headerB64 = base64url(new TextEncoder().encode(JSON.stringify(header)));
  const claimSetB64 = base64url(new TextEncoder().encode(JSON.stringify(claimSet)));
  const signatureInput = `${headerB64}.${claimSetB64}`;

  const pemContents = sa.private_key
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s+/g, "");

  const binaryKey = base64ToArrayBuffer(pemContents);
  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(signatureInput)
  );

  const signatureB64 = base64url(signature);
  const assertion = `${signatureInput}.${signatureB64}`;

  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${assertion}`,
  });

  if (!tokenResponse.ok) {
    throw new Error(`Failed to generate Firebase OAuth token: ${await tokenResponse.text()}`);
  }

  const tokenData = await tokenResponse.json();
  return tokenData.access_token;
}

export async function sendFcmNotification(payload: FcmPayload): Promise<boolean> {
  const { token, title, body, data } = payload;
  
  const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
  const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
  
  if (!projectId || !serviceAccountJson) {
    console.warn("FCM credentials missing. Skipping notification.");
    return false;
  }

  try {
    const accessToken = await getAccessToken(serviceAccountJson);
    
    const fcmMessage = {
      message: {
        token,
        notification: {
          title,
          body,
        },
        data: data || {},
      },
    };

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(fcmMessage),
      }
    );

    if (response.ok) {
      return true;
    }

    const errorText = await response.text();
    console.error(`FCM send error (Status ${response.status}): ${errorText}`);

    // If token is invalid/unregistered, remove it from public.profiles
    if (response.status === 404 || response.status === 410) {
      console.log(`FCM token unregistered. Clearing from database.`);
      const adminClient = createAdminClient();
      await adminClient
        .from("profiles")
        .update({ fcm_token: null })
        .eq("fcm_token", token);
    }
    
    return false;
  } catch (err) {
    console.error(`FCM sending exception: ${err}`);
    return false;
  }
}
