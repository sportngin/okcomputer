#### v1.8.1

* making JSON view default
* making all checks display by default

#### v1.8.0

* No longer display name of requested check when no matching check is found. This eliminates possibility of XSS vulnerability with maliciously crafted requests.
    * Before: "No check registered with 'CHECK_NAME'"
    * After: "No matching check"

#### v1.7.3

* Adds support for Neo4j

#### v1.7.2

* Only apply basic auth headers for HTTP checks when basic auth credentials are configured.

#### v1.7.1

* Add Support for basic auth on http checks

#### v1.7.0

* Add RabbitmqCheck check to test your RabbitMQ connection.

#### v1.6.6

* Reduce Rails dependencies outside of the engine. The upshot is OK Computer is now easier to port to non-Rails apps.

#### v1.6.5

* Add `okcomputer_check` and `okcomputer_checks` names to existing routes. Now you can `link_to okcomputer_checks` or otherwise refer to them programmatically.

#### v1.6.4

* Added support for Mongoid 5

#### v1.6.3
* Added support for Sidekiq 4

#### v1.6.2

* Fix exception when requiring `okcomputer` without the use of Bundler.

#### v1.6.1

* Add built in redis health check

#### v1.6.0

* Added a configuration option to run checks in parallel.

#### v1.5.1
#### v1.5.0

* Added new options to DelayedJobBackedUpCheck: which queue to check, whether to include running jobs in the count, whether to include failed jobs in the count, and a minimum priority of jobs to count.
* Updated MongoidCheck for compatibility with Mongoid 5.

#### v1.4.0

* Added two new checks:
    * SolrCheck, which tests connection to a Solr instance
    * HttpCheck, which tests connection to an arbitrary HTTP endpoint
* ElasticsearchCheck has been modified to be a child of HttpCheck, with no change in external behavior.

#### v1.3.0

* MongoidCheck now accepts an optional `session` argument to check the given session.

#### v1.2.0

* Added two new checks:
    * ElasticsearchCheck, which tests the health of your Elasticsearch cluster
    * AppVersionCheck, which reports the version (as a SHA) of your app is running

#### v1.1.0

* Added two new checks:
    * GenericCacheCheck, which tests that `Rails.cache` is able to read and write.
    * MongoidReplicaSetCheck, which tests that all of your configured Mongoid replica sets can be reached.
* Modified CacheCheck to accept an optional Memcached host to test. The default behavior of testing Memcached on the local machine remains unchanged.

#### v1.0.0

* Version bump
* For prior breaking changes from initial development, see [the Deprecations and Breaking Changes section][breaking-changes] of the pre 1.0 README.

[breaking-changes]:https://github.com/sportngin/okcomputer/blob/3f6708b333ddaf7ecc14d8c2b163335d46343f66/README.markdown#deprecations-and-breaking-changes
