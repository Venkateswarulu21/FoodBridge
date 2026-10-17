<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
/* ===== Glassmorphism Topbar ===== */
.topbar {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 32px;
  padding: 16px 24px;
  background: rgba(255,253,249,.65);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255,255,255,.6);
  border-radius: 18px;
  box-shadow: 0 4px 24px rgba(26,26,46,.07), inset 0 1px 0 rgba(255,255,255,.8);
  animation: topbarSlide .4s cubic-bezier(.4,0,.2,1) both;
  position: relative;
  z-index: 50;            /* keep the notification panel above the page content */
}
.topbar::before {
  content: '';
  position: absolute; top: 0; left: 0; right: 0; height: 2px;
  background: linear-gradient(90deg, transparent, var(--saffron), var(--forest-light), transparent);
  opacity: .6;
  border-radius: 18px 18px 0 0;
}
@keyframes topbarSlide {
  from { opacity: 0; transform: translateY(-12px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* Left side */
.topbar-left { display: flex; flex-direction: column; gap: 3px; }
.breadcrumb {
  display: flex; align-items: center; gap: 6px;
  font-size: .76rem; color: var(--muted);
}
.breadcrumb .sep { color: var(--saffron); opacity: .5; }
.breadcrumb .current { color: var(--charcoal); font-weight: 500; }
.topbar-left h2 {
  font-size: 1.5rem; color: var(--charcoal);
  font-family: 'Playfair Display', Georgia, serif;
  letter-spacing: -.01em; line-height: 1.2;
}
.topbar-left p { color: var(--muted); font-size: .83rem; margin-top: 1px; }

/* Right side */
.topbar-right {
  display: flex; align-items: center; gap: 12px;
  position: relative;
}

/* ===== Notification Bell ===== */
.notif-btn {
  position: relative;
  width: 42px; height: 42px;
  background: rgba(255,255,255,.7);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,.8);
  border-radius: 12px;
  cursor: pointer;
  font-size: 18px;
  display: flex; align-items: center; justify-content: center;
  transition: all .25s cubic-bezier(.4,0,.2,1);
  box-shadow: 0 2px 8px rgba(26,26,46,.08);
  color: var(--charcoal);
}
.notif-btn:hover {
  background: rgba(232,130,26,.1);
  border-color: rgba(232,130,26,.3);
  transform: scale(1.08);
  box-shadow: 0 4px 16px rgba(232,130,26,.2);
}
.notif-btn:hover .bell-icon { animation: bellRing .4s ease; }
@keyframes bellRing {
  0%,100% { transform: rotate(0); }
  20%      { transform: rotate(-20deg); }
  40%      { transform: rotate(20deg); }
  60%      { transform: rotate(-10deg); }
  80%      { transform: rotate(10deg); }
}
.bell-icon { display: inline-block; transition: transform .2s; }

.notif-badge {
  position: absolute; top: -4px; right: -4px;
  background: linear-gradient(135deg, #EF4444, #DC2626);
  color: #fff; font-size: .58rem; font-weight: 700;
  width: 18px; height: 18px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  border: 2px solid #fff;
  box-shadow: 0 2px 6px rgba(239,68,68,.4);
  animation: badgePop .3s cubic-bezier(.4,0,.2,1) both, badgePulse 2.5s ease-in-out 1s infinite;
}
@keyframes badgePop {
  from { transform: scale(0); opacity: 0; }
  to   { transform: scale(1); opacity: 1; }
}
@keyframes badgePulse {
  0%,100% { box-shadow: 0 2px 6px rgba(239,68,68,.4); }
  50%      { box-shadow: 0 2px 14px rgba(239,68,68,.7); }
}

/* Notification Panel */
.notif-panel {
  position: absolute; top: calc(100% + 12px); right: 0;
  width: 360px;
  background: rgba(255,253,249,.92);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(255,255,255,.7);
  border-radius: 18px;
  box-shadow: 0 20px 60px rgba(26,26,46,.15), 0 0 0 1px rgba(232,130,26,.06);
  z-index: 1000;
  display: none;
  overflow: hidden;
  animation: panelSlide .25s cubic-bezier(.4,0,.2,1) both;
}
.notif-panel.open { display: block; }
@keyframes panelSlide {
  from { opacity: 0; transform: translateY(-10px) scale(.97); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}

.notif-panel-header {
  padding: 16px 20px;
  border-bottom: 1px solid rgba(232,130,26,.1);
  display: flex; justify-content: space-between; align-items: center;
  background: linear-gradient(135deg, rgba(255,253,249,.9), rgba(254,243,232,.6));
}
.notif-panel-header strong { font-size: .92rem; color: var(--charcoal); }

.notif-list { max-height: 320px; overflow-y: auto; }
.notif-list::-webkit-scrollbar { width: 4px; }
.notif-list::-webkit-scrollbar-thumb { background: var(--border); border-radius: 99px; }

.notif-item {
  padding: 14px 20px;
  border-bottom: 1px solid rgba(232,130,26,.06);
  cursor: pointer;
  transition: all .2s;
  position: relative;
}
.notif-item::before {
  content: '';
  position: absolute; left: 0; top: 0; bottom: 0;
  width: 3px; background: var(--saffron);
  transform: scaleY(0); transition: transform .2s;
  border-radius: 0 2px 2px 0;
}
.notif-item:hover { background: rgba(232,130,26,.06); transform: translateX(3px); }
.notif-item:hover::before { transform: scaleY(1); }
.notif-item:last-child { border-bottom: 0; }
.notif-item.unread { background: rgba(232,130,26,.05); }
.notif-item.unread::before { transform: scaleY(1); }
.notif-item p { font-size: .85rem; color: var(--charcoal); line-height: 1.5; }
.notif-item time { font-size: .72rem; color: var(--muted); margin-top: 4px; display: block; }

/* ===== User Chip ===== */
.user-chip {
  display: flex; align-items: center; gap: 10px;
  padding: 6px 14px 6px 6px;
  background: rgba(255,255,255,.7);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,.8);
  border-radius: 99px;
  cursor: pointer;
  transition: all .25s cubic-bezier(.4,0,.2,1);
  box-shadow: 0 2px 8px rgba(26,26,46,.06);
}
.user-chip:hover {
  background: rgba(232,130,26,.08);
  border-color: rgba(232,130,26,.25);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(232,130,26,.15);
}
.user-chip .avatar {
  width: 32px; height: 32px; border-radius: 50%;
  background: linear-gradient(135deg, #E8821A, #F5A84C);
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-weight: 700; font-size: .82rem;
  box-shadow: 0 2px 8px rgba(232,130,26,.35);
  transition: transform .25s;
}
.user-chip:hover .avatar { transform: scale(1.12) rotate(-5deg); }
.user-chip span { font-size: .85rem; font-weight: 500; color: var(--charcoal); white-space: nowrap; }

/* Online dot */
.user-chip .online-dot {
  width: 8px; height: 8px; border-radius: 50%;
  background: #10b981;
  box-shadow: 0 0 6px rgba(16,185,129,.5);
  animation: onlinePulse 2s ease-in-out infinite;
  flex-shrink: 0;
}
@keyframes onlinePulse {
  0%,100% { opacity:1; transform:scale(1); }
  50%      { opacity:.7; transform:scale(.85); }
}

/* Date/time chip */
.time-chip {
  display: flex; align-items: center; gap: 7px;
  padding: 7px 14px;
  background: rgba(255,255,255,.6);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,.7);
  border-radius: 99px;
  font-size: .78rem; color: var(--muted);
  box-shadow: 0 2px 8px rgba(26,26,46,.05);
  white-space: nowrap;
}
.time-chip .time-icon { font-size: 13px; }
</style>

<div class="topbar">
  <div class="topbar-left">
    <div class="breadcrumb">
      <span>FoodBridge</span>
      <span class="sep">›</span>
      <span class="current"><c:out value="${pageTitle}"/></span>
    </div>
    <h2><c:out value="${pageTitle}"/></h2>
    <c:if test="${not empty pageSubtitle}">
      <p><c:out value="${pageSubtitle}"/></p>
    </c:if>
  </div>

  <div class="topbar-right">

    <!-- Date/Time -->
    <div class="time-chip">
      <span class="time-icon">📅</span>
      <span id="topbarDate"></span>
    </div>

    <!-- Notification Bell -->
    <button class="notif-btn" id="notifBtn" title="Notifications">
      <span class="bell-icon">🔔</span>
      <span class="notif-badge" id="notifBadge"
            style="display:${unreadCount > 0 ? 'flex' : 'none'}"><c:out value="${unreadCount}"/></span>
    </button>

    <div class="notif-panel" id="notifPanel">
      <div class="notif-panel-header">
        <strong>Notifications</strong>
        <button id="markAllRead" class="btn btn-sm btn-outline"
                style="font-size:.72rem;padding:4px 10px">✓ Mark all read</button>
      </div>
      <div class="notif-list" id="notifList">
        <c:choose>
          <c:when test="${not empty notifications}">
            <c:forEach var="n" items="${notifications}">
              <div class="notif-item ${n.read ? '' : 'unread'}">
                <p><c:out value="${n.message}"/></p>
                <time><c:out value="${n.createdAt}"/></time>
              </div>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <div class="empty-state" style="padding:28px">
              <div class="empty-icon">🔔</div>
              <p>No notifications yet</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <!-- User Chip -->
    <div class="user-chip">
      <div class="avatar"><c:out value="${fn:substring(currentUser.name,0,1)}"/></div>
      <span><c:out value="${currentUser.name}"/></span>
      <div class="online-dot"></div>
    </div>

  </div>
</div>

<script>
// Live date display
(function() {
  const el = document.getElementById('topbarDate');
  if (!el) return;
  const update = () => {
    const now = new Date();
    el.textContent = now.toLocaleDateString('en-IN', { weekday:'short', day:'numeric', month:'short' });
  };
  update();
  setInterval(update, 60000);
})();
</script>

<c:if test="${not empty param.err}">
  <div class="alert alert-danger" style="margin-bottom:20px">⚠️ <c:out value="${param.err}"/></div>
</c:if>
