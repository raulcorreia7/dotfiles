import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { symbolCell } from "../../core/state.ts";
import { withInteractiveMode } from "../../core/shell.ts";
import { mountComposer, onInteractiveMode, type InteractiveModeLike } from "../../core/interactive-mode.ts";
import { label, SHORTCUTS } from "../../shortcuts.ts";
import { CONFIG } from "../../config.ts";
import {
   reduceHudState,
   hudStateText,
   parseHudArgs,
   type HudAction,
   type HudState,
   type HudTarget,
} from "./core.ts";

const HUD_USAGE = "Usage: /hud [todo|agents|all] [toggle|show|hide]";

const STATE = Symbol.for("rcorreia.hud-toggle.state.v1");
const hudState = symbolCell<HudState>(STATE);
const getState = () => hudState.init(() => ({ ...CONFIG.hud }));

// Push current visibility into the host composer.
function applyHudState(mode: InteractiveModeLike): void {
   const s = getState();
   mountComposer(mode, { todo: s.todoVisible, agents: s.agentsVisible });
}

function applyAndNotify(context: ExtensionContext, target: HudTarget, action: HudAction): void {
   withInteractiveMode(context, "HUD toggle", (mode) => {
      const next = reduceHudState(getState(), target, action);
      hudState.set(next);
      applyHudState(mode);
      context.ui.notify(hudStateText(next), "info");
   });
}

export function registerHudToggle(pi: ExtensionAPI): void {
   pi.setLabel("HUD Toggle");

   // Apply visibility once the live mode exists (immediately if already captured).
   onInteractiveMode(applyHudState);

   pi.registerShortcut(SHORTCUTS.hud.toggleTodo, {
      description: "Toggle TODO HUD",
      handler: (context) => applyAndNotify(context, "todo", "toggle"),
   });
   pi.registerShortcut(SHORTCUTS.hud.toggleSubagents, {
      description: "Toggle Subagents HUD",
      handler: (context) => applyAndNotify(context, "agents", "toggle"),
   });
   pi.registerShortcut(SHORTCUTS.hud.toggleAll, {
      description: "Toggle TODO + Subagents HUDs",
      handler: (context) => applyAndNotify(context, "all", "toggle"),
   });

   pi.registerCommand("hud", {
      description: "Show/hide TODO and Subagents HUDs",
      handler: async (args, context) => {
         const parsed = parseHudArgs(args);
         if (!parsed.target) {
            const help = `${label(SHORTCUTS.hud.toggleTodo)} TODO · ${label(SHORTCUTS.hud.toggleSubagents)} Subagents · ${label(SHORTCUTS.hud.toggleAll)} both`;
            context.ui.notify(args.trim() ? HUD_USAGE : `${hudStateText(getState())}\n${help}`, "warning");
            return;
         }
         if (!parsed.action) {
            context.ui.notify(HUD_USAGE, "warning");
            return;
         }
         applyAndNotify(context, parsed.target, parsed.action);
      },
   });
}