# is_reply_requests_api

What a module implements so the airlock can post a reply for it, without
the web driver knowing anything of Slack or Teams.

- `WritesSlackReplyRequests`, for a `RepliesInSlackConversation`, and
  `WritesWebAddressReplyRequests`, for a `RepliesUnderWebAddress` (as
  Teams' Bot Connector takes replies). One interface per endpoint case, so
  an endpoint and the id read back for it always match.
- `draw(to, trajectory, content)` returns the `ProposedRequest`s that post
  a `ReplyContent`, in the order they are to be sent. How the text is
  split into messages is the writer's. Each request carries no sign-in,
  and must go to an address the endpoint `admitsAddress`.
- `posted(response)` reads what one request posted, as an `Outcome`:
  - `Ran(id)`: the server named the message it posted.
  - `NothingRan(why)`: the response itself says nothing posted, such as
    Slack's `"ok": false` (its error is the `why`) or a refusing 4xx.
  - `StoppedPartway(why, done: null)`: it can't be told, such as a 5xx or
    a body that won't parse; the message may have posted.

A writer is pure: it holds no secret and sends nothing. The airlock draws
with the endpoint and trajectory it granted, refuses the whole reply before
sending anything if a request falls outside the endpoint, sets the sign-in
it granted, sends each through `CarriesOutWebRequests`, and stops at the
first piece that isn't `Ran`. It builds each `PostedMessage` itself with
`.answering(endpoint, id)`, so the conversation the logbook records comes
from the grant, never from the writer.

It depends on `is_effects` (`ProposedRequest`, `WebResponse`, `Outcome`),
`is_reply_vocabulary` and `is_shapes` (`TrajectoryId`), and re-exports
none of them: import each one you use.
