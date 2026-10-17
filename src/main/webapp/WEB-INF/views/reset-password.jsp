<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Reset Password — FoodBridge</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo-mark.png">
</head>
<body>
<div class="auth-page">

  <!-- Left Panel -->
  <div class="auth-left">
    <div class="auth-left-content">
      <a href="${pageContext.request.contextPath}/" style="display:flex;align-items:center;gap:10px;text-decoration:none">
        <img src="${pageContext.request.contextPath}/images/logo-mark.png" alt="FoodBridge" style="width:46px;height:46px;border-radius:12px;box-shadow:0 4px 14px rgba(0,0,0,.35)">
        <span style="color:#fff;font-family:var(--font-display);font-size:1.3rem;font-weight:700">FoodBridge</span>
      </a>
      <h2>Bridging surplus<br><em style="color:var(--saffron-light)">to those in need</em></h2>
      <p>Join thousands of donors, NGOs, and volunteers making a difference — one meal at a time.</p>

      <div class="auth-feature">
        <div class="icon">🍱</div>
        <div><strong>Donors</strong><p>Submit leftover food from any event and schedule a pickup in minutes.</p></div>
      </div>
      <div class="auth-feature" style="margin-top:12px">
        <div class="icon">🏛️</div>
        <div><strong>NGOs & Trusts</strong><p>Request food deliveries and track them in real-time to your doorstep.</p></div>
      </div>
      <div class="auth-feature" style="margin-top:12px">
        <div class="icon">🛵</div>
        <div><strong>Volunteers</strong><p>Pick up tasks, update delivery status, and see your community impact.</p></div>
      </div>
    </div>
  </div>

  <!-- Right Panel -->
  <div class="auth-right">
    <div class="auth-form-box animate-in">
      <h2 class="auth-title">Set a new password</h2>
      <p class="auth-sub">Enter the code from your email and choose a new password.</p>
      <c:if test="${not empty param.msg}"><div class="alert alert-success">✅ <c:out value="${param.msg}"/></div></c:if>
      <c:if test="${not empty param.err}"><div class="alert alert-danger">⚠️ <c:out value="${param.err}"/></div></c:if>
      <c:if test="${not empty error}"><div class="alert alert-danger">⚠️ <c:out value="${error}"/></div></c:if>

      <form action="${pageContext.request.contextPath}/reset-password" method="post" novalidate>
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <c:choose>
          <c:when test="${not empty email}"><input type="hidden" name="email" value="${fn:escapeXml(email)}"></c:when>
          <c:otherwise>
            <div class="form-group" style="margin-bottom:18px">
              <label class="form-label">Email Address <span>*</span></label>
              <input type="email" name="email" class="form-control" placeholder="you@example.com" required>
            </div>
          </c:otherwise>
        </c:choose>
        <div class="form-group" style="margin-bottom:18px">
          <label class="form-label">6-digit code <span>*</span></label>
          <input type="text" name="otpCode" class="form-control" inputmode="numeric" autocomplete="one-time-code"
                 pattern="[0-9]{6}" maxlength="6" placeholder="123456" required
                 style="letter-spacing:8px;font-size:1.4rem;text-align:center">
        </div>
        <div class="form-group" style="margin-bottom:18px">
          <label class="form-label">New password <span>*</span></label>
          <input type="password" name="password" class="form-control" placeholder="At least 8 characters, with a letter and a number" minlength="8" required>
        </div>
        <div class="form-group" style="margin-bottom:24px">
          <label class="form-label">Confirm new password <span>*</span></label>
          <input type="password" name="confirm" class="form-control" minlength="8" required>
        </div>
        <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center;padding:13px;font-size:1rem">Change password →</button>
      </form>
      <c:if test="${not empty email}">
      <form action="${pageContext.request.contextPath}/resend-otp" method="post" style="text-align:center;margin-top:20px">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <input type="hidden" name="email" value="${fn:escapeXml(email)}">
        <input type="hidden" name="purpose" value="RESET_PASSWORD">
        <button type="submit" id="resendBtn" class="btn btn-outline btn-sm" disabled>Resend code</button>
        <div id="resendHint" style="color:var(--muted);font-size:.8rem;margin-top:8px"></div>
      </form>
      <script>
(function () {
  var btn = document.getElementById('resendBtn'), hint = document.getElementById('resendHint');
  if (!btn) return;
  var left = 60;
  function tick() {
    if (left <= 0) { btn.disabled = false; hint.textContent = ''; return; }
    hint.textContent = 'You can ask for a new code in ' + left + 's';
    left--; setTimeout(tick, 1000);
  }
  tick();
})();
</script>
      </c:if>
      <p style="text-align:center;margin-top:20px">
        <a href="${pageContext.request.contextPath}/login" style="color:var(--muted);font-size:.85rem">← Back to sign in</a>
      </p>
    </div>
  </div>

</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
