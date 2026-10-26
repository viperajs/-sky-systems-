// Run from the workspace root: node tests/tuning_camera_key_spec.cjs
// The mechanic UI page reports the tuning camera key (default H) to tuning_camera.lua while
// the tuning menu has the keyboard: once per press and on release, never while typing in a
// field, and with the key the menu sends when it opens.
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

fire('keydown', key('h'));
fire('keydown', key('h', { repeat: true }));
fire('keyup', key('h'));
assert.deepEqual(posts.map((p) => p.body), [{ pressed: true, direction: 1 }, { pressed: false }]);
assert.equal(posts[0].url, 'https://sky_mechanicjob/tuning:rotateCamera');

posts.length = 0;
fire('keydown', key('H', { shiftKey: true }));
fire('keyup', key('H'));
assert.deepEqual(posts.map((p) => p.body), [{ pressed: true, direction: -1 }, { pressed: false }], 'Shift+H turns the other way');

posts.length = 0;
fire('keydown', key('h', { target: { tagName: 'INPUT' } }));
fire('keydown', key('h', { ctrlKey: true }));
fire('keydown', key('g'));
assert.equal(posts.length, 0, 'typing or other keys moved the camera');

// The menu sends the configured key when it opens.
fire('message', { data: { action: 'tuningCamera:config', payload: { enabled: true, key: 'G' } } });
fire('keydown', key('g'));
fire('keyup', key('g'));
fire('keydown', key('h'));
assert.deepEqual(posts.map((p) => p.body), [{ pressed: true, direction: 1 }, { pressed: false }]);

posts.length = 0;
fire('message', { data: { action: 'tuningCamera:config', payload: { enabled: false, key: 'G' } } });
fire('keydown', key('g'));
assert.equal(posts.length, 0, 'disabled camera still reported');

console.log('PASS: the tuning camera key is reported on press and release (Shift reverses), not while typing, with the configured key.');
