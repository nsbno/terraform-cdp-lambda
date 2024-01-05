# terraform-cdp-lambda

A terraform module for allocating resources for and deploying AWS Lambda functions.
The module builds a zip for the lambda deployment using the archive provider.

Things the module currently does not do (often suprisingly hard without null resources or similar "hacks"):
- Automatically deploy layers is not supported at this time 
- Deploy arbitrary set of source files (though it _does_ support including an optional `upsert.sql`)
