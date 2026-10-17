<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="Request Food" />
<c:set var="pageSubtitle" value="Submit a food requirement for your organisation" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <div style="max-width:680px">
      <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ <c:out value="${error}"/></div>
      </c:if>

      <div class="card animate-in">
        <div class="card-header">
          <h3>📋 New Food Requirement</h3>
        </div>
        <div class="card-body">
          <form action="${pageContext.request.contextPath}/receiver/request" method="post">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div class="form-grid">
              <!-- People Count -->
              <div class="form-group">
                <label class="form-label">Number of People to Feed <span>*</span></label>
                <input type="number" name="people_count" class="form-control" required
                       placeholder="e.g. 50" min="1">
              </div>

              <!-- Food Preference -->
              <div class="form-group">
                <label class="form-label">Food Preference <span>*</span></label>
                <select name="food_preference" class="form-control" required>
                  <option value="">— Select —</option>
                  <option value="veg">🟢 Vegetarian Only</option>
                  <option value="non-veg">🔴 Non-Vegetarian</option>
                  <option value="both">🟡 Both (No preference)</option>
                </select>
              </div>

              <!-- Required Date -->
              <div class="form-group form-full">
                <label class="form-label">Food Required By (Date) <span>*</span></label>
                <input type="date" name="required_date" class="form-control" required
                       min="${today}"">
              </div>

              <!-- Delivery Location -->
              <div class="form-group form-full">
                <label class="form-label">Delivery Location / Address <span>*</span></label>
                <input type="text" name="location" class="form-control" required
                       placeholder="Full address — e.g. Seva Trust, 45 Karol Bagh, New Delhi 110005"
                       value="${fn:escapeXml(not empty currentUser.address ? currentUser.address : '')}">
              </div>

              <!-- Description -->
              <div class="form-group form-full">
                <label class="form-label">Additional Information</label>
                <textarea name="description" class="form-control"
                          placeholder="Any special dietary requirements, accessibility notes, or contact instructions for the delivery volunteer..."></textarea>
              </div>
            </div>

            <div class="alert alert-info" style="margin-top:4px">
              💡 Our admin will match your requirement with available food donations and assign a volunteer for delivery.
            </div>

            <div style="display:flex;gap:12px;margin-top:4px">
              <button type="submit" class="btn btn-success" style="padding:12px 28px;font-size:.95rem">
                📋 Submit Request
              </button>
              <a href="${pageContext.request.contextPath}/receiver/dashboard" class="btn btn-outline" style="padding:12px 24px">
                Cancel
              </a>
            </div>

          </form>
        </div>
      </div>
    </div>

  </main>
</div>
<%@ include file="/WEB-INF/views/includes/foot.jsp" %>
