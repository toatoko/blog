// Toggle theme on button click
document.addEventListener('click', (e) => {
  const btn = e.target.closest('.btn-theme-toggle');
  if (!btn) return;

  e.preventDefault();

  const current = localStorage.getItem('theme') || 'light';
  const next = current === 'light' ? 'dark' : 'light';

  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('theme', next);

  const icon = btn.querySelector('.theme-icon') || document.querySelector('.theme-icon');
  if (icon) {
    icon.classList.remove('bi-sun', 'bi-moon-stars');
    icon.classList.add(next === 'dark' ? 'bi-sun' : 'bi-moon-stars');
  }
});

// Set theme and icon on every page load (Turbo-compatible)
document.addEventListener('turbo:load', () => {
  const saved = localStorage.getItem('theme') || 'light';
  document.documentElement.setAttribute('data-theme', saved);

  const icon = document.querySelector('.theme-icon');
  if (icon) {
    icon.classList.remove('bi-sun', 'bi-moon-stars');
    icon.classList.add(saved === 'dark' ? 'bi-sun' : 'bi-moon-stars');
  }
});
