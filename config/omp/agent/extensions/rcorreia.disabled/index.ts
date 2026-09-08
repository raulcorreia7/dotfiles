import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { watchInteractiveMode } from "./src/core/interactive-mode.ts";
import { register } from "./src/core/register.ts";
import { registerHudToggle } from "./src/features/hud/index.ts";
import { registerReasoningShortcuts } from "./src/features/reasoning/index.ts";
import { registerAgentCycling } from "./src/features/agent-cycle/index.ts";

export default function rcorreiaExtension(pi: ExtensionAPI): void {
   pi.setLabel("rcorreia");

   // Outside register(): failure here disables every feature.
   watchInteractiveMode(pi);

   register(registerHudToggle, pi);
   register(registerReasoningShortcuts, pi);
   register(registerAgentCycling, pi);
}