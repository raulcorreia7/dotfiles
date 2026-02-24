# Process Management Best Practices

## Problem: Broad Process Killing

Using `pkill` or `killall` without filters is dangerous:
- Kills ALL matching processes system-wide
- Can affect unrelated applications  
- No way to verify you killed the right process
- Race conditions in multi-process environments

## Solution: Targeted PID-Based Management

### 1. Capture PID at Startup

When starting a background process, immediately capture its PID:
- Use process-specific identifiers (port numbers, unique arguments)
- Store PID for later cleanup
- Allow time for process initialization

### 2. Graceful Shutdown Sequence

Always attempt graceful termination before force kill:
1. Send SIGTERM (signal 15) - allows cleanup
2. Wait with timeout (5 seconds typical)
3. Check if process still exists
4. Send SIGKILL (signal 9) only if necessary

### 3. Pattern Matching for Discovery

When PID is unknown, use specific patterns:
- Match on process name + arguments
- Include unique identifiers (ports, PIDs in command line)
- Avoid matching just the executable name
- Example: `myapp.*--port.*8080` not just `myapp`

### 4. Verification

Always verify process termination:
- Check with signal 0 (exists check)
- Wait and re-check
- Handle already-gone processes gracefully

## Key Principles

1. **Target Specific Processes**: Use full command line matching
2. **Track PIDs Explicitly**: Don't rely on pattern matching for known processes
3. **Graceful Before Force**: SIGTERM before SIGKILL
4. **Verify Termination**: Confirm process is gone
5. **Isolate by Design**: Use unique ports/identifiers per test instance

## Anti-Patterns to Avoid

- `pkill process_name` (too broad)
- `killall process_name` (system-wide)
- Immediate SIGKILL (no cleanup)
- Not checking if process exists before killing
- Relying on sleep/heuristics without verification

## Testing Considerations

- Each test should use isolated resources (unique ports)
- Cleanup must be deterministic, not best-effort
- Failed tests should not leak processes
- Process lifetime should match test fixture scope
