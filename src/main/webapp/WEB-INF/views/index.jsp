<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>FoodBridge — Connecting Surplus to Need</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
<link rel="manifest" href="/manifest.webmanifest">
<meta name="theme-color" content="#245c43">
<style>
/* ===== Navbar ===== */
.hero-nav {
  display: flex; align-items: center; justify-content: space-between;
  padding: 20px 48px;
  position: sticky; top: 0; z-index: 100;
  backdrop-filter: blur(16px);
  background: rgba(26,26,46,.7);
  border-bottom: 1px solid rgba(255,255,255,.06);
  transition: all .3s;
}
.nav-links { display: flex; align-items: center; gap: 6px; }
.nav-link {
  color: rgba(255,255,255,.7); font-size: .88rem; font-weight: 400;
  padding: 8px 16px; border-radius: 99px;
  transition: all .25s; text-decoration: none; position: relative;
}
.nav-link::after {
  content: ''; position: absolute; bottom: 4px; left: 50%; right: 50%;
  height: 2px; background: var(--saffron); border-radius: 99px; transition: all .25s;
}
.nav-link:hover { color: #fff; background: rgba(255,255,255,.07); }
.nav-link:hover::after { left: 16px; right: 16px; }
.nav-actions { display: flex; gap: 10px; align-items: center; }

/* ===== Hero ===== */
.hero {
  background: linear-gradient(135deg, #1A1A2E 0%, #16213E 50%, #0d1b2a 100%);
  min-height: 100vh; display: flex; flex-direction: column;
  position: relative; overflow: hidden;
}
.hero-pattern {
  position: absolute; inset: 0;
  background-image:
    radial-gradient(circle at 15% 50%, rgba(232,130,26,.18) 0%, transparent 50%),
    radial-gradient(circle at 85% 20%, rgba(82,183,136,.12) 0%, transparent 40%),
    radial-gradient(circle at 60% 80%, rgba(74,144,217,.08) 0%, transparent 40%);
  pointer-events: none;
  animation: patternShift 8s ease-in-out infinite alternate;
}
@keyframes patternShift { from { opacity:.8; } to { opacity:1; } }

.hero-body {
  flex: 1; display: flex; align-items: center;
  padding: 60px 48px; position: relative; z-index: 1; gap: 60px;
}
.hero-text { max-width: 540px; flex: 1; }

/* ===== Hero Visual ===== */
.hero-visual {
  flex: 1; display: flex; align-items: center; justify-content: center; position: relative;
}
.hero-logo-card {
  width: 360px; height: 360px; border-radius: 48px; overflow: hidden; position: relative;
  box-shadow: 0 30px 80px rgba(0,0,0,.4), 0 0 0 1px rgba(255,255,255,.08);
  animation: floatCard 5s ease-in-out infinite;
}
.hero-logo-card img { width: 100%; height: 100%; object-fit: cover; transition: transform .5s; }
.hero-logo-card:hover img { transform: scale(1.05); }
.float-badge {
  position: absolute;
  background: rgba(255,255,255,.1); backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,.15); border-radius: 14px;
  padding: 10px 16px; color: #fff; font-size: .82rem;
  display: flex; align-items: center; gap: 8px; white-space: nowrap;
  box-shadow: 0 8px 24px rgba(0,0,0,.2);
}
.float-badge .dot { width: 8px; height: 8px; border-radius: 50%; }
.float-badge-1 { top: -20px; left: -40px; animation: floatBadge1 4s ease-in-out infinite; }
.float-badge-2 { bottom: 40px; right: -50px; animation: floatBadge2 5s ease-in-out infinite; }
.float-badge-3 { top: 50%; left: -60px; animation: floatBadge3 4.5s ease-in-out infinite; }
@keyframes floatCard { 0%,100% { transform: translateY(0) rotate(0deg); } 50% { transform: translateY(-12px) rotate(1deg); } }
@keyframes floatBadge1 { 0%,100% { transform:translate(0,0); } 50% { transform:translate(-6px,-8px); } }
@keyframes floatBadge2 { 0%,100% { transform:translate(0,0); } 50% { transform:translate(8px,6px); } }
@keyframes floatBadge3 { 0%,100% { transform:translateY(-50%); } 50% { transform:translateY(calc(-50% - 8px)); } }
.hero-visual::before {
  content: ''; position: absolute; width: 420px; height: 420px; border-radius: 50%;
  background: radial-gradient(circle, rgba(232,130,26,.15) 0%, transparent 70%);
  animation: glowPulse 3s ease-in-out infinite;
}
@keyframes glowPulse { 0%,100% { transform:scale(1); opacity:.6; } 50% { transform:scale(1.08); opacity:1; } }

.hero-text .eyebrow {
  display: inline-flex; align-items: center; gap: 8px;
  background: rgba(232,130,26,.15); color: var(--saffron-light);
  padding: 7px 18px; border-radius: 99px;
  font-size: .8rem; font-weight: 600; letter-spacing: .1em; text-transform: uppercase;
  margin-bottom: 24px; border: 1px solid rgba(232,130,26,.25); backdrop-filter: blur(8px);
}
.hero-text h1 { color:#fff; font-size:clamp(2.2rem,4.5vw,3.4rem); line-height:1.15; margin-bottom:20px; }
.hero-text h1 em { color:var(--saffron-light); font-style:italic; }
.hero-text p { color:rgba(255,255,255,.65); font-size:1.05rem; line-height:1.85; margin-bottom:36px; max-width:480px; }
.hero-cta { display:flex; gap:14px; flex-wrap:wrap; margin-bottom:48px; }
.hero-stats {
  display:flex; gap:32px; padding:20px 24px;
  background:rgba(255,255,255,.05); backdrop-filter:blur(10px);
  border:1px solid rgba(255,255,255,.08); border-radius:16px; width:fit-content;
}
.hero-stat { text-align:center; }
.hero-stat .val { font-family:var(--font-display); font-size:1.9rem; font-weight:700; color:var(--saffron-light); line-height:1; }
.hero-stat .lbl { font-size:.72rem; color:rgba(255,255,255,.45); text-transform:uppercase; letter-spacing:.08em; margin-top:4px; }
.hero-stat-divider { width:1px; background:rgba(255,255,255,.1); align-self:stretch; }

/* ===== Sections ===== */
.section-tag {
  display: inline-block; background: var(--saffron-pale); color: var(--saffron);
  padding: 5px 16px; border-radius: 99px;
  font-size: .75rem; font-weight: 600; letter-spacing: .1em; text-transform: uppercase;
  margin-bottom: 14px; border: 1px solid rgba(232,130,26,.2);
}
.section-header { text-align:center; margin-bottom:60px; }
.section-header h2 { margin-bottom:12px; }
.section-header p { color:var(--muted); font-size:1rem; line-height:1.7; max-width:500px; margin:0 auto; }

/* ===== Features ===== */
.features {
  padding: 100px 48px; background: var(--warm-white);
  position: relative; overflow: hidden;
}
.features::before {
  content: ''; position: absolute; top:0; left:0; right:0; height:4px;
  background: linear-gradient(90deg, var(--saffron), var(--forest-light), var(--saffron));
  background-size: 200% auto; animation: gradientSlide 3s linear infinite;
}
@keyframes gradientSlide { from { background-position:0% center; } to { background-position:200% center; } }
.features-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr)); gap:28px; max-width:1100px; margin:0 auto; }
.feature-card {
  padding:36px 28px; background:var(--warm-white); border:1px solid var(--border);
  border-radius:var(--radius); text-align:center;
  transition:all .3s cubic-bezier(.4,0,.2,1); position:relative; overflow:hidden;
}
.feature-card::before {
  content:''; position:absolute; inset:0;
  background:linear-gradient(135deg,var(--saffron-pale) 0%,transparent 60%);
  opacity:0; transition:opacity .3s;
}
.feature-card:hover { transform:translateY(-8px); box-shadow:var(--shadow-lg); border-color:rgba(232,130,26,.2); }
.feature-card:hover::before { opacity:1; }
.feature-card .icon { font-size:2.8rem; margin-bottom:20px; display:block; transition:transform .3s cubic-bezier(.4,0,.2,1); }
.feature-card:hover .icon { transform:scale(1.2) rotate(-5deg); }
.feature-card h3 { margin-bottom:12px; position:relative; }
.feature-card p { color:var(--muted); font-size:.9rem; line-height:1.75; position:relative; }

/* ===== How it works ===== */
.how-it-works { padding:100px 48px; background:linear-gradient(135deg,var(--cream) 0%,#f0ebe0 100%); position:relative; overflow:hidden; }
.steps { display:flex; gap:0; max-width:900px; margin:60px auto 0; position:relative; }
.steps::before { content:''; position:absolute; top:36px; left:calc(12.5%); right:calc(12.5%); height:2px; background:linear-gradient(90deg,var(--saffron),var(--forest-light)); }
.step { flex:1; text-align:center; position:relative; }
.step-num {
  width:72px; height:72px; background:linear-gradient(135deg,var(--saffron),#cf6f12);
  color:#fff; border-radius:50%; display:flex; align-items:center; justify-content:center;
  font-family:var(--font-display); font-size:1.4rem; font-weight:700;
  margin:0 auto 20px; position:relative; z-index:1;
  box-shadow:0 6px 24px rgba(232,130,26,.4); transition:all .3s cubic-bezier(.4,0,.2,1);
}
.step:hover .step-num { transform:scale(1.15) translateY(-4px); box-shadow:0 12px 32px rgba(232,130,26,.5); }
.step h4 { font-size:1rem; margin-bottom:8px; font-weight:600; }
.step p { font-size:.85rem; color:var(--muted); padding:0 16px; line-height:1.7; }

/* ===== About ===== */
.about-section { padding:100px 48px; background:var(--cream); }
.about-inner { max-width:1100px; margin:0 auto; display:grid; grid-template-columns:1fr 1fr; gap:80px; align-items:center; }
.about-text h2 { margin-bottom:20px; }
.about-text p { color:var(--muted); line-height:1.85; font-size:.98rem; margin-bottom:16px; }
.about-visual { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
.about-stat-box { background:var(--warm-white); border:1px solid var(--border); border-radius:var(--radius); padding:24px; text-align:center; transition:all .3s; }
.about-stat-box:hover { transform:translateY(-4px); box-shadow:var(--shadow-md); }
.about-stat-box .val { font-family:var(--font-display); font-size:2rem; font-weight:700; color:var(--saffron); display:block; margin-bottom:6px; }
.about-stat-box .lbl { font-size:.78rem; color:var(--muted); text-transform:uppercase; letter-spacing:.06em; }

/* ===== NGOs ===== */
.ngos-section { padding:100px 48px; background:var(--warm-white); text-align:center; }
.ngo-cards { display:flex; gap:24px; justify-content:center; flex-wrap:wrap; margin-top:48px; }
.ngo-card {
  background:var(--cream); border:1px solid var(--border); border-radius:var(--radius);
  padding:28px 32px; min-width:180px; transition:all .3s;
  display:flex; flex-direction:column; align-items:center; gap:12px;
}
.ngo-card:hover { transform:translateY(-6px); box-shadow:var(--shadow-md); border-color:rgba(232,130,26,.2); background:var(--saffron-pale); }
.ngo-card .ngo-icon { font-size:2.2rem; }
.ngo-card h4 { font-size:.95rem; font-weight:600; }
.ngo-card p { font-size:.82rem; color:var(--muted); line-height:1.6; text-align:center; }

/* ===== Contact ===== */
.contact-section { padding:100px 48px; background:linear-gradient(135deg,#1A1A2E 0%,#16213E 100%); position:relative; overflow:hidden; }
.contact-section::before { content:''; position:absolute; top:-100px; right:-100px; width:400px; height:400px; background:radial-gradient(circle,rgba(232,130,26,.12) 0%,transparent 70%); border-radius:50%; }
.contact-inner { max-width:600px; margin:0 auto; text-align:center; position:relative; z-index:1; }
.contact-inner h2 { color:#fff; margin-bottom:16px; }
.contact-inner p { color:rgba(255,255,255,.6); font-size:1rem; line-height:1.8; margin-bottom:36px; }
.contact-form { display:flex; flex-direction:column; gap:16px; }
.contact-form input, .contact-form textarea {
  padding:14px 18px; background:rgba(255,255,255,.07); border:1px solid rgba(255,255,255,.12);
  border-radius:var(--radius-sm); color:#fff; font-family:var(--font-body); font-size:.9rem;
  transition:all .2s; outline:none; backdrop-filter:blur(8px);
}
.contact-form input::placeholder, .contact-form textarea::placeholder { color:rgba(255,255,255,.35); }
.contact-form input:focus, .contact-form textarea:focus { border-color:var(--saffron); box-shadow:0 0 0 3px rgba(232,130,26,.15); background:rgba(255,255,255,.1); }
.contact-form textarea { min-height:120px; resize:vertical; }

/* ===== Footer ===== */
footer { background:#0d1117; color:rgba(255,255,255,.4); padding:48px; }
.footer-inner { max-width:1100px; margin:0 auto; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:24px; }
.footer-brand { display:flex; align-items:center; gap:12px; }
.footer-brand img { width:44px; height:44px; border-radius:12px; object-fit:cover; }
.footer-brand span { color:#fff; font-family:var(--font-display); font-size:1.2rem; }
.footer-links { display:flex; gap:24px; flex-wrap:wrap; }
.footer-links a { color:rgba(255,255,255,.4); font-size:.85rem; transition:color .2s; }
.footer-links a:hover { color:var(--saffron-light); }
.footer-copy { font-size:.82rem; text-align:center; width:100%; padding-top:24px; border-top:1px solid rgba(255,255,255,.06); }

@media (max-width:900px) {
  .hero-body { flex-direction:column; padding:40px 24px; }
  .hero-visual { display:none; }
  .hero-nav { padding:16px 24px; }
  .nav-links { display:none; }
  .features, .how-it-works, .ngos-section, .contact-section, .about-section { padding:60px 24px; }
  .about-inner { grid-template-columns:1fr; gap:40px; }
  .footer-inner { flex-direction:column; text-align:center; }
}

/* ===== Phone fixes ===== */
@media (max-width: 600px) {
  .hero-nav { padding: 12px 16px; }
  .hero-nav h1 { font-size: 1.15rem !important; }
  .nav-actions { gap: 6px; }
  .nav-actions .btn { padding: 8px 12px; font-size: .8rem; }
  .hero-body { padding: 32px 18px; }
  .hero-cta .btn { width: 100%; justify-content: center; }
  .hero-stats { width: 100%; gap: 12px; padding: 14px 12px; justify-content: space-around; }
  .hero-stat .val { font-size: 1.5rem; }
  .steps { flex-direction: column; gap: 32px; }
  .steps::before { display: none; }
  .about-visual { grid-template-columns: 1fr 1fr; gap: 10px; }
  .ngo-card { min-width: 0; width: 100%; }
  footer { padding: 32px 20px; }
}
</style>
  <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo-mark.png">
</head>
<body>

<section class="hero" id="home">
  <div class="hero-pattern"></div>

  <nav class="hero-nav">
    <div class="logo" style="display:flex;align-items:center;gap:12px">
      <img src="${pageContext.request.contextPath}/images/logo-mark.png" alt="FoodBridge Logo"
           style="width:46px;height:46px;border-radius:12px;object-fit:cover;box-shadow:0 4px 12px rgba(0,0,0,.4)">
      <h1 style="color:#fff;font-family:var(--font-display);font-size:1.4rem;font-weight:700">FoodBridge</h1>
    </div>

    <div class="nav-links">
      <a href="#about"        class="nav-link">About</a>
      <a href="#how-it-works" class="nav-link">How It Works</a>
      <a href="#ngos"         class="nav-link">NGOs</a>
      <a href="#contact"      class="nav-link">Contact</a>
    </div>

    <div class="nav-actions">
      <a href="${pageContext.request.contextPath}/login"
         class="btn btn-outline"
         style="border-color:rgba(255,255,255,.25);color:#fff;backdrop-filter:blur(8px)">Sign In</a>
      <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Join Free →</a>
    </div>
  </nav>

  <div class="hero-body">
    <div class="hero-text">
      <div class="eyebrow" data-aos="fade-down">🌿 Zero Hunger Initiative</div>
      <h1 data-aos="fade-up" data-aos-delay="100">Turn <em>Leftover Food</em><br>Into Lasting Hope</h1>
      <p data-aos="fade-up" data-aos-delay="200">
        FoodBridge connects event organizers, restaurants, and households with surplus food
        to NGOs, trusts, and individuals who need it most — all managed seamlessly by a dedicated admin team.
      </p>
      <div class="hero-cta" data-aos="fade-up" data-aos-delay="300">
        <a href="${pageContext.request.contextPath}/register?role=donor"
           class="btn btn-primary" style="font-size:1rem;padding:14px 28px">🍱 I Have Food to Donate</a>
        <a href="${pageContext.request.contextPath}/register?role=receiver"
           class="btn btn-outline" style="border-color:rgba(255,255,255,.35);color:#fff;font-size:1rem;padding:14px 28px">🏛️ We Need Food</a>
      </div>
      <div class="hero-stats" data-aos="fade-up" data-aos-delay="400">
        <div class="hero-stat"><div class="val">500+</div><div class="lbl">Donations Made</div></div>
        <div class="hero-stat-divider"></div>
        <div class="hero-stat"><div class="val">12K</div><div class="lbl">People Fed</div></div>
        <div class="hero-stat-divider"></div>
        <div class="hero-stat"><div class="val">48</div><div class="lbl">NGO Partners</div></div>
      </div>
    </div>

    <div class="hero-visual" data-aos="zoom-in" data-aos-delay="300">
      <div class="hero-logo-card">
        <img src="${pageContext.request.contextPath}/images/logo-full.png" alt="FoodBridge">
      </div>
      <div class="float-badge float-badge-1">
        <div class="dot" style="background:#10B981"></div>
        <span>500+ Active Donors</span>
      </div>
      <div class="float-badge float-badge-2">
        <div class="dot" style="background:var(--saffron)"></div>
        <span>🍱 Food Delivered Today</span>
      </div>
      <div class="float-badge float-badge-3">
        <div class="dot" style="background:#3B82F6"></div>
        <span>48 NGO Partners</span>
      </div>
    </div>
  </div>
</section>

<!-- ABOUT -->
<section class="about-section" id="about">
  <div class="about-inner">
    <div class="about-text" data-aos="fade-right">
      <div class="section-tag">About Us</div>
      <h2>Fighting Food Waste,<br>One Meal at a Time</h2>
      <p>Every day, tons of perfectly good food goes to waste while millions go hungry. FoodBridge was built to bridge this gap — creating a seamless platform that connects surplus food with those who need it most.</p>
      <p>Our technology ensures that no good food goes to waste. From weddings to restaurants, we make food donation simple, trackable, and impactful.</p>
      <a href="${pageContext.request.contextPath}/register" class="btn btn-primary" style="margin-top:8px">Join the Movement →</a>
    </div>
    <div class="about-visual" data-aos="fade-left" data-aos-delay="100">
      <div class="about-stat-box" data-aos="zoom-in" data-aos-delay="200"><span class="val">500+</span><span class="lbl">Donations Made</span></div>
      <div class="about-stat-box" data-aos="zoom-in" data-aos-delay="300"><span class="val">12K+</span><span class="lbl">People Fed</span></div>
      <div class="about-stat-box" data-aos="zoom-in" data-aos-delay="400"><span class="val">48</span><span class="lbl">NGO Partners</span></div>
      <div class="about-stat-box" data-aos="zoom-in" data-aos-delay="500"><span class="val">0kg</span><span class="lbl">Food Wasted</span></div>
    </div>
  </div>
</section>

<!-- FEATURES -->
<section class="features" id="features">
  <div class="section-header" data-aos="fade-up">
    <div class="section-tag">Features</div>
    <h2>Built for Every Role</h2>
    <p>A platform that works for everyone in the food sharing chain</p>
  </div>
  <div class="features-grid">
    <div class="feature-card" data-aos="fade-up" data-aos-delay="0"><span class="icon">🍽️</span><h3>Donors</h3><p>Submit surplus food from weddings, parties, restaurants, or home events with pickup time and location.</p></div>
    <div class="feature-card" data-aos="fade-up" data-aos-delay="100"><span class="icon">🏛️</span><h3>NGOs & Trusts</h3><p>Submit daily food requirements and receive matched donations — tracked from pickup to delivery.</p></div>
    <div class="feature-card" data-aos="fade-up" data-aos-delay="200"><span class="icon">🛵</span><h3>Volunteers</h3><p>Get assigned pickup tasks, update delivery status in real-time, and track your impact over time.</p></div>
    <div class="feature-card" data-aos="fade-up" data-aos-delay="300"><span class="icon">⚙️</span><h3>Admin Control</h3><p>Approve donations, match food to receivers, assign volunteers, and monitor the full ecosystem.</p></div>
  </div>
</section>

<!-- HOW IT WORKS -->
<section class="how-it-works" id="how-it-works">
  <div class="section-header" data-aos="fade-up">
    <div class="section-tag">Process</div>
    <h2>How FoodBridge Works</h2>
    <p>Four simple steps to turn surplus food into hope</p>
  </div>
  <div class="steps">
    <div class="step" data-aos="fade-up" data-aos-delay="0"><div class="step-num">1</div><h4>Donor Submits</h4><p>Add food details, location & pickup window</p></div>
    <div class="step" data-aos="fade-up" data-aos-delay="150"><div class="step-num">2</div><h4>Admin Reviews</h4><p>Approves, matches & assigns volunteer</p></div>
    <div class="step" data-aos="fade-up" data-aos-delay="300"><div class="step-num">3</div><h4>Volunteer Picks Up</h4><p>Collects food from donor location</p></div>
    <div class="step" data-aos="fade-up" data-aos-delay="450"><div class="step-num">4</div><h4>NGO Receives</h4><p>Food delivered to the right hands</p></div>
  </div>
</section>

<!-- NGOs -->
<section class="ngos-section" id="ngos">
  <div class="section-header" data-aos="fade-up">
    <div class="section-tag">Partners</div>
    <h2>Our NGO Partners</h2>
    <p>Working with trusted organizations to ensure food reaches those who need it most</p>
  </div>
  <div class="ngo-cards">
    <div class="ngo-card" data-aos="zoom-in" data-aos-delay="0"><div class="ngo-icon">🏛️</div><h4>Seva Trust</h4><p>Serving communities in Delhi NCR since 2010</p></div>
    <div class="ngo-card" data-aos="zoom-in" data-aos-delay="100"><div class="ngo-icon">🤝</div><h4>Helping Hands</h4><p>Daily meal programs for 500+ people</p></div>
    <div class="ngo-card" data-aos="zoom-in" data-aos-delay="200"><div class="ngo-icon">🌱</div><h4>Green Plate</h4><p>Sustainable food distribution network</p></div>
    <div class="ngo-card" data-aos="zoom-in" data-aos-delay="300"><div class="ngo-icon">❤️</div><h4>Anna Daan</h4><p>Traditional food sharing with a modern touch</p></div>
    <div class="ngo-card" data-aos="zoom-in" data-aos-delay="400"><div class="ngo-icon">🍚</div><h4>Roti Bank</h4><p>Zero hunger initiative across 10 cities</p></div>
  </div>
</section>

<!-- CONTACT -->
<section class="contact-section" id="contact">
  <div class="contact-inner" data-aos="fade-up">
    <div class="section-tag" style="background:rgba(232,130,26,.2);color:var(--saffron-light);border-color:rgba(232,130,26,.3)">Contact Us</div>
    <h2 style="color:#fff">Get In Touch</h2>
    <p>Have questions about joining FoodBridge? Want to partner with us? We'd love to hear from you.</p>
    <div class="contact-form">
      <input type="text" placeholder="Your Name">
      <input type="email" placeholder="Your Email">
      <textarea placeholder="Your Message..."></textarea>
      <button class="btn btn-primary" style="padding:14px;font-size:1rem;justify-content:center">Send Message →</button>
    </div>
  </div>
</section>

<!-- FOOTER -->
<footer>
  <div class="footer-inner">
    <div class="footer-brand">
      <img src="${pageContext.request.contextPath}/images/logo-mark.png" alt="FoodBridge Logo">
      <span>FoodBridge</span>
    </div>
    <div class="footer-links">
      <a href="#about">About</a>
      <a href="#how-it-works">How It Works</a>
      <a href="#ngos">NGOs</a>
      <a href="#contact">Contact</a>
      <a href="${pageContext.request.contextPath}/login">Sign In</a>
      <a href="${pageContext.request.contextPath}/register">Register</a>
    </div>
    <div class="footer-copy">
      Built with ❤️ to fight food waste —
      <strong style="color:var(--saffron-light)">FoodBridge © 2024</strong><br>
      <small style="opacity:.6">Core Java · Servlets · JSP · MySQL · Tomcat 10</small>
    </div>
  </div>
</footer>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
  if (window.AOS) {
    AOS.init({ duration: 700, easing: 'ease-out-cubic', once: true, offset: 60 });
  } else {   // animation library not reachable: show everything instead of leaving it hidden
    document.querySelectorAll('[data-aos]').forEach(function (el) { el.removeAttribute('data-aos'); });
  }

  // Sticky navbar on scroll
  window.addEventListener('scroll', () => {
    const nav = document.querySelector('.hero-nav');
    if (window.scrollY > 20) {
      nav.style.boxShadow = '0 4px 24px rgba(0,0,0,.3)';
      nav.style.background = 'rgba(26,26,46,.95)';
    } else {
      nav.style.boxShadow = 'none';
      nav.style.background = 'rgba(26,26,46,.7)';
    }
  });

  // Smooth scroll
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
      e.preventDefault();
      const target = document.querySelector(a.getAttribute('href'));
      if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });

  // Counter animation
  function animateCounter(el, target, suffix) {
    let start = 0;
    const step = target / (2000 / 16);
    const timer = setInterval(() => {
      start += step;
      if (start >= target) { el.textContent = target + suffix; clearInterval(timer); return; }
      el.textContent = Math.floor(start) + suffix;
    }, 16);
  }
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const vals = document.querySelectorAll('.hero-stat .val');
        animateCounter(vals[0], 500, '+');
        animateCounter(vals[1], 12, 'K');
        animateCounter(vals[2], 48, '');
        observer.disconnect();
      }
    });
  }, { threshold: 0.5 });
  const statsEl = document.querySelector('.hero-stats');
  if (statsEl) observer.observe(statsEl);
</script>
<script>
  if ("serviceWorker" in navigator) {
    window.addEventListener("load", function () {
      navigator.serviceWorker.register("/service-worker.js")
        .then(function (registration) {
          console.log(
            "FoodBridge service worker registered successfully:",
            registration.scope
          );
        })
        .catch(function (error) {
          console.error(
            "FoodBridge service worker registration failed:",
            error
          );
        });
    });
  }
</script>
</body>
</html>
