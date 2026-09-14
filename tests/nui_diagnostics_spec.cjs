// Run from the workspace root: node tests/nui_diagnostics_spec.cjs
const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');

const diagnosticsSource = fs.readFileSync('sky_jobs_base/source/html/assets/sky-diagnostics.js', 'utf8');
function fixture(resource, readyFailures = 0) {
  const f = { logs: [], listeners: {}, timers: new Map(), requests: [] };
  let timerId = 0;
  f.reply = (text = '{"success":true}', ok = true) => ({
    ok, status: ok ? 200 : 500, statusText: ok ? 'OK' : 'Server Error',
    text: async () => text, json: async () => JSON.parse(text),
  });
  f.context = vm.createContext({
    console: Object.fromEntries(['log', 'warn', 'error'].map(method => [method, text => f.logs.push(text)])),
    document: { documentElement: { dataset: { skyResource: resource } } },
    GetParentResourceName: () => resource,
    addEventListener: (name, fn) => { f.listeners[name] = fn; },
    setTimeout: fn => { f.timers.set(++timerId, fn); return timerId; },
    clearTimeout: id => f.timers.delete(id),
    fetch: async (url, options) => {
      f.requests.push({ url, options });
      if (url.endsWith('/sжky:diagnostics:ui') && JSON.parse(options.body).stage === 'ready' && readyFailures-- > 0) {
        return { ...f.reply('', false), status: 404 };
      }
      return f.reply();
    },
    EZ: false, OZ: resource, NZ: 'http://localhost:3002', H$: () => resource,
  });
  vm.runInContext('var window = globalThis;', f.context);
  vm.runInContext(diagnosticsSource, f.context);
  f.count = event => f.logs.filter(line => line.includes(`[${event}]`)).length;
  f.has = text => f.logs.some(line => line.includes(text));
  f.logger = f.context.SkyJobsDiagnostics;
  return f;
}

(async () => {
  // Startup can precede native NUI callback registration. Retry 404s, then stop.
  for (const failures of [2, Infinity]) {
    const late = fixture('sky_mechanicjob', failures);
    await new Promise(setImmediate);
    for (let i = 0; i < 9 && late.timers.size; i++) {
      const [id, fn] = late.timers.entries().next().value;
      late.timers.delete(id);
      fn();
      await new Promise(setImmediate);
    }
    assert.equal(late.timers.size, 0);
    if (failures === 2) {
      assert.equal(late.requests.length, 3);
      assert.equal(late.count('logging.lua_connected'), 1);
      assert.equal(late.count('logging.ack_failed'), 0);
    } else {
      assert.equal(late.requests.length, 10);
      assert.equal(late.count('logging.ack_failed'), 1);
      assert(late.has('local source/diagnostics.lua'));
    }
  }
  for (const resource of ['sky_base', 'sky_jobs_base', 'sky_mechanicjob']) {
    const path = `${resource}/source/html/assets/sky-diagnostics.js`;
    assert.equal(fs.readFileSync(path, 'utf8'), diagnosticsSource, 'UI diagnostics must stay synchronized');
    const f = fixture(resource);
    assert(f.has(`[${resource}][NUI][INFO][logging.ready]`));
    assert.equal(f.requests[0].url, `https://${resource}/sky:diagnostics:ui`);
    assert.equal(JSON.parse(f.requests[0].options.body).stage, 'ready');
    f.listeners.message({ data: { type: 'tablet:open', diagnosticId: 'tablet-1', route: '/tablet/mechanic-orders' } });
    assert.equal(f.count('nui.message_received'), 1);
    assert.equal(JSON.parse(f.requests[1].options.body).diagnosticId, 'tablet-1');
    assert.equal(JSON.parse(f.requests[1].options.body).stage, 'received');
    f.listeners.message({ data: { type: 'sky:diagnostics:settings', verbose: false } });
    f.listeners.message({ data: { type: 'hidden-message' } });
    assert.equal(f.count('nui.message_received'), 1);
    f.listeners.error({ target: { tagName: 'AUDIO', src: 'sounds/missing.wav', error: { code: 4 } } });
    f.listeners.error({ target: { tagName: 'SCRIPT', src: 'https://example.test/missing.js?token=DO_NOT_LOG' } });
    f.listeners.error({ error: new Error('UI crashed'), filename: 'ui.js', lineno: 12, colno: 4 });
    f.listeners.unhandledrejection({ reason: new Error('Rejected operation') });
    assert.equal(f.count('media.load_failed'), 1);
    assert.equal(f.count('asset.load_failed'), 1);
    assert.equal(f.count('javascript.error'), 1);
    assert.equal(f.count('promise.unhandled'), 1);
    assert(!f.has('DO_NOT_LOG'));
    let previousCalled = false;
    const app = { config: { errorHandler: () => { previousCalled = true; } } };
    f.logger.attachVue(app);
    app.config.errorHandler(new Error('Render failed'), { $options: { name: 'Camera' } }, 'render');
    assert.equal(f.count('vue.error'), 1);
    assert(previousCalled);
    let navigation, routerError;
    f.logger.attachRouter({ afterEach: fn => { navigation = fn; }, onError: fn => { routerError = fn; } });
    navigation({ path: '/tablet/mechanic-orders', matched: [{}] }, { path: '/' });
    navigation({ path: '/unknown', matched: [] }, { path: '/' });
    routerError(new Error('Router failed'));
    assert.equal(f.count('router.navigation'), 2);
    assert.equal(f.count('router.unmatched'), 1);
    assert.equal(f.count('router.error'), 1);
  }

  const f = fixture('sky_jobs_base');
  const bundle = fs.readFileSync('sky_jobs_base/source/html/assets/sky-index-JneVRsBQ.js', 'utf8');
  const start = bundle.indexOf('async function skyJobsNuiRequest(');
  const end = bundle.indexOf('const wt=', start);
  assert(start > 0 && end > start);
  vm.runInContext(bundle.slice(start, end), f.context);
  vm.runInContext(bundle.slice(bundle.lastIndexOf('// Keep optional shutter audio failures')), f.context);
  f.logger.setVerbose(false);
  f.context.fetch = async (url, options) => {
    f.requests.push({ url, options });
    return f.reply('{"success":true,"data":{"ok":1}}');
  };
  const success = await f.context.je('test:success', { privatePayload: 'DO_NOT_LOG' });
  assert.equal(success.data.ok, 1);
  assert.equal(f.requests.at(-1).options.body, '{"privatePayload":"DO_NOT_LOG"}');
  assert.equal(f.count('callback.completed'), 0);
  f.logger.setVerbose(true);
  await f.context.je('test:verbose');
  assert.equal(f.count('callback.started'), 1);
  assert.equal(f.count('callback.completed'), 1);
  f.logger.setVerbose(false);
  f.context.fetch = async () => f.reply('{"success":false,"error":"callback_not_registered"}');
  assert.equal((await f.context.je('test:missing', {}, 'POST', { logErrors: false })).success, false);
  await f.context.je('test:missing');
  assert.equal(f.count('callback.failed'), 1, 'Duplicate errors should be limited');
  for (const [endpoint, response, expected] of [
    ['test:http', f.reply('Unavailable', false), '500'],
    ['test:empty', f.reply(''), 'Empty response'],
    ['test:json', f.reply('{bad'), 'Invalid JSON'],
  ]) {
    f.context.fetch = async () => response;
    const result = await f.context.je(endpoint);
    assert.equal(result.success, false);
    assert(result.error.includes(expected));
    assert(f.has(`"endpoint":"${endpoint}"`));
  }
  f.context.fetch = async () => { throw new Error('Network unavailable'); };
  assert.equal((await f.context.je('test:network')).success, false);
  assert(f.has('Network unavailable'));
  let finish;
  f.context.fetch = () => new Promise(resolve => { finish = resolve; });
  const pending = f.context.je('test:slow');
  assert.equal(f.timers.size, 1);
  [...f.timers.values()][0]();
  assert.equal(f.count('callback.waiting'), 1);
  finish(f.reply());
  assert.equal((await pending).success, true);
  assert.equal(f.timers.size, 0);
  const sound = { src: 'sounds/camera-sound.wav', currentTime: 4, play: () => Promise.resolve() };
  f.context.skyPlayCameraShutter(sound);
  await new Promise(setImmediate);
  assert.equal(sound.currentTime, 0);
  assert.equal(f.count('camera.shutter_playing'), 1);
  sound.play = () => Promise.reject(Object.assign(new Error('Unsupported source'), { name: 'NotSupportedError' }));
  f.context.skyPlayCameraShutter(sound);
  await new Promise(setImmediate);
  assert.equal(f.count('camera.shutter_failed'), 1);
  sound.play = () => { throw new Error('Synchronous playback failure'); };
  assert.doesNotThrow(() => f.context.skyPlayCameraShutter(sound));
  assert.equal(f.count('camera.shutter_failed'), 2);
  assert(!f.has('DO_NOT_LOG'));

  // Test the actual mechanic bundle transport, including its throwing behavior.
  const mechanic = fixture('sky_mechanicjob');
  const mechanicBundle = fs.readFileSync('sky_mechanicjob/source/html/assets/sky-index-CMGC7Rva.js', 'utf8');
  const mechanicStart = mechanicBundle.indexOf('skyMechanicNuiRequest=async');
  const mechanicEnd = mechanicBundle.indexOf(',Oe=', mechanicStart);
  assert(mechanicStart > 0 && mechanicEnd > mechanicStart);
  vm.runInContext(`const ${mechanicBundle.slice(mechanicStart, mechanicEnd)}; globalThis.mechanicCall=Se;`, mechanic.context);
  assert.equal((await mechanic.context.mechanicCall('orders:getAll')).success, true);
  mechanic.context.fetch = async () => mechanic.reply('{"success":false,"error":"vehicle_missing"}');
  assert.equal((await mechanic.context.mechanicCall('wear:getDiagnostics')).success, false);
  assert.equal(mechanic.count('callback.failed'), 1);
  const originalError = new Error('Connection failed');
  mechanic.context.fetch = async () => { throw originalError; };
  await assert.rejects(mechanic.context.mechanicCall('orders:getAll'), error => error === originalError);
  assert.equal(mechanic.count('callback.exception'), 1);
  assert.equal(mechanic.timers.size, 0);
  console.log('PASS: all three UI loggers, media/assets/JS/promises/Vue/router errors, browser ACK/settings, actual jobs/mechanic transports, slow callbacks, and camera playback.');
})().catch(error => { console.error(error); process.exitCode = 1; });
