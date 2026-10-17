<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentUser"  value="${sessionScope.currentUser}" />
<c:set var="pageTitle"    value="Donate Food" />
<c:set var="pageSubtitle" value="Submit your leftover food for redistribution" />
<%@ include file="/WEB-INF/views/includes/head.jsp" %>

<div class="page-layout">
  <%@ include file="/WEB-INF/views/includes/sidebar.jsp" %>
  <main class="main-content">
    <%@ include file="/WEB-INF/views/includes/topbar.jsp" %>

    <div style="max-width:760px">
      <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ <c:out value="${error}"/></div>
      </c:if>

      <div class="card animate-in">
        <div class="card-header">
          <h3>🍱 New Food Donation Request</h3>
        </div>
        <div class="card-body">
          <form action="${pageContext.request.contextPath}/donor/request?${_csrf.parameterName}=${_csrf.token}"
                method="post" enctype="multipart/form-data">

            <div class="form-grid">
              <!-- Food Name -->
              <div class="form-group form-full">
                <label class="form-label">Food Name / Description <span>*</span></label>
                <input type="text" name="food_name" class="form-control" required
                       placeholder="e.g. Biryani, Puri Sabzi, Mixed Veg Thali">
              </div>

              <!-- Food Type -->
              <div class="form-group">
                <label class="form-label">Food Type <span>*</span></label>
                <select name="food_type" class="form-control" required>
                  <option value="">— Select —</option>
                  <option value="veg">🟢 Vegetarian</option>
                  <option value="non-veg">🔴 Non-Vegetarian</option>
                  <option value="both">🟡 Mixed (Both)</option>
                </select>
              </div>

              <!-- Event Type -->
              <div class="form-group">
                <label class="form-label">Event Type <span>*</span></label>
                <select name="event_type" class="form-control" required>
                  <option value="">— Select —</option>
                  <option value="home">🏠 Home</option>
                  <option value="wedding">💍 Wedding</option>
                  <option value="party">🎉 Party / Birthday</option>
                  <option value="restaurant">🍽️ Restaurant</option>
                  <option value="corporate">🏢 Corporate Event</option>
                  <option value="other">📦 Other</option>
                </select>
              </div>

              <!-- Quantity -->
              <div class="form-group">
                <label class="form-label">Quantity <span>*</span></label>
                <input type="number" name="quantity" class="form-control" required
                       placeholder="e.g. 10" min="0.1" step="0.1">
              </div>

              <!-- Unit -->
              <div class="form-group">
                <label class="form-label">Unit <span>*</span></label>
                <select name="unit" class="form-control" required>
                  <option value="kg">kg (kilograms)</option>
                  <option value="plates">plates / servings</option>
                  <option value="litres">litres</option>
                  <option value="packets">packets</option>
                  <option value="boxes">boxes</option>
                  <option value="pieces">pieces</option>
                </select>
              </div>

              <!-- Pickup Deadline -->
              <div class="form-group">
                <label class="form-label">Pickup Before (Deadline) <span>*</span></label>
                <input type="datetime-local" name="pickup_deadline" class="form-control" required>
              </div>

              <!-- Location -->
              <div class="form-group form-full">
                <label class="form-label">Pickup Location / Address <span>*</span></label>
                <input type="text" name="location" class="form-control" required
                       placeholder="Full address with landmark — e.g. 12, Connaught Place, New Delhi, 110001">
              </div>

              <!-- Description -->
              <div class="form-group form-full">
                <label class="form-label">Additional Notes</label>
                <textarea name="description" class="form-control"
                          placeholder="Describe the food condition, packaging, storage, or any instructions for the pickup volunteer..."></textarea>
              </div>

              <!-- Photo Upload -->
              <div class="form-group form-full">
                <label class="form-label">Food Photo (optional)</label>
                <input type="file" name="photo" class="form-control"
                       accept="image/jpeg,image/png,image/webp">
                <small style="color:var(--muted);font-size:.78rem">Max 5MB — JPG, PNG, WebP accepted</small>
              </div>
            </div>

            <!-- Info box -->
            <div class="alert alert-info" style="margin-top:4px">
              💡 Once submitted, our admin team will review and approve your request, then assign a volunteer for pickup.
            </div>

            <div style="display:flex;gap:12px;margin-top:4px">
              <button type="submit" class="btn btn-primary" style="padding:12px 28px;font-size:.95rem">
                🍱 Submit Donation
              </button>
              <a href="${pageContext.request.contextPath}/donor/dashboard" class="btn btn-outline" style="padding:12px 24px">
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
