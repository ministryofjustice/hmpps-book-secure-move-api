This directory contains scripts and configuration to enable automated delivery of CSV reports via GovNotify.

With the exception of the Monthly Incomplete PER Report (see below) new jobs can be configured by replicating the config and cronjob files in each subfolder.

***Note: Where possible, use the read-replica database.*** The SQL in the configuration is executed directly against the database.

# CronJob File
Most of the cronjob can be copied wholesale when adding new reports, replacing the following as required:

`metadata.name`
The name of the configmap in the `configMapKeyRef` for each of the environment variables (except the first two which are in secrets) and for the `report-sql` volume.
The name of the configmap should match that of the `metadata.name` in the respective config file.

`spec.schedule` should be changed as needed. This is in UTC and as such will run at eg 8.30 AM in Summer when defined as `30 7 * * *` 

# Config file:

Fields in the config file define the report and the content of the email.

- from-date: The date with which any `[FROM]` placeholders in the sql are replaced. This can be specified in relative terms "1 day ago" and is interpreted by GNU `date`
- to-date: As with from date. The interpreted data replaces any `[TO]` placeholders in the sql
- subject: The subject line of the outgoing email
- body: The line of text inserted into the email before the download link.
- filename: The filename of the email attachment. The `.csv` extension is automatically appended
- retention: The duration a file should be made available to download from GovNotify eg `1 week`. Max value is 78 weeks.
- confirm_email: True or false - Whether the recipient of a file must confirm the email to which it was sent before downloading the file. In most cases this should be true, see the [GovNotify guidance](https://docs.notifications.service.gov.uk/rest-api.html#ask-recipients-to-confirm-their-email-address-before-they-can-download-the-file) regarding this.
- recipients: Comma separated list of recipients to which the report is sent. An email is sent to each recipient individually
- report_sql: The SQL to run against the database. Use the placeholders `[FROM]` and `[TO]` to have the dates defined in the `from-date` and `to-date` keys subsituted in in the format `'YYY-MM-DD'`



# Placeholders

As described above, the SQL script will have any `[FROM]` or `[TO]` placeholders replaced by the date interpeted from the `from-date` and `to-date` keys in the config.
These dates and the current day's date are also available to be used in the email subject, body and filename in the following formats, using these placeholders:

- `[FROM_DATE]` The date defined by the `from-date` key in the configmap, in the format `YYYY-MM-DD`
- `[FROM_DATE_FULL]`  The date defined by the `from-date` key in the configmap, as text eg `Wednesday, 17 April`
- `[TO_DATE]`  The date defined by the `to-date` key in the configmap, in the format `YYYY-MM-DD`
- `[TO_DATE_FULL]` The date defined by the `to-date` key in the configmap, as text eg `Wednesday, 17 April`
- `[TODAY_DATE]`  Today's date in the format `YYYY-MM-DD`
- `[TODAY_FULL]`  Today's date as text eg `Wednesday, 17 April`


# Monthly Incomplete PER report

This report shouldn't be used as a template for creating any one-file reports as it is scripted differently to allow for multiple queries to be run before being combined as sheets in an xlsx.
It still uses parts of the scripts in `00-reporting-scripts` so changes to those will affect all reports.