<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="Manage Users" />
<c:set var="pageSubtitle" value="View and manage all registered users" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <div class="card animate-in">
      <div class="card-header">
        <h3>👥 All Users</h3>
        <span style="font-size:.85rem;color:var(--muted)"><c:out value="${fn:length(users)}"/> registered</span>
      </div>
      <div class="table-wrap">
        <c:choose>
          <c:when test="${not empty users}">
            <table>
              <thead>
                <tr>
                  <th>#</th><th>Name</th><th>Email</th><th>Phone</th>
                  <th>Role</th><th>Organisation</th><th>Status</th><th>Joined</th><th>Actions</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="u" items="${users}">
                <tr>
                  <td style="color:var(--muted);font-size:.8rem"><c:out value="${u.userId}"/></td>
                  <td>
                    <div style="display:flex;align-items:center;gap:9px">
                      <div class="avatar" style="width:32px;height:32px;font-size:.78rem;flex-shrink:0">
                        <c:out value="${fn:substring(u.name,0,1)}"/>
                      </div>
                      <strong><c:out value="${u.name}"/></strong>
                    </div>
                  </td>
                  <td style="font-size:.85rem"><c:out value="${u.email}"/></td>
                  <td style="font-size:.85rem"><c:out value="${u.phone}"/></td>
                  <td>
                    <span class="badge badge-info" style="text-transform:capitalize"><c:out value="${u.role}"/></span>
                  </td>
                  <td style="font-size:.82rem"><c:out value="${not empty u.orgName ? u.orgName : '—'}"/></td>
                  <td><span class="badge badge-${u.status}"><c:out value="${u.status}"/></span></td>
                  <td style="font-size:.78rem;color:var(--muted)"><c:out value="${u.createdAt}"/></td>
                  <td>
                    <c:if test="${u.userId != currentUser.userId}">
                      <form method="post" style="display:inline">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <input type="hidden" name="user_id" value="${fn:escapeXml(u.userId)}">
                        <c:choose>
                          <c:when test="${u.status == 'active'}">
                            <button name="status" value="inactive"
                                    class="btn btn-sm btn-danger"
                                    data-confirm="Deactivate this user?">🚫 Deactivate</button>
                          </c:when>
                          <c:otherwise>
                            <button name="status" value="active"
                                    class="btn btn-sm btn-success">✓ Activate</button>
                          </c:otherwise>
                        </c:choose>
                      </form>
                    </c:if>
                    <c:if test="${u.userId == currentUser.userId}">
                      <span style="color:var(--muted);font-size:.8rem">You</span>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-icon">👥</div>
              <p>No users registered yet</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </main>
</div>
<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
