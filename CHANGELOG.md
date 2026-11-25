# Changelog

## 0.1.0

- `WritesSlackReplyRequests` and `WritesWebAddressReplyRequests`: a
  module's pure code for posting a reply. `draw(to, trajectory, content)`
  writes the web requests, in order, with no sign-in; `posted(response)`
  reads what one of them posted as an `Outcome`: `Ran` with the server's
  id, `NothingRan` only when the response itself says nothing posted,
  `StoppedPartway` with `done` null when that can't be told.
