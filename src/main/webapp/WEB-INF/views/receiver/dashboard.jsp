<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="Receiver Dashboard" />
<c:set var="pageSubtitle" value="Track your food requirements and incoming deliveries" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <c:if test="${not empty param.msg}">
      <div class="alert alert-success alert-auto">✅ <c:out value="${param.msg}"/></div>
    </c:if>

    <!-- Welcome Banner -->
    <div style="background:linear-gradient(135deg,var(--forest) 0%,#1e4d38 100%);border-radius:var(--radius);padding:28px 32px;margin-bottom:28px;display:flex;justify-content:space-between;align-items:center;color:#fff" class="animate-in">
      <div>
        <h2 style="color:#fff;font-size:1.5rem;margin-bottom:6px">
          Welcome, <c:out value="${not empty currentUser.orgName ? currentUser.orgName : currentUser.name}"/>! 🏛️
        </h2>
        <p style="opacity:.85;font-size:.9rem">Managing food for those who need it most.</p>
      </div>
      <a href="${pageContext.request.contextPath}/receiver/request"
         class="btn" style="background:#fff;color:var(--forest);font-weight:600;padding:12px 24px;white-space:nowrap">
        + Request Food
      </a>
    </div>

    <!-- Stats -->
    <div class="stats-grid" style="grid-template-columns:repeat(3,1fr)">
      <div class="stat-card green animate-in">
        <div class="stat-icon">📋</div>
        <div class="stat-value"><c:out value="${fn:length(requests)}"/></div>
        <div class="stat-label">My Requests</div>
      </div>
      <div class="stat-card orange animate-in anim-delay-1">
        <div class="stat-icon">✅</div>
        <div class="stat-value"><c:out value="${deliveredCount}"/></div>
        <div class="stat-label">Deliveries Received</div>
      </div>
      <div class="stat-card blue animate-in anim-delay-2">
        <div class="stat-icon">🔔</div>
        <div class="stat-value"><c:out value="${unreadCount}"/></div>
        <div class="stat-label">Unread Notifications</div>
      </div>
    </div>

    <!-- My Food Requirements -->
    <div class="card animate-in" style="margin-bottom:24px">
      <div class="card-header">
        <h3>📋 My Food Requirements</h3>
        <a href="${pageContext.request.contextPath}/receiver/request" class="btn btn-sm btn-primary">+ New Request</a>
      </div>
      <div class="table-wrap">
        <c:choose>
          <c:when test="${not empty requests}">
            <table>
              <thead>
                <tr>
                  <th>#</th><th>People</th><th>Preference</th>
                  <th>Required Date</th><th>Location</th><th>Status</th><th>Submitted</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="r" items="${requests}">
                <tr>
                  <td style="color:var(--muted);font-size:.8rem">#<c:out value="${r.requestId}"/></td>
                  <td><strong><c:out value="${r.peopleCount}"/></strong> people</td>
                  <td><span class="badge badge-${r.foodPreference}"><c:out value="${r.foodPreference}"/></span></td>
                  <td><c:out value="${r.requiredDate}"/></td>
                  <td style="font-size:.82rem;color:var(--muted);max-width:150px;white-space:normal"><c:out value="${r.location}"/></td>
                  <td><span class="badge badge-${r.status}"><c:out value="${r.status}"/></span></td>
                  <td style="font-size:.78rem;color:var(--muted)"><c:out value="${r.createdAt}"/></td>
                </tr>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">🏛️</div>
              <p>No food requests yet.</p>
              <br>
              <a href="${pageContext.request.contextPath}/receiver/request" class="btn btn-primary">Request Food Now</a>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <!-- Incoming Deliveries -->
    <div class="card animate-in">
      <div class="card-header">
        <h3>🚚 Active Deliveries</h3>
      </div>
      <div class="table-wrap">
        <c:choose>
          <c:when test="${not empty assignments}">
            <table>
              <thead>
                <tr>
                  <th>Food</th><th>Volunteer</th><th>Status</th><th>Pickup Time</th><th>Delivered</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="a" items="${assignments}">
                <c:if test="${a.status != 'failed'}">
                <tr>
                  <td><strong><c:out value="${a.donorFoodName}"/></strong></td>
                  <td><c:out value="${not empty a.volunteerName ? a.volunteerName : '—'}"/></td>
                  <td><span class="badge badge-${a.status}"><c:out value="${a.status}"/></span></td>
                  <td style="font-size:.8rem;color:var(--muted)"><c:out value="${not empty a.pickedUpAt ? a.pickedUpAt : '—'}"/></td>
                  <td style="font-size:.8rem;color:var(--muted)"><c:out value="${not empty a.deliveredAt ? a.deliveredAt : '—'}"/></td>
                </tr>
                </c:if>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">🚚</div>
              <p>No active deliveries at the moment</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

  </main>
</div>
<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
