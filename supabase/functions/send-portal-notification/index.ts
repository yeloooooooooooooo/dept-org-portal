import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface NotificationRecord {
  id?: string;
  recipient_id?: string;
  title?: string;
  message?: string;
  org_code?: string;
  post_id?: string;
}

interface WebhookPayload {
  type?: string;
  table?: string;
  schema?: string;
  record?: NotificationRecord;
}

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

function base64UrlEncode(input: Uint8Array | string): string {
  const bytes = typeof input === "string" ? new TextEncoder().encode(input) : input;
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const clean = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const binary = atob(clean);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

async function getFcmAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = base64UrlEncode(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claimSet = base64UrlEncode(
    JSON.stringify({
      iss: sa.client_email,
      sub: sa.client_email,
      aud: "https://oauth2.googleapis.com/token",
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      iat: now,
      exp: now + 3600,
    }),
  );

  const signingInput = `${header}.${claimSet}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(signingInput),
  );

  const jwt = `${signingInput}.${base64UrlEncode(new Uint8Array(signature))}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!tokenRes.ok) {
    const errText = await tokenRes.text();
    throw new Error(`Failed to get Google OAuth token: ${errText}`);
  }

  const tokenJson = await tokenRes.json();
  return tokenJson.access_token as string;
}

Deno.serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { "Content-Type": "application/json" },
      });
    }

    const payload = (await req.json()) as WebhookPayload;
    const record = payload.record;

    if (!record?.recipient_id) {
      console.log("Skipped: missing recipient_id", payload);
      return new Response(
        JSON.stringify({ skipped: "Missing recipient_id in payload record" }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const saRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");

    if (!supabaseUrl || !serviceRoleKey || !saRaw) {
      throw new Error("Missing required Edge Function environment secrets.");
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);
    const { data: profile, error: profileErr } = await supabase
      .from("profiles")
      .select("fcm_token")
      .eq("id", record.recipient_id)
      .maybeSingle();

    if (profileErr) {
      throw new Error(`Profile lookup failed: ${profileErr.message}`);
    }

    const fcmToken = profile?.fcm_token?.trim();
    if (!fcmToken) {
      console.log("Skipped: no fcm_token for", record.recipient_id);
      return new Response(
        JSON.stringify({ skipped: "Recipient has no fcm_token stored" }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    }

    const serviceAccount = JSON.parse(saRaw) as ServiceAccount;
    const projectId = serviceAccount.project_id || "org-portal-d2f3f";
    const accessToken = await getFcmAccessToken(serviceAccount);

    const title = record.title?.trim() || "CICS Portal Reminder";
    const body = record.message?.trim() || "You have a new campus update.";

    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: fcmToken,
            notification: {
              title,
              body,
            },
            data: {
              notification_id: String(record.id ?? ""),
              org_code: String(record.org_code ?? ""),
              post_id: String(record.post_id ?? ""),
              route: "notifications",
            },
          },
        }),
      },
    );

    const fcmResult = await fcmRes.json();
    if (!fcmRes.ok) {
      const errorCode = fcmResult?.error?.details?.[0]?.errorCode;
      if (errorCode === "UNREGISTERED") {
        await supabase
          .from("profiles")
          .update({ fcm_token: null })
          .eq("id", record.recipient_id);
      }

      return new Response(
        JSON.stringify({ error: "FCM send failed", details: fcmResult }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }
    console.log("FCM sent:", record.recipient_id, fcmResult);
    return new Response(
      
      JSON.stringify({ success: true, fcm: fcmResult }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});