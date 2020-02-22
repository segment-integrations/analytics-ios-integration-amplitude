Releasing
=========

 1. Ensure you are on the `master` branch with your latest changes pulled down.
 2. Update the version in `Segment-Amplitude.podspec`.
 3. Update the `CHANGELOG.md` for the impending release.
 4. `cd carthage && carthage build --no-skip-current`
 5. `zip Archive.zip Carthage/Build/iOS/Segment_Amplitude.framework && cd ..`
 6. `git commit -am "Prepare for release X.Y.Z."` (where X.Y.Z is the new version)
 7. `git tag -a X.Y.Z -m "Version X.Y.Z"` (where X.Y.Z is the new version)
 8. `git push origin master --tags`
 9. `pod trunk push Segment-Amplitude.podspec --allow-warnings`
 10. Go to github and add proper release notes on the tag, as well as attach the 
       Archive.zip created in the earlier step.
