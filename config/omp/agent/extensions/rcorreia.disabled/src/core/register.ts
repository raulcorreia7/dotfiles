import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

/**
 * Register one feature in isolation. A throwing registration logs a warning;
 * the remaining features still load.
 */
export function register(
   feature: (pi: ExtensionAPI) => void,
   pi: ExtensionAPI,
): void {
   try {
      feature(pi);
   } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      pi.logger.warn(`rcorreia: feature registration failed: ${message}`);
   }
}