Releasing
=========

 1. Ensure you are on the `master` branch with your latest changes pulled down.
 2. Update the version in `Segment-Amplitude.podspec`.
 3. Update the `CHANGELOG.md` for the impending release.
 4. `git commit -am "Prepare for release X.Y.Z."` (where X.Y.Z is the new version)
 5. `git tag -a X.Y.Z -m "Version X.Y.Z"` (where X.Y.Z is the new version)
 6. `git push origin master --tags`
 7. `pod trunk push Segment-Amplitude.podspec --allow-warnings`
