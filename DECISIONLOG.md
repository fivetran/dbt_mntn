# Decision Log

## `campaign_id` cardinality between `campaign_group` and `campaign_info`
`mntn__campaign_report` is sourced from `campaign_group` (MNTN's preferred campaign-level reporting grain) and is not joined to `stg_mntn__campaign_info`, even though both tables carry a `campaign_id` field. The cardinality between `campaign_group`'s `campaign_id` and `campaign_info`'s `campaign_id` (a distinct, finer id space) is unconfirmed against live MNTN data, so joining them could silently fan out or drop rows. `stg_mntn__campaign_info` is staged and documented, but intentionally left unjoined until this relationship is confirmed.

## One advertiser account per MNTN connection
`campaign_group`, `creative_group`, `creative`, and the country/state analytics tables carry no `advertiser_id` of their own. Every end model that enriches these grains with `account_id`/`account_name` does so via a join to `advertiser` on `date_day` alone. This assumes a single advertiser account per MNTN connection — if MNTN ever syncs multiple advertiser accounts through one connection, this join logic will need a real join key.

## Country and region reports have no `campaign_id`
MNTN's legacy API returns one table per dimension per request, so `analytics_by_country` and `analytics_by_state` carry no `campaign_id`. `mntn__country_report` and `mntn__region_report` hardcode `campaign_id`/`campaign_name` to `null`/`'Account-level'`, mirroring the field-mapping precedent set by `facebook_ads__country_report`/`facebook_ads__region_report`.

## Region report uses state/province, not DMA
MNTN's legacy API also exposes a DMA (media market) breakdown, but `mntn__region_report` is sourced from `analytics_by_state` instead, since DMA has no analog on other ad_reporting platforms and would be a one-off grain unsupported by cross-package consistency tests.

## `mntn__segment_report` is a standalone report
MNTN's audience/targeting-segment concept has no equivalent report type in any other ad_reporting platform (the closest precedent is `pinterest_ads__pin_promotion_report`). It is deliberately kept standalone and is not unioned into any shared cross-platform schema/report layer.

## Singular vs. plural passthrough metric naming in `segment`
Five `segment` source columns added by MNTN in June 2026 (`site_visitor`, `existing_site_visitor`, `new_site_visitor`, `existing_user_reached`, `new_user_reached`) are singular, breaking from the plural convention (`*_visitors`, `*_reached`) used everywhere else in this package. To opt into them via `mntn__segment_passthrough_metrics`, pass `{name: 'site_visitor', transform_sql: 'site_visitor', alias: 'site_visitors'}` — both `transform_sql` and `alias` are required, since `alias` alone is read by `fivetran_utils.fill_pass_through_columns` as the literal source column name, not a rename.

## URL parameter extraction on Databricks
`mntn__url_report` extracts UTM parameters from `creative_info.click_url` via a custom `mntn_extract_url_parameter()` macro (dispatched per-adapter) rather than calling `dbt_utils.get_url_parameter()` directly, because that macro's default implementation does not reliably split URL query parameters on Spark/Databricks. The `spark__` implementation uses `regexp_extract()` instead, matching the workaround used by `facebook_ads`, `google_ads`, and `linkedin`.

## Passing through metrics not natively supported
Additional passthrough metrics are only available at the source-table grain (account, campaign, ad group, ad, country, region, segment) via the `mntn__*_passthrough_metrics` variables. Metrics that are already aggregations at a finer grain (e.g. rates or ratios) should not be summed when rolled up into a coarser report grain — passthrough metrics are only appropriate for additive measures.
