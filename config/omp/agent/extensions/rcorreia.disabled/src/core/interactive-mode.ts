import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { symbolCell } from "./state.ts";
import { CONFIG } from "../config.ts";

/** Runtime members of the host's interactive mode that this extension touches. */
export interface InteractiveModeLike {
   readonly focusedAgentId?: string;
   focusAgentSession(agentId: string): Promise<void>;
   unfocusSession(): Promise<void>;

   chatContainer: unknown;
   pendingMessagesContainer: unknown;
   todoContainer: unknown;
   subagentContainer: unknown;
   btwContainer: unknown;
   omfgContainer: unknown;
   cleanseContainer: unknown;
   errorBannerContainer: unknown;
   modelCycleContainer: unknown;
   deferredCommandContainer: unknown;
   statusContainer: unknown;
   attachmentChipsContainer: unknown;
   hookWidgetContainerAbove: unknown;
   editorContainer: unknown;
   hookWidgetContainerBelow: unknown;
   composer?: { setRuntimeChildren(children: unknown[]): void };
   ui: { requestRender(force?: boolean): void };
}

type ModeListener = (mode: InteractiveModeLike) => void;

// globalThis slots: survive extension reloads.
const CAPTURED = Symbol.for("rcorreia.interactive-mode.captured.v1");
const LISTENERS = Symbol.for("rcorreia.interactive-mode.listeners.v1");
const PATCHED = Symbol.for("rcorreia.interactive-mode.patched.v1");

const captured = symbolCell<InteractiveModeLike>(CAPTURED);
const listeners = symbolCell<Set<ModeListener>>(LISTENERS);

const MOUNT_WARNED = Symbol.for("rcorreia.interactive-mode.mount-warned.v1");
const mountWarned = symbolCell<boolean>(MOUNT_WARNED);

export function getInteractiveMode(): InteractiveModeLike | undefined {
   return captured.get();
}

/** Run listener immediately when the mode exists, else on first capture. */
export function onInteractiveMode(listener: ModeListener): void {
   const current = getInteractiveMode();
   if (current) {
      listener(current);
      return;
   }
   listeners.init(() => new Set<ModeListener>()).add(listener);
}

function capture(mode: InteractiveModeLike): void {
   captured.set(mode);
   const pending = listeners.get();
   listeners.set(undefined);
   if (pending) {
      for (const listener of pending) {
         try {
            listener(mode);
         } catch (error) {
            console.warn(`${CONFIG.logTag} interactive-mode listener failed:`, error);
         }
      }
   }
}

// Host internals; absent target degrades every dependent feature to a warning.
export function watchInteractiveMode(pi: ExtensionAPI): void {
   const prototype = (
      pi.pi as { InteractiveMode?: { prototype?: { init?: (...args: unknown[]) => Promise<unknown> } } }
   ).InteractiveMode?.prototype;
   const init = prototype?.init;

   if (!init) {
      pi.logger.warn(`${CONFIG.logTag} InteractiveMode.init unavailable; OMP internals may have changed.`);
      return;
   }
   const patchable = prototype as { init?: (...args: unknown[]) => Promise<unknown>; [PATCHED]?: boolean };
   if (patchable[PATCHED]) return;

   patchable.init = async function (this: InteractiveModeLike, ...args: unknown[]) {
      const result = await init.apply(this, args);
      capture(this);
      return result;
   };
   patchable[PATCHED] = true;
}

/** Re-mount composer children, omitting HUDs marked invisible. No-op + warning when the host lacks the API. */
export function mountComposer(mode: InteractiveModeLike, visible: { todo: boolean; agents: boolean }): void {
   const setChildren = mode.composer?.setRuntimeChildren;
   if (typeof setChildren !== "function") {
      if (!mountWarned.get()) {
         mountWarned.set(true);
         console.warn(`${CONFIG.logTag} composer.setRuntimeChildren unavailable; HUD toggles disabled.`);
      }
      return;
   }

   // Host-defined child order; absent members drop out.
   setChildren.call(
      mode.composer,
      [
         mode.chatContainer,
         mode.pendingMessagesContainer,
         ...(visible.todo ? [mode.todoContainer] : []),
         ...(visible.agents ? [mode.subagentContainer] : []),
         mode.btwContainer,
         mode.omfgContainer,
         mode.cleanseContainer,
         mode.errorBannerContainer,
         mode.modelCycleContainer,
         mode.deferredCommandContainer,
         mode.statusContainer,
         mode.attachmentChipsContainer,
         mode.hookWidgetContainerAbove,
         mode.editorContainer,
         mode.hookWidgetContainerBelow,
      ].filter(Boolean),
   );
   mode.ui.requestRender(true);
}