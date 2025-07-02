document.addEventListener('turbo:load', () => {
  const btn = document.querySelector('.btn-theme-toggle');
  if (!btn) return;

  btn.addEventListener('click', (e) => {
    e.preventDefault();

    const current = document.documentElement.getAttribute('data-theme') || 'light'; // default light
    const next = current === 'light' ? 'dark' : 'light';

    document.documentElement.setAttribute('data-theme', next);
    document.cookie = `theme=${next}; path=/; max-age=${60 * 60 * 24 * 365}`;
    fetch('/set-theme', { headers: { 'Accept': 'application/json' } });

    // ✅ Move this inside the click handler:
    const icon = document.querySelector('.theme-icon');
    if (icon) {
      icon.classList.remove('bi-sun', 'bi-moon-stars');
      icon.classList.add(next === 'dark' ? 'bi-sun' : 'bi-moon-stars');
    }
  });
});
