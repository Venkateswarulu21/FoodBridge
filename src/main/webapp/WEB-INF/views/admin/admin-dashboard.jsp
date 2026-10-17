<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentUser" value="${sessionScope.currentUser}" />
<c:set var="pageTitle"   value="Admin Dashboard" />
<c:set var="pageSubtitle" value="Overview of food redistribution operations" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<style>
/* ===== Dashboard Extra Styles ===== */
.main-content {
  background: linear-gradient(135deg, #f8f5f0 0%, #faf7f2 50%, #f5f0e8 100%);
  min-height: 100vh;
  position: relative;
}
.main-content::before {
  content: '';
  position: fixed; top: -200px; right: -200px;
  width: 600px; height: 600px;
  background: radial-gradient(circle, rgba(232,130,26,.05) 0%, transparent 70%);
  border-radius: 50%; pointer-events: none; z-index: 0;
}
.main-content::after {
  content: '';
  position: fixed; bottom: -200px; left: -200px;
  width: 500px; height: 500px;
  background: radial-gradient(circle, rgba(82,183,136,.04) 0%, transparent 70%);
  border-radius: 50%; pointer-events: none; z-index: 0;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px; margin-bottom: 28px;
  position: relative; z-index: 1;
}
.stat-card {
  background: rgba(255,253,249,.75);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border-radius: 18px;
  padding: 24px;
  border: 1px solid rgba(255,255,255,.7);
  box-shadow: 0 4px 20px rgba(26,26,46,.07), inset 0 1px 0 rgba(255,255,255,.9);
  position: relative; overflow: hidden;
  transition: transform .3s cubic-bezier(.4,0,.2,1), box-shadow .3s;
  cursor: default;
}
.stat-card::after {
  content: '';
  position: absolute; inset: 0;
  background: linear-gradient(135deg, rgba(255,255,255,.4) 0%, transparent 60%);
  pointer-events: none;
}
.stat-card:hover {
  transform: translateY(-6px) scale(1.01);
  box-shadow: 0 12px 40px rgba(26,26,46,.12), inset 0 1px 0 rgba(255,255,255,.9);
}
.stat-card::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px;
  transition: height .3s;
}
.stat-card:hover::before { height: 5px; }
.stat-card.orange::before { background: linear-gradient(90deg, #E8821A, #F5A84C); }
.stat-card.green::before  { background: linear-gradient(90deg, #2D6A4F, #52B788); }
.stat-card.blue::before   { background: linear-gradient(90deg, #3B82F6, #60A5FA); }
.stat-card.purple::before { background: linear-gradient(90deg, #8B5CF6, #A78BFA); }

.stat-card .stat-icon {
  width: 52px; height: 52px; border-radius: 14px;
  display: flex; align-items: center; justify-content: center;
  font-size: 24px; margin-bottom: 16px;
  transition: transform .3s cubic-bezier(.4,0,.2,1);
  position: relative; z-index: 1;
}
.stat-card:hover .stat-icon { transform: scale(1.18) rotate(-8deg); }
.stat-card.orange .stat-icon { background: linear-gradient(135deg, #FEF3E8, #fde8c8); box-shadow: 0 4px 14px rgba(232,130,26,.2); }
.stat-card.green  .stat-icon { background: linear-gradient(135deg, #EAF4EE, #d1f0df); box-shadow: 0 4px 14px rgba(82,183,136,.2); }
.stat-card.blue   .stat-icon { background: linear-gradient(135deg, #EEF4FC, #dbeafe); box-shadow: 0 4px 14px rgba(59,130,246,.2); }
.stat-card.purple .stat-icon { background: linear-gradient(135deg, #F5F0FF, #ede9fe); box-shadow: 0 4px 14px rgba(139,92,246,.2); }

.stat-card .stat-value {
  font-family: 'Playfair Display', Georgia, serif;
  font-size: 2.2rem; font-weight: 700; color: #1A1A2E;
  line-height: 1; margin-bottom: 4px; position: relative; z-index: 1;
  transition: color .2s;
}
.stat-card:hover.orange .stat-value { color: #E8821A; }
.stat-card:hover.green  .stat-value { color: #2D6A4F; }
.stat-card:hover.blue   .stat-value { color: #3B82F6; }
.stat-card:hover.purple .stat-value { color: #8B5CF6; }
.stat-card .stat-label {
  color: #6B6B7B; font-size: .78rem; font-weight: 600;
  text-transform: uppercase; letter-spacing: .08em; position: relative; z-index: 1;
}

/* Cards */
.card {
  background: rgba(255,253,249,.75);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border-radius: 18px;
  border: 1px solid rgba(255,255,255,.7);
  box-shadow: 0 4px 20px rgba(26,26,46,.07), inset 0 1px 0 rgba(255,255,255,.9);
  overflow: hidden; margin-bottom: 24px;
  transition: box-shadow .3s, transform .3s;
  position: relative; z-index: 1;
}
.card:hover { box-shadow: 0 8px 32px rgba(26,26,46,.10); }

.card-header {
  padding: 18px 24px;
  border-bottom: 1px solid rgba(232,130,26,.08);
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(255,253,249,.9), rgba(254,243,232,.4));
}
.card-header h3 { font-size: 1rem; display: flex; align-items: center; gap: 8px; }

/* Table */
.table-wrap { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; }
thead th {
  font-size: .72rem; text-transform: uppercase; letter-spacing: .08em;
  color: #6B6B7B; font-weight: 600; padding: 12px 16px;
  background: linear-gradient(135deg, rgba(250,247,242,.9), rgba(245,240,232,.6));
  border-bottom: 1px solid rgba(232,130,26,.08); text-align: left;
}
tbody td { padding: 14px 16px; border-bottom: 1px solid rgba(232,130,26,.05); font-size: .88rem; vertical-align: middle; }
tbody tr { transition: all .2s; }
tbody tr:last-child td { border-bottom: 0; }
tbody tr:hover td { background: rgba(232,130,26,.04); }
tbody tr:hover { transform: translateX(2px); }

/* Badges */
.badge { display: inline-flex; align-items: center; padding: 4px 11px; border-radius: 99px; font-size: .7rem; font-weight: 600; text-transform: uppercase; letter-spacing: .06em; }
.badge-pending   { background: linear-gradient(135deg,#FEF9C3,#fef08a); color: #854D0E; }
.badge-approved  { background: linear-gradient(135deg,#D1FAE5,#a7f3d0); color: #065F46; }
.badge-assigned  { background: linear-gradient(135deg,#DBEAFE,#bfdbfe); color: #1E40AF; }
.badge-collected { background: linear-gradient(135deg,#EDE9FE,#ddd6fe); color: #5B21B6; }
.badge-delivered { background: linear-gradient(135deg,#D1FAE5,#a7f3d0); color: #065F46; }
.badge-rejected  { background: linear-gradient(135deg,#FEE2E2,#fecaca); color: #991B1B; }
.badge-on_the_way { background: linear-gradient(135deg,#DBEAFE,#bfdbfe); color: #1E40AF; }
.badge-picked_up { background: linear-gradient(135deg,#EDE9FE,#ddd6fe); color: #5B21B6; }
.badge-fulfilled { background: linear-gradient(135deg,#D1FAE5,#a7f3d0); color: #065F46; }

/* Two col grid */
.two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; position: relative; z-index: 1; }

/* Quick actions */
.quick-actions {
  display: flex; gap: 12px; flex-wrap: wrap;
  margin-bottom: 28px; position: relative; z-index: 1;
}
.quick-action-btn {
  display: flex; align-items: center; gap: 8px;
  padding: 10px 18px;
  background: rgba(255,253,249,.75);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,.7);
  border-radius: 12px;
  font-size: .85rem; font-weight: 500; color: #1A1A2E;
  text-decoration: none; cursor: pointer;
  transition: all .25s cubic-bezier(.4,0,.2,1);
  box-shadow: 0 2px 8px rgba(26,26,46,.06);
}
.quick-action-btn:hover {
  background: linear-gradient(135deg, #E8821A, #F5A84C);
  color: #fff; border-color: transparent;
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(232,130,26,.35);
}
.quick-action-btn .qa-icon { font-size: 16px; transition: transform .25s; }
.quick-action-btn:hover .qa-icon { transform: scale(1.2) rotate(-8deg); }

/* Alert */
.alert { padding: 14px 18px; border-radius: 12px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; font-size: .88rem; backdrop-filter: blur(8px); animation: alertSlide .3s ease both; position: relative; z-index: 1; }
.alert-success { background: rgba(209,250,229,.8); color: #065F46; border: 1px solid rgba(16,185,129,.2); border-left: 4px solid #10B981; }
@keyframes alertSlide { from { opacity:0; transform:translateX(-16px); } to { opacity:1; transform:translateX(0); } }

/* Progress */
.progress-track { height: 5px; background: rgba(26,26,46,.08); border-radius: 99px; overflow: hidden; margin-top: 12px; }
.progress-fill { height: 100%; background: linear-gradient(90deg, #E8821A, #F5A84C); border-radius: 99px; transition: width .9s cubic-bezier(.4,0,.2,1); }
.progress-fill.green { background: linear-gradient(90deg, #2D6A4F, #52B788); }

/* Empty state */
.empty-state { text-align: center; padding: 40px 20px; color: #6B6B7B; }
.empty-icon { font-size: 2.5rem; margin-bottom: 10px; opacity: .5; animation: floatEmpty 3s ease-in-out infinite; }
@keyframes floatEmpty { 0%,100% { transform:translateY(0); } 50% { transform:translateY(-6px); } }

@media (max-width: 900px) {
  .two-col { grid-template-columns: 1fr; }
  .stats-grid { grid-template-columns: 1fr 1fr; }
}
</style>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content" style="padding:32px 36px">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <c:if test="${not empty param.msg}">
      <div class="alert alert-success alert-auto">✅ <c:out value="${param.msg}"/></div>
    </c:if>

    <!-- Quick Actions -->
    <div class="quick-actions">
      <a href="${pageContext.request.contextPath}/admin/donors" class="quick-action-btn">
        <span class="qa-icon">🍱</span> Review Donations
      </a>
      <a href="${pageContext.request.contextPath}/admin/assign" class="quick-action-btn">
        <span class="qa-icon">🔗</span> Assign Food
      </a>
      <a href="${pageContext.request.contextPath}/admin/receivers" class="quick-action-btn">
        <span class="qa-icon">🏛️</span> View Requests
      </a>
      <a href="${pageContext.request.contextPath}/admin/users" class="quick-action-btn">
        <span class="qa-icon">👥</span> Manage Users
      </a>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">
      <div class="stat-card orange" data-aos="fade-up" data-aos-delay="0">
        <div class="stat-icon">🍱</div>
        <div class="stat-value"><c:out value="${totalDonations}"/></div>
        <div class="stat-label">Total Donations</div>
        <div class="progress-track">
          <div class="progress-fill" data-progress="70"></div>
        </div>
      </div>
      <div class="stat-card green" data-aos="fade-up" data-aos-delay="80">
        <div class="stat-icon">✅</div>
        <div class="stat-value"><c:out value="${deliveredCount}"/></div>
        <div class="stat-label">Deliveries Done</div>
        <div class="progress-track">
          <div class="progress-fill green" data-progress="55"></div>
        </div>
      </div>
      <div class="stat-card blue" data-aos="fade-up" data-aos-delay="160">
        <div class="stat-icon">🏛️</div>
        <div class="stat-value"><c:out value="${totalReceivers}"/></div>
        <div class="stat-label">Receiver Requests</div>
      </div>
      <div class="stat-card purple" data-aos="fade-up" data-aos-delay="240">
        <div class="stat-icon">⏳</div>
        <div class="stat-value"><c:out value="${pendingDonations}"/></div>
        <div class="stat-label">Pending Approvals</div>
      </div>
      <div class="stat-card orange" data-aos="fade-up" data-aos-delay="320">
        <div class="stat-icon">🤝</div>
        <div class="stat-value"><c:out value="${totalDonors}"/></div>
        <div class="stat-label">Registered Donors</div>
      </div>
      <div class="stat-card green" data-aos="fade-up" data-aos-delay="400">
        <div class="stat-icon">🛵</div>
        <div class="stat-value"><c:out value="${totalVolunteers}"/></div>
        <div class="stat-label">Active Volunteers</div>
      </div>
    </div>

    <!-- Two Column -->
    <div class="two-col">

      <!-- Pending Donations -->
      <div class="card" data-aos="fade-up" data-aos-delay="0">
        <div class="card-header">
          <h3>⏳ Pending Donations</h3>
          <a href="${pageContext.request.contextPath}/admin/donors" class="btn btn-sm btn-outline">View All</a>
        </div>
        <div class="table-wrap">
          <c:choose>
            <c:when test="${not empty recentDonations}">
              <table>
                <thead><tr><th>Donor</th><th>Food</th><th>Qty</th><th>Action</th></tr></thead>
                <tbody>
                <c:forEach var="d" items="${recentDonations}" end="4">
                  <tr>
                    <td><strong><c:out value="${d.donorName}"/></strong></td>
                    <td><c:out value="${d.foodName}"/></td>
                    <td><c:out value="${d.quantity}"/> <c:out value="${d.unit}"/></td>
                    <td>
                      <form method="post" action="${pageContext.request.contextPath}/admin/donors" style="display:inline">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <input type="hidden" name="action" value="approve">
                        <input type="hidden" name="request_id" value="${fn:escapeXml(d.requestId)}">
                        <input type="hidden" name="donor_id" value="${fn:escapeXml(d.donorId)}">
                        <button class="btn btn-sm btn-success">✓ Approve</button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
                </tbody>
              </table>
            </c:when>
            <c:otherwise>
              <div class="empty-state"><div class="empty-icon">🎉</div><p>No pending donations</p></div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <!-- Receiver Requests -->
      <div class="card" data-aos="fade-up" data-aos-delay="100">
        <div class="card-header">
          <h3>📋 Food Requirements</h3>
          <a href="${pageContext.request.contextPath}/admin/receivers" class="btn btn-sm btn-outline">View All</a>
        </div>
        <div class="table-wrap">
          <c:choose>
            <c:when test="${not empty recentRequests}">
              <table>
                <thead><tr><th>Organisation</th><th>People</th><th>Date</th><th>Status</th></tr></thead>
                <tbody>
                <c:forEach var="r" items="${recentRequests}" end="4">
                  <tr>
                    <td><strong><c:out value="${not empty r.receiverOrg ? r.receiverOrg : r.receiverName}"/></strong></td>
                    <td><c:out value="${r.peopleCount}"/></td>
                    <td><c:out value="${r.requiredDate}"/></td>
                    <td><span class="badge badge-${r.status}"><c:out value="${r.status}"/></span></td>
                  </tr>
                </c:forEach>
                </tbody>
              </table>
            </c:when>
            <c:otherwise>
              <div class="empty-state"><div class="empty-icon">📭</div><p>No pending requests</p></div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>

    <!-- Recent Assignments -->
    <div class="card" data-aos="fade-up">
      <div class="card-header">
        <h3>🔗 Recent Assignments</h3>
        <a href="${pageContext.request.contextPath}/admin/assign" class="btn btn-sm btn-primary">Manage Assignments</a>
      </div>
      <div class="table-wrap">
        <c:choose>
          <c:when test="${not empty assignments}">
            <table>
              <thead>
                <tr>
                  <th>#</th><th>Food</th><th>Pickup Location</th>
                  <th>Receiver</th><th>Volunteer</th><th>Status</th><th>Assigned</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="a" items="${assignments}" end="9">
                <tr>
                  <td style="color:#6B6B7B;font-size:.78rem">#<c:out value="${a.assignmentId}"/></td>
                  <td><strong><c:out value="${a.donorFoodName}"/></strong></td>
                  <td style="font-size:.82rem;color:#6B6B7B"><c:out value="${a.donorLocation}"/></td>
                  <td><c:out value="${not empty a.receiverOrgName ? a.receiverOrgName : '—'}"/></td>
                  <td><c:out value="${not empty a.volunteerName ? a.volunteerName : '—'}"/></td>
                  <td><span class="badge badge-${a.status}"><c:out value="${a.status}"/></span></td>
                  <td style="font-size:.78rem;color:#6B6B7B"><c:out value="${a.assignedAt}"/></td>
                </tr>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">📦</div>
              <p>No assignments yet. <a href="${pageContext.request.contextPath}/admin/assign">Create one now</a></p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

  </main>
</div>

<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
