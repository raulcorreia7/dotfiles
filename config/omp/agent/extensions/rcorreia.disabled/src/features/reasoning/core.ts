/** Pure reasoning-effort transitions; levels come from whatever the model advertises. */
export type ReasoningLevel = "minimal" | "low" | "medium" | "high" | "xhigh" | "max";
export type ThinkingLevel = "off" | ReasoningLevel | "auto";
export type Direction = -1 | 1;

const REASONING_LEVELS: readonly ReasoningLevel[] = ["minimal", "low", "medium", "high", "xhigh", "max"];
// ponytail: "auto" sits bottom-end (floor); "off" kept for rank fallback only, not cycled.
const THINKING_LEVELS: readonly ThinkingLevel[] = ["auto", "off", ...REASONING_LEVELS];

function isReasoningLevel(value: unknown): value is ReasoningLevel {
   if (typeof value !== "string") return false;

   return (REASONING_LEVELS as readonly string[]).includes(value);
}

function isThinkingLevel(value: unknown): value is ThinkingLevel {
   return value === "off" || value === "auto" || isReasoningLevel(value);
}

function supportedEfforts(thinking: unknown): ReasoningLevel[] {
   let efforts: unknown;
   if (typeof thinking === "object" && thinking !== null && "efforts" in thinking) {
      efforts = thinking.efforts;
   }
   const values = Array.isArray(thinking) ? thinking : Array.isArray(efforts) ? efforts : [];
   return values.filter(isReasoningLevel);
}

export function modelThinkingLevels(model: { thinking?: unknown } | undefined): readonly ThinkingLevel[] {
   const levels = supportedEfforts(model?.thinking);
   return levels.length === 0 ? [] : ["auto", ...levels];
}
/** Host default behind `cE`: explicit defaultLevel, else "high". */
export function modelDefaultLevel(model: { thinking?: unknown } | undefined): ThinkingLevel {
   const thinking = model?.thinking;
   if (typeof thinking === "object" && thinking !== null && "defaultLevel" in thinking) {
      const candidate: unknown = thinking.defaultLevel;
      if (isThinkingLevel(candidate)) return candidate;
   }
   return "high";
}

/** Host readback is lossy: auto mode reports the model default, never "auto". Test seam. */
export function resolveCurrentLevel(
   reported: unknown,
   modelDefault: ThinkingLevel,
   remembered: ThinkingLevel | undefined,
): unknown {
   if (reported === modelDefault && (remembered === "auto" || remembered === undefined)) return "auto";
   return reported;
}

export function nextThinkingLevel(
   current: unknown,
   levels: readonly ThinkingLevel[],
   direction: Direction,
): ThinkingLevel | undefined {
   if (levels.length === 0) return undefined;

   const currentLevel = isThinkingLevel(current) ? current : "off";
   const currentIndex = levels.indexOf(currentLevel);
   if (currentIndex >= 0) {
      // Clamp at both ends; no wrap or toggle.
      const nextIndex = Math.min(Math.max(currentIndex + direction, 0), levels.length - 1);
      return levels[nextIndex];
   }

   const currentRank = THINKING_LEVELS.indexOf(currentLevel);
   if (direction > 0) {
      for (const level of levels) {
         if (THINKING_LEVELS.indexOf(level) > currentRank) return level;
      }
      return levels[levels.length - 1];
   }

   for (let index = levels.length - 1; index >= 0; index -= 1) {
      const level = levels[index];
      if (THINKING_LEVELS.indexOf(level) < currentRank) return level;
   }
   return levels[0];
}