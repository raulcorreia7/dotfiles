import { spawn } from "node:child_process";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const AUTH_FILE_PATH = join(homedir(), ".local", "share", "opencode", "auth.json");
const PROVIDER_IDS = ["zai-coding-plan", "zai"];
const SERVER_COMMAND = "npx";
const SERVER_ARGS = ["-y", "@z_ai/mcp-server@latest"];

function getEnvValue(name) {
  const value = process.env[name];
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}

function readAuthFile() {
  try {
    const content = readFileSync(AUTH_FILE_PATH, "utf8");
    return JSON.parse(content);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(`Failed to read auth file at ${AUTH_FILE_PATH}: ${message}`);
  }
}

function resolveApiKey() {
  const envApiKey = getEnvValue("Z_AI_API_KEY");
  if (envApiKey) return envApiKey;

  const auth = readAuthFile();
  for (const providerId of PROVIDER_IDS) {
    const key = auth?.[providerId]?.key;
    if (typeof key === "string" && key.trim().length > 0) {
      return key.trim();
    }
  }

  throw new Error(
    `No Z.AI API key found in ${AUTH_FILE_PATH}. Run /connect and select Z.AI Coding Plan, or set Z_AI_API_KEY.`
  );
}

function buildEnvironment() {
  return {
    ...process.env,
    Z_AI_API_KEY: resolveApiKey(),
    Z_AI_MODE: getEnvValue("Z_AI_MODE") ?? "ZAI",
  };
}

function attachSignalHandlers(child) {
  for (const signal of ["SIGINT", "SIGTERM"]) {
    process.on(signal, () => child.kill(signal));
  }
}

function startServer() {
  const child = spawn(SERVER_COMMAND, SERVER_ARGS, {
    env: buildEnvironment(),
    stdio: "inherit",
  });

  attachSignalHandlers(child);

  child.on("error", (error) => {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`[zai-mcp-launcher] Failed to start MCP server: ${message}`);
    process.exit(1);
  });

  child.on("exit", (code, signal) => {
    if (signal) {
      process.kill(process.pid, signal);
      return;
    }
    process.exit(code ?? 1);
  });
}

try {
  startServer();
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`[zai-mcp-launcher] ${message}`);
  process.exit(1);
}
