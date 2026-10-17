<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="Volunteer Dashboard" />
<c:set var="pageSubtitle" value="Your pickup and delivery assignments" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <c:if test="${not empty param.msg}">
      <div class="alert alert-success alert-auto">✅ <c:out value="${param.msg}"/></div>
    </c:if>

    <!-- Welcome Banner -->
    <div style="background:linear-gradient(135deg,#1E40AF 0%,#1e3a8a 100%);border-radius:var(--radius);padding:28px 32px;margin-bottom:28px;color:#fff" class="animate-in">
      <h2 style="color:#fff;font-size:1.5rem;margin-bottom:6px">Ready for today's deliveries, <c:out value="${currentUser.name}"/>! 🛵</h2>
      <p style="opacity:.85;font-size:.9rem">You're making a real difference — one pickup at a time.</p>
    </div>

    <!-- Stats -->
    <div class="stats-grid" style="grid-template-columns:repeat(3,1fr)">
      <div class="stat-card blue animate-in">
        <div class="stat-icon">📦</div>
        <div class="stat-value"><c:out value="${fn:length(assignments)}"/></div>
        <div class="stat-label">Total Assignments</div>
      </div>
      <div class="stat-card green animate-in anim-delay-1">
        <div class="stat-icon">✅</div>
        <div class="stat-value">
          <c:set var="delCount" value="0"/>
          <c:forEach var="a" items="${assignments}">
            <c:if test="${a.status == 'delivered'}">
              <c:set var="delCount" value="${delCount + 1}"/>
            </c:if>
          </c:forEach>
          <c:out value="${delCount}"/>
        </div>
        <div class="stat-label">Delivered</div>
      </div>
      <div class="stat-card orange animate-in anim-delay-2">
        <div class="stat-icon">🚗</div>
        <div class="stat-value">
          <c:set var="activeCount" value="0"/>
          <c:forEach var="a" items="${assignments}">
            <c:if test="${a.status != 'delivered' && a.status != 'failed'}">
              <c:set var="activeCount" value="${activeCount + 1}"/>
            </c:if>
          </c:forEach>
          <c:out value="${activeCount}"/>
        </div>
        <div class="stat-label">Active Tasks</div>
      </div>
    </div>

    <!-- Active Tasks -->
    <div class="card animate-in" style="margin-bottom:24px">
      <div class="card-header">
        <h3>🚀 Active Pickup Tasks</h3>
      </div>
      <div class="table-wrap">
        <c:set var="hasActive" value="false"/>
        <c:forEach var="a" items="${assignments}">
          <c:if test="${a.status != 'delivered' && a.status != 'failed'}">
            <c:set var="hasActive" value="true"/>
          </c:if>
        </c:forEach>

        <c:choose>
          <c:when test="${hasActive}">
            <table>
              <thead>
                <tr>
                  <th>#</th><th>Food</th><th>Pickup Location</th>
                  <th>Deliver To</th><th>Assigned At</th><th>Status</th><th>Update Status</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="a" items="${assignments}">
                <c:if test="${a.status != 'delivered' && a.status != 'failed'}">
                <tr>
                  <td style="color:var(--muted);font-size:.8rem">#<c:out value="${a.assignmentId}"/></td>
                  <td><strong><c:out value="${a.donorFoodName}"/></strong></td>
                  <td>
                    <div style="font-size:.85rem;font-weight:500"><c:out value="${a.donorLocation}"/></div>
                    <a href="https://maps.google.com?q=${a.donorLocation}" target="_blank"
                       style="font-size:.75rem;color:var(--saffron)">📍 Open in Maps</a>
                  </td>
                  <td style="font-size:.85rem">
                    <c:out value="${not empty a.receiverOrgName ? a.receiverOrgName : '—'}"/>
                    <c:if test="${not empty a.receiverLocation}">
                      <br><small style="color:var(--muted)"><c:out value="${a.receiverLocation}"/></small>
                    </c:if>
                  </td>
                  <td style="font-size:.78rem;color:var(--muted)"><c:out value="${a.assignedAt}"/></td>
                  <td><span class="badge badge-${a.status}"><c:out value="${a.status}"/></span></td>
                  <td>
                    <form method="post" action="${pageContext.request.contextPath}/volunteer/update"
                          style="display:flex;gap:6px;flex-wrap:wrap">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                      <input type="hidden" name="assignment_id"    value="${fn:escapeXml(a.assignmentId)}">
                      <input type="hidden" name="donor_request_id" value="${fn:escapeXml(a.donorRequestId)}">
                      <c:if test="${a.status == 'assigned'}">
                        <button name="status" value="on_the_way"
                                class="btn btn-sm btn-outline">🚗 On My Way</button>
                      </c:if>
                      <c:if test="${a.status == 'on_the_way'}">
                        <button name="status" value="picked_up"
                                class="btn btn-sm btn-primary">📦 Picked Up</button>
                      </c:if>
                      <c:if test="${a.status == 'picked_up'}">
                        <button name="status" value="delivered"
                                class="btn btn-sm btn-success"
                                data-confirm="Confirm delivery complete?">✅ Delivered</button>
                      </c:if>
                    </form>
                  </td>
                </tr>
                </c:if>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">🎉</div>
              <p>No active tasks right now. Great job!</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <!-- Delivery History -->
    <div class="card animate-in">
      <div class="card-header">
        <h3>📜 Delivery History</h3>
      </div>
      <div class="table-wrap">
        <c:set var="hasHistory" value="false"/>
        <c:forEach var="a" items="${assignments}">
          <c:if test="${a.status == 'delivered' || a.status == 'failed'}">
            <c:set var="hasHistory" value="true"/>
          </c:if>
        </c:forEach>

        <c:choose>
          <c:when test="${hasHistory}">
            <table>
              <thead>
                <tr><th>#</th><th>Food</th><th>Pickup From</th><th>Delivered To</th><th>Status</th><th>Delivered At</th></tr>
              </thead>
              <tbody>
              <c:forEach var="a" items="${assignments}">
                <c:if test="${a.status == 'delivered' || a.status == 'failed'}">
                <tr>
                  <td style="color:var(--muted);font-size:.8rem">#<c:out value="${a.assignmentId}"/></td>
                  <td><c:out value="${a.donorFoodName}"/></td>
                  <td style="font-size:.82rem;color:var(--muted)"><c:out value="${a.donorLocation}"/></td>
                  <td style="font-size:.82rem"><c:out value="${not empty a.receiverOrgName ? a.receiverOrgName : '—'}"/></td>
                  <td><span class="badge badge-${a.status}"><c:out value="${a.status}"/></span></td>
                  <td style="font-size:.78rem;color:var(--muted)"><c:out value="${not empty a.deliveredAt ? a.deliveredAt : '—'}"/></td>
                </tr>
                </c:if>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">📜</div>
              <p>No completed deliveries yet</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

  </main>
</div>
<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
