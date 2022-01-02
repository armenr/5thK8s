# Dependencies

## Rationale

Most everything in this directory is managed/handled & defined by a tool called `vendir`.

Vendir allows us to version, track, and maintain inflated repositories & external dependencies in a safe & sane way. We then vend those dependencies & assets from this directory.

In general, production-level deployments should not blindly rely on pulling, building, and deploying remote manifests and charts directly from git or elsewhere.

...what happens to your deploments and infrastructure if:

- Github goes down?
- Github becomes unreachable from your cluster/vpc?
- Someone mistakenly (or intentionally) sneaks a bad (or malicious) commit into an artefact you're pulling directly from git?
- The location/path/address of a dependent artefact changes out from under you, without warning?

## How-to

Instructions go here. For now, just know this: `cd dependencies && vendir sync`
