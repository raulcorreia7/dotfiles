/** Pure HUD visibility: state reducer and /hud argument parsing. */
export type HudTarget = "todo" | "agents" | "all";
export type HudAction = "toggle" | "show" | "hide";

export interface HudState {
   todoVisible: boolean;
   agentsVisible: boolean;
}

const FIXED_VISIBILITY: Partial<Record<HudAction, boolean>> = { show: true, hide: false };

/** Apply one (target, action) to a state, returning the next state. */
export function reduceHudState(state: HudState, target: HudTarget, action: HudAction): HudState {
   if (target === "todo") {
      return { ...state, todoVisible: FIXED_VISIBILITY[action] ?? !state.todoVisible };
   }
   if (target === "agents") {
      return { ...state, agentsVisible: FIXED_VISIBILITY[action] ?? !state.agentsVisible };
   }
   if (action === "toggle") {
      // "all" toggle is one master switch: if both visible, hide; otherwise show both.
      const visible = !(state.todoVisible && state.agentsVisible);
      return { todoVisible: visible, agentsVisible: visible };
   }
   const visible = action === "show";
   return { todoVisible: visible, agentsVisible: visible };
}

export function hudStateText(state: HudState): string {
   return `HUD: TODO ${state.todoVisible ? "shown" : "hidden"} · Subagents ${state.agentsVisible ? "shown" : "hidden"}`;
}

const TARGET_ALIASES: Record<string, HudTarget> = {
   todo: "todo",
   todos: "todo",
   agent: "agents",
   agents: "agents",
   subagent: "agents",
   subagents: "agents",
   all: "all",
   both: "all",
};

const ACTION_ALIASES: Record<string, HudAction> = {
   toggle: "toggle",
   show: "show",
   on: "show",
   hide: "hide",
   off: "hide",
};

interface HudArgs {
   target?: HudTarget;
   action?: HudAction;
}

export function parseHudArgs(args: string): HudArgs {
   const parts = args.trim().toLowerCase().split(/\s+/).filter(Boolean);
   if (parts.length === 0) return {};

   return {
      target: TARGET_ALIASES[parts[0]],
      action: parts[1] ? ACTION_ALIASES[parts[1]] : "toggle",
   };
}