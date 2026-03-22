~ "../uwu-html/lib.ua" ~ Html
Http ~ "../uwu-http/lib.ua"
Assert ~ "../uwu-assert/lib.ua"

$ (function() {
$   const POLL_ENDPOINT = '/__uwu-build-version';
$   const POLL_INTERVAL = 1000;
$   let currentVersion = null;
$   async function poll() {
$     try {
$       const res = await fetch(POLL_ENDPOINT, { cache: 'no-store' });
$       const version = await res.text();
$       if (currentVersion === null) {
$         currentVersion = version;
$       } else if (version !== currentVersion) {
$         window.location.reload();
$       }
$     } catch {}
$     setTimeout(poll, POLL_INTERVAL);
$   }
$   poll();
$ })();
HotReloadScript ↚

HotReloadScriptTagInDevEnv ↚ Html!(
  ToString Script!(°⊸Defer "true") UnsafeRawText HotReloadScript
)

DevEnv ↚ °"DEV" ⌵&var "ENV"

# Struct!Http~Response ? Struct!Http~Response
InsertScript ← (
  ⊸Assert!Struct!Http.Response
  Assert!Is!DevEnv
  ⍥⍣(⍜(°$"_</head>_" °utf₈ Http.Response.Body|˜⊂HotReloadScriptTagInDevEnv)|∘)
)

# A timestamp that changes whenever the server is restarted, used for hot reload functionality to detect changes.
BuildVersion ↚ memo(°⋕now)

# An endpoint that returns the current build version, used by the hot reload script to detect changes.
# Struct!Http~Response ? Struct!Http~Request
BuildVersionEndpoint ← (
  ⊸Assert!Struct!Http.Request DevEnv
  °"/__uwu-build-version" Http.Request.Path
  Http.ResponseOk BuildVersion
)
