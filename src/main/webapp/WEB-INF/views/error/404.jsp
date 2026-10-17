<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Not Found — FoodBridge</title>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
<style>
body{font-family:'DM Sans',sans-serif;background:#1A1A2E;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;color:#fff}
.err{text-align:center;padding:40px}
.code{font-family:'Playfair Display',serif;font-size:8rem;line-height:1;color:#E8821A;margin-bottom:8px}
h1{font-size:1.8rem;margin-bottom:12px}
p{color:rgba(255,255,255,.55);margin-bottom:28px}
.btn{background:#E8821A;color:#fff;padding:12px 28px;border-radius:8px;text-decoration:none;font-weight:500}
</style>
  <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo-mark.png">
</head>
<body>
<div class="err">
  <div class="code">404</div>
  <h1>Page Not Found</h1>
  <p>The page you're looking for doesn't exist or has been moved.</p>
  <a href="${pageContext.request.contextPath}/" class="btn">← Back to Home</a>
</div>
</body>
</html>
