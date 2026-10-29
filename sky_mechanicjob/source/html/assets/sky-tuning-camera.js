// Tuning menu free camera key (Config.TuningCamera, default H; Shift+H too). While the tuning
// menu has the keyboard the game cannot see the key, so the page reports a press to
// tuning_camera.lua, which hands the camera to the player until the key is pressed again.
(() => {
  let enabled = true;
  let key = 'h';

  const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'sky_mechanicjob';
  const send = () => {
    fetch(`https://${resource}/tuning:toggleCamera`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({}),
    }).catch(() => {});
  };

  const isTyping = (target) =>
    !!target && (target.isContentEditable || ['INPUT', 'TEXTAREA', 'SELECT'].includes(target.tagName));

  window.addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.action !== 'tuningCamera:config') return;
    const payload = data.payload || {};
    enabled = payload.enabled !== false;
    if (typeof payload.key === 'string' && payload.key.length > 0) key = payload.key.toLowerCase();
  });

  window.addEventListener('keydown', (event) => {
    if (!enabled || event.repeat || event.ctrlKey || event.altKey || event.metaKey) return;
    if (String(event.key || '').toLowerCase() !== key || isTyping(event.target)) return;
    send();
  });
})();
