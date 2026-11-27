# Changelog

## 0.3.0

Breaking: the reply types now come from `is_conversation_vocabulary`
^0.1.0, which `is_conversation_reply_vocabulary` was merged into; the types
and their JSON are unchanged. On `is_effects` ^0.18.0, so both share
`checked_json` ^0.3.0. Import the reply types from
`package:is_conversation_vocabulary/is_conversation_vocabulary.dart`.

## 0.2.0

Breaking: the reply types now come from `is_conversation_reply_vocabulary`
^0.1.0, the renamed `is_reply_vocabulary`, which ends at 0.2.1. The API and
JSON are unchanged. An implementer switches its dependency and its imports
together, in one change: a package that still resolves `is_reply_vocabulary`
beside this one has two `ReplyEndpoint` types, and they don't match.

## 0.1.0

- `WritesSlackReplyRequests` and `WritesWebAddressReplyRequests`: a
  module's pure code for posting a reply. `draw(to, trajectory, content)`
  writes the web requests, in order, with no sign-in; `posted(response)`
  reads what one of them posted as an `Outcome`: `Ran` with the server's
  id, `NothingRan` only when the response itself says nothing posted,
  `StoppedPartway` with `done` null when that can't be told.
