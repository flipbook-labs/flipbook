# Anonymized usage telemetry

Opt-in flow:

- Popup when user opens Flipbook, prompt them to opt-in to anonymized usage statistics
- Can be turned off at any point in Settings
- Only if true do we collect metrics

A session is established when Flipbook is first opened, if and only if the user has given their consent. A session is given a unique ID to keep track of it. This ID is in no way tied to the user of the plugin, all session data is left anonymous.

# Metrics to track

Core metrics:

- Session started (Plugin opened)
- Session ended (Plugin unloaded)
- Story opened
- Story closed
- Time spent with stories open
- Pages navigated to

Daily active users calculated by:

1. Plugin was opened
2. User performed one other action while using the plugin
3. Plugin remained open for at least 30s

Concurrent users:

- Plugin opened

# Implementation

## Backend service

I really don't want to handle all the session management myself. Is there a crate I can offload that to? I really just want to setup a thin REST API that routes in events and directs them to a data lake

- tower_sessions can be used with axum https://docs.rs/tower-sessions/latest/tower_sessions/
- PostHog also seems promising: https://posthog.com/docs/libraries/rust
  - Would still need a Rust backend to handle the API key and requests but this could make life a lot easier

Base URL: `https://apis.flipbooklabs.com`

Endpoints:

`POST /telemetry/ingest`

General endpoint to collect events from the client

`GET /telemetry/start-session`

Returns a session ID and, if there is not already an installation ID, returns that too.

The session ID only exists for the duration that Flipbook is loaded, where “loaded” means that the widget has been mounted for the first time and the plugin has not unloaded yet.

The installation ID gets stored in the plugin settings and used as a unique ID for the current installation of Flipbook. This helps give our events continuity over several sessions.

`GET /telemetry/still-alive`

Called periodically during a session to keep it alive.

Since we can't always know when a session ends, this helps us keep track of the last time we

Since there is ambiguity around when a session ends, this helps ensure

`GET /telemetry/end-session`

Called when the plugin is unloading.

This endpoint will not always be called. Some cases include:

1. Roblox Studio exited in such a way that the `Unloading` event did not fire
2. The user disabled http requests for Flipbook during the session

As such, we assume that a session has ended 1 hour after the last request to `/telemetry/still-alive`

## Backend handshake

Metric logging needs to be setup with a public API. We could use rate limiting and setup something similar to Roblox where you hit the endpoint, it returns a token, then that token is used for everything.

Is there a better way to ensure that requests are coming from a Roblox session?

## Plugin sending HTTP requests

Plugins are able to send HTTP requests but each domain is able to be allowed/disallowed by the user at any point.

The user will initially be prompted to allow HTTP requests for the domains that the plugin hits. The user has the choice to deselect the domains they do not want to give permission to. As such, it needs to be expected that requests will be blocked immediately and handled accordingly.

## Anonymous

No UserIds or other PII will be sent with requests. We still need a way to maintain continuity though, and this will be established by…

1. A unique ID is generated when Flipbook is first run
2. This ID will be stored in the user's plugin settings
3. Any telemetry events will use this ID to maintain continuity

If the user clears their plugin settings then this ID is also destroyed and a new one generated later

There will also be another ID for tracking the current session. This will allow us to sort events per-session and per-lifetime

## Gentle nudges

If a user has disabled access to `api.flipbooklabs.com`, give them an occasional gentle nudge about it. Show a dialog that explains Flipbook may not work properly with http requests disabled.

Give the user the option of “don't show this again” so they can dismiss it forever

## Storage & Analysis

PostgreSQL will be used for storing all of the telemetry events.

Later I'll figure out a good way to analyze the data but the main focus is to handle ingestion and storage right now

## Deployment

1. Setup [`apis.flipbooklabs.com`](http://apis.flipbooklabs.com) to host backend
2. Use Cloudflare tunnels to manage the DNS
3. Maybe create a new DigitalOcean droplet (or App?) for the service
