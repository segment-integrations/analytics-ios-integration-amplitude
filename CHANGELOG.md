Change Log
==========
Version 1.5.0 *(20th October, 2017)*
-----------------------------
*(Supports analytics-ios 3.6+ and Amplitude 4.0+)*

* [Adds](https://github.com/segment-integrations/analytics-ios-integration-amplitude/commit/d86cc3ed8e14ad0156f7247e4cb2e4e68a316269): Fallback to `total` if `revenue` is not present on E-Commerce events.
* [Adds](https://github.com/segment-integrations/analytics-ios-integration-amplitude/commit/25d8659a5a3475bb6c4f852f2f5111f627c297d3): Check for `snake_case` properties, which is the expected casing for analytics-ios.
* [Refactor](https://github.com/segment-integrations/analytics-ios-integration-amplitude/commit/b26c83eaaddfec900403f4b195f877e134611861) and [cleanup](https://github.com/segment-integrations/analytics-ios-integration-amplitude/commit/b282af19c09cb4b002d49e7a0ecc2813ce960f35): revenue logic.
* [Adds tests](https://github.com/segment-integrations/analytics-ios-integration-amplitude/commit/455841ba95038446a33071b6210ede210db0ec07).

Version 1.4.4 *(9th October, 2017)*
-----------------------------
*(Supports analytics-ios 3.6+ and Amplitude 4.0+)*

* [Updates](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/24/files): Amplitude dependency and removes [deprecated methods](https://github.com/amplitude/Amplitude-iOS/releases) in preparation for iOS 11.


Version 1.4.3 *(25th May, 2017)*
-----------------------------
*(Supports analytics-ios 3.6+ and Amplitude 3.8+)*

 * [Adds](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/22) support for Amplitude's groups capability via `identify` and `track`

Version 1.4.2 *(27th April, 2017)*
-----------------------------
*(Supports analytics-ios 3.2+ and Amplitude 3.8+)*

 * [Adds](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/21): `reset` mapping to Amplitude's `regenerateDeviceId`.

Version 1.4.1 *(8th August, 2016)*
-----------------------------
*(Supports analytics-ios 3.2+ and Amplitude 3.8+)*

 * Fix a bug where revenue would be tracked with the `useLogRevenueV2` option.

Version 1.4.0 *(21st July, 2016)*
-----------------------------
*(Supports analytics-ios 3.2+ and Amplitude 3.8+)*

 * Update Amplitude dependency to 3.8.
 * Add support for `useLogRevenueV2` option.

Version 1.3.0 *(1st June, 2016)*
-----------------------------
*(Supports analytics-ios 3.0.7+ and Amplitude 3.6.+)*

 * Segment-Amplitude now includes support for iOS 7.0+ (previously 8.0+ only).

Version 1.2.0 *(6th April, 2016)*
----------------------------
*(Supports analytics-ios 3.0.7+ and Amplitude 3.6.+)*

* Update Analytics dependency.
* Update Amplitude dependency.

Version 1.1.0 *(25th January, 2016)*
----------------------------
*(Supports analytics-ios 3.0.6+ and Amplitude 3.5.+)*

* Fix signature of identify method.
* Update Analytics dependency.

Version 1.1.0 *(22nd January, 2016)*
----------------------------
*(Supports analytics-ios 3.0.+ and Amplitude 3.5.+)*

Updates Amplitude dependency.

Version 1.0.0 *(24th November, 2015)*
----------------------------
*(Supports analytics-ios 3.0.+ and Amplitude 3.2.+)*

Initial stable release.

Version 1.0.0-alpha *(18th November, 2015)*
----------------------------
*(Supports analytics-ios 3.0.+ and Amplitude 3.2.+)*

Initial release.
