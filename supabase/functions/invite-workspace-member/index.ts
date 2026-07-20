import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const allowedRoles = new Set(["admin", "manager", "worker", "viewOnly"]);
const publicInviteBaseUrl =
  Deno.env.get("PUBLIC_INVITE_BASE_URL") ??
    "https://issuedinventory.com/invite";
const customInviteSchemeBaseUrl = "issued://invite";

serve(async (request) => {
  if (request.method === "OPTIONS") {
    return json({ success: true }, 200);
  }
  if (request.method !== "POST") {
    return json({ success: false, message: "Method not allowed." }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    return json(
      { success: false, message: "Invite service is not configured." },
      500,
    );
  }

  const authorization = request.headers.get("Authorization") ?? "";
  const jwt = authorization.replace(/^Bearer\s+/i, "").trim();
  if (!jwt) {
    return json({ success: false, message: "Sign in to invite members." }, 401);
  }

  let body: InviteRequest;
  try {
    body = await request.json();
  } catch (_) {
    return json({ success: false, message: "Invalid invite request." }, 400);
  }

  const workspaceId = body.workspaceId?.trim();
  const email = body.email?.trim().toLowerCase();
  const role = body.role?.trim();

  if (!workspaceId || !isUuid(workspaceId)) {
    return json({ success: false, message: "Workspace is required." }, 400);
  }
  if (!email || !looksLikeEmail(email)) {
    return json({ success: false, message: "Enter a valid email address." }, 400);
  }
  if (!role || !allowedRoles.has(role)) {
    return json({ success: false, message: "Choose a valid role." }, 400);
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: userData, error: userError } =
    await adminClient.auth.getUser(jwt);
  const caller = userData.user;
  if (userError || !caller) {
    return json({ success: false, message: "Sign in to invite members." }, 401);
  }

  const { data: callerMembership, error: membershipError } = await adminClient
    .from("workspace_members")
    .select("id, role, status")
    .eq("workspace_id", workspaceId)
    .eq("user_id", caller.id)
    .eq("status", "active")
    .in("role", ["owner", "admin"])
    .maybeSingle();

  if (membershipError) {
    return json(
      { success: false, message: "Could not verify workspace permissions." },
      500,
    );
  }
  if (!callerMembership) {
    return json(
      {
        success: false,
        message: "Your current role does not allow this action.",
      },
      403,
    );
  }

  // TODO: Server-side plan enforcement is needed before production billing.
  // Organization plan selection currently lives only in the Flutter client,
  // so this function has no authoritative server-side user limit to enforce.

  const { data: workspace, error: workspaceError } = await adminClient
    .from("workspaces")
    .select("id, name")
    .eq("id", workspaceId)
    .maybeSingle();
  if (workspaceError || !workspace) {
    return json(
      { success: false, message: "Could not find that workspace." },
      404,
    );
  }

  const { data: existingMembers, error: existingMemberError } =
    await adminClient
      .from("workspace_members")
      .select("id, status")
      .eq("workspace_id", workspaceId)
      .ilike("email", email)
      .limit(1);
  if (existingMemberError) {
    return json(
      { success: false, message: "Could not check existing members." },
      500,
    );
  }
  if (existingMembers?.some((member) => member.status === "active")) {
    return json(
      {
        success: false,
        message: "That person is already a workspace member.",
      },
      409,
    );
  }

  const expiresAt = new Date(
    Date.now() + 14 * 24 * 60 * 60 * 1000,
  ).toISOString();
  const inviteToken = createInviteToken();

  const { error: inviteError } = await adminClient
    .from("workspace_invites")
    .upsert(
      {
        workspace_id: workspaceId,
        email,
        role,
        invite_token: inviteToken,
        status: "pending",
        invited_by: caller.id,
        invited_user_id: null,
        accepted_at: null,
        expires_at: expiresAt,
      },
      { onConflict: "workspace_id,email" },
    );

  if (inviteError) {
    return json(
      { success: false, message: "Could not save workspace invite." },
      500,
    );
  }

  // Workspace invites are app-opening links, not Supabase Auth links.
  // Sign-in remains the separate Supabase OTP/code flow.
  const encodedInviteToken = encodeURIComponent(inviteToken);
  const inviteUrl = `${publicInviteBaseUrl}?token=${encodedInviteToken}`;
  const directAppUrl = `${customInviteSchemeBaseUrl}?token=${encodedInviteToken}`;
  const inviteEmailError = await sendInviteEmail({
    to: email,
    workspaceName: workspace.name?.toString() ?? "Issued workspace",
    role,
    inviteUrl,
    directAppUrl,
  });

  if (inviteEmailError) {
    return json(
      {
        success: true,
        warning:
          "Invite saved, but email could not be sent. Check Edge Function logs.",
      },
      200,
    );
  }

  return json(
    {
      success: true,
      message:
        "Invite sent. They should open the email and sign in with that email address.",
    },
    200,
  );
});

type InviteRequest = {
  workspaceId?: string;
  email?: string;
  role?: string;
  displayName?: string;
};

function json(payload: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function looksLikeEmail(value: string): boolean {
  return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(value);
}

function isUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(value);
}

function createInviteToken(): string {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return btoa(String.fromCharCode(...bytes))
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");
}

async function sendInviteEmail({
  to,
  workspaceName,
  role,
  inviteUrl,
  directAppUrl,
}: {
  to: string;
  workspaceName: string;
  role: string;
  inviteUrl: string;
  directAppUrl: string;
}): Promise<Error | null> {
  const resendApiKey = Deno.env.get("RESEND_API_KEY");
  if (!resendApiKey) {
    return new Error("RESEND_API_KEY is not configured.");
  }

  const from = Deno.env.get("INVITE_EMAIL_FROM") ??
    "Issued <noreply@issuedinventory.com>";
  const roleLabel = roleLabelFor(role);
  const subject = `You're invited to ${workspaceName} in Issued`;
  const html = inviteEmailHtml({
    workspaceName,
    roleLabel,
    invitedEmail: to,
    inviteUrl,
    directAppUrl,
  });
  const text = [
    "You've been invited to Issued.",
    `Organization: ${workspaceName}`,
    `Role: ${roleLabel}`,
    `Invited email: ${to}`,
    "",
    "Open Issued:",
    inviteUrl,
    "",
    "Open directly in the app:",
    directAppUrl,
    "",
    "If the app does not open, open Issued manually and sign in with this email address.",
  ].join("\n");

  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${resendApiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to,
      subject,
      html,
      text,
    }),
  });

  if (!response.ok) {
    const details = await response.text();
    return new Error(`Resend failed: ${response.status} ${details}`);
  }
  return null;
}

function inviteEmailHtml({
  workspaceName,
  roleLabel,
  invitedEmail,
  inviteUrl,
  directAppUrl,
}: {
  workspaceName: string;
  roleLabel: string;
  invitedEmail: string;
  inviteUrl: string;
  directAppUrl: string;
}): string {
  const safeWorkspace = escapeHtml(workspaceName);
  const safeRole = escapeHtml(roleLabel);
  const safeEmail = escapeHtml(invitedEmail);
  const safeUrl = escapeHtml(inviteUrl);
  const safeDirectAppUrl = escapeHtml(directAppUrl);
  return `
    <div style="font-family:Arial,sans-serif;color:#17212f;line-height:1.5;max-width:560px;margin:0 auto;padding:24px;">
      <div style="font-size:24px;font-weight:700;margin-bottom:18px;">Issued</div>
      <h1 style="font-size:22px;margin:0 0 12px;">You've been invited to Issued</h1>
      <p style="margin:0 0 16px;"><strong>Organization:</strong> ${safeWorkspace}</p>
      <p style="margin:0 0 16px;"><strong>Role:</strong> ${safeRole}<br><strong>Invited email:</strong> ${safeEmail}</p>
      <p style="margin:0 0 22px;">
        <a href="${safeUrl}" style="display:inline-block;background:#1e3a5f;color:#ffffff;text-decoration:none;font-weight:700;padding:12px 18px;border-radius:8px;">Open Issued</a>
      </p>
      <p style="margin:0 0 12px;">
        <a href="${safeDirectAppUrl}" style="color:#1e3a5f;font-weight:700;">Open directly in the app</a>
      </p>
      <p style="margin:0 0 8px;">If the app does not open, open Issued manually and sign in with this email address.</p>
      <p style="margin:0;color:#526173;font-size:13px;">If the button does not work, copy and paste this URL into your browser:<br>${safeUrl}</p>
    </div>
  `;
}

function roleLabelFor(role: string): string {
  if (role === "viewOnly") return "View-only";
  return role.charAt(0).toUpperCase() + role.slice(1);
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}
