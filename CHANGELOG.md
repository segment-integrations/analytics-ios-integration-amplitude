Change Log
==========

Version 3.2.4 *(2nd February, 2021)
-------------------------------------
* Fix issue compiling staticly where headers cannot be located.

Version 3.2.3 *(29th October, 2020)
-------------------------------------
* Fix a bug with import headers support new namespacing introduced in v4.x

Version 3.2.2 *(14th October, 2020)
-------------------------------------
* Update SEGAnalytics imports to support new namespacing introduced in v4.x

Version 3.2.1 *(23rd September, 2020)
-------------------------------------
* Fixed compile issue w/ 7.0.1 build of Amplitude-iOS
* Added mechanism to allow idfa and location services to be configured in Amplitude-iOS.

Version 3.2.0 *(15th July, 2020)*
---------------------------------
* Updated Carthage to use Analytics 4.0.x.
* Moved Carthage files to proper location.

Version 3.1.0 *(14th July, 2020)*
---------------------------------
* Removed version pinning for Amplitude.
* Moved to Amplitude pod, away from Amplitude-iOS pod.

Version 3.0.1 *(21st February, 2020)*
-----------------------------
* Added Carthage support

Version 3.0.0 *(19th November, 2019)*
-----------------------------
* Update Amplitude to 4.8+
* Update Analytics to 3.7+
* Update OCHamrest to 7.1.2
* Update OCMockito to 5.1.2

Version 2.0.1-beta *(24th September, 2018)*
-----------------------------
*(Supports analytics-ios 3.6+ and Amplitude 4.0+)*

* [Chore](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/61): Move release process to CircleCI.

Version 2.0.0 *(1st November, 2017)*
-----------------------------
*(Supports analytics-ios 3.6+ and Amplitude 4.0+)*

* [Improvement](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/43): Supports new Segment settings `groupTypeTrait` (group type) and `groupTypeValue` (group value) , which allows you to set which keys the Segment integration will look for to determine what to set for the group type and group values in Amplitude.
* [Improvement](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/54): Introduces new setting `trackAllPagesV2`, which sends a "Loaded Screen" event and the screen name as a property to Amplitude. Moving forward, this is the preferred method of tracking screen events in Amplitude.
* [Fix](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/35): If `price` is not present on an Ecommerce event, fallsback to first setting `revenue`, then `total`, for the value of the reserved Amplitude property `price`.
* [Fix](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/44): Sets `userId` to nil on `reset`.
* [New](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/45): Supports Amplitude's add functionality via `traitsToIncrement` setting, configured via Segment's UI. The setting accepts an array of traits (of type NSString) to check in `identify.traits`. If the trait is present, it will increment the trait given the value passed in.
* [New](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/49): Supports Location Listening via Segment's UI setting `enableLocationListening`. Defaults to disabled.
* [New](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/50): Enabling `useAdvertisingIdForDeviceId` setting in Segment UI  allows users to use `advertisingIdentifier` instead of `identifierForVendor` as the Device ID.
* [New](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/51): Supports Amplitude's `setOnce` method on `identify`. Values configured in Segment's UI to be set only once will set the value of a user trait only once on `identify`. Subsequent setOnce operations on that user property will be ignored.
* [New](https://github.com/segment-integrations/analytics-ios-integration-amplitude/pull/52): Supports `outOfSession` passed in as true if the integration specific option is passed in: `integrations.amplitude.outOfSession`.


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
