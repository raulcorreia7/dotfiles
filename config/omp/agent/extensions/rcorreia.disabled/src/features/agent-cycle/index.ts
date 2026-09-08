import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { withInteractiveMode } from "../../core/shell.ts";
import { CONFIG } from "../../config.ts";
import { getInteractiveMode } from "../../core/interactive-mode.ts";
import { focusableAgents, neighborAgentId, type AgentRef, type CycleDirection } from "./core.ts";
import { SHORTCUTS } from "../../shortcuts.ts";

interface AgentRegistryLike {
   global(): { list(): AgentRef[] };
}

async function focusNeighbor(context: ExtensionContext, registry: AgentRegistryLike, direction: CycleDirection): Promise<void> {
   await withInteractiveMode(context, "Agent cycling", async (mode) => {
      const agents = focusableAgents(registry.global().list());
      if (agents.length === 0) {
         context.ui.notify("No subagents in this session.", "info");
         return;
      }

      try {
         await mode.focusAgentSession(neighborAgentId(agents, mode.focusedAgentId, direction));
      } catch (error) {
         context.ui.notify(`Agent focus failed: ${error instanceof Error ? error.message : String(error)}`, "warning");
      }
   });
}

async function returnToMain(context: ExtensionContext): Promise<void> {
   const mode = getInteractiveMode();
   if (!mode?.focusedAgentId) return;

   try {
      await mode.unfocusSession();
   } catch (error) {
      context.ui.notify(`Return to main failed: ${error instanceof Error ? error.message : String(error)}`, "warning");
   }
}

export function registerAgentCycling(pi: ExtensionAPI): void {
   const registry = (pi.pi as { AgentRegistry?: AgentRegistryLike }).AgentRegistry;
   if (!registry) {
      pi.logger.warn(`${CONFIG.logTag} AgentRegistry export unavailable; agent cycling disabled.`);
      return;
   }

   pi.registerShortcut(SHORTCUTS.agentCycle.forward, {
      description: "View next subagent",
      handler: (context) => focusNeighbor(context, registry, 1),
   });
   pi.registerShortcut(SHORTCUTS.agentCycle.backward, {
      description: "View previous subagent",
      handler: (context) => focusNeighbor(context, registry, -1),
   });
   pi.registerShortcut(SHORTCUTS.agentCycle.home, {
      description: "Return to main session",
      handler: (context) => returnToMain(context),
   });
}