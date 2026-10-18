<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
/* ===== Glassmorphism Sidebar ===== */
.sidebar {
  width: 270px;
  min-width: 270px;
  background: linear-gradient(180deg, rgba(15,20,40,.97) 0%, rgba(20,28,55,.97) 50%, rgba(10,15,35,.97) 100%);
  backdrop-filter: blur(20px);
  display: flex;
  flex-direction: column;
  position: sticky;
  top: 0;
  height: 100vh;
  overflow-y: auto;
  overflow-x: hidden;
  border-right: 1px solid rgba(255,255,255,.07);
  box-shadow: 4px 0 32px rgba(0,0,0,.25);
  transition: width .3s cubic-bezier(.4,0,.2,1);
  scrollbar-width: none;
}
.sidebar::-webkit-scrollbar { display: none; }

/* Brand */
.sidebar-brand {
  padding: 28px 22px 22px;
  border-bottom: 1px solid rgba(255,255,255,.07);
  position: relative;
  overflow: hidden;
}
.sidebar-brand::before {
  content: '';
  position: absolute; top: -40px; right: -40px;
  width: 120px; height: 120px;
  background: radial-gradient(circle, rgba(232,130,26,.2) 0%, transparent 70%);
  border-radius: 50%;
  animation: brandGlow 4s ease-in-out infinite alternate;
}
@keyframes brandGlow {
  from { transform: scale(1); opacity: .6; }
  to   { transform: scale(1.3); opacity: 1; }
}

.brand-logo-wrap {
  display: flex; align-items: center; gap: 12px; margin-bottom: 4px;
  text-decoration: none;
}
.brand-icon {
  width: 46px; height: 46px;
  border-radius: 14px;
  display: block; object-fit: cover;
  box-shadow: 0 6px 20px rgba(0,0,0,.4);
  transition: transform .3s cubic-bezier(.4,0,.2,1), box-shadow .3s;
  flex-shrink: 0;
}
.sidebar-brand .brand-icon { margin-bottom: 0; background: none; }
.brand-icon:hover {
  transform: rotate(-8deg) scale(1.12);
  box-shadow: 0 10px 28px rgba(232,130,26,.55);
}
.brand-text h1 {
  color: #fff;
  font-size: 1.25rem;
  font-family: 'Playfair Display', Georgia, serif;
  letter-spacing: -.01em;
  line-height: 1.2;
}
.brand-text p {
  color: rgba(255,255,255,.38);
  font-size: 0.68rem;
  text-transform: uppercase;
  letter-spacing: .12em;
  margin-top: 1px;
}

/* Role badge */
.role-badge {
  display: inline-flex; align-items: center; gap: 6px;
  margin-top: 12px;
  padding: 5px 12px;
  background: rgba(255,255,255,.06);
  border: 1px solid rgba(255,255,255,.1);
  border-radius: 99px;
  font-size: .72rem; color: rgba(255,255,255,.6);
  text-transform: capitalize; letter-spacing: .05em;
  backdrop-filter: blur(8px);
}
.role-dot {
  width: 7px; height: 7px; border-radius: 50%;
  animation: dotPulse 2s ease-in-out infinite;
}
@keyframes dotPulse {
  0%,100% { opacity:1; transform:scale(1); }
  50%      { opacity:.6; transform:scale(.8); }
}
.role-admin    .role-dot { background: #f59e0b; }
.role-donor    .role-dot { background: #10b981; }
.role-receiver .role-dot { background: #3b82f6; }
.role-volunteer .role-dot { background: #8b5cf6; }

/* Nav */
.sidebar-nav { padding: 16px 12px; flex: 1; }

.nav-section {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: .14em;
  color: rgba(255,255,255,.25);
  padding: 14px 12px 6px;
  font-weight: 600;
}

.nav-item {
  display: flex; align-items: center; gap: 11px;
  padding: 11px 14px;
  border-radius: 12px;
  color: rgba(255,255,255,.6);
  font-size: .88rem; font-weight: 400;
  transition: all .25s cubic-bezier(.4,0,.2,1);
  margin-bottom: 3px;
  position: relative;
  overflow: hidden;
  text-decoration: none;
  cursor: pointer;
}
.nav-item::before {
  content: '';
  position: absolute; inset: 0;
  background: linear-gradient(135deg, rgba(255,255,255,.07), rgba(255,255,255,.02));
  opacity: 0;
  transition: opacity .25s;
  border-radius: 12px;
}
.nav-item::after {
  content: '';
  position: absolute; left: 0; top: 20%; bottom: 20%;
  width: 3px;
  background: linear-gradient(180deg, #E8821A, #F5A84C);
  border-radius: 0 3px 3px 0;
  transform: scaleY(0);
  transition: transform .25s cubic-bezier(.4,0,.2,1);
}
.nav-item:hover {
  color: #fff;
  transform: translateX(4px);
  background: rgba(255,255,255,.07);
}
.nav-item:hover::before { opacity: 1; }
.nav-item:hover::after  { transform: scaleY(1); }

.nav-item.active {
  background: linear-gradient(135deg, rgba(232,130,26,.25), rgba(232,130,26,.1));
  color: #fff;
  font-weight: 500;
  border: 1px solid rgba(232,130,26,.2);
  box-shadow: 0 4px 16px rgba(232,130,26,.15), inset 0 1px 0 rgba(255,255,255,.08);
}
.nav-item.active::after { transform: scaleY(1); }
.nav-item.active::before { opacity: 1; }

.nav-item .icon {
  width: 32px; height: 32px;
  display: flex; align-items: center; justify-content: center;
  font-size: 16px;
  background: rgba(255,255,255,.06);
  border-radius: 9px;
  flex-shrink: 0;
  transition: all .25s cubic-bezier(.4,0,.2,1);
  border: 1px solid rgba(255,255,255,.06);
}
.nav-item:hover .icon,
.nav-item.active .icon {
  background: rgba(232,130,26,.2);
  border-color: rgba(232,130,26,.3);
  transform: scale(1.1) rotate(-5deg);
}

/* Separator */
.nav-separator {
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,.08), transparent);
  margin: 10px 12px;
}

/* Footer */
.sidebar-footer {
  padding: 12px 12px 20px;
  border-top: 1px solid rgba(255,255,255,.07);
  background: linear-gradient(0deg, rgba(0,0,0,.2), transparent);
}

/* User info in footer */
.sidebar-user {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 12px; margin-bottom: 6px;
  background: rgba(255,255,255,.04);
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,.06);
}
.sidebar-user-avatar {
  width: 34px; height: 34px; border-radius: 50%;
  background: linear-gradient(135deg, #E8821A, #F5A84C);
  display: flex; align-items: center; justify-content: center;
  font-size: .8rem; font-weight: 700; color: #fff;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(232,130,26,.3);
}
.sidebar-user-info { min-width: 0; }
.sidebar-user-name { color: #fff; font-size: .82rem; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.sidebar-user-role { color: rgba(255,255,255,.38); font-size: .68rem; text-transform: capitalize; }

/* Logout */
.nav-item.logout {
  color: rgba(255,100,100,.7);
  margin-top: 4px;
}
.nav-item.logout:hover {
  color: #ff6b6b;
  background: rgba(255,100,100,.08);
  border-color: rgba(255,100,100,.1);
}
.nav-item.logout:hover .icon {
  background: rgba(255,100,100,.15);
  border-color: rgba(255,100,100,.2);
}
.nav-item.logout::after { background: linear-gradient(180deg, #ff6b6b, #ff4444); }

/* Entrance animation */
.sidebar { animation: sidebarEnter .4s cubic-bezier(.4,0,.2,1) both; }
@keyframes sidebarEnter {
  from { transform: translateX(-20px); opacity: 0; }
  to   { transform: translateX(0); opacity: 1; }
}
.nav-item { animation: navItemEnter .3s ease both; }
.nav-item:nth-child(1)  { animation-delay: .05s; }
.nav-item:nth-child(2)  { animation-delay: .08s; }
.nav-item:nth-child(3)  { animation-delay: .11s; }
.nav-item:nth-child(4)  { animation-delay: .14s; }
.nav-item:nth-child(5)  { animation-delay: .17s; }
.nav-item:nth-child(6)  { animation-delay: .20s; }
.nav-item:nth-child(7)  { animation-delay: .23s; }
@keyframes navItemEnter {
  from { transform: translateX(-12px); opacity: 0; }
  to   { transform: translateX(0); opacity: 1; }
}

/* ===== Mobile drawer ===== */
.sidebar-overlay { display: none; }
@media (max-width: 900px) {
  .sidebar {
    position: fixed; top: 0; left: 0; bottom: 0;
    width: 280px; min-width: 280px; max-width: 85vw;
    height: 100vh; height: 100dvh;
    z-index: 1000;
    transform: translateX(-105%);
    animation: none;            /* the entrance animation would lock the transform */
    transition: transform .3s cubic-bezier(.4,0,.2,1);
  }
  .sidebar.open { transform: translateX(0); box-shadow: 8px 0 40px rgba(0,0,0,.35); }
  .sidebar-overlay {
    display: block; position: fixed; inset: 0; z-index: 999;
    background: rgba(10,15,35,.55); backdrop-filter: blur(2px);
    opacity: 0; pointer-events: none; transition: opacity .3s;
  }
  .sidebar-overlay.open { opacity: 1; pointer-events: auto; }
  body.nav-open { overflow: hidden; }
}
</style>

<div class="sidebar-overlay" id="sidebarOverlay"></div>

<nav class="sidebar">

  <!-- Brand -->
  <div class="sidebar-brand">
    <div class="brand-logo-wrap">
      <img class="brand-icon" src="${pageContext.request.contextPath}/images/logo-mark.png" alt="FoodBridge">
      <div class="brand-text">
        <h1>FoodBridge</h1>
        <p>Food Redistribution</p>
      </div>
    </div>
    <div class="role-badge role-${currentUser.role}">
      <div class="role-dot"></div>
      <c:out value="${currentUser.role}"/>
    </div>
  </div>

  <!-- Nav -->
  <div class="sidebar-nav">
    <c:choose>

      <%-- ADMIN --%>
      <c:when test="${currentUser.role == 'admin'}">
        <div class="nav-section">Main</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/admin/dashboard">
          <span class="icon">📊</span><span>Dashboard</span>
        </a>
        <div class="nav-separator"></div>
        <div class="nav-section">Requests</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/admin/donors">
          <span class="icon">🍱</span><span>Donor Requests</span>
        </a>
        <a class="nav-item" href="${pageContext.request.contextPath}/admin/receivers">
          <span class="icon">🏛️</span><span>Receiver Requests</span>
        </a>
        <a class="nav-item" href="${pageContext.request.contextPath}/admin/assign">
          <span class="icon">🔗</span><span>Assign & Match</span>
        </a>
        <div class="nav-separator"></div>
        <div class="nav-section">Management</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/admin/users">
          <span class="icon">👥</span><span>Manage Users</span>
        </a>
      </c:when>

      <%-- DONOR --%>
      <c:when test="${currentUser.role == 'donor'}">
        <div class="nav-section">Main</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/donor/dashboard">
          <span class="icon">📊</span><span>Dashboard</span>
        </a>
        <div class="nav-separator"></div>
        <div class="nav-section">Actions</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/donor/request">
          <span class="icon">➕</span><span>Donate Food</span>
        </a>
      </c:when>

      <%-- RECEIVER --%>
      <c:when test="${currentUser.role == 'receiver'}">
        <div class="nav-section">Main</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/receiver/dashboard">
          <span class="icon">📊</span><span>Dashboard</span>
        </a>
        <div class="nav-separator"></div>
        <div class="nav-section">Actions</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/receiver/request">
          <span class="icon">📋</span><span>Request Food</span>
        </a>
      </c:when>

      <%-- VOLUNTEER --%>
      <c:when test="${currentUser.role == 'volunteer'}">
        <div class="nav-section">Main</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/volunteer/dashboard">
          <span class="icon">📊</span><span>Dashboard</span>
        </a>
        <div class="nav-separator"></div>
        <div class="nav-section">Tasks</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/volunteer/tasks">
          <span class="icon">🛵</span><span>My Deliveries</span>
        </a>
      </c:when>

    </c:choose>
  </div>

  <!-- Footer -->
  <div class="sidebar-footer">
    <a class="profile-link" href="${pageContext.request.contextPath}/profile" title="View my profile">
    <div class="sidebar-user">
      <div class="sidebar-user-avatar">
        <c:out value="${not empty currentUser.name ? currentUser.name.substring(0,1).toUpperCase() : 'U'}"/>
      </div>
      <div class="sidebar-user-info">
        <div class="sidebar-user-name"><c:out value="${currentUser.name}"/></div>
        <div class="sidebar-user-role"><c:out value="${currentUser.role}"/></div>
      </div>
    </div>
    </a>
    <a class="nav-item logout" href="${pageContext.request.contextPath}/logout">
      <span class="icon">🚪</span><span>Logout</span>
    </a>
  </div>

</nav>

<script>
// Highlight active nav item
(function() {
  const path = window.location.pathname;
  document.querySelectorAll('.nav-item').forEach(item => {
    const href = item.getAttribute('href');
    if (href && path.includes(href.split('?')[0].replace(/.*\//, '/'))) {
      item.classList.add('active');
    }
  });
})();

// Mobile menu: open/close the sidebar drawer
(function () {
  const sb = document.querySelector('.sidebar');
  const ov = document.getElementById('sidebarOverlay');
  if (!sb || !ov) return;
  const setOpen = o => {
    sb.classList.toggle('open', o);
    ov.classList.toggle('open', o);
    document.body.classList.toggle('nav-open', o);
  };
  document.addEventListener('click', e => {
    if (e.target.closest('#menuBtn')) setOpen(!sb.classList.contains('open'));
    else if (e.target.closest('#sidebarOverlay') || e.target.closest('.sidebar .nav-item')) setOpen(false);
  });
  document.addEventListener('keydown', e => { if (e.key === 'Escape') setOpen(false); });
  window.matchMedia('(min-width: 901px)').addEventListener('change', e => { if (e.matches) setOpen(false); });
})();
</script>