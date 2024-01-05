# terraform-cdp-lambda

A terraform module for allocating resources for and deploying AWS Lambda functions.
The module builds a zip for the lambda deployment using the archive provider.

The module currently does not (often surprisingly hard without null resources or similar "hacks"):
- Deploy layers automatically.
- Deploy an arbitrary set of source files (though it does support including an optional `upsert.sql`).
