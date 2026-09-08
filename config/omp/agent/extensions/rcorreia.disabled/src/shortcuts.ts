/** Single rebinding point for every chord the rcorreia extension registers.
 *  Keys are `<domain>.<action>`, one domain per feature. */
export const SHORTCUTS = {
   hud: {
      toggleTodo: "alt+t",
      toggleSubagents: "alt+s",
      toggleAll: "alt+h",
   },
   reasoning: {
      decrease: "alt+,",
      increase: "alt+.",
   },
   agentCycle: {
      forward: "alt+right",
      backward: "alt+left",
      home: "alt+up",
   },
} as const;

/** Turns "alt+t" into "Alt+T" for descriptions and help text. */
export function label(chord: string): string {
   return chord
      .split("+")
      .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
      .join("+");
}