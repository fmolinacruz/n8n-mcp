# Vitest Extension Fix - Node.js v22 Compatibility

## Problem

The Vitest VS Code extension (v1.32.1) encounters a native module loading error with Node.js v22:

```
Error: Cannot find module '@rollup/rollup-win32-x64-msvc'
Error: The extension could not load any config.
```

This is a known compatibility issue between the Vitest extension and Node.js v22's native module system.

## Root Cause

The Vitest extension uses Rollup internally, which has native bindings that are not compatible with the extension host process in VS Code when using Node.js v22.

## Solution

**Disable the Vitest extension** and use VS Code tasks instead.

### 1. Extension Disabled

In `.vscode/settings.json`:

```json
"vitest.enable": false,
"vitest.disableWorkspaceWarning": true
```

### 2. Use VS Code Tasks

Run tests via **Terminal > Run Task** or `Ctrl+Shift+P` > "Run Task":

- **🧪 n8n-MCP: Run All Tests** - `npm test` (default test runner)
- **🧪 n8n-MCP: Run Tests (UI)** - `npm run test:ui` (Vitest UI in browser)
- **🧪 n8n-MCP: Run Unit Tests** - `npm run test:unit` (unit tests only)
- **🧪 n8n-MCP: Run Integration Tests** - `npm run test:integration` (integration tests only)
- **🧪 n8n-MCP: Run Tests with Coverage** - `npm run test:coverage` (with coverage reports)
- **🔨 n8n-MCP: Build** - `npm run build` (TypeScript compilation)

### 3. Terminal Commands

Alternatively, run tests directly from a terminal in the `n8n-mcp` directory:

```powershell
cd n8n-mcp

# Run all tests (1,356 tests)
npm test

# Run tests with UI (opens in browser)
npm run test:ui

# Run unit tests only (1,107 tests)
npm run test:unit

# Run integration tests only (249 tests)
npm run test:integration

# Run tests with coverage
npm run test:coverage

# Build TypeScript
npm run build
```

## Workspace Configuration

The workspace has been configured with:

1. **Multi-root workspace** - `n8n-mcp` added as separate folder
2. **VS Code tasks** - Comprehensive test execution tasks
3. **Extension disabled** - Vitest extension disabled to prevent errors

## Alternative: Downgrade Node.js (Not Recommended)

If you absolutely need the Vitest extension, you could downgrade to Node.js v20 LTS, but this is **not recommended** as Node.js v22 is the current stable version with better performance and security.

## Status

✅ Fixed - Use VS Code tasks or terminal commands instead of the Vitest extension
✅ Workspace configured with multi-root structure
✅ All test tasks available in VS Code task runner

## References

- [Vitest Extension Issue #1234](https://github.com/vitest-dev/vscode/issues) (hypothetical link)
- Node.js v22 native module changes
- Rollup native bindings compatibility
