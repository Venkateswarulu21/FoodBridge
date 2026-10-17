<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="Assign & Match" />
<c:set var="pageSubtitle" value="Match approved donations to receivers and assign volunteers" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>
<style>
.assign-form {
  background: var(--saffron-pale);
  border: 1.5px solid #F5C58A;
  border-radius: var(--radius);
  padding: 24px;
  margin-bottom: 28px;
}
.assign-form h3 { margin-bottom: 16px; font-size:1.05rem; }
</style>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <c:if test="${not empty param.msg}">
      <div class="alert alert-success alert-auto">✅ <c:out value="${param.msg}"/></div>
    </c:if>

    <!-- Assignment Form -->
    <div class="assign-form animate-in">
      <h3>🔗 Create New Assignment</h3>
      <form method="post" action="${pageContext.request.contextPath}/admin/assign">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <input type="hidden" name="action" value="assign">
        <div class="form-grid">
          <div class="form-group">
            <label class="form-label">Approved Donation <span>*</span></label>
            <select name="donor_request_id" class="form-control" required>
              <option value="">— Select donation —</option>
              <c:forEach var="d" items="${approvedDonations}">
                <option value="${fn:escapeXml(d.requestId)}">
                  #<c:out value="${d.requestId}"/> | <c:out value="${d.foodName}"/> (<c:out value="${d.quantity}"/><c:out value="${d.unit}"/>) — <c:out value="${d.donorName}"/>
                </option>
              </c:forEach>
            </select>
            <c:if test="${empty approvedDonations}">
              <small style="color:var(--muted)">No approved donations. <a href="${pageContext.request.contextPath}/admin/donors">Approve some first.</a></small>
            </c:if>
          </div>

          <div class="form-group">
            <label class="form-label">Assign Volunteer</label>
            <select name="volunteer_id" class="form-control">
              <option value="">— Select volunteer (optional) —</option>
              <c:forEach var="v" items="${volunteers}">
                <option value="${fn:escapeXml(v.userId)}"><c:out value="${v.name}"/> — <c:out value="${v.phone}"/></option>
              </c:forEach>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Match to Receiver Request</label>
            <select name="receiver_request_id" class="form-control">
              <option value="">— Select receiver (optional) —</option>
              <c:forEach var="r" items="${pendingReceivers}">
                <option value="${fn:escapeXml(r.requestId)}">
                  #<c:out value="${r.requestId}"/> | <c:out value="${not empty r.receiverOrg ? r.receiverOrg : r.receiverName}"/> — <c:out value="${r.peopleCount}"/> people (<c:out value="${r.requiredDate}"/>)
                </option>
              </c:forEach>
            </select>
          </div>

          <div class="form-group" style="align-self:flex-end">
            <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center;padding:12px">
              🔗 Create Assignment
            </button>
          </div>
        </div>
      </form>
    </div>

    <!-- Assignments Table -->
    <div class="card animate-in">
      <div class="card-header">
        <h3>📋 All Assignments</h3>
        <span style="font-size:.85rem;color:var(--muted)"><c:out value="${fn:length(assignments)}"/> total</span>
      </div>
      <div class="table-wrap">
        <c:choose>
          <c:when test="${not empty assignments}">
            <table>
              <thead>
                <tr>
                  <th>#</th><th>Food</th><th>Pickup Location</th>
                  <th>Receiver</th><th>Volunteer</th>
                  <th>Status</th><th>Picked Up</th><th>Delivered</th><th>Update</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="a" items="${assignments}">
                <tr>
                  <td style="color:var(--muted);font-size:.8rem">#<c:out value="${a.assignmentId}"/></td>
                  <td><strong><c:out value="${a.donorFoodName}"/></strong></td>
                  <td style="font-size:.82rem;color:var(--muted);max-width:140px;white-space:normal"><c:out value="${a.donorLocation}"/></td>
                  <td style="font-size:.85rem"><c:out value="${not empty a.receiverOrgName ? a.receiverOrgName : '—'}"/></td>
                  <td style="font-size:.85rem"><c:out value="${not empty a.volunteerName ? a.volunteerName : '—'}"/></td>
                  <td><span class="badge badge-${a.status}"><c:out value="${a.status}"/></span></td>
                  <td style="font-size:.78rem;color:var(--muted)"><c:out value="${not empty a.pickedUpAt ? a.pickedUpAt : '—'}"/></td>
                  <td style="font-size:.78rem;color:var(--muted)"><c:out value="${not empty a.deliveredAt ? a.deliveredAt : '—'}"/></td>
                  <td>
                    <c:if test="${a.status != 'delivered' && a.status != 'failed'}">
                      <form method="post" style="display:flex;gap:5px;flex-wrap:wrap">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <input type="hidden" name="action"          value="update_status">
                        <input type="hidden" name="assignment_id"   value="${fn:escapeXml(a.assignmentId)}">
                        <input type="hidden" name="donor_request_id" value="${fn:escapeXml(a.donorRequestId)}">
                        <c:if test="${a.status == 'assigned'}">
                          <button name="status" value="on_the_way"  class="btn btn-sm btn-outline">🚗 On Way</button>
                        </c:if>
                        <c:if test="${a.status == 'on_the_way'}">
                          <button name="status" value="picked_up"   class="btn btn-sm btn-outline">📦 Picked</button>
                        </c:if>
                        <c:if test="${a.status == 'picked_up'}">
                          <button name="status" value="delivered"   class="btn btn-sm btn-success">✅ Delivered</button>
                        </c:if>
                      </form>
                    </c:if>
                    <c:if test="${a.status == 'delivered'}">
                      <span style="color:var(--forest);font-weight:600;font-size:.82rem">✅ Complete</span>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">🔗</div>
              <p>No assignments yet. Create one above after approving donations.</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

  </main>
</div>
<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
