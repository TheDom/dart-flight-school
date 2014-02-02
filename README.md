dart-flight-school
==================

This is a small Dart demo application, created at [Dart Flight School in Vienna](https://plus.google.com/events/chsfbc3o56e5jfd1aho4kjjsd70) on Feb 1st, 2014.

My intention was to explore how to use Dart on the server-side. To do this I created a simple RESTful web service that handles requests to `/:resource/:id` and fetches / persists data from a local Redis server. This turned out to be really easy since Dart comes with "batteries included."

Disclaimer: This application is very basic and was just created for learning purposes.

To run the service, install the dependencies via `pub install` and then start it with `dart bin/dartra.dart`. Afterwards requests can be issued to `http://127.0.0.1:4040`.