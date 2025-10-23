# Xcode Project

- If the prompt revolves around a code change inside a specific scheme, (like a LOCAL package dependency, or target) contained in the project, build and test just the scheme to save build times and keep the focus on the problem your were tasked with. FOR EXAMPLE: if I ask to "fix build errors" in a file called "RunningAppService.swift" that is a part of a local package named "RunningAppService", use `RunningAppService` as the scheme.
- If the above command fails with e.g. `xcodebuild: error: Scheme RunningAppService is not currently configured for the test action.`, stop, and ask for my attention and further steps.

