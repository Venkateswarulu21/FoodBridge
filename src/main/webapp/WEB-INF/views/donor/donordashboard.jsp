<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="Donor Dashboard" />
<c:set var="pageSubtitle" value="Track your food donations and their impact" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<style>
.main-content {
  background: linear-gradient(135deg, #f8f5f0 0%, #faf7f2 50%, #f5f0e8 100%);
  min-height: 100vh; position: relative;
}
.main-content::before {
  content: ''; position: fixed; top: -200px; right: -200px;
  width: 600px; height: 600px;
  background: radial-gradient(circle, rgba(232,130,26,.05) 0%, transparent 70%);
  border-radius: 50%; pointer-events: none; z-index: 0;
}

/* Welcome Banner */
.welcome-banner {
  background: linear-gradient(135deg, #E8821A 0%, #cf6f12 50%, #b85e0a 100%);
  border-radius: 20px; padding: 32px 36px; margin-bottom: 28px;
  display: flex; justify-content: space-between; align-items: center;
  color: #fff; position: relative; overflow: hidden;
  box-shadow: 0 8px 32px rgba(232,130,26,.35);
  animation: bannerEnter .5s cubic-bezier(.4,0,.2,1) both;
  z-index: 1;
}
.welcome-banner::before {
  content: ''; position: absolute; top: -60px; right: -60px;
  width: 220px; height: 220px;
  background: radial-gradient(circle, rgba(255,255,255,.15) 0%, transparent 70%);
  border-radius: 50%; animation: orbFloat 5s ease-in-out infinite alternate;
}
.welcome-banner::after {
  content: ''; position: absolute; bottom: -40px; left: 200px;
  width: 160px; height: 160px;
  background: radial-gradient(circle, rgba(255,255,255,.08) 0%, transparent 70%);
  border-radius: 50%;
}
@keyframes bannerEnter { from { opacity:0; transform:translateY(-16px); } to { opacity:1; transform:translateY(0); } }
@keyframes orbFloat { from { transform:scale(1) translate(0,0); } to { transform:scale(1.2) translate(-10px,-10px); } }

.welcome-text h2 { color:#fff; font-size:1.6rem; margin-bottom:8px; position:relative; z-index:1; }
.welcome-text p  { opacity:.85; font-size:.92rem; line-height:1.6; position:relative; z-index:1; }
.welcome-stats {
  display: flex; gap: 24px; margin-top: 16px; position: relative; z-index: 1;
}
.welcome-stat { text-align: center; }
.welcome-stat .wval { font-size: 1.5rem; font-weight: 700; font-family: 'Playfair Display', serif; }
.welcome-stat .wlbl { font-size: .7rem; opacity: .7; text-transform: uppercase; letter-spacing: .08em; }

.welcome-action { position: relative; z-index: 1; flex-shrink: 0; }
.donate-btn {
  display: flex; align-items: center; gap: 8px;
  background: rgba(255,255,255,.95);
  color: #E8821A; font-weight: 700; font-size: .95rem;
  padding: 14px 28px; border-radius: 14px; text-decoration: none;
  transition: all .3s cubic-bezier(.4,0,.2,1);
  box-shadow: 0 4px 16px rgba(0,0,0,.15), inset 0 1px 0 rgba(255,255,255,.8);
  border: none; cursor: pointer;
  white-space: nowrap;
}
.donate-btn:hover {
  background: #fff; transform: translateY(-3px) scale(1.03);
  box-shadow: 0 10px 28px rgba(0,0,0,.2);
  color: #cf6f12;
}
.donate-btn .btn-icon { font-size: 18px; transition: transform .3s; }
.donate-btn:hover .btn-icon { transform: rotate(-10deg) scale(1.2); }

/* Stats */
.stats-grid {
  display: grid; grid-template-columns: repeat(3,1fr);
  gap: 20px; margin-bottom: 28px; position: relative; z-index: 1;
}
.stat-card {
  background: rgba(255,253,249,.8);
  backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
  border-radius: 18px; padding: 24px;
  border: 1px solid rgba(255,255,255,.75);
  box-shadow: 0 4px 20px rgba(26,26,46,.07), inset 0 1px 0 rgba(255,255,255,.9);
  position: relative; overflow: hidden;
  transition: transform .3s cubic-bezier(.4,0,.2,1), box-shadow .3s;
}
.stat-card::after {
  content: ''; position: absolute; inset: 0;
  background: linear-gradient(135deg, rgba(255,255,255,.4) 0%, transparent 60%);
  pointer-events: none;
}
.stat-card:hover { transform: translateY(-6px) scale(1.01); box-shadow: 0 12px 40px rgba(26,26,46,.12); }
.stat-card::before { content: ''; position: absolute; top:0; left:0; right:0; height:3px; transition: height .3s; }
.stat-card:hover::before { height: 5px; }
.stat-card.orange::before { background: linear-gradient(90deg,#E8821A,#F5A84C); }
.stat-card.green::before  { background: linear-gradient(90deg,#2D6A4F,#52B788); }
.stat-card.blue::before   { background: linear-gradient(90deg,#3B82F6,#60A5FA); }

.stat-icon { width:52px; height:52px; border-radius:14px; display:flex; align-items:center; justify-content:center; font-size:24px; margin-bottom:16px; transition:transform .3s cubic-bezier(.4,0,.2,1); position:relative; z-index:1; }
.stat-card:hover .stat-icon { transform: scale(1.18) rotate(-8deg); }
.stat-card.orange .stat-icon { background:linear-gradient(135deg,#FEF3E8,#fde8c8); box-shadow:0 4px 14px rgba(232,130,26,.2); }
.stat-card.green  .stat-icon { background:linear-gradient(135deg,#EAF4EE,#d1f0df); box-shadow:0 4px 14px rgba(82,183,136,.2); }
.stat-card.blue   .stat-icon { background:linear-gradient(135deg,#EEF4FC,#dbeafe); box-shadow:0 4px 14px rgba(59,130,246,.2); }

.stat-value { font-family:'Playfair Display',serif; font-size:2.2rem; font-weight:700; color:#1A1A2E; line-height:1; margin-bottom:4px; position:relative; z-index:1; transition:color .2s; }
.stat-card:hover.orange .stat-value { color:#E8821A; }
.stat-card:hover.green  .stat-value { color:#2D6A4F; }
.stat-card:hover.blue   .stat-value { color:#3B82F6; }
.stat-label { color:#6B6B7B; font-size:.78rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; position:relative; z-index:1; }

/* Card */
.card {
  background: rgba(255,253,249,.8);
  backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
  border-radius: 18px; border: 1px solid rgba(255,255,255,.75);
  box-shadow: 0 4px 20px rgba(26,26,46,.07), inset 0 1px 0 rgba(255,255,255,.9);
  overflow: hidden; margin-bottom: 24px;
  transition: box-shadow .3s; position: relative; z-index: 1;
}
.card-header {
  padding: 18px 24px;
  border-bottom: 1px solid rgba(232,130,26,.08);
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(255,253,249,.9), rgba(254,243,232,.4));
}
.card-header h3 { font-size: 1rem; }

/* Table */
.table-wrap { overflow-x: auto; }
table { width:100%; border-collapse:collapse; }
thead th { font-size:.72rem; text-transform:uppercase; letter-spacing:.08em; color:#6B6B7B; font-weight:600; padding:12px 16px; background:linear-gradient(135deg,rgba(250,247,242,.9),rgba(245,240,232,.6)); border-bottom:1px solid rgba(232,130,26,.08); text-align:left; }
tbody td { padding:13px 16px; border-bottom:1px solid rgba(232,130,26,.05); font-size:.87rem; vertical-align:middle; }
tbody tr { transition:all .2s; }
tbody tr:last-child td { border-bottom:0; }
tbody tr:hover td { background:rgba(232,130,26,.04); }
tbody tr:hover { transform:translateX(2px); }

.badge { display:inline-flex; align-items:center; padding:4px 10px; border-radius:99px; font-size:.7rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }
.badge-pending  { background:linear-gradient(135deg,#FEF9C3,#fef08a); color:#854D0E; }
.badge-approved { background:linear-gradient(135deg,#D1FAE5,#a7f3d0); color:#065F46; }
.badge-assigned { background:linear-gradient(135deg,#DBEAFE,#bfdbfe); color:#1E40AF; }
.badge-collected { background:linear-gradient(135deg,#EDE9FE,#ddd6fe); color:#5B21B6; }
.badge-delivered { background:linear-gradient(135deg,#D1FAE5,#a7f3d0); color:#065F46; }
.badge-rejected  { background:linear-gradient(135deg,#FEE2E2,#fecaca); color:#991B1B; }
.badge-veg     { background:linear-gradient(135deg,#D1FAE5,#a7f3d0); color:#065F46; }
.badge-non-veg { background:linear-gradient(135deg,#FEE2E2,#fecaca); color:#991B1B; }
.badge-both    { background:linear-gradient(135deg,#FEF3E8,#fde8c8); color:#7C2D12; }

.alert { padding:14px 18px; border-radius:12px; margin-bottom:20px; display:flex; align-items:center; gap:10px; font-size:.88rem; animation:alertSlide .3s ease both; position:relative; z-index:1; }
.alert-success { background:rgba(209,250,229,.8); color:#065F46; border:1px solid rgba(16,185,129,.2); border-left:4px solid #10B981; }
@keyframes alertSlide { from { opacity:0; transform:translateX(-16px); } to { opacity:1; transform:translateX(0); } }

.empty-state { text-align:center; padding:48px 20px; color:#6B6B7B; }
.empty-icon { font-size:2.8rem; margin-bottom:12px; opacity:.5; animation:floatEmpty 3s ease-in-out infinite; }
@keyframes floatEmpty { 0%,100% { transform:translateY(0); } 50% { transform:translateY(-7px); } }

/* Impact card */
.impact-card {
  background: linear-gradient(135deg, rgba(45,106,79,.12), rgba(82,183,136,.06));
  border: 1px solid rgba(82,183,136,.2);
  border-radius: 16px; padding: 20px 24px; margin-bottom: 24px;
  display: flex; align-items: center; gap: 16px;
  position: relative; z-index: 1;
  animation: fadeInUp .5s .2s ease both;
}
@keyframes fadeInUp { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:translateY(0); } }
.impact-icon { font-size: 2.5rem; flex-shrink: 0; }
.impact-text h4 { color: #2D6A4F; font-size: 1rem; margin-bottom: 4px; }
.impact-text p { color: #6B6B7B; font-size: .85rem; line-height: 1.6; }

@media (max-width:900px) {
  .welcome-banner { flex-direction:column; gap:20px; text-align:center; }
  .welcome-stats { justify-content:center; }
  .stats-grid { grid-template-columns:1fr 1fr; }
}
</style>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content" style="padding:32px 36px">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <c:if test="${not empty param.msg}">
      <div class="alert alert-success alert-auto">✅ <c:out value="${param.msg}"/></div>
    </c:if>

    <!-- Welcome Banner -->
    <div class="welcome-banner">
      <div class="welcome-text">
        <h2>Welcome back, <c:out value="${currentUser.name}"/>! 🌾</h2>
        <p>Every donation matters. Thank you for your generosity and kindness.</p>
        <div class="welcome-stats">
          <div class="welcome-stat">
            <div class="wval"><c:out value="${fn:length(requests)}"/></div>
            <div class="wlbl">Donations</div>
          </div>
          <div class="welcome-stat">
            <div class="wval"><c:out value="${collectedCount}"/></div>
            <div class="wlbl">Collected</div>
          </div>
          <div class="welcome-stat">
            <div class="wval"><c:out value="${pendingCount}"/></div>
            <div class="wlbl">Pending</div>
          </div>
        </div>
      </div>
      <div class="welcome-action">
        <a href="${pageContext.request.contextPath}/donor/request" class="donate-btn">
          <span class="btn-icon">🍱</span> Donate Food
        </a>
      </div>
    </div>

    <!-- Impact Message -->
    <div class="impact-card" data-aos="fade-up">
      <div class="impact-icon">🌱</div>
      <div class="impact-text">
        <h4>Your Impact So Far</h4>
        <p>You've contributed <strong><c:out value="${fn:length(requests)}"/> donation(s)</strong> through FoodBridge, helping feed people in need. Keep going — every meal counts!</p>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-grid">
      <div class="stat-card orange" data-aos="fade-up" data-aos-delay="0">
        <div class="stat-icon">🍱</div>
        <div class="stat-value"><c:out value="${fn:length(requests)}"/></div>
        <div class="stat-label">My Donations</div>
      </div>
      <div class="stat-card green" data-aos="fade-up" data-aos-delay="100">
        <div class="stat-icon">✅</div>
        <div class="stat-value"><c:out value="${collectedCount}"/></div>
        <div class="stat-label">Collected</div>
      </div>
      <div class="stat-card blue" data-aos="fade-up" data-aos-delay="200">
        <div class="stat-icon">⏳</div>
        <div class="stat-value"><c:out value="${pendingCount}"/></div>
        <div class="stat-label">Pending Review</div>
      </div>
    </div>

    <!-- Donations Table -->
    <div class="card" data-aos="fade-up">
      <div class="card-header">
        <h3>📋 My Donation History</h3>
        <a href="${pageContext.request.contextPath}/donor/request" class="btn btn-sm btn-primary">+ New Donation</a>
      </div>
      <div class="table-wrap">
        <c:choose>
          <c:when test="${not empty requests}">
            <table>
              <thead>
                <tr>
                  <th>#</th><th>Food Name</th><th>Type</th><th>Quantity</th>
                  <th>Event</th><th>Pickup Deadline</th><th>Location</th><th>Status</th><th>Submitted</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="d" items="${requests}">
                <tr>
                  <td style="color:#6B6B7B;font-size:.78rem">#<c:out value="${d.requestId}"/></td>
                  <td>
                    <strong><c:out value="${d.foodName}"/></strong>
                    <c:if test="${not empty d.description}">
                      <br><small style="color:#6B6B7B"><c:out value="${fn:substring(d.description,0,40)}"/></small>
                    </c:if>
                  </td>
                  <td><span class="badge badge-${d.foodType}"><c:out value="${d.foodType}"/></span></td>
                  <td><strong><c:out value="${d.quantity}"/></strong> <c:out value="${d.unit}"/></td>
                  <td style="text-transform:capitalize;font-size:.85rem"><c:out value="${d.eventType}"/></td>
                  <td style="font-size:.8rem;color:#6B6B7B"><c:out value="${d.pickupDeadline}"/></td>
                  <td style="font-size:.82rem;max-width:150px;white-space:normal;color:#6B6B7B"><c:out value="${d.location}"/></td>
                  <td><span class="badge badge-${d.status}"><c:out value="${d.status}"/></span></td>
                  <td style="font-size:.78rem;color:#6B6B7B"><c:out value="${d.createdAt}"/></td>
                </tr>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">🍽️</div>
              <p>You haven't made any donations yet.</p>
              <br>
              <a href="${pageContext.request.contextPath}/donor/request" class="btn btn-primary" style="margin-top:8px">🍱 Make Your First Donation</a>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

  </main>
</div>
<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
