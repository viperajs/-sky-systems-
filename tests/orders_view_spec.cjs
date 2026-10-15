// Run from the workspace root: node tests/orders_view_spec.cjs
// Drives the Install button handler of the mechanic tablet's Orders view, taken from the built
// UI bundle: Install works without a connected vehicle (the client finds the order's car) and
// says when the order's car is not nearby.
const fs = require('node:fs');
const assert = require('node:assert/strict');

const bundle = fs.readFileSync('sky_mechanicjob/source/html/assets/sky-index-CMGC7Rva.js', 'utf8');

// The Install button no longer stays grey until a vehicle is connected.
assert.ok(bundle.includes('disabled:!V.value||Ce.installed===!0||M.value===`${U.value.id}-${He}`'), 'Install button condition');
assert.ok(!bundle.includes('disabled:!V.value||!w(r)||Ce.installed'), 'Install still requires a connected vehicle');

// The handler source: "R=async(oe,ue)=>{...}" up to its closing brace.
const start = bundle.indexOf('R=async(oe,ue)=>{if(!U.value)return;');
assert.ok(start >= 0, 'Install handler not found');
let end = -1;
for (let i = bundle.indexOf('{', start), depth = 0; i < bundle.length; i++) {
  const c = bundle[i];
  if (c === '"' || c === '`') {
    i++;
    while (bundle[i] !== c) i += bundle[i] === '\\' ? 2 : 1;
  } else if (c === '{') {
    depth++;
  } else if (c === '}' && --depth === 0) {
    end = i + 1;
    break;
  }
}
const handlerSource = bundle.slice(start + 2, end);

// Runs the handler for part 1 of order 7 (plate TEST 123) and records what it does.
async function install({ connected = null, reply }) {
  const f = { requests: [], messages: [], closed: false };
  const make = new Function('U', 'r', 'V', 'M', 'we', 'Se', 'L', 'fe', 'te', `return ${handlerSource}`);
  const handler = make(
    { value: { id: 7, plate: 'TEST 123' } },
    { value: connected },
    { value: true },
    { value: '' },
    (key, fallback, type, params) => f.messages.push({ key, fallback, type, params }),
    async (name, payload) => { f.requests.push({ name, payload }); return reply; },
    async () => { f.closed = true; },
    item => `item:${item}`,
    { value: 'Unknown' },
  );
  await handler({ requiredItem: 'engine' }, 0);
  return f;
}

(async () => {
  // Nothing connected: the install starts and the client picks the order's car.
  let f = await install({ reply: { success: true } });
  assert.deepEqual(f.requests, [{ name: 'orders:startInstall', payload: { orderId: 7, partIndex: 1, vehicleNetId: 0 } }]);
  assert.equal(f.messages[0].key, 'tablet.orders.installStarted');
  assert.ok(f.closed, 'the tablet closes so the steps can be done');

  // A connected vehicle is still passed along.
  f = await install({ connected: { netId: 109, plate: 'TEST 123' }, reply: { success: true } });
  assert.equal(f.requests[0].payload.vehicleNetId, 109);

  // The order's car is not near: its plate is named, the tablet stays open.
  f = await install({ reply: { success: false, error: 'vehicle_not_found', plate: 'TEST 123' } });
  assert.deepEqual(f.messages, [{
    key: 'tablet.orders.vehicleNotNearby',
    fallback: "The order's vehicle ({plate}) is not nearby. Bring it closer and press Install again.",
    type: 'warning',
    params: { plate: 'TEST 123' },
  }]);
  assert.ok(!f.closed);

  f = await install({ reply: { success: false, error: 'vehicle_too_far' } });
  assert.equal(f.messages[0].key, 'tablet.orders.vehicleNotNearby');
  assert.deepEqual(f.messages[0].params, { plate: 'TEST 123' }, 'the selected order gives the plate');

  // Unchanged: a missing part and other errors.
  f = await install({ reply: { success: false, error: 'missing_item', requiredItem: 'engine' } });
  assert.equal(f.messages[0].key, 'tablet.orders.missingItemWithName');
  assert.deepEqual(f.messages[0].params, { item: 'item:engine' });
  f = await install({ reply: { success: false, error: 'unauthorized' } });
  assert.equal(f.messages[0].key, 'tablet.orders.installStartFailed');

  console.log('PASS: Orders view Install without a connected vehicle, the connected vehicle passed along, the order\'s car out of reach named by its plate, missing part and other errors.');
})().catch(error => {
  console.error(error);
  process.exit(1);
});
