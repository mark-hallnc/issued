import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const allowedRoles = new Set(["admin", "manager", "worker", "viewOnly"]);

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
  const displayName = body.displayName?.trim();

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

  const { error: inviteError } = await adminClient
    .from("workspace_invites")
    .upsert(
      {
        workspace_id: workspaceId,
        email,
        role,
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

  const redirectTo = Deno.env.get("INVITE_REDIRECT_URL") ?? undefined;
  const { error: inviteEmailError } =
    await adminClient.auth.admin.inviteUserByEmail(email, {
      data: {
        workspace_id: workspaceId,
        role,
        display_name: displayName,
      },
      redirectTo,
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

  return json({ success: true, message: "Invite sent." }, 200);
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
