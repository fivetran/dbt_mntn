# Decision Log

## `campaign_id` cardinality between `campaign_group` and `campaign_info`
`mntn__campaign_report` is sourced from `campaign_group` (MNTN's preferred campaign-level reporting grain) and is not joined to `stg_mntn__campaign_info`, even though both tables carry a `campaign_id` field. The cardinality between `campaign_group`'s `campaign_id` and `campaign_info`'s `campaign_id` (a distinct, finer id space) is unconfirmed against live MNTN data, so joining them could silently fan out or drop rows. `stg_mntn__campaign_info` is staged and documented, but intentionally left unjoined until this relationship is confirmed.

## Account context is not enriched into non-account reports
`campaign_group`, `creative_group`, `creative`, and the country/state analytics tables carry no `advertiser_id` of their own — the only available join to `advertiser` was `date_day` (+ `source_relation`) alone. Per the MNTN Advertisers API (`GET /api/v1/advertisers`, a paginated list/search endpoint returning "advertisers the caller is authorized to see"), a single connection can be authorized against more than one advertiser account, so a `date_day`-only join risks fanning out metrics across every account active that day whenever a connection covers multiple accounts. Since none of these source tables expose an `advertiser_id` to join on properly, `account_id`/`account_name` were removed from `mntn__ad_report`, `mntn__ad_group_report`, `mntn__campaign_report`, `mntn__country_report`, `mntn__region_report`, and `mntn__url_report`. Account-level attribution is only available via `mntn__account_report`, which joins `advertiser` to `advertiser_info` on the real `account_id` key.

## Country and region reports have no `campaign_id`
MNTN's legacy API returns one table per dimension per request, so `analytics_by_country` and `analytics_by_state` carry no `campaign_id`. `mntn__country_report` and `mntn__region_report` hardcode `campaign_id`/`campaign_name` to `null`/`'Account-level'`.

## Region report uses state/province, not DMA
MNTN's legacy API also exposes a DMA (media market) breakdown, but `mntn__region_report` is sourced from `analytics_by_state` instead, since DMA has no analog on other ad_reporting platforms and would be a one-off grain unsupported by cross-package consistency tests.

## `mntn__segment_report` is a standalone report
MNTN's audience/targeting-segment concept has no equivalent report type in any other ad_reporting platform. It is deliberately kept standalone and is not planned on being unioned into the `dbt_ad_reporting` roll-up package.

## MNTN's API may omit records with empty fields rather than returning nulls
For some MNTN report endpoints, if a requested field is empty for a given record, the API may omit the entire record from the response instead of returning it with a null value for that field. This can result in missing rows with no error or warning, which may look like a data issue (e.g. a gap in `date_day` coverage) during validation. This is upstream API behavior that the package cannot detect or correct for.