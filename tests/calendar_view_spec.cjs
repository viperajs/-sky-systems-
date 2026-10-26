// Run from the workspace root: node tests/calendar_view_spec.cjs
// The calendar's "Add entry" date picker opens below the field and its Select button ends up
// under the tablet's bezel, so a picked date and time were never applied and every entry was
// saved on the selected day at 00:00. The picker now applies each click (auto-apply) and stays
// open (closeOnAutoApply off) so the time can be set too.
const fs = require('node:fs');
const assert = require('node:assert/strict');

const bundle = fs.readFileSync('sky_jobs_base/source/html/assets/sky-index-JneVRsBQ.js', 'utf8');

const label = 'calendar.modal.addEntry.datetimeLabel';
const start = bundle.indexOf(label);
assert.ok(start >= 0, 'calendar date field not found');
const picker = bundle.slice(start, bundle.indexOf('["modelValue"]', start));
assert.ok(picker.includes('"enable-time-picker":!0'), 'time picker');
assert.ok(picker.includes('"auto-apply":!0'), 'the calendar picker does not apply a picked date');
assert.ok(picker.includes('config:{closeOnAutoApply:!1}'), 'the calendar picker closes before the time can be set');

console.log('PASS: the calendar entry date picker applies the picked date and time without its hidden Select button.');
