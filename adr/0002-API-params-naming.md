# 2. Name API parameters to match DPS APIs
Date: 2020-02-06

## Status

Accepted

## Context

The naming of the params used in the APIs needs be consistent.

For example:
nomis_offender_id, prison_number and nomis_prison_number refer to the same data.

## Decision
Use param names similar to those used on [DPS APIs](https://gateway.prod.nomis-api.service.hmpps.dsd.io/elite2api/swagger-ui.html#//offenders/getAddressesByOffenderNoUsingGET)

Use snake_case in place of camelCase.
Consider to prefix the param with `nomis_` to clarify the source.

For example:
`offenderNo` -> `nomis_offender_no`


## Consequences
We will be able achieve consistency on naming API params.
