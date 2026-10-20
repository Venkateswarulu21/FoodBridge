
const CACHE_NAME = "foodbridge-v1";

const APP_FILES = [
  "/",
  "/manifest.webmanifest",
  "/css/style.css"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) =>
      cache.addAll(APP_FILES).catch((error) => {
        console.log("Some files could not be cached:", error);
      })
    )
  );

  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      )
    )
  );

  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;

  const url = new URL(event.request.url);

  // Never cache login, registration, OTP, or other dynamic requests.
  if (url.origin !== self.location.origin) return;

  if (
    url.pathname.startsWith("/login") ||
    url.pathname.startsWith("/register") ||
    url.pathname.startsWith("/verify-otp") ||
    url.pathname.startsWith("/resend-otp") ||
    url.pathname.startsWith("/api/") ||
    url.pathname.startsWith("/admin/") ||
    url.pathname.startsWith("/donor/") ||
    url.pathname.startsWith("/receiver/") ||
    url.pathname.startsWith("/volunteer/")
  ) {
    return;
  }

  event.respondWith(
    fetch(event.request).catch(() => caches.match(event.request))
  );
});
