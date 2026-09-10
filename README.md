<!--section="mntn_transformation_model"-->
# MNTN dbt Package

This dbt package transforms data from Fivetran's MNTN connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 32
- Connector documentation
  - [MNTN connector documentation](https://fivetran.com/docs/connectors/applications/mntn)
  - [MNTN ERD](https://fivetran.com/connector-erd/mountain)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_mntn)
  - [dbt Docs](https://fivetran.github.io/dbt_mntn/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_mntn/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_mntn/blob/main/CHANGELOG.md)
- dbt Core™ supported versions
  - `>=1.3.0, <3.0.0`

## What does this dbt package do?
This package enables you to better understand the performance of your MNTN connected TV and streaming ads across varying grains and produces modeled tables that leverage MNTN data. It creates enriched models with metrics focused on account, campaign, ad group, ad, geographic (country/state), destination URL, and audience-segment reporting.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_mntn
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| `mntn__account_report` | Daily account-level performance, including `impressions`, `clicks`, `spend`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>How does performance compare across different MNTN accounts?</li><li>Is spend trending up or down over time at the account level?</li></ul> |
| `mntn__campaign_report` | Daily campaign-level performance, sourced from MNTN's `campaign_group` table (the platform's preferred campaign-level reporting grain).<br><br>**Example Analytics Questions:**<ul><li>Which campaigns are most efficient in terms of cost per conversion?</li><li>Which campaigns contribute most to overall spend or conversions?</li></ul> |
| `mntn__ad_group_report` | Daily ad-group-level performance, sourced from MNTN's `creative_group` table (one TV commercial plus its tracking).<br><br>**Example Analytics Questions:**<ul><li>Which ad groups have the strongest engagement relative to spend?</li><li>Do certain ad groups dominate impressions within a campaign?</li></ul> |
| `mntn__ad_report` | Daily ad-level performance, sourced from MNTN's `creative` table (the platform's most granular metrics grain), enriched with ad activation status and ad-serving tag attributes.<br><br>**Example Analytics Questions:**<ul><li>Which ad creatives are driving the lowest cost per conversion?</li><li>How do performance trends change after refreshing creative?</li></ul> |
| `mntn__country_report` | Daily performance broken out by country.<br><br>**Example Analytics Questions:**<ul><li>Which countries are delivering the highest return on ad spend for each account?</li><li>Are there seasonal performance variations by geographic region?</li></ul> |
| `mntn__region_report` | Daily performance broken out by state/province.<br><br>**Example Analytics Questions:**<ul><li>Which states are driving the most efficient account performance?</li><li>How do regional performance trends correlate with local market conditions?</li></ul> |
| `mntn__url_report` | Daily performance broken out by destination URL, parsed from `creative_info.click_url`. By default, excludes ads with NULL `click_url` values.<br><br>**Example Analytics Questions:**<ul><li>Which landing pages are driving the highest conversion rates?</li><li>Which UTM campaigns are driving the most traffic across different creatives?</li></ul> |
| `mntn__segment_report` | Daily audience/targeting-segment performance, MNTN's audience concept with no equivalent report type in other ad_reporting platforms.<br><br>**Example Analytics Questions:**<ul><li>Which audience segments are driving the most site visits?</li><li>How does new vs. existing audience reach vary by segment?</li></ul> |

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging and final models materialized as `view` or `table`.

---

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran MNTN connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.
- The `advertiser` and `advertiser_info` source tables syncing, since every end model is enriched with account-level context.
- Note that `creative_group`, `campaign_info`, `creative`, `creative_info`, `ad_info`, `analytics_by_country`, and `analytics_by_state` are optional source tables gated below ~70% account adoption (per Fivetran usage data). If any of these are not syncing for your MNTN connection, the corresponding report(s) will be disabled by default — see [Enable or Disable Optional Reports](#enable-or-disable-optional-reports) below.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/data-models/quickstart-management).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_mntn/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package
Include the following mntn package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/mntn
    version: [">=0.1.0", "<0.2.0"] # we recommend using ranges to capture non-breaking changes automatically
```

#### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Define database and schema variables
By default, this package runs using your destination and the `mntn` schema. If this is not where your MNTN data is (for example, if your MNTN schema is named `mntn_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    mntn_database: your_destination_name
    mntn_schema: your_schema_name
```

### (Optional) Additional configurations
<details open><summary>Expand/Collapse details</summary>

#### Union multiple connections
If you have multiple MNTN connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. For each source table, the package will union all of the data together and pass the unioned table into the transformations. The `source_relation` column in each model indicates the origin of each record.

To use this functionality, set the `mntn_sources` variable in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
  mntn_sources:
    - database: connection_1_destination_name # Required
      schema: connection_1_schema_name # Required
      name: connection_1_source_name # Required only if incorporating unioned sources into your DAG

    - database: connection_2_destination_name
      schema: connection_2_schema_name
      name: connection_2_source_name
```
> NOTE: The native `src_mntn.yml` connection set up in the package will not function when the union feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `src_mntn.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the `union_connections` macro. This will ensure a proper configuration and correct visualization of connections in the DAG.

#### Enable or Disable Optional Reports
This package uses several optional source tables that not every MNTN account may sync. If you are running this package via Fivetran Quickstart, transformations of the below tables will be dynamically enabled or disabled. Otherwise, all are **enabled** by default.

To disable transformations of any of the below tables and their corresponding report(s), add the relevant variable configuration(s) to your root `dbt_project.yml` file:

```yml
vars:
  mntn__using_creative_group: false     # True by default. Enables/disables use of the `creative_group` table and the `mntn__ad_group_report` model.
  mntn__using_campaign_info: false      # True by default. Enables/disables use of the `campaign_info` table.
  mntn__using_creative: false           # True by default. Enables/disables use of the `creative` table and the `mntn__ad_report`/`mntn__url_report` models.
  mntn__using_creative_info: false      # True by default. Enables/disables use of the `creative_info` table and the `mntn__url_report` model.
  mntn__using_ad_info: false            # True by default. Enables/disables use of the `ad_info` table.
  mntn__using_analytics_by_country: false # True by default. Enables/disables use of the `analytics_by_country` table and the `mntn__country_report` model.
  mntn__using_analytics_by_state: false   # True by default. Enables/disables use of the `analytics_by_state` table and the `mntn__region_report` model.
```

#### Passing Through Additional Metrics
By default, this package selects `impressions`, `clicks`, `spend`, `conversions`, and `conversions_value` (where available) from the source reporting tables to store into the output models. If you would like to pass through additional metrics, add the below configurations to your `dbt_project.yml` file. These variables allow for the pass-through fields to be aliased (`alias`) and transformed (`transform_sql`) if desired, but not required. Only the `name` of each metric field is required. Use the below format for declaring the respective pass-through variables:

> **Note**: Please ensure you exercise due diligence when adding metrics to these models. The metrics added by default have been vetted by the Fivetran team maintaining this package for accuracy. You will want to ensure whichever metrics you pass through are appropriate to aggregate at the respective reporting levels provided in this package.

```yml
vars:
    mntn__account_passthrough_metrics: # add metrics found in ADVERTISER
      - name: "new_custom_field"
        alias: "custom_field_alias"
        transform_sql: "coalesce(custom_field_alias, 0)" # reference the `alias` here if you are using one (otherwise the `name`)
    mntn__campaign_passthrough_metrics: # add metrics found in CAMPAIGN_GROUP
      - name: "another_one"
    mntn__ad_group_passthrough_metrics: # add metrics found in CREATIVE_GROUP
      - name: "another_one"
    mntn__ad_passthrough_metrics: # add metrics found in CREATIVE
      - name: "another_one"
    mntn__country_passthrough_metrics: # add metrics found in ANALYTICS_BY_COUNTRY
      - name: "another_one"
    mntn__region_passthrough_metrics: # add metrics found in ANALYTICS_BY_STATE
      - name: "another_one"
    mntn__segment_passthrough_metrics: # add metrics found in SEGMENT
      - name: "site_visitor"
        transform_sql: "site_visitor"
        alias: "site_visitors"
```
> **Note**: A small number of `segment` source columns added by MNTN in June 2026 (`site_visitor`, `existing_site_visitor`, `new_site_visitor`, `existing_user_reached`, `new_user_reached`) are singular, breaking from the plural convention (`*_visitors`, `*_reached`) used everywhere else in this package. To opt into these specific columns, you must provide both `transform_sql` and `alias` as shown above — `alias` alone is read as the literal source column name, not a rename.

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable. This is not available when running the package on multiple unioned connections.

> IMPORTANT: See this project's [`models/staging/src_mntn.yml`](https://github.com/fivetran/dbt_mntn/blob/main/models/staging/src_mntn.yml) source declarations to see the expected names.

```yml
vars:
    mntn_<default_source_table_name>_identifier: your_table_name
```

</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
<!--section="mntn_maintenance"-->
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package only maintains the latest version of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_mntn/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

#### Contributors
We thank [everyone](https://github.com/fivetran/dbt_mntn/graphs/contributors) who has taken the time to contribute. Each PR, bug report, and feature request has made this package better and is truly appreciated.

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_mntn/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
