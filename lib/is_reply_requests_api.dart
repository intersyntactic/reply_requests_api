/// What a module implements to post a reply: `WritesSlackReplyRequests` or
/// `WritesWebAddressReplyRequests`, one for each kind of `ReplyEndpoint`.
///
/// A writer is pure. The airlock decides on the reply, has the module's
/// writer turn it into web requests, checks each against the endpoint,
/// sets the sign-in it granted, sends them through the ordinary web
/// driver, and asks the writer what each response says was posted.
library;

export 'src/reply_requests.dart';
