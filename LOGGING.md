# Sky resource diagnostics

Logging is enabled by default across `sky_base`, `sky_jobs_base`, and `sky_mechanicjob`.
Each resource now includes its own `source/diagnostics.lua` and loads it first from its own manifest.
Upload the updated files for all three resources, including **each `fxmanifest.lua` and `source/diagnostics.lua`**. Then restart in this order:

```text
restart sky_base
restart sky_jobs_base
restart sky_mechanicjob
```

Read client Lua and browser logs in F8 / NUI DevTools. Read server Lua logs in the server console or txAdmin.
Filter by the resource name, `[ERROR]`, or `tablet_bridge`.

On both client and server, check for `[logging.ready]` with `version: 2` and the message `Resource-local diagnostics loaded`.
If the initializer is missing, `[logging.unavailable]` names the local file to update. Exports, the tablet bridge, and callback registration fall back to native behavior so a missing logger does not stop gameplay registration.
The browser retries its startup acknowledgment up to ten times at 500 ms intervals. A persistent `logging.ack_failed` / 404 means its Lua diagnostics callback is still unavailable.

```text
[sky_mechanicjob][client][INFO][tablet_bridge.open_started][12345ms] ...
[sky_mechanicjob][NUI][ERROR][callback.failed] ...
```

Each Lua log includes the resource, client/server side, severity, event, and elapsed game time.
Handler logs include the original file/line, caller, call ID, and duration. Exceptions include a stack trace.
Browser logs include UTC timestamps, callback names, request IDs, and failure reasons.
Identical frequent messages are limited; later messages include a repeat count.

## Log levels

The default is detailed logging (`2`). To set the level persistently, add one of these to `server.cfg`:

```cfg
setr sky_logs 2 # detailed events, callbacks, SQL await calls and UI requests
# setr sky_logs 1 # startup, tablet status, warnings and errors
# setr sky_logs 0 # warnings and errors
```

Lua reads this setting as it logs. Browser verbosity is synchronized when its diagnostic script starts.
To change browser verbosity immediately, use its NUI DevTools console:

```js
SkyJobsDiagnostics.setVerbose(false) // hide routine messages and request success logs
SkyJobsDiagnostics.setVerbose(true)  // show them
```

The browser helper retains the same name in all three UIs. It labels messages with the actual resource.

## Check the mechanic tablet

Open a mechanic app and follow these events:

1. `tablet.app_owner`: jobs base selected `sky_mechanicjob` as the owner.
2. `tablet_bridge.open_event_received` / `route_resolved`: the mechanic bridge received and resolved the request.
3. `tablet_bridge.open_started`: includes route, app key, a `diagnosticId`, jobs-base state and browser readiness.
4. `tablet_bridge.vehicle_connected`: includes the vehicle handle, network ID and detection method. `no_nearby_vehicle` means the UI can open but vehicle operations may be unavailable.
5. `nui.focus` and `tablet_bridge.messages_sent`: Lua assigned focus and sent the tablet messages.
6. Browser `nui.message_received` and Lua `nui.browser_received`: the browser acknowledged the same `diagnosticId`.
7. Browser `router.navigation`: check the resolved route and that `matched` is greater than zero. `router.unmatched` means the bundle has no matching page.
8. `callback.started` / `callback.completed` or `callback.failed`: inspect the app's subsequent requests.

A browser acknowledgment confirms message receipt. It does not prove that the page rendered correctly or that every gameplay action works.
`nui.browser_no_ack` reports no acknowledgment after ten seconds. `nui.no_reply` reports a Lua NUI handler that has not answered after ten seconds.

General tablet routes use the `sky_jobs_base` export. Check `tablet_bridge.fallback_requested` and `fallback_result`.
The mechanic bridge preserves the requested job color. Mechanic event-prefix checks were corrected so jobs base releases its own UI before mechanic apps launch.
The jobs callback proxy also prevents a second response after jobs base has already replied.

## Coverage and limits

- All 226 existing Lua/config scripts have a `file.started` marker. A marker means chunk execution began; it does not certify successful initialization. Duplicate executions log `loadCount` and a warning.
- Shared instrumentation covers local/network event handlers, commands, exports, threads, timers, state-bag handlers, Sky callbacks, NUI requests/replies/messages/focus, SQL `await` methods, and HTTP callbacks.
- All three UIs report script/style loads, failed resource/media loads, uncaught JavaScript errors, rejected promises and Vue errors. Both tablet routers and callback transports are instrumented.
- Event arguments, NUI request bodies, SQL parameters, HTTP bodies and authorization headers are not dumped by the new instrumentation. Error messages can still contain details supplied by the underlying library.
- Static data, media and compiled game assets cannot execute logs. Browser asset failures are reported where the browser exposes them. Lua syntax errors still appear in FiveM's native startup logs.
- Existing configuration branches can skip optional integrations; a file-start message does not mean that integration was selected.
- The provided UIs contain built bundles without their Vue source project. Preserve the diagnostic hooks when replacing those bundles. `sky-diagnostics.js` is kept identical in all three resources.

The Lua implementation is copied identically to `source/diagnostics.lua` in each resource and is loaded locally by that resource's manifest. The coverage checks verify that the copies stay synchronized.

## Local verification

```sh
lua tests/diagnostics_spec.lua
node tests/nui_diagnostics_spec.cjs
python3 tests/check_scripts.py
```

The behavioral checks use mocked FiveM APIs and browser APIs. They cover routing, focus, callbacks, browser acknowledgments, error paths, return values, and coroutine waits. Regression checks deliberately omit the logger and confirm native tablet exports, proxy setup and the `creator:getPlayerJob` / `creator:getData` server callbacks still work. Startup acknowledgment retries are checked for eventual success and a permanently missing callback.
The stock Lua syntax check normalizes one existing CfxLua optional-chain expression in memory; the actual file keeps its CfxLua syntax.
Live FiveM, database, framework and gameplay verification must be performed on the server.
