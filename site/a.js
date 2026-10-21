// Cookieless analytics: an ID kept only for this tab session, sent straight to PostHog. No cookies, no library.
(function () {
  var key = "phc_CappPjX82qb8tAk4hH7oSYccrSnw2YT7QrQkKrN7F5Gf";
  var id;
  try { id = sessionStorage.getItem("pid") || (crypto.randomUUID ? crypto.randomUUID() : String(Math.random()).slice(2)); sessionStorage.setItem("pid", id); }
  catch (e) { id = String(Math.random()).slice(2); }
  window.track = function (event, props) {
    var p = Object.assign({ app: "profiley-site", $current_url: location.href, $pathname: location.pathname, $referrer: document.referrer, $process_person_profile: false }, props || {});
    var body = JSON.stringify({ api_key: key, event: event, distinct_id: id, properties: p });
    if (!(navigator.sendBeacon && navigator.sendBeacon("https://us.i.posthog.com/i/v0/e/", new Blob([body], { type: "text/plain" })))) {
      fetch("https://us.i.posthog.com/i/v0/e/", { method: "POST", body: body, keepalive: true }).catch(function () {});
    }
  };
  track("$pageview");
})();
