import type { AgentRef } from "@oh-my-pi/pi-coding-agent";

export type { AgentRef };

/** Pure agent-cycle decisions over an AgentRef[] roster. */

export type CycleDirection = -1 | 1;

/**
 * Registry refs that can hold the main view. Advisors are transcript-only
 * rows, the main session is the ambient view, and aborted agents have no
 * live session to ensure.
 */
const UNFOCUSABLE_KINDS: Record<string, true> = {
   advisor: true,
   main: true,
};
const UNFOCUSABLE_STATUSES: Record<string, true> = {
   aborted: true,
};

export function isFocusable(ref: AgentRef): boolean {
   const kindAllowed = !UNFOCUSABLE_KINDS[ref.kind];
   const statusAllowed = !UNFOCUSABLE_STATUSES[ref.status];

   return kindAllowed && statusAllowed;
}

/** Stable roster order: spawn time first, id as tiebreaker. */
export function bySpawnOrder(a: AgentRef, b: AgentRef): number {
   const byTime = (a.createdAt ?? 0) - (b.createdAt ?? 0);
   if (byTime !== 0) return byTime;

   return a.id.localeCompare(b.id);
}

export function focusableAgents(agents: AgentRef[]): AgentRef[] {
   return agents.filter(isFocusable).sort(bySpawnOrder);
}

/** Wrap-aware neighbor selection; an unfocused view enters from the near edge. */
export function neighborAgentId(
   agents: AgentRef[],
   focusedId: string | undefined,
   direction: CycleDirection,
): string {
   const index = focusedId
      ? agents.findIndex((agent) => agent.id === focusedId)
      : -1;
   if (index < 0) {
      return direction > 0 ? agents[0].id : agents[agents.length - 1].id;
   }
   const next = (index + direction + agents.length) % agents.length;
   return agents[next].id;
}