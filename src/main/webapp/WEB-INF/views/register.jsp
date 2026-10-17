<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Register — FoodBridge</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
.role-cards { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:20px; }
.role-card  { position:relative; cursor:pointer; }
.role-card input[type=radio] { position:absolute; opacity:0; }
.role-card label {
  display:flex; flex-direction:column; align-items:center;
  padding:16px 10px; border:2px solid var(--border); border-radius:var(--radius-sm);
  cursor:pointer; transition:all .2s; text-align:center;
}
.role-card label .r-icon { font-size:1.8rem; margin-bottom:8px; }
.role-card label .r-name { font-weight:600; font-size:.85rem; }
.role-card label .r-desc { font-size:.72rem; color:var(--muted); margin-top:2px; }
.role-card input:checked + label { border-color:var(--saffron); background:var(--saffron-pale); }
#orgNameGroup { display:none; }
</style>
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
      <h2>Join the movement<br><em style="color:var(--saffron-light)">for zero hunger</em></h2>
      <p>Register today and become part of a community dedicated to eliminating food waste and feeding those in need.</p>
      <div class="auth-feature" style="margin-top:24px">
        <div class="icon">✅</div>
        <div><strong>Free Forever</strong><p>No charges or hidden fees — FoodBridge is a community service.</p></div>
      </div>
      <div class="auth-feature" style="margin-top:12px">
        <div class="icon">🔒</div>
        <div><strong>Secure & Private</strong><p>Your data is protected with BCrypt-hashed passwords and secure sessions.</p></div>
      </div>
      <div class="auth-feature" style="margin-top:12px">
        <div class="icon">📲</div>
        <div><strong>Real-time Tracking</strong><p>Follow your food from donation to delivery with live status updates.</p></div>
      </div>
    </div>
  </div>

  <!-- Right Panel -->
  <div class="auth-right" style="align-items:flex-start;padding-top:48px;overflow-y:auto">
    <div class="auth-form-box animate-in" style="max-width:500px">
      <h2 class="auth-title">Create your account</h2>
      <p class="auth-sub">Choose your role and fill in your details</p>

      <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ <c:out value="${error}"/></div>
      </c:if>

      <form action="${pageContext.request.contextPath}/register" method="post">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

        <!-- Role Selection -->
        <div class="form-group" style="margin-bottom:20px">
          <label class="form-label">I want to join as <span>*</span></label>
          <div class="role-cards">
            <div class="role-card">
              <input type="radio" name="role" id="roleDonor" value="donor"
                     ${param.role == 'donor' || empty param.role ? 'checked' : ''}>
              <label for="roleDonor">
                <span class="r-icon">🍱</span>
                <span class="r-name">Donor</span>
                <span class="r-desc">I have food to share</span>
              </label>
            </div>
            <div class="role-card">
              <input type="radio" name="role" id="roleReceiver" value="receiver"
                     ${param.role == 'receiver' ? 'checked' : ''}>
              <label for="roleReceiver">
                <span class="r-icon">🏛️</span>
                <span class="r-name">NGO / Trust</span>
                <span class="r-desc">We need food</span>
              </label>
            </div>
            <div class="role-card">
              <input type="radio" name="role" id="roleVolunteer" value="volunteer"
                     ${param.role == 'volunteer' ? 'checked' : ''}>
              <label for="roleVolunteer">
                <span class="r-icon">🛵</span>
                <span class="r-name">Volunteer</span>
                <span class="r-desc">I'll deliver food</span>
              </label>
            </div>
          </div>
        </div>

        <div class="form-grid">
          <div class="form-group form-full">
            <label class="form-label">Full Name <span>*</span></label>
            <input type="text" name="name" class="form-control"
                   placeholder="Rajesh Kumar" required value="${fn:escapeXml(param.name)}">
          </div>
          <div class="form-group">
            <label class="form-label">Email Address <span>*</span></label>
            <input type="email" name="email" class="form-control"
                   placeholder="you@example.com" required value="${fn:escapeXml(param.email)}">
          </div>
          <div class="form-group">
            <label class="form-label">Phone Number</label>
            <input type="tel" name="phone" class="form-control"
                   placeholder="9876543210" value="${fn:escapeXml(param.phone)}">
          </div>
          <div class="form-group form-full">
            <label class="form-label">Password <span>*</span></label>
            <input type="password" name="password" class="form-control"
                   placeholder="At least 8 characters, with a letter and a number" required minlength="8">
          </div>
          <div class="form-group form-full">
            <label class="form-label">Address / Area</label>
            <input type="text" name="address" class="form-control"
                   placeholder="Connaught Place, New Delhi" value="${fn:escapeXml(param.address)}">
          </div>
          <div class="form-group form-full" id="orgNameGroup">
            <label class="form-label">Organisation / Trust Name</label>
            <input type="text" name="org_name" class="form-control"
                   placeholder="Seva Trust NGO" value="${fn:escapeXml(param.org_name)}">
          </div>
        </div>

        <button type="submit" class="btn btn-primary"
                style="width:100%;justify-content:center;padding:13px;font-size:1rem;margin-top:8px">
          Create Account →
        </button>
      </form>

      <p style="text-align:center;margin-top:24px;color:var(--muted);font-size:.9rem">
        Already registered?
        <a href="${pageContext.request.contextPath}/login" style="color:var(--saffron);font-weight:500">Sign in here</a>
      </p>
    </div>
  </div>
</div>

<script>
  // Show org name field only for receiver
  const roleInputs = document.querySelectorAll('input[name=role]');
  const orgGroup   = document.getElementById('orgNameGroup');
  function toggleOrg() {
    const selected = document.querySelector('input[name=role]:checked')?.value;
    orgGroup.style.display = selected === 'receiver' ? 'flex' : 'none';
  }
  roleInputs.forEach(r => r.addEventListener('change', toggleOrg));
  toggleOrg();
</script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
