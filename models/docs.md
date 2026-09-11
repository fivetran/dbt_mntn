{% docs source_relation %}
The source of the record if the unioning functionality is being used. If not, this field will be empty.
{% enddocs %}

{% docs date_day %}
The date for which the performance metrics are reported.
{% enddocs %}

{% docs account_id %}
Unique identifier for the MNTN advertiser account.
{% enddocs %}

{% docs account_name %}
Name of the MNTN advertiser account.
{% enddocs %}

{% docs campaign_id %}
Unique identifier for the campaign (MNTN's campaign_group, the platform's preferred grain for campaign-level reporting).
{% enddocs %}

{% docs campaign_name %}
Name of the campaign.
{% enddocs %}

{% docs ad_group_id %}
Unique identifier for the ad group (MNTN's creative_group — one TV commercial plus its tracking).
{% enddocs %}

{% docs ad_group_name %}
Name of the ad group.
{% enddocs %}

{% docs ad_id %}
Unique identifier for the ad (MNTN's creative — the platform's most granular metrics grain).
{% enddocs %}

{% docs ad_name %}
Name of the ad.
{% enddocs %}

{% docs impressions %}
Total number of times the ad was served.
{% enddocs %}

{% docs clicks %}
Total number of engagement events mapped to MNTN's visits metric. MNTN's CTV/OTT inventory has no native click event, so this represents site visits attributed to the ad, not literal ad clicks — treat cross-platform CTR comparisons involving this field with caution.
{% enddocs %}

{% docs spend %}
Total amount spent, in the account's currency.
{% enddocs %}

{% docs conversions %}
Total number of conversions attributed to the ad.
{% enddocs %}

{% docs conversions_value %}
Total dollar value of orders attributed to the ad's conversions.
{% enddocs %}

{% docs fivetran_id %}
Fivetran-generated surrogate key for the row. Used as the primary key on tables where MNTN's legacy API exposes no stable natural key (geo and network breakdown tables).
{% enddocs %}
