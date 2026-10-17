<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="Receiver Requests" />
<c:set var="pageSubtitle" value="Manage food requirements from NGOs and individuals" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <div class="card">
      <div class="card-header">
        <h3>🏛️ All Receiver Requests</h3>
        <span style="font-size:.85rem;color:var(--muted)"><c:out value="${fn:length(requests)}"/> records</span>
      </div>
      <div class="table-wrap">
        <c:choose>
          <c:when test="${not empty requests}">
            <table>
              <thead>
                <tr>
                  <th>#</th><th>Organisation</th><th>Contact</th>
                  <th>People</th><th>Preference</th><th>Required Date</th>
                  <th>Location</th><th>Status</th><th>Actions</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="r" items="${requests}">
                <tr>
                  <td style="color:var(--muted);font-size:.8rem">#<c:out value="${r.requestId}"/></td>
                  <td>
                    <strong><c:out value="${not empty r.receiverOrg ? r.receiverOrg : r.receiverName}"/></strong>
                    <c:if test="${not empty r.receiverOrg}">
                      <br><small style="color:var(--muted)"><c:out value="${r.receiverName}"/></small>
                    </c:if>
                  </td>
                  <td style="font-size:.82rem"><c:out value="${r.receiverPhone}"/></td>
                  <td><strong><c:out value="${r.peopleCount}"/></strong> people</td>
                  <td><span class="badge badge-${r.foodPreference}"><c:out value="${r.foodPreference}"/></span></td>
                  <td><c:out value="${r.requiredDate}"/></td>
                  <td style="font-size:.82rem;max-width:160px;white-space:normal"><c:out value="${r.location}"/></td>
                  <td><span class="badge badge-${r.status}"><c:out value="${r.status}"/></span></td>
                  <td>
                    <c:if test="${r.status == 'pending'}">
                      <form method="post" style="display:flex;gap:6px">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <input type="hidden" name="request_id" value="${fn:escapeXml(r.requestId)}">
                        <button name="status" value="fulfilled"
                                class="btn btn-sm btn-success"
                                data-confirm="Mark this request as fulfilled?">✓ Fulfilled</button>
                        <button name="status" value="cancelled"
                                class="btn btn-sm btn-danger"
                                data-confirm="Cancel this request?">✗ Cancel</button>
                      </form>
                    </c:if>
                    <c:if test="${r.status != 'pending'}">
                      <span style="color:var(--muted);font-size:.8rem">—</span>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">🏛️</div>
              <p>No receiver requests found</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

  </main>
</div>
<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
