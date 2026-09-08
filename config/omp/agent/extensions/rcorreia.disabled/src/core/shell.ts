/** Shell helpers over the live interactive mode. */

import type { ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { getInteractiveMode, type InteractiveModeLike } from "./interactive-mode.ts";

/** Run `work` with the captured mode, or notify when it is unavailable. */
export function withInteractiveMode<T>(
   context: ExtensionContext,
   feature: string,
   work: (mode: InteractiveModeLike) => T,
): T | undefined {
   const mode = getInteractiveMode();
   if (!mode) {
      context.ui.notify(`${feature}: interactive mode is not available.`, "warning");
      return undefined;
   }
   return work(mode);
}