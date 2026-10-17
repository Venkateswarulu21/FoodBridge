<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="My Profile" />
<c:set var="pageSubtitle" value="Your account details" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <div style="max-width:760px">
      <div class="card animate-in">
        <div class="card-body">
          <div class="profile-hero">
            <div class="profile-avatar"><c:out value="${not empty profile.name ? profile.name.substring(0,1).toUpperCase() : 'U'}"/></div>
            <div>
              <h2 style="margin:0 0 8px"><c:out value="${profile.name}"/></h2>
              <span class="badge badge-assigned" style="text-transform:capitalize"><c:out value="${profile.role}"/></span>
              <c:choose>
                <c:when test="${profile.status == 'active'}"><span class="badge badge-approved">Active</span></c:when>
                <c:otherwise><span class="badge badge-pending"><c:out value="${profile.status}"/></span></c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>

      <div class="card animate-in" style="margin-top:20px">
        <div class="card-header"><h3>👤 Account details</h3></div>
        <div class="card-body">
          <div class="profile-grid">
            <div class="profile-field">
              <label>Full name</label>
              <div><c:out value="${profile.name}"/></div>
            </div>
            <div class="profile-field">
              <label>Role</label>
              <div style="text-transform:capitalize"><c:out value="${profile.role}"/></div>
            </div>
            <div class="profile-field">
              <label>Email</label>
              <div>
                <c:out value="${profile.email}"/>
                <c:if test="${profile.emailVerified}"><span class="badge badge-approved" style="margin-left:6px">Verified</span></c:if>
              </div>
            </div>
            <div class="profile-field">
              <label>Phone</label>
              <div><c:choose><c:when test="${not empty profile.phone}"><c:out value="${profile.phone}"/></c:when><c:otherwise>—</c:otherwise></c:choose></div>
            </div>
            <c:if test="${not empty profile.orgName}">
              <div class="profile-field">
                <label>Organisation</label>
                <div><c:out value="${profile.orgName}"/></div>
              </div>
            </c:if>
            <div class="profile-field">
              <label>Member since</label>
              <div><c:out value="${fn:substring(profile.createdAt, 0, 10)}"/></div>
            </div>
            <div class="profile-field" style="grid-column:1 / -1">
              <label>Address</label>
              <div><c:choose><c:when test="${not empty profile.address}"><c:out value="${profile.address}"/></c:when><c:otherwise>—</c:otherwise></c:choose></div>
            </div>
          </div>
        </div>
      </div>

      <div style="display:flex;gap:12px;margin-top:20px">
        <c:choose>
          <c:when test="${profile.role == 'admin'}"><c:set var="home" value="/admin/dashboard"/></c:when>
          <c:when test="${profile.role == 'donor'}"><c:set var="home" value="/donor/dashboard"/></c:when>
          <c:when test="${profile.role == 'receiver'}"><c:set var="home" value="/receiver/dashboard"/></c:when>
          <c:otherwise><c:set var="home" value="/volunteer/dashboard"/></c:otherwise>
        </c:choose>
        <a href="${pageContext.request.contextPath}${home}" class="btn btn-outline" style="padding:12px 24px">← Back to dashboard</a>
      </div>
    </div>

  </main>
</div>
<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
