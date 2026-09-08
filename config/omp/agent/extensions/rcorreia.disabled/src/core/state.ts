/** State slot on globalThis under a registered symbol; survives extension reloads. */
export interface Cell<T> {
   get(): T | undefined;
   set(value: T | undefined): void;
   /** Return the existing value, or create and store it on first access. */
   init(create: () => T): T;
}

export function symbolCell<T>(key: symbol): Cell<T> {
   const g = globalThis as typeof globalThis & Record<symbol, unknown>;
   return {
      get: () => g[key] as T | undefined,
      set: (value) => {
         if (value === undefined) delete g[key];
         else g[key] = value;
      },
      init: (create) => {
         const existing = g[key] as T | undefined;
         if (existing !== undefined) return existing;
         const created = create();
         g[key] = created;
         return created;
      },
   };
}