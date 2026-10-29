// Run from the workspace root: node tests/tuning_camera_key_spec.cjs
// The mechanic UI page reports the tuning free camera key (default H) to tuning_camera.lua while
// the tuning menu has the keyboard: once per press (Shift+H too, held keys do not repeat), never
// while typing in a field, and with the key the menu sends when it opens.
const fs = require('node:fs');
const assert = require('node:assert/strict');
const vm = require('node:vm');

const html = fs.readFileSync('sky_mechanicjob/source/html/index.html', 'utf8');
assert.ok(html.includes('assets/sky-tuning-camera.js'), 'the page does not load the camera key script');

const listeners = {};
const posts = [];
const window = { addEventListener: (type, fn) => { (listeners[type] = listeners[type] || []).push(fn); } };
const context = {
  window,
  GetParentResourceName: () => 'sky_mechanicjob',
  fetch: (url, options) => { posts.push({ url, body: JSON.parse(options.body) }); return Promise.resolve(); },
  JSON,
  String,
};
vm.runInNewContext(fs.readFileSync('sky_mechanicjob/source/html/assets/sky-tuning-camera.js', 'utf8'), context);
const fire = (type, event) => (listeners[type] || []).forEach((fn) => fn(event));
const key = (k, extra = {}) => ({ key: k, target: { tagName: 'DIV' }, ...extra });

// One press is one toggle; holding the key (repeats) and letting go send nothing more.
fire('keydown', key('h'));
fire('keydown', key('h', { repeat: true }));
fire('keyup', key('h'));
assert.equal(posts.length, 1, 'a held key toggled more than once');
assert.equal(posts[0].url, 'https://sky_mechanicjob/tuning:toggleCamera');

posts.length = 0;
fire('keydown', key('H', { shiftKey: true }));
fire('keyup', key('H'));
assert.equal(posts.length, 1, 'Shift+H does not toggle the free camera');

posts.length = 0;
fire('keydown', key('h', { target: { tagName: 'INPUT' } }));
fire('keydown', key('h', { ctrlKey: true }));
fire('keydown', key('g'));
assert.equal(posts.length, 0, 'typing or other keys toggled the camera');

// The menu sends the configured key when it opens.
fire('message', { data: { action: 'tuningCamera:config', payload: { enabled: true, key: 'G' } } });
fire('keydown', key('g'));
fire('keydown', key('h'));
assert.equal(posts.length, 1, 'the configured key is not the one reported');

posts.length = 0;
fire('message', { data: { action: 'tuningCamera:config', payload: { enabled: false, key: 'G' } } });
fire('keydown', key('g'));
assert.equal(posts.length, 0, 'disabled camera still reported');

console.log('PASS: the tuning free camera key is reported once per press (Shift+H too), not while typing, with the configured key.');
