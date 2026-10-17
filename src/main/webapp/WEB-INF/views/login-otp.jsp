<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Confirm Sign In — FoodBridge</title>
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
    <style>
      @keyframes shake { 0%,100% { transform: translateX(0) } 25% { transform: translateX(-8px) } 75% { transform: translateX(8px) } }
      .shake { animation: shake .35s }
      #otpCode:disabled { opacity: .6 }
      .live-msg { min-height: 52px; }
    </style>
    <div class="auth-form-box animate-in">
      <h2 class="auth-title">Confirm it's you</h2>
      <p class="auth-sub">Type the 6-digit sign-in code we sent to <strong><c:out value="${maskedEmail}"/></strong>. It submits by itself.</p>

      <div class="live-msg" id="liveMsg" role="status" aria-live="polite">
        <c:if test="${not empty param.msg}"><div class="alert alert-success">✅ <c:out value="${param.msg}"/></div></c:if>
        <c:if test="${not empty param.err}"><div class="alert alert-danger">⚠️ <c:out value="${param.err}"/></div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger">⚠️ <c:out value="${error}"/></div></c:if>
      </div>

      <form id="otpForm" action="${pageContext.request.contextPath}/login-otp" method="post" novalidate>
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <div class="form-group" style="margin-bottom:12px">
          <label class="form-label" for="otpCode">Verification code <span>*</span></label>
          <input type="text" name="otpCode" id="otpCode" class="form-control" inputmode="numeric" autocomplete="one-time-code"
                 pattern="[0-9]{6}" maxlength="6" placeholder="••••••" required autofocus
                 style="letter-spacing:10px;font-size:1.5rem;text-align:center">
        </div>
        <div style="display:flex;justify-content:space-between;color:var(--muted);font-size:.82rem;margin-bottom:20px">
          <span id="expiryNote">Code expires in <b id="expiry">--:--</b></span>
          <span id="statusNote"></span>
        </div>
        <button type="submit" id="verifyBtn" class="btn btn-primary" style="width:100%;justify-content:center;padding:13px;font-size:1rem">Sign in →</button>
      </form>

      <div style="text-align:center;margin-top:20px">
        <button type="button" id="resendBtn" class="btn btn-outline btn-sm" disabled>Resend code</button>
        <div id="resendHint" style="color:var(--muted);font-size:.8rem;margin-top:8px"></div>
      </div>

      <p style="text-align:center;margin-top:20px">
        <a href="${pageContext.request.contextPath}/login" style="color:var(--muted);font-size:.85rem">← Use a different account</a>
      </p>
    </div>
  </div>

</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>

<script>
(function () {
  var ctx = '${pageContext.request.contextPath}';
  var expiresIn = Number('${empty expiresIn ? 0 : expiresIn}');
  var resendIn  = Number('${empty resendIn ? 0 : resendIn}');
  var form = document.getElementById('otpForm'), input = document.getElementById('otpCode');
  var btn = document.getElementById('verifyBtn'), msg = document.getElementById('liveMsg');
  var resendBtn = document.getElementById('resendBtn'), hint = document.getElementById('resendHint');
  var expiryEl = document.getElementById('expiry'), expiryNote = document.getElementById('expiryNote');
  var statusNote = document.getElementById('statusNote');
  var csrf = form.querySelector('input[name="_csrf"]').value;
  var busy = false, done = false;

  function show(kind, text) {
    var d = document.createElement('div');
    d.className = 'alert alert-' + kind;
    d.textContent = (kind === 'success' ? '✅ ' : '⚠️ ') + text;
    msg.innerHTML = ''; msg.appendChild(d);
  }
    function post(url, data) {
    var body = new URLSearchParams(data).toString();
    return fetch(ctx + url, { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-CSRF-TOKEN': csrf, 'Accept': 'application/json' },
      body: body }).then(function (r) { if (!r.ok) throw new Error('http ' + r.status); return r.json(); });
  }

  // ----- live timers -----
  function fmt(s) { var m = Math.floor(s / 60), r = s % 60; return m + ':' + (r < 10 ? '0' : '') + r; }
  function tick() {
    if (done) return;
    if (expiresIn > 0) { expiryEl.textContent = fmt(expiresIn); expiresIn--; }
    else { expiryNote.textContent = 'This code has expired. Ask for a new one.'; }
    if (resendIn > 0) { resendBtn.disabled = true; hint.textContent = 'You can ask for a new code in ' + resendIn + 's'; resendIn--; }
    else { resendBtn.disabled = false; hint.textContent = ''; }
  }
  tick(); setInterval(tick, 1000);

  // ----- submit the moment 6 digits are in -----
  function submitCode() {
    var code = input.value.trim();
    if (busy || done || !/^\d{6}$/.test(code)) return;
        busy = true; input.disabled = true; btn.disabled = true; statusNote.textContent = 'Verifying…';
    post('/api/login-otp/verify', { otpCode: code }).then(function (res) {
      if (res.ok) {
        done = true; show('success', res.message); statusNote.textContent = '';
        expiryNote.style.display = 'none'; resendBtn.disabled = true;
        setTimeout(function () { window.location.href = ctx + res.redirect; }, 900);
      } else {
        show('danger', res.message); if (res.restart) { setTimeout(function () { window.location.href = ctx + '/login'; }, 1800); } input.value = ''; input.classList.add('shake');
        setTimeout(function () { input.classList.remove('shake'); }, 400);
      }
    }).catch(function () {
      show('danger', 'Could not reach the server. Please try again.');
    }).then(function () {
      busy = false; statusNote.textContent = '';
      if (!done) { input.disabled = false; btn.disabled = false; input.focus(); }
    });
  }
  input.addEventListener('input', function () {
    input.value = input.value.replace(/\D/g, '').slice(0, 6);
    if (input.value.length === 6) submitCode();
  });
  form.addEventListener('submit', function (e) { e.preventDefault(); submitCode(); });

  // ----- resend without leaving the page -----
  resendBtn.addEventListener('click', function () {
    if (resendBtn.disabled) return;
    resendBtn.disabled = true; hint.textContent = 'Sending…';
    post('/api/login-otp/resend', {}).then(function (res) {
      show(res.ok ? 'success' : 'danger', res.message);
      if (res.expiresIn !== undefined) { expiresIn = res.expiresIn; expiryNote.innerHTML = 'Code expires in <b id="expiry">--:--</b>'; expiryEl = document.getElementById('expiry'); }
      resendIn = res.resendIn !== undefined ? res.resendIn : 60;
      input.value = ''; input.focus();
    }).catch(function () { show('danger', 'Could not reach the server. Please try again.'); resendIn = 5; });
  });
})();
</script>
</body>
</html>
