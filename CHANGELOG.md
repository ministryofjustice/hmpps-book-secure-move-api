# Changelog

## [v1.10.2](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.10.2) (2020-05-20)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.10.1...v1.10.2)

**Merged pull requests:**

- Remove rubocop-rspec from lock file as it's been removed from our gems [\#473](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/473) ([cwrw](https://github.com/cwrw))
- P4-1560 Add allocation filter to moves endpoint [\#472](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/472) ([cwrw](https://github.com/cwrw))
- P4-1474 Add support for optional `requested\_by` attribute in allocation model [\#468](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/468) ([smoothcontract](https://github.com/smoothcontract))
- Fix output for set\_profile\_from\_person rake [\#467](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/467) ([alexdesi](https://github.com/alexdesi))
- Clearer last\_name sorting test [\#466](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/466) ([martyn-w](https://github.com/martyn-w))
- Modernise rubocop [\#465](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/465) ([willfish](https://github.com/willfish))
- Clean up rake tasks reference\_data [\#463](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/463) ([alexdesi](https://github.com/alexdesi))
- \[P4-1450\] Migrate a moves reference from a Person to a Profile [\#462](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/462) ([willfish](https://github.com/willfish))
- Update CHANGELOG.md [\#461](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/461) ([martyn-w](https://github.com/martyn-w))
- P4-1384 GET /reference/regions API endpoint [\#460](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/460) ([smoothcontract](https://github.com/smoothcontract))

## [v1.10.1](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.10.1) (2020-05-15)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.10.0...v1.10.1)

**Merged pull requests:**

- P4-1441 Cancel allocations [\#459](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/459) ([cwrw](https://github.com/cwrw))
- P4-1530 Allow person to be updated on a move [\#458](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/458) ([cwrw](https://github.com/cwrw))
- P4-1525 Improve validation of `moves\_count` when creating an allocation [\#457](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/457) ([smoothcontract](https://github.com/smoothcontract))
- P4-1468 bonus move filters [\#456](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/456) ([martyn-w](https://github.com/martyn-w))
- P4-1428 Replicate review app database from main heroku API app [\#455](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/455) ([smoothcontract](https://github.com/smoothcontract))
- V1.10.0 Update CHANGELOG.md [\#454](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/454) ([cwrw](https://github.com/cwrw))
- Add slack notifications to CI workflow [\#453](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/453) ([teneightfive](https://github.com/teneightfive))

## [v1.10.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.10.0) (2020-05-13)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.9.0...v1.10.0)

**Merged pull requests:**

- Revert "Add profile relationship to Move \(\#432\)" [\#452](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/452) ([alexdesi](https://github.com/alexdesi))
- P4-1469 new cancellation reason [\#451](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/451) ([martyn-w](https://github.com/martyn-w))
- Fixes patching empty documents on move [\#450](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/450) ([willfish](https://github.com/willfish))
- P4-1398 Surface associated moves in allocations [\#447](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/447) ([cwrw](https://github.com/cwrw))
- Simplify/Speed up serializer specs [\#446](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/446) ([alexdesi](https://github.com/alexdesi))
- P4-1428 Allow disabling API authentication for local dev and heroku review apps [\#445](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/445) ([smoothcontract](https://github.com/smoothcontract))
- \[P4-1185\] Updates default fallback question for building personal care need [\#444](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/444) ([willfish](https://github.com/willfish))
- Log Nomis court hearing saving result [\#443](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/443) ([willfish](https://github.com/willfish))
- Fail fast and fix flakey test [\#442](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/442) ([cwrw](https://github.com/cwrw))
- P4-1180 journey create, update, index and show endpoints [\#441](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/441) ([martyn-w](https://github.com/martyn-w))
- Bump doorkeeper from 5.1.0 to 5.1.1 [\#440](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/440) ([dependabot[bot]](https://github.com/apps/dependabot))
- Handle missing attributes when patching a moves documents [\#439](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/439) ([willfish](https://github.com/willfish))
- P4-1466 Surface an allocation associated to a move [\#438](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/438) ([cwrw](https://github.com/cwrw))
- Add recent rake tasks for reference data to README [\#437](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/437) ([smoothcontract](https://github.com/smoothcontract))
- Fix flaky specs [\#436](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/436) ([smoothcontract](https://github.com/smoothcontract))
- \[P4-1185\] adds special vehicle to personal care needs [\#435](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/435) ([willfish](https://github.com/willfish))
- P4-1462 Hard code default sort order for GET /allocations endpoint [\#434](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/434) ([smoothcontract](https://github.com/smoothcontract))
- Hugely speed up linting [\#433](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/433) ([willfish](https://github.com/willfish))
- Add profile relationship to Move [\#432](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/432) ([alexdesi](https://github.com/alexdesi))

## [v1.9.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.9.0) (2020-05-06)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.8.5...v1.9.0)

**Merged pull requests:**

- P4-1273 Add importer class to populate regions reference data [\#431](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/431) ([smoothcontract](https://github.com/smoothcontract))
- \[P4-1433\] Removes unused supplier serializer code [\#430](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/430) ([willfish](https://github.com/willfish))
- Small improvement for Moves::ImportPeople. More need to be done! [\#429](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/429) ([alexdesi](https://github.com/alexdesi))
- Data migration to update profile ID with the correct profile. [\#427](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/427) ([alexdesi](https://github.com/alexdesi))
- P4-1376 Create moves when creating an allocation [\#426](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/426) ([cwrw](https://github.com/cwrw))
- Fix flaky spec [\#425](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/425) ([willfish](https://github.com/willfish))
- \[P4-1444\] Handle unparseable errors from Azure API Gateway [\#424](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/424) ([willfish](https://github.com/willfish))
- P4 1357 patch people notifications [\#423](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/423) ([martyn-w](https://github.com/martyn-w))
- A move can have many court hearings [\#422](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/422) ([willfish](https://github.com/willfish))
- P4-1275 Added support for filtering by location on GET /allocations endpoint [\#421](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/421) ([smoothcontract](https://github.com/smoothcontract))
- \[P4-1413\] Change plural form of timetable [\#420](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/420) ([willfish](https://github.com/willfish))
- Update CHANGELOG.md [\#419](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/419) ([martyn-w](https://github.com/martyn-w))
- P4-1392 Patch a moves document relationships [\#417](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/417) ([willfish](https://github.com/willfish))
- Catch 500 error when latest\_nomis\_booking\_id is missing [\#413](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/413) ([alexdesi](https://github.com/alexdesi))
- CourtHearings Post service: change error level + clean up [\#407](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/407) ([alexdesi](https://github.com/alexdesi))

## [v1.8.5](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.8.5) (2020-05-01)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.8.4...v1.8.5)

**Merged pull requests:**

- \[P4-1422\] Change to defaulting to creating a court hearing in Nomis [\#418](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/418) ([willfish](https://github.com/willfish))

## [v1.8.4](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.8.4) (2020-05-01)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.8.3...v1.8.4)

**Merged pull requests:**

- Update supplier\_locations.yml [\#416](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/416) ([martyn-w](https://github.com/martyn-w))
- \[P4-1436\] Fix timestamp coercion in court hearings POST [\#415](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/415) ([willfish](https://github.com/willfish))
- P4-1385 Allow move creation and serialisation without a person [\#414](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/414) ([cwrw](https://github.com/cwrw))
- P4 1355 temporary redirect endpoint [\#412](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/412) ([martyn-w](https://github.com/martyn-w))
- P4-1428 Fix Heroku Review apps [\#411](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/411) ([smoothcontract](https://github.com/smoothcontract))
- \[P4-1422\] Adds ability to control creation of a court hearing in Nomis [\#410](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/410) ([willfish](https://github.com/willfish))
- \[P4-1413\] Adds swagger documentation for new timetable api [\#408](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/408) ([willfish](https://github.com/willfish))

## [v1.8.3](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.8.3) (2020-04-29)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.8.2...v1.8.3)

**Closed issues:**

- Intermittent failures [\#375](https://github.com/ministryofjustice/hmpps-book-secure-move-api/issues/375)

**Merged pull requests:**

- P4-1284 create allocation [\#409](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/409) ([smoothcontract](https://github.com/smoothcontract))
- P4 1402 update suppliers locations [\#406](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/406) ([alexdesi](https://github.com/alexdesi))
- Fix timetable after integration highlighted bug [\#405](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/405) ([willfish](https://github.com/willfish))
- P4 1365 basic auth on webhooks [\#404](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/404) ([martyn-w](https://github.com/martyn-w))
- P4 1305 journey api additions swagger [\#403](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/403) ([martyn-w](https://github.com/martyn-w))
- P4-1286 get allocation [\#401](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/401) ([smoothcontract](https://github.com/smoothcontract))
- Bumps test gems [\#400](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/400) ([willfish](https://github.com/willfish))
- \[P4-1095\] Timetable feature [\#398](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/398) ([willfish](https://github.com/willfish))
- Convert swagger definition files to yaml [\#397](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/397) ([willfish](https://github.com/willfish))

## [v1.8.2](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.8.2) (2020-04-24)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.8.1...v1.8.2)

**Merged pull requests:**

- Update supplier location: [\#399](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/399) ([alexdesi](https://github.com/alexdesi))
- Nomis Error handling [\#396](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/396) ([alexdesi](https://github.com/alexdesi))
- updating changelog to 1.8.1 [\#395](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/395) ([martyn-w](https://github.com/martyn-w))
- P4-1274 Add new endpoint to GET /allocations [\#384](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/384) ([smoothcontract](https://github.com/smoothcontract))

## [v1.8.1](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.8.1) (2020-04-22)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.8.0...v1.8.1)

**Merged pull requests:**

- Fixes Rakefile for production environment [\#393](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/393) ([willfish](https://github.com/willfish))
- P4-1345 Remove last unneeded file [\#392](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/392) ([smoothcontract](https://github.com/smoothcontract))
- CHANGELOG.md [\#391](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/391) ([willfish](https://github.com/willfish))
- P4 1304 move api additions swagger [\#390](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/390) ([martyn-w](https://github.com/martyn-w))
- P4-1283 Add new reference endpoint for allocation complex cases [\#389](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/389) ([smoothcontract](https://github.com/smoothcontract))
- \[P4-1264\] Court case filters [\#388](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/388) ([willfish](https://github.com/willfish))
- Fix case\_type enums [\#387](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/387) ([willfish](https://github.com/willfish))
- P4-1435 Remove lots of duplicated swagger definitions and refactor specs [\#386](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/386) ([smoothcontract](https://github.com/smoothcontract))

## [v1.8.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.8.0) (2020-04-17)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.7.0...v1.8.0)

**Merged pull requests:**

- Fix nomis integration [\#383](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/383) ([willfish](https://github.com/willfish))
- Removes unused env var [\#382](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/382) ([willfish](https://github.com/willfish))
- Add sentry log if move is missing [\#381](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/381) ([alexdesi](https://github.com/alexdesi))
- Update swagger doc to explain need for move to create a nomis hearing [\#380](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/380) ([willfish](https://github.com/willfish))
- Reinstates pending court\_hearings\_spec examples [\#379](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/379) ([willfish](https://github.com/willfish))
- Add log for court hearing in case of success [\#378](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/378) ([alexdesi](https://github.com/alexdesi))
- Update supplier locations [\#377](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/377) ([alexdesi](https://github.com/alexdesi))
- CourtHearing client specs are breaking mocks to Nomis [\#376](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/376) ([willfish](https://github.com/willfish))
- Speed up circle ci builds by using cached deps [\#374](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/374) ([willfish](https://github.com/willfish))
- Fix sentry for create court hearing [\#373](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/373) ([alexdesi](https://github.com/alexdesi))
- Fixes migration after change to db column [\#372](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/372) ([willfish](https://github.com/willfish))
- P4 1148 journey event models [\#371](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/371) ([martyn-w](https://github.com/martyn-w))
- P4-1274 Added data model to support allocations [\#369](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/369) ([smoothcontract](https://github.com/smoothcontract))
- Controversially change the PR template [\#362](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/362) ([willfish](https://github.com/willfish))

## [v1.7.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.7.0) (2020-04-15)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.6.2...v1.7.0)

**Merged pull requests:**

- Save the CourtHearing.post response and Fix the time format [\#370](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/370) ([alexdesi](https://github.com/alexdesi))
- P4-1316 fix court hearing swagger [\#368](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/368) ([willfish](https://github.com/willfish))
- Call the service to create court hearings in Nomis [\#367](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/367) ([alexdesi](https://github.com/alexdesi))
- Add service CreateHearingInNomis [\#366](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/366) ([alexdesi](https://github.com/alexdesi))
- \[P4-1165\] Extrapolate court hearing controller from move controller [\#365](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/365) ([willfish](https://github.com/willfish))
- Fix ID parameter in person/images endpoint [\#364](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/364) ([teneightfive](https://github.com/teneightfive))
- court\_type -\> case\_type [\#363](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/363) ([willfish](https://github.com/willfish))

## [v1.6.2](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.6.2) (2020-04-09)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.6.1...v1.6.2)

**Merged pull requests:**

- \[P4-1165\] Create and show a court hearing when managing moves [\#360](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/360) ([willfish](https://github.com/willfish))
- id -\> person\_id [\#358](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/358) ([willfish](https://github.com/willfish))

## [v1.6.1](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.6.1) (2020-04-09)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.6.0...v1.6.1)

**Merged pull requests:**

- P4-1263 Updated unique date validation to exclude proposed moves [\#361](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/361) ([smoothcontract](https://github.com/smoothcontract))
- P4-1263 Minor tweak for move date attribute API spec [\#359](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/359) ([smoothcontract](https://github.com/smoothcontract))
- Fixes broken swagger documentation generation [\#357](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/357) ([willfish](https://github.com/willfish))
- P4-1263 Update date validation rules around proposed moves [\#356](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/356) ([smoothcontract](https://github.com/smoothcontract))
- P4-1213 Use StringIO rather than temp file to serialize image blob [\#355](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/355) ([smoothcontract](https://github.com/smoothcontract))
- Get court cases from Nomis [\#354](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/354) ([alexdesi](https://github.com/alexdesi))
- P4-1027 Non-unique move return error rather than crashing [\#326](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/326) ([starswan](https://github.com/starswan))

## [v1.6.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.6.0) (2020-03-30)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.5.3...v1.6.0)

**Merged pull requests:**

- P4-1225 Add new rake task and gem to generate ERD [\#353](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/353) ([smoothcontract](https://github.com/smoothcontract))
- P4-1189 Refactor circleci build to introduce explicit job for API docs [\#352](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/352) ([smoothcontract](https://github.com/smoothcontract))
- P4-1216 rename prison transfer reasons [\#351](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/351) ([martyn-w](https://github.com/martyn-w))

## [v1.5.3](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.5.3) (2020-03-27)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.5.2...v1.5.3)

**Merged pull requests:**

- P4-1200 fix old migration to be reversible [\#350](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/350) ([starswan](https://github.com/starswan))

## [v1.5.2](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.5.2) (2020-03-26)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.5.1...v1.5.2)

**Merged pull requests:**

- Add missing 'dev' environment to list in docs [\#348](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/348) ([starswan](https://github.com/starswan))
- P4-1188-tweaks [\#347](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/347) ([martyn-w](https://github.com/martyn-w))
- Fix for empty latest\_nomis\_booking\_id when retrieving image from nomis [\#346](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/346) ([alexdesi](https://github.com/alexdesi))
- Add move\_date to email personalisation [\#345](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/345) ([martyn-w](https://github.com/martyn-w))
- Add GOVUK\_NOTIFY\_ENABLED flag [\#344](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/344) ([martyn-w](https://github.com/martyn-w))
- support new 'dev' environment [\#341](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/341) ([starswan](https://github.com/starswan))
- Revert "use vendor/bundle for bundler" [\#339](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/339) ([starswan](https://github.com/starswan))
- p4-1188 emails for prison recall moves [\#338](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/338) ([starswan](https://github.com/starswan))
- P4-1147 remove NOMIS sync from moves\#index [\#330](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/330) ([starswan](https://github.com/starswan))

## [v1.5.1](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.5.1) (2020-03-19)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.5.0...v1.5.1)

**Merged pull requests:**

- Add link Pentonville \(PVI\) -\> Serco supplier [\#337](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/337) ([alexdesi](https://github.com/alexdesi))
- P4 1047 1122 email notifications [\#328](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/328) ([martyn-w](https://github.com/martyn-w))

## [v1.5.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.5.0) (2020-03-18)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.4.0...v1.5.0)

**Merged pull requests:**

- Improve tasks recreate\_all fake data. [\#334](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/334) ([alexdesi](https://github.com/alexdesi))
- P4-1159 cancel NOMIS synched moves from prisons [\#333](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/333) ([starswan](https://github.com/starswan))
- Save picture in S3 and return S3 URL [\#332](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/332) ([alexdesi](https://github.com/alexdesi))
- P4 1090 send azure events [\#329](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/329) ([starswan](https://github.com/starswan))

## [v1.4.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.4.0) (2020-03-12)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.3.1...v1.4.0)

**Merged pull requests:**

- Revert "P4 982 azure app insights redux \(\#324\)" [\#331](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/331) ([starswan](https://github.com/starswan))
- P4-1142 created\_at\_to search needs to be inclusive [\#327](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/327) ([starswan](https://github.com/starswan))
- add variable 'date' field in move factory [\#325](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/325) ([starswan](https://github.com/starswan))
- P4 982 azure app insights redux [\#324](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/324) ([starswan](https://github.com/starswan))
- P4-1123 adding sort\_by to moves\#index [\#319](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/319) ([starswan](https://github.com/starswan))
- Allow to update nomis\_alert\_type, nomis\_alert\_type\_description, nomis… [\#318](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/318) ([alexdesi](https://github.com/alexdesi))
- P4 1104 add date\_from and date\_to to move entity [\#309](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/309) ([starswan](https://github.com/starswan))
- port specs to doorkeeper test auth [\#298](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/298) ([starswan](https://github.com/starswan))

## [v1.3.1](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.3.1) (2020-03-05)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.3.0...v1.3.1)

**Merged pull requests:**

- Revert "P4 982 azure app insights \(\#292\)" [\#323](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/323) ([starswan](https://github.com/starswan))

## [v1.3.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.3.0) (2020-03-05)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.2.0...v1.3.0)

**Closed issues:**

- Application sometimes hangs when generating client auth token [\#115](https://github.com/ministryofjustice/hmpps-book-secure-move-api/issues/115)

**Merged pull requests:**

- Specify localhost in database.yml [\#321](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/321) ([alexdesi](https://github.com/alexdesi))
- Update filter for people with prison\_number [\#320](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/320) ([alexdesi](https://github.com/alexdesi))
- Rename filter nomis\_offender\_id to prison\_number [\#317](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/317) ([alexdesi](https://github.com/alexdesi))
- upgrade to Puma \(security alert\) after version 3.12.3 vanished [\#316](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/316) ([starswan](https://github.com/starswan))
- add faker data to locations and profiles [\#315](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/315) ([starswan](https://github.com/starswan))
- P4-982 it seems we needed enabled = true for each piece of the config… [\#314](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/314) ([starswan](https://github.com/starswan))
- P4-982 fix dockerfile issue [\#313](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/313) ([starswan](https://github.com/starswan))
- P4-1117 remove superfluous index as it causes crashes [\#312](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/312) ([starswan](https://github.com/starswan))
- p4-1114 add disabled\_at to prison\_transfer\_reasons entity [\#310](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/310) ([starswan](https://github.com/starswan))
- Bump puma from 3.12.2 to 3.12.3 [\#308](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/308) ([dependabot[bot]](https://github.com/apps/dependabot))
- p4-1099 missing ethnicity bad JSON response [\#307](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/307) ([starswan](https://github.com/starswan))
- Bump nokogiri from 1.10.7 to 1.10.8 [\#306](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/306) ([dependabot[bot]](https://github.com/apps/dependabot))
- Fixes for the nomis-alert mapping [\#305](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/305) ([alexdesi](https://github.com/alexdesi))
- P4 1094 add image url to person [\#304](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/304) ([starswan](https://github.com/starswan))
- P4 1079 new assessment question for nfr [\#302](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/302) ([alexdesi](https://github.com/alexdesi))
- Add support for move\_agreed and move\_agreed\_by in the apis [\#301](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/301) ([alexdesi](https://github.com/alexdesi))
- P4-1091 added created\_at to move with filters [\#300](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/300) ([starswan](https://github.com/starswan))
- P4-1069 add proposed status to move [\#299](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/299) ([starswan](https://github.com/starswan))
- Removed validation for move\_agreed and move\_agreed\_by [\#297](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/297) ([alexdesi](https://github.com/alexdesi))
- add default to move\_agreed so that old data is still valid [\#296](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/296) ([starswan](https://github.com/starswan))
- Update get\_move\_responses.json [\#295](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/295) ([martyn-w](https://github.com/martyn-w))
- better handling of failed webhook status [\#293](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/293) ([martyn-w](https://github.com/martyn-w))
- P4 982 azure app insights [\#292](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/292) ([starswan](https://github.com/starswan))
- Small documentation tweaks for webhooks [\#291](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/291) ([martyn-w](https://github.com/martyn-w))
- Add field move\_agreed and move\_agreed\_by with relevant validations. [\#290](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/290) ([alexdesi](https://github.com/alexdesi))
- P4-885 step 2 = add task to back-fill profile data [\#289](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/289) ([starswan](https://github.com/starswan))
- P4 1070 new attributes on move [\#288](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/288) ([ngw](https://github.com/ngw))
- move SCH9 from serco to GeoAmey due to error [\#287](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/287) ([starswan](https://github.com/starswan))
- P4 999 static docs [\#286](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/286) ([starswan](https://github.com/starswan))
- Revert "actual functionality for P4-885" [\#285](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/285) ([starswan](https://github.com/starswan))
- Revert p4 999 docs [\#282](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/282) ([starswan](https://github.com/starswan))
- converted metrics to only run if env var is actively set [\#281](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/281) ([starswan](https://github.com/starswan))
- P4 1038 webhooks documentation [\#279](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/279) ([martyn-w](https://github.com/martyn-w))
- Run asset pipeline in dockerfile [\#278](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/278) ([starswan](https://github.com/starswan))
- P4-1059 update move now doesn't allow all fields to be updated [\#277](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/277) ([starswan](https://github.com/starswan))
- added new improved coverage numbers [\#276](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/276) ([starswan](https://github.com/starswan))
- Use CircleCI to deploy to sidekiq pods [\#275](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/275) ([martyn-w](https://github.com/martyn-w))
- put back rake rswag:specs:swaggerize task [\#274](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/274) ([starswan](https://github.com/starswan))
- Add PR template [\#273](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/273) ([spikeheap](https://github.com/spikeheap))
- Create sidekiq.yml [\#272](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/272) ([martyn-w](https://github.com/martyn-w))
- Only notify slack on CircleCI failures [\#271](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/271) ([teneightfive](https://github.com/teneightfive))
- link SCH/STCs to suppliers [\#270](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/270) ([starswan](https://github.com/starswan))
- P4 983 documentation anomalies [\#269](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/269) ([starswan](https://github.com/starswan))
- Upgrade bundler 2.0.2 --\> 2.1.4 [\#268](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/268) ([martyn-w](https://github.com/martyn-w))
- P4 1030 add nomis offender no to api docs [\#267](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/267) ([martyn-w](https://github.com/martyn-w))
- Only run production build/deploy jobs on Git tags [\#265](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/265) ([teneightfive](https://github.com/teneightfive))
- fix up schema.rb on master as local changes slipped through by mistake [\#264](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/264) ([starswan](https://github.com/starswan))
- P4-946 added Rswag test for delete document from move [\#263](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/263) ([starswan](https://github.com/starswan))
- P4 950 async notification job [\#262](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/262) ([ngw](https://github.com/ngw))
- Revert "P4 950 async notification job" [\#261](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/261) ([ngw](https://github.com/ngw))
- git merge managed to break the linter [\#260](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/260) ([starswan](https://github.com/starswan))
- P4-939 associate existing documents with newly created move [\#259](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/259) ([starswan](https://github.com/starswan))
- Add support for nomis offender id to v1 people endpoint [\#258](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/258) ([alexdesi](https://github.com/alexdesi))
- P4-1026 fixed bug to re-enable PNC filter [\#257](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/257) ([starswan](https://github.com/starswan))
- P4-1025 fixed problem with move JSON containing 'profile' rather than… [\#256](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/256) ([starswan](https://github.com/starswan))
- P4 1021 import stc sch yoi [\#255](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/255) ([starswan](https://github.com/starswan))
- P4-940 added can\_upload\_documents to Location model and exposed via API [\#254](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/254) ([starswan](https://github.com/starswan))
- Adding portsmouth to geoamey [\#253](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/253) ([ngw](https://github.com/ngw))
- P4 950 async notification job [\#252](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/252) ([ngw](https://github.com/ngw))
- P4-999 placeholder documentation pages [\#251](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/251) ([starswan](https://github.com/starswan))
- use standard doorkeeper mechanism for move controller create spec [\#250](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/250) ([starswan](https://github.com/starswan))
- Add support for nomis\_offender\_no to the /api/v1/people - Part1 [\#246](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/246) ([alexdesi](https://github.com/alexdesi))
- P4-936 converted delete documents endpoint to a soft-delete [\#245](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/245) ([starswan](https://github.com/starswan))
- POST /documents to upload a document without a move [\#243](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/243) ([ngw](https://github.com/ngw))
- add comment about coverage percentage [\#241](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/241) ([starswan](https://github.com/starswan))
- Add ADR to keep track of the Architech Decisions [\#240](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/240) ([alexdesi](https://github.com/alexdesi))
- remove duplicated profile save during move imports [\#239](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/239) ([starswan](https://github.com/starswan))
- remove webmock \(for now\) as it doesn't work in this project [\#238](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/238) ([starswan](https://github.com/starswan))
- P4-822 Papertrail for auditing writes [\#237](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/237) ([starswan](https://github.com/starswan))
- add swagger.yaml to .gitignore [\#235](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/235) ([starswan](https://github.com/starswan))
- P4 951 webhook models [\#234](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/234) ([martyn-w](https://github.com/martyn-w))
- Remove swagger yaml [\#233](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/233) ([starswan](https://github.com/starswan))
- /%s/rails/rake/g in Create reference data section [\#232](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/232) ([ngw](https://github.com/ngw))
- Revert swagger yaml [\#231](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/231) ([starswan](https://github.com/starswan))
- P4 922 sync completed moves [\#230](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/230) ([starswan](https://github.com/starswan))
- put back swagger.yaml generation into dockerfile [\#229](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/229) ([starswan](https://github.com/starswan))
- added special vehicle assessment question [\#228](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/228) ([ngw](https://github.com/ngw))
- Re-add schema definitions to swagger\_helper [\#227](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/227) ([spikeheap](https://github.com/spikeheap))
- P4-929 re-add suppliers [\#226](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/226) ([spikeheap](https://github.com/spikeheap))
- P4 915 multiple status values [\#225](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/225) ([starswan](https://github.com/starswan))
- remove swagger.yaml from source control [\#224](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/224) ([starswan](https://github.com/starswan))
- P4-918 Remove BDS1 Luton Custody Suite and BDS2 Kempston Custody Suit… [\#223](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/223) ([electrified](https://github.com/electrified))
- P4 885 part 2 data fixup [\#221](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/221) ([starswan](https://github.com/starswan))
- P4 885 part 1 migration [\#220](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/220) ([starswan](https://github.com/starswan))
- p4-885 part 0 - allow fake data in test environment [\#219](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/219) ([starswan](https://github.com/starswan))
- P4-870 add locations mk2 [\#218](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/218) ([spikeheap](https://github.com/spikeheap))
- P4-870 Add locations to suppliers in reference rake task [\#217](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/217) ([spikeheap](https://github.com/spikeheap))
- Anonymisers have been removed [\#216](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/216) ([ngw](https://github.com/ngw))
- Revert "P4-860 Revert GEOAmey locations introduced in https://github.… [\#214](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/214) ([ngw](https://github.com/ngw))
- add index on people\#nomis\_prison\_number [\#213](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/213) ([starswan](https://github.com/starswan))
- add logging of move count from NOMIS API [\#212](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/212) ([starswan](https://github.com/starswan))
- use correct status names for move filtering [\#211](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/211) ([starswan](https://github.com/starswan))
- Remove action\_mailer default\_host [\#210](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/210) ([ngw](https://github.com/ngw))
- P4-878 set hostname from ENV var [\#209](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/209) ([spikeheap](https://github.com/spikeheap))
- GDS Trailing comma styles for Rubocop [\#208](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/208) ([starswan](https://github.com/starswan))
- More gds style [\#207](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/207) ([starswan](https://github.com/starswan))
- added environment files for staging and preprod [\#204](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/204) ([starswan](https://github.com/starswan))
- implement GDS rubocop standards  [\#203](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/203) ([starswan](https://github.com/starswan))
- p4-881 prefactor - re-factor tests [\#202](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/202) ([starswan](https://github.com/starswan))
- P4 881 log nomis api calls [\#201](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/201) ([starswan](https://github.com/starswan))
- Moves can be filtered by supplier [\#200](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/200) ([ngw](https://github.com/ngw))
- Supplier/Location rake task replaces locations for each supplier [\#199](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/199) ([spikeheap](https://github.com/spikeheap))
- P4-879, P4-882 update supplier allocations [\#198](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/198) ([spikeheap](https://github.com/spikeheap))
- P4 876 synch wrong personal care record [\#197](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/197) ([starswan](https://github.com/starswan))
- Coverage [\#196](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/196) ([starswan](https://github.com/starswan))
- P4-873 adds remaining 28 custody suites for GEOAmey [\#195](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/195) ([spikeheap](https://github.com/spikeheap))
- git ignores for ruby mine [\#194](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/194) ([starswan](https://github.com/starswan))
- added basic test coverage support [\#193](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/193) ([starswan](https://github.com/starswan))
- P4-875 - crashes when \>10 offenders, and when no personal care records [\#192](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/192) ([starswan](https://github.com/starswan))
- P4 869 additional suppliers [\#191](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/191) ([spikeheap](https://github.com/spikeheap))
- Revert GEOAmey locations introduced in  [\#190](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/190) ([spikeheap](https://github.com/spikeheap))
- Basic RBAC implementation [\#189](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/189) ([ngw](https://github.com/ngw))
- Integrate Swagger into move tests [\#188](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/188) ([spikeheap](https://github.com/spikeheap))
- Update police custodies for January rollout [\#187](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/187) ([spikeheap](https://github.com/spikeheap))
- Use url\_for across all environments to retrieve service URL. [\#186](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/186) ([spikeheap](https://github.com/spikeheap))
- Change db table declaration to be nice with UUIDS [\#185](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/185) ([ngw](https://github.com/ngw))
- S3 works locally [\#184](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/184) ([ngw](https://github.com/ngw))
- ActiveStorage need S3 gem [\#182](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/182) ([ngw](https://github.com/ngw))
- S3 configuration and filesize [\#181](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/181) ([ngw](https://github.com/ngw))
- Add supplier/location mappings to rake task for December 2019 rollout [\#179](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/179) ([spikeheap](https://github.com/spikeheap))
- Retries on timeout and connection failed [\#178](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/178) ([ngw](https://github.com/ngw))
- Vulnerable dependency updates [\#177](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/177) ([spikeheap](https://github.com/spikeheap))
- Add Serco locations for Weds 4th December [\#176](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/176) ([spikeheap](https://github.com/spikeheap))
- Swagger ui fixes [\#175](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/175) ([spikeheap](https://github.com/spikeheap))
- Hotfix limit multipart to document creation [\#174](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/174) ([ngw](https://github.com/ngw))
- Supplier relationship rake output [\#172](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/172) ([spikeheap](https://github.com/spikeheap))
- Add GeoAmey locations for rollout on Monday [\#171](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/171) ([spikeheap](https://github.com/spikeheap))
- P4 807 support ability to delete documents via api [\#170](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/170) ([ngw](https://github.com/ngw))
- Removes the Serco -\> Brixton association [\#169](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/169) ([spikeheap](https://github.com/spikeheap))
- Add Bishopsgate police custody to Serco supplier reference data [\#168](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/168) ([spikeheap](https://github.com/spikeheap))
- Add POLICE agency type to NOMIS location import [\#167](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/167) ([spikeheap](https://github.com/spikeheap))
- Batching calls to /persona-care-needs [\#166](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/166) ([ngw](https://github.com/ngw))
- P4 703 support ability to upload documents via api [\#165](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/165) ([ngw](https://github.com/ngw))
- Add preprod to circleci [\#164](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/164) ([spikeheap](https://github.com/spikeheap))
- Batching calls for /alerts/ [\#163](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/163) ([ngw](https://github.com/ngw))
- Do not log AR in production + filter sensitive data [\#162](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/162) ([ngw](https://github.com/ngw))
- Hotfix cleanup script [\#161](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/161) ([ngw](https://github.com/ngw))
- Enable Swagger UI to run against prod, staging and localhost [\#159](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/159) ([spikeheap](https://github.com/spikeheap))
- Add CORS for Swagger UI [\#158](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/158) ([spikeheap](https://github.com/spikeheap))
- Fixes rbenv installation by removing 'ruby-' prefix from version spec [\#157](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/157) ([spikeheap](https://github.com/spikeheap))
- Hotfix duplicate moves [\#156](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/156) ([ngw](https://github.com/ngw))
- Fixing mass moves cancellation [\#155](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/155) ([ngw](https://github.com/ngw))
- Batching calls for /prisoners/ [\#154](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/154) ([ngw](https://github.com/ngw))
- P4 765 updated sync logic for nomis [\#153](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/153) ([ngw](https://github.com/ngw))
- Add keepalive connections [\#152](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/152) ([ngw](https://github.com/ngw))
- use updated GH team for CP deploy [\#151](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/151) ([spikeheap](https://github.com/spikeheap))
- Logstash formatting [\#150](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/150) ([spikeheap](https://github.com/spikeheap))
- police national computer filter [\#149](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/149) ([ngw](https://github.com/ngw))
- Add rudimentary timing for NOMIS client requests [\#148](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/148) ([spikeheap](https://github.com/spikeheap))
- task for removing duplicates + unique contraint on nomis\_event\_id [\#147](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/147) ([ngw](https://github.com/ngw))
- cancel duplicates in sweeper [\#146](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/146) ([ngw](https://github.com/ngw))
- Creating references between locations and suppliers [\#145](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/145) ([ngw](https://github.com/ngw))
- Splitting location params by , [\#144](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/144) ([ngw](https://github.com/ngw))
- Adding suppliers to locations output [\#143](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/143) ([ngw](https://github.com/ngw))
- Documentation for /reference/supplier\* [\#142](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/142) ([ngw](https://github.com/ngw))
- locations accept filter supplier\_ids [\#141](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/141) ([ngw](https://github.com/ngw))
- Add habtm locations-suppliers [\#140](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/140) ([ngw](https://github.com/ngw))
- reference/supplier has been added [\#139](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/139) ([ngw](https://github.com/ngw))
- Attempt to fix to\_location\_id and fetch multiple from\_location\_id [\#138](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/138) ([ngw](https://github.com/ngw))
- Supplier model + data seeding [\#137](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/137) ([ngw](https://github.com/ngw))
- \[P4-707\] Support for multiple location downloads [\#136](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/136) ([stevehook](https://github.com/stevehook))
- Validator for move params [\#135](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/135) ([ngw](https://github.com/ngw))
- \[P4-708\] Add a `type` parameter to the PersonalCareNeeds URL [\#134](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/134) ([stevehook](https://github.com/stevehook))
- \[P4-669\] Ensure that `Move\#status` is imported from NOMIS [\#133](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/133) ([stevehook](https://github.com/stevehook))
- \[P4-691\] Cancel duplicate moves when importing [\#132](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/132) ([stevehook](https://github.com/stevehook))
- NomisClient now anonymises data when in test\_mod [\#131](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/131) ([ngw](https://github.com/ngw))
- \[P4-680\] Import maternity status from NOMIS personal care needs API [\#130](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/130) ([stevehook](https://github.com/stevehook))
- Add missing instruction to README [\#129](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/129) ([stevehook](https://github.com/stevehook))
- Retrieves data on show + corrected fake\_data gen [\#128](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/128) ([ngw](https://github.com/ngw))
- \[P4-675\] Fallback mappings to assessment questions [\#124](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/124) ([stevehook](https://github.com/stevehook))

## [v1.2.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.2.0) (2019-09-18)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/v1.1.0...v1.2.0)

**Merged pull requests:**

- \[P4-670\] Remove redundant AssessmentQuestion attributes [\#126](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/126) ([stevehook](https://github.com/stevehook))
- Import status from NOMIS [\#125](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/125) ([cesidio](https://github.com/cesidio))
- \[P4-670\] Extra alert attributes to enable summary by NOMIS category [\#123](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/123) ([stevehook](https://github.com/stevehook))

## [v1.1.0](https://github.com/ministryofjustice/hmpps-book-secure-move-api/tree/v1.1.0) (2019-09-11)

[Full Changelog](https://github.com/ministryofjustice/hmpps-book-secure-move-api/compare/97f350a5bbbd092574efedd9e95880f927961536...v1.1.0)

**Merged pull requests:**

- \[P4-664\] Only synchronise move data from NOMIS for prisons [\#121](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/121) ([stevehook](https://github.com/stevehook))
- \[P4-606\] Ensure that title and comments are set when importing alerts [\#120](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/120) ([stevehook](https://github.com/stevehook))
- Fix assessment question description [\#119](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/119) ([teneightfive](https://github.com/teneightfive))
- Bundle update gems and rubocop [\#118](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/118) ([cesidio](https://github.com/cesidio))
- QUICKFIX: Handle nil values for ethnicity and gender [\#117](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/117) ([stevehook](https://github.com/stevehook))
- \[P4-606\] Trigger alerts import when importing a move from NOMIS [\#116](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/116) ([stevehook](https://github.com/stevehook))
- \[P4-606\] Alerts importer [\#114](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/114) ([stevehook](https://github.com/stevehook))
- \[P4-606\] NOMIS alerts 'importer' [\#113](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/113) ([stevehook](https://github.com/stevehook))
- Import moves from NOMIS on GET moves [\#112](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/112) ([cesidio](https://github.com/cesidio))
- Added cancellation reason and comment, configurable DB\_USERNAME [\#111](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/111) ([ngw](https://github.com/ngw))
- \[P4-564\] Alerts data fixtures [\#110](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/110) ([stevehook](https://github.com/stevehook))
- \[P4-606\] Alerts NOMIS client library [\#109](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/109) ([stevehook](https://github.com/stevehook))
- Add moves and people importer [\#108](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/108) ([cesidio](https://github.com/cesidio))
- Set default sort order to ID on moves [\#107](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/107) ([teneightfive](https://github.com/teneightfive))
- Change moves time\_due to be a datetime [\#106](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/106) ([cesidio](https://github.com/cesidio))
- Upgrade nokogiri following recommendation from Github [\#105](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/105) ([stevehook](https://github.com/stevehook))
- Add NomisClient People and Moves libraries [\#104](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/104) ([cesidio](https://github.com/cesidio))
- Fixes persistence of Move\#additional\_information [\#102](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/102) ([stevehook](https://github.com/stevehook))
- \[P4-561\] Bugfix for persistence of `Move\#move\_type` [\#101](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/101) ([stevehook](https://github.com/stevehook))
- \[P4-564\] NOMIS API data fixtures [\#100](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/100) ([stevehook](https://github.com/stevehook))
- \[P4-561\] Backend work to support prison recalls [\#99](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/99) ([stevehook](https://github.com/stevehook))
- Change Prometheus collection condition [\#98](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/98) ([teneightfive](https://github.com/teneightfive))
- \[P4-537\] Add `gender\_additional\_information` in person update/create endpoints [\#97](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/97) ([stevehook](https://github.com/stevehook))
- Add move collector for metrics on Prometheus [\#96](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/96) ([cesidio](https://github.com/cesidio))
- Allow filtering of location by NOMIS agency ID [\#95](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/95) ([slorek](https://github.com/slorek))
- \[P4-537\] Extended input for trans gender [\#94](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/94) ([stevehook](https://github.com/stevehook))
- \[P4-443\] Extend metrics from prometheus exporter [\#93](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/93) ([stevehook](https://github.com/stevehook))
- \[P4-551\] Change move reference format to ABC1234D [\#92](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/92) ([stevehook](https://github.com/stevehook))
- Update README with instructions to setup reference data [\#91](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/91) ([stevehook](https://github.com/stevehook))
- Update README with instructions about the production environment [\#90](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/90) ([stevehook](https://github.com/stevehook))
- \[P4-557\] Create a list of Hidden ethnicities and disable at import time [\#89](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/89) ([stevehook](https://github.com/stevehook))
- \[P4-556\] Ensure that `disabled\_at` is populated on import [\#88](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/88) ([stevehook](https://github.com/stevehook))
- Add Sentry gem for error reporting [\#87](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/87) ([cesidio](https://github.com/cesidio))
- \[P4-516\] Reference data class `\#disabled\_at` attribute [\#86](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/86) ([stevehook](https://github.com/stevehook))
- \[P4-183\] CircleCI config for production [\#85](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/85) ([stevehook](https://github.com/stevehook))
- \[P4-513\] Assessment question reference data [\#84](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/84) ([stevehook](https://github.com/stevehook))
- Add logic to import locations from NOMIS [\#83](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/83) ([cesidio](https://github.com/cesidio))
- Rename field location\_code in nomis\_agency\_id [\#82](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/82) ([cesidio](https://github.com/cesidio))
- \[P4-491\] Reference data setup [\#81](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/81) ([stevehook](https://github.com/stevehook))
- Fix non refreshable token [\#80](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/80) ([cesidio](https://github.com/cesidio))
- \[P4-414\] Rename `AssessmentAnswer\#date` to `created\_at` [\#79](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/79) ([stevehook](https://github.com/stevehook))
- \[P4-474\] GET /api/v1/reference/locations/:id` endpoint [\#78](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/78) ([stevehook](https://github.com/stevehook))
- \[P4-393\] GET /api/v1/reference/identifier\_types [\#77](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/77) ([stevehook](https://github.com/stevehook))
- \[P4-456\] Return gender and ethnicity from GET /moves [\#76](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/76) ([stevehook](https://github.com/stevehook))
- \[P4-457\] Rename a couple of AssessmentQuestion\#key values [\#75](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/75) ([stevehook](https://github.com/stevehook))
- \[P4-452\] PATCH /api/v1/moves/:moveId [\#74](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/74) ([stevehook](https://github.com/stevehook))
- \[P4-187\] Enable Prometheus monitoring [\#73](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/73) ([stevehook](https://github.com/stevehook))
- \[P4-409\] Fix assessment answer inconsistencies [\#72](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/72) ([stevehook](https://github.com/stevehook))
- Change references to old repo name [\#71](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/71) ([cesidio](https://github.com/cesidio))
- Move k8s configuration to deploy repo [\#70](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/70) ([cesidio](https://github.com/cesidio))
- Correction to Swagger docs for PUT /people [\#69](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/69) ([stevehook](https://github.com/stevehook))
- \[P4-392\] Add AssessmentAnswer\#key [\#68](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/68) ([stevehook](https://github.com/stevehook))
- Attempt to fix env variable not recognised [\#67](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/67) ([cesidio](https://github.com/cesidio))
- \[P4-359\] Add `key` attribute for reference types [\#66](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/66) ([stevehook](https://github.com/stevehook))
- Remove move\_type field from moves [\#65](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/65) ([cesidio](https://github.com/cesidio))
- Remove validation of time\_due for moves [\#64](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/64) ([cesidio](https://github.com/cesidio))
- \[P4-358\] Rename profile attributes etc. [\#63](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/63) ([stevehook](https://github.com/stevehook))
- Change move status [\#62](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/62) ([cesidio](https://github.com/cesidio))
- \[P4-360\] PUT /api/v1/people/:id endpoint [\#61](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/61) ([stevehook](https://github.com/stevehook))
- Refactor request specs to be more consistent [\#59](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/59) ([cesidio](https://github.com/cesidio))
- Add Authentication for API endpoints [\#58](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/58) ([slorek](https://github.com/slorek))
- \[P4-297\] \[Bugfix\] Remove dependency on `rspec` in production/staging [\#57](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/57) ([stevehook](https://github.com/stevehook))
- \[P4-297\] Switch to serve API docs on production/staging [\#56](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/56) ([stevehook](https://github.com/stevehook))
- Handle fields with multiple validation errors [\#55](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/55) ([cesidio](https://github.com/cesidio))
- \[P4-318\] Move reference number [\#54](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/54) ([stevehook](https://github.com/stevehook))
- Add shared examples with it\_behaves\_like 'an endpoint that responds with...' [\#53](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/53) ([cesidio](https://github.com/cesidio))
- \[P4-327\] POST /api/v1/people API [\#52](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/52) ([stevehook](https://github.com/stevehook))
- Refactor moves\_controller\_spec [\#51](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/51) ([cesidio](https://github.com/cesidio))
- Update swagger docs [\#50](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/50) ([teneightfive](https://github.com/teneightfive))
- \[P4-188\] Optimise queries for `GET /api/v1/moves` [\#49](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/49) ([stevehook](https://github.com/stevehook))
- Add error message for 404 errors [\#48](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/48) ([cesidio](https://github.com/cesidio))
- \[P4-188\] Configure serializers to return correct data from `GET /api/v1/moves` [\#47](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/47) ([stevehook](https://github.com/stevehook))
- Remove id attribute from errors [\#46](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/46) ([cesidio](https://github.com/cesidio))
- Implement create move endpoint [\#45](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/45) ([cesidio](https://github.com/cesidio))
- Update fake data rake tasks following DB schema changes [\#44](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/44) ([stevehook](https://github.com/stevehook))
- \[P4-186\] Use JSONB column for Profile\#profile\_attributes [\#43](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/43) ([stevehook](https://github.com/stevehook))
- \[P4-186\] Extend Move and Profile schemas [\#42](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/42) ([stevehook](https://github.com/stevehook))
- \[P4-186\] Add some test data for ethnicities and genders [\#41](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/41) ([stevehook](https://github.com/stevehook))
- Implement show move endpoint [\#40](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/40) ([cesidio](https://github.com/cesidio))
- \[P4-280\] Return moves sorted by destination name [\#39](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/39) ([stevehook](https://github.com/stevehook))
- Implement delete move endpoint [\#38](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/38) ([cesidio](https://github.com/cesidio))
- Fix create fake data rake task [\#37](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/37) ([cesidio](https://github.com/cesidio))
- \[P4-192\] GET ethnicities and nationalities API build [\#36](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/36) ([stevehook](https://github.com/stevehook))
- Allow passing headers and params to token [\#35](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/35) ([cesidio](https://github.com/cesidio))
- Remove locations controller, moved under reference [\#34](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/34) ([cesidio](https://github.com/cesidio))
- Fix find and replace word in migration [\#33](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/33) ([cesidio](https://github.com/cesidio))
- \[P4-192\] `GET /api/v1/reference/genders` API build [\#32](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/32) ([stevehook](https://github.com/stevehook))
- \[P4-192\] GET /api/v1/reference/locations API build [\#31](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/31) ([stevehook](https://github.com/stevehook))
- \[P4-192\] `GET /api/v1/reference/locations` API contract [\#30](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/30) ([stevehook](https://github.com/stevehook))
- \[P4-192\] Supporting data API build - profile attribute types [\#29](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/29) ([stevehook](https://github.com/stevehook))
- Fix swagger documentation for POST /api/v1/moves [\#28](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/28) ([cesidio](https://github.com/cesidio))
- \[P4-253\] Extend JSON schema [\#27](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/27) ([stevehook](https://github.com/stevehook))
- Add instructions for creating test data [\#26](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/26) ([teneightfive](https://github.com/teneightfive))
- Add remaining moves endpoints contract [\#25](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/25) ([cesidio](https://github.com/cesidio))
- \[P4-173\] Supporting data API contract [\#24](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/24) ([stevehook](https://github.com/stevehook))
- \[P4-167\] Add specs to validate `GET /api/v1/moves` responses [\#23](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/23) ([stevehook](https://github.com/stevehook))
- Add NOMIS client library [\#22](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/22) ([cesidio](https://github.com/cesidio))
- \[P4-167\] API contract for `GET /api/v1/moves` [\#21](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/21) ([stevehook](https://github.com/stevehook))
- \[P4-125\] Implement pagination with pager\_api gem [\#19](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/19) ([cesidio](https://github.com/cesidio))
- Update README [\#18](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/18) ([stevehook](https://github.com/stevehook))
- Bump version of rails to 5.2.3 + minor gems updates [\#17](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/17) ([cesidio](https://github.com/cesidio))
- \[P4-93\] Initial GET /api/v1/moves API [\#16](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/16) ([stevehook](https://github.com/stevehook))
- Move to live-1 cluster [\#15](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/15) ([cesidio](https://github.com/cesidio))
- \[P4-71\] Initial database schema [\#14](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/14) ([stevehook](https://github.com/stevehook))
- Change image tag name to be consistent with environment [\#13](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/13) ([cesidio](https://github.com/cesidio))
- Fix k8s config [\#12](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/12) ([cesidio](https://github.com/cesidio))
- Add secrets.yml and remove credentials.yml [\#11](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/11) ([cesidio](https://github.com/cesidio))
- Add kubernetes deploy configuration [\#10](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/10) ([cesidio](https://github.com/cesidio))
- Add rubocop-rspec [\#9](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/9) ([cesidio](https://github.com/cesidio))
- Add rubocop [\#8](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/8) ([cesidio](https://github.com/cesidio))
- Add rspec gem [\#7](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/7) ([cesidio](https://github.com/cesidio))
- Add docker configuration [\#6](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/6) ([cesidio](https://github.com/cesidio))
- Fix team name in CircleCI config.yml file [\#5](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/5) ([cesidio](https://github.com/cesidio))
- Fix CircleCI config.yml file [\#4](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/4) ([cesidio](https://github.com/cesidio))
- Add CircleCI configuration [\#3](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/3) ([cesidio](https://github.com/cesidio))
- Update ruby version to 2.6.2 [\#2](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/2) ([cesidio](https://github.com/cesidio))
- Health and ping endpoints [\#1](https://github.com/ministryofjustice/hmpps-book-secure-move-api/pull/1) ([doctorpod](https://github.com/doctorpod))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
