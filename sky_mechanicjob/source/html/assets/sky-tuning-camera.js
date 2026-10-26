// Tuning menu camera key (Config.TuningCamera, default H). While the tuning menu has the
// keyboard the game cannot see the key, so the page reports presses to tuning_camera.lua.
(() => {
  let enabled = true;
  let key = 'h';
  let down = false;

  const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'sky_mechanicjob';
  const send = (body) => {
    fetch(`https://${resource}/tuning:rotateCamera`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
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
    if (!enabled || event.repeat || down || event.ctrlKey || event.altKey || event.metaKey) return;
    if (String(event.key || '').toLowerCase() !== key || isTyping(event.target)) return;
    down = true;
    send({ pressed: true, direction: event.shiftKey ? -1 : 1 });
  });

  const release = () => {
    if (!down) return;
    down = false;
    send({ pressed: false });
  };
  window.addEventListener('keyup', (event) => {
    if (String(event.key || '').toLowerCase() === key) release();
  });
  window.addEventListener('blur', release);
})();
