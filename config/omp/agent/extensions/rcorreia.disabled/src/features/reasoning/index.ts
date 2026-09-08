import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { symbolCell } from "../../core/state.ts";
import {
   modelDefaultLevel,
   modelThinkingLevels,
   nextThinkingLevel,
   resolveCurrentLevel,
   type Direction,
   type ThinkingLevel,
} from "./core.ts";
import { label, SHORTCUTS } from "../../shortcuts.ts";

const lastSet = symbolCell<ThinkingLevel>(Symbol.for("rcorreia.reasoning.lastSet"));

/** Build a shortcut handler that steps the thinking level one notch. */
function cycleHandler(pi: ExtensionAPI, direction: Direction) {
   return (context: ExtensionContext): void => {
      const model = context.models.current();
      const levels = modelThinkingLevels(model);
      // Host readback is lossy: auto mode reports the model default (e.g. medium), never "auto".
      const current = resolveCurrentLevel(pi.getThinkingLevel(), modelDefaultLevel(model), lastSet.get());
      const next = nextThinkingLevel(current, levels, direction);

      if (next === undefined) {
         context.ui.notify("This model does not support configurable reasoning.", "info");
         return;
      }
      if (next === current) {
         context.ui.notify(`Reasoning: ${next} (${direction > 0 ? "max" : "min"})`, "info");
         return;
      }

      // Host models levels as a string const-enum; values match our vocabulary.
      pi.setThinkingLevel(next as Parameters<typeof pi.setThinkingLevel>[0]);
      lastSet.set(next);
      context.ui.notify(`Reasoning: ${next}`, "info");
   };
}

export function registerReasoningShortcuts(pi: ExtensionAPI): void {
   pi.registerShortcut(SHORTCUTS.reasoning.decrease, {
      description: `Decrease reasoning effort (${label(SHORTCUTS.reasoning.decrease)})`,
      handler: cycleHandler(pi, -1),
   });
   pi.registerShortcut(SHORTCUTS.reasoning.increase, {
      description: `Increase reasoning effort (${label(SHORTCUTS.reasoning.increase)})`,
      handler: cycleHandler(pi, 1),
   });
}