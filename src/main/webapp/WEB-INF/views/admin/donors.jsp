<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="Donor Requests" />
<c:set var="pageSubtitle" value="Review and manage food donation submissions" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <!-- Filter bar -->
    <div style="display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap">
      <a href="?filter=all"      class="btn btn-sm ${empty param.filter || param.filter=='all'      ? 'btn-primary' : 'btn-outline'}">All</a>
      <a href="?filter=pending"  class="btn btn-sm ${param.filter=='pending'  ? 'btn-primary' : 'btn-outline'}">⏳ Pending</a>
      <a href="?filter=approved" class="btn btn-sm ${param.filter=='approved' ? 'btn-primary' : 'btn-outline'}">✅ Approved</a>
      <a href="?filter=assigned" class="btn btn-sm ${param.filter=='assigned' ? 'btn-primary' : 'btn-outline'}">🔗 Assigned</a>
      <a href="?filter=collected"class="btn btn-sm ${param.filter=='collected'? 'btn-primary' : 'btn-outline'}">📦 Collected</a>
      <a href="?filter=rejected" class="btn btn-sm ${param.filter=='rejected' ? 'btn-primary' : 'btn-outline'}">❌ Rejected</a>
    </div>

    <div class="card">
      <div class="card-header">
        <h3>🍱 All Donation Requests</h3>
        <span style="font-size:.85rem;color:var(--muted)"><c:out value="${fn:length(requests)}"/> records</span>
      </div>
      <div class="table-wrap">
        <c:choose>
          <c:when test="${not empty requests}">
            <table>
              <thead>
                <tr>
                  <th>#</th><th>Donor</th><th>Food Name</th><th>Type</th>
                  <th>Quantity</th><th>Event</th><th>Pickup By</th>
                  <th>Location</th><th>Status</th><th>Actions</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="d" items="${requests}">
                <c:if test="${empty param.filter || param.filter=='all' || param.filter==d.status}">
                <tr>
                  <td style="color:var(--muted);font-size:.8rem">#<c:out value="${d.requestId}"/></td>
                  <td>
                    <strong><c:out value="${d.donorName}"/></strong><br>
                    <small style="color:var(--muted)"><c:out value="${d.donorPhone}"/></small>
                  </td>
                  <td><strong><c:out value="${d.foodName}"/></strong>
                    <c:if test="${not empty d.description}">
                      <br><small style="color:var(--muted)" title="${fn:escapeXml(d.description)}"><c:out value="${fn:substring(d.description,0,35)}"/>...</small>
                    </c:if>
                  </td>
                  <td><span class="badge badge-${d.foodType}"><c:out value="${d.foodType}"/></span></td>
                  <td><c:out value="${d.quantity}"/> <c:out value="${d.unit}"/></td>
                  <td style="font-size:.82rem;text-transform:capitalize"><c:out value="${d.eventType}"/></td>
                  <td style="font-size:.8rem;color:var(--muted)"><c:out value="${d.pickupDeadline}"/></td>
                  <td style="font-size:.82rem;max-width:160px;white-space:normal"><c:out value="${d.location}"/></td>
                  <td><span class="badge badge-${d.status}"><c:out value="${d.status}"/></span></td>
                  <td>
                    <div style="display:flex;gap:6px;flex-wrap:wrap">
                      <c:if test="${d.status == 'pending'}">
                        <form method="post" style="display:inline">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                          <input type="hidden" name="action"     value="approve">
                          <input type="hidden" name="request_id" value="${fn:escapeXml(d.requestId)}">
                          <input type="hidden" name="donor_id"   value="${fn:escapeXml(d.donorId)}">
                          <button class="btn btn-sm btn-success">✓ Approve</button>
                        </form>
                        <form method="post" style="display:inline">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                          <input type="hidden" name="action"     value="reject">
                          <input type="hidden" name="request_id" value="${fn:escapeXml(d.requestId)}">
                          <input type="hidden" name="donor_id"   value="${fn:escapeXml(d.donorId)}">
                          <button class="btn btn-sm btn-danger"
                                  data-confirm="Reject this donation request?">✗ Reject</button>
                        </form>
                      </c:if>
                      <c:if test="${d.status == 'approved'}">
                        <a href="${pageContext.request.contextPath}/admin/assign" class="btn btn-sm btn-primary">🔗 Assign</a>
                      </c:if>
                    </div>
                  </td>
                </tr>
                </c:if>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">🍱</div>
              <p>No donation requests found</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

  </main>
</div>
<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
