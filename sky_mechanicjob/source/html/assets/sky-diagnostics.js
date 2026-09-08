// Shared NUI diagnostics for Sky resources. Copied identically into each UI.
(() => {
  if (globalThis.SkyJobsDiagnostics) return;

  const resource = typeof GetParentResourceName === "function"
    ? GetParentResourceName()
    : document.documentElement.dataset.skyResource || "sky_jobs_base";
  let verbose = true;
  let requestId = 0;
  const recent = new Map();
  const sourceUrl = (value) => String(value || "unknown").split(/[?#]/)[0];
  const errorDetails = (error) => ({
    name: error && error.name ? String(error.name) : "Error",
    message: (error && (error.message || error.fallback || error.key || error.code)
      ? String(error.message || error.fallback || error.key || error.code)
      : String(error ?? "Unknown error")).slice(0, 1500),
    stack: error && error.stack ? String(error.stack).slice(0, 2500) : undefined,
  });

  function log(level, event, details = {}) {
    if (level === "debug" && !verbose) return;
    try {
      if (level === "error" || level === "warn") {
        const key = JSON.stringify([event, details.endpoint, details.source, details.name, details.message]);
        const previous = recent.get(key);
        if (previous && Date.now() - previous.time < 5000) {
          previous.repeats += 1;
          return;
        }
        if (previous && previous.repeats) details = { ...details, repeatsSinceLastLog: previous.repeats };
        recent.delete(key);
        recent.set(key, { time: Date.now(), repeats: 0 });
        if (recent.size > 100) recent.delete(recent.keys().next().value);
      }
      const output = `[${resource}][NUI][${level.toUpperCase()}][${event}] ${new Date().toISOString()} ${JSON.stringify(details)}`;
      // One string keeps details readable in FiveM's console instead of [object Object].
      const method = level === "error" ? "error" : level === "warn" ? "warn" : "log";
      console[method](output);
    } catch (_) {
      // Diagnostics must never interrupt the UI action being observed.
    }
  }

  async function traceRequest(endpoint, method, run) {
    const id = ++requestId;
    const started = Date.now();
    const context = { requestId: id, endpoint, method };
    let slow = false;
    log("debug", "callback.started", context);
    const timer = setTimeout(() => {
      slow = true;
      log("warn", "callback.waiting", {
        ...context, elapsedMs: Date.now() - started,
        message: "Still waiting for a response. Check this NUI callback and the client/server console.",
      });
    }, 10000);
    try {
      const result = await run();
      const timing = { ...context, elapsedMs: Date.now() - started };
      if (result && result.success === false) {
        log("error", "callback.failed", { ...timing, ...errorDetails(result.error || "Callback returned success=false") });
      } else {
        log(slow || endpoint === "uiReady" ? "info" : "debug", "callback.completed", timing);
      }
      return result;
    } catch (error) {
      log("error", "callback.exception", { ...context, elapsedMs: Date.now() - started, ...errorDetails(error) });
      throw error;
    } finally {
      clearTimeout(timer);
    }
  }

  function attachVue(app) {
    const previous = app.config.errorHandler;
    app.config.errorHandler = (error, instance, info) => {
      const options = instance && instance.$options;
      log("error", "vue.error", {
        ...errorDetails(error),
        component: options && (options.name || options.__name) || "anonymous",
        context: info,
      });
      if (previous) previous(error, instance, info);
    };
  }

  function attachRouter(router) {
    router.afterEach((to, from, failure) => {
      log(failure ? "warn" : "info", "router.navigation", {
        route: to.path, previousRoute: from.path,
        matched: to.matched ? to.matched.length : undefined,
        message: failure ? String(failure.message || failure) : "Route navigation completed.",
      });
      if (!failure && to.matched && to.matched.length === 0) {
        log("error", "router.unmatched", { route: to.path, message: "No UI page matches this route." });
      }
    });
    router.onError((error) => log("error", "router.error", errorDetails(error)));
  }

  function notifyLua(data, attempt = 1) {
    if (typeof GetParentResourceName !== "function") return;
    const handleFailure = (details) => {
      if (data.stage === "ready" && attempt < 10) {
        log("debug", "logging.waiting_for_lua", { ...details, attempt });
        setTimeout(() => notifyLua(data, attempt + 1), 500);
      } else {
        log("warn", "logging.ack_failed", {
          ...details, attempt,
          hint: "Check this resource's local source/diagnostics.lua and fxmanifest.lua, then restart it.",
        });
      }
    };
    fetch(`https://${resource}/sky:diagnostics:ui`, {
      method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(data),
    }).then((response) => {
      if (!response.ok) handleFailure({ status: response.status });
      else if (attempt > 1) log("info", "logging.lua_connected", { attempt });
    }).catch((error) => handleFailure(errorDetails(error)));
  }

  globalThis.SkyJobsDiagnostics = {
    log, errorDetails, sourceUrl, traceRequest, attachVue, attachRouter,
    setVerbose(enabled) {
      verbose = enabled === true;
      log("info", "logging.settings", { verbose });
    },
  };

  window.addEventListener("error", (event) => {
    const target = event.target;
    if (target && target !== window && target.tagName) {
      const media = target.tagName === "AUDIO" || target.tagName === "VIDEO";
      const mediaReasons = {
        1: "Playback was aborted.",
        2: "A network error stopped media loading.",
        3: "The media could not be decoded.",
        4: "The media source is missing or its format is unsupported.",
      };
      log("error", media ? "media.load_failed" : "asset.load_failed", {
        source: sourceUrl(target.currentSrc || target.src || target.href),
        element: target.tagName,
        mediaErrorCode: media && target.error ? target.error.code : undefined,
        message: media ? mediaReasons[target.error && target.error.code] || "Media failed to load." : "UI file failed to load.",
        hint: "Check that the file/URL exists and local files are included in fxmanifest.lua.",
      });
      return;
    }
    log("error", "javascript.error", {
      ...errorDetails(event.error || event.message),
      source: sourceUrl(event.filename), line: event.lineno, column: event.colno,
    });
  }, true);

  window.addEventListener("unhandledrejection", (event) => {
    log("error", "promise.unhandled", errorDetails(event.reason));
  });

  window.addEventListener("load", (event) => {
    const target = event.target;
    if (target && (target.tagName === "SCRIPT" || target.tagName === "LINK")) {
      log("debug", "asset.loaded", { source: sourceUrl(target.src || target.href), element: target.tagName });
    }
  }, true);

  window.addEventListener("message", (event) => {
    const data = event.data;
    if (!data || typeof data !== "object") return;
    if (data.type === "sky:diagnostics:settings") {
      globalThis.SkyJobsDiagnostics.setVerbose(data.verbose === true);
      return;
    }
    const nested = data.data && typeof data.data === "object" ? data.data : {};
    log("debug", "nui.message_received", {
      type: data.type || data.action, route: data.route || nested.route,
      appKey: data.appKey || nested.appKey, diagnosticId: data.diagnosticId,
    });
    if (typeof data.diagnosticId === "string") {
      notifyLua({ stage: "received", diagnosticId: data.diagnosticId });
    }
  });

  log("info", "logging.ready", {
    resource, message: "Detailed UI logging enabled. SkyJobsDiagnostics.setVerbose(false) hides routine callback logs.",
  });
  notifyLua({ stage: "ready" });
})();
