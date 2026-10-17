function csrfHeaders(){const t=document.querySelector('meta[name="_csrf"]');const h=document.querySelector('meta[name="_csrf_header"]');return t&&h?{[h.content]:t.content}:{};}
/* FoodBridge — Main JS */

// ===== Notification Panel =====
function initNotifications() {
  const btn   = document.getElementById('notifBtn');
  const panel = document.getElementById('notifPanel');
  if (!btn || !panel) return;

  btn.addEventListener('click', (e) => {
    e.stopPropagation();
    panel.classList.toggle('open');
    if (panel.classList.contains('open')) {
      loadNotifications();
    }
  });

  document.addEventListener('click', () => panel.classList.remove('open'));
  panel.addEventListener('click', e => e.stopPropagation());
  document.getElementById('markAllRead')?.addEventListener('click', () => {
    fetch(contextPath + '/notifications', { method: 'POST', headers: csrfHeaders() })
      .then(() => { loadNotifications(); updateBadge(0); });
  });
}

function loadNotifications() {
  fetch(contextPath + '/notifications')
    .then(r => r.json())
    .then(data => {
      const list = document.getElementById('notifList');
      if (!list) return;
      updateBadge(data.unreadCount);
      if (data.notifications.length === 0) {
        list.innerHTML = '<div class="empty-state" style="padding:30px"><div class="empty-icon">🔔</div><p>No notifications yet</p></div>';
        return;
      }
      list.innerHTML = data.notifications.map(n => `
        <div class="notif-item ${n.read ? '' : 'unread'}">
          <p>${escHtml(n.message)}</p>
          <time>${timeAgo(n.createdAt)}</time>
        </div>
      `).join('');
    }).catch(() => {});
}

function updateBadge(count) {
  const badge = document.getElementById('notifBadge');
  if (!badge) return;
  badge.textContent = count;
  badge.style.display = count > 0 ? 'flex' : 'none';
}

function timeAgo(ts) {
  if (!ts) return '';
  const d = new Date(ts);
  const diff = (Date.now() - d) / 1000;
  if (diff < 60) return 'just now';
  if (diff < 3600) return Math.floor(diff/60) + 'm ago';
  if (diff < 86400) return Math.floor(diff/3600) + 'h ago';
  return d.toLocaleDateString();
}

function escHtml(str) {
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

// ===== Flash message auto-dismiss =====
function initAlerts() {
  document.querySelectorAll('.alert-auto').forEach(el => {
    setTimeout(() => {
      el.style.transition = 'opacity .4s';
      el.style.opacity = '0';
      setTimeout(() => el.remove(), 400);
    }, 4000);
  });
}

// ===== Confirm dialogs for destructive actions =====
function initConfirm() {
  document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', e => {
      if (!confirm(el.dataset.confirm || 'Are you sure?')) e.preventDefault();
    });
  });
}

// ===== Animate on scroll / initial render =====
function initAnimations() {
  document.querySelectorAll('.stat-card, .card').forEach((el, i) => {
    el.style.animationDelay = (i * 0.06) + 's';
    el.classList.add('animate-in');
  });
}

// ===== Form validation hints =====
function initForms() {
  document.querySelectorAll('form').forEach(form => {
    form.addEventListener('submit', () => {
      form.querySelectorAll('[required]').forEach(input => {
        if (!input.value.trim()) {
          input.style.borderColor = '#EF4444';
          input.addEventListener('input', () => input.style.borderColor = '', { once: true });
        }
      });
    });
  });
}

// ===== Sidebar active nav =====
function initNav() {
  const path = window.location.pathname;
  document.querySelectorAll('.nav-item').forEach(item => {
    if (item.getAttribute('href') && path.includes(item.getAttribute('href').split('?')[0])) {
      item.classList.add('active');
    }
  });
}

// ===== Progress bars =====
function initProgressBars() {
  document.querySelectorAll('[data-progress]').forEach(el => {
    const target = parseInt(el.dataset.progress);
    setTimeout(() => { el.style.width = target + '%'; }, 200);
  });
}

// ===== Init =====
document.addEventListener('DOMContentLoaded', () => {
  initNotifications();
  initAlerts();
  initConfirm();
  initAnimations();
  initForms();
  initNav();
  initProgressBars();

  // Poll notifications every 60s
  if (typeof contextPath !== 'undefined') {
    setInterval(loadNotifications, 60000);
  }
});
