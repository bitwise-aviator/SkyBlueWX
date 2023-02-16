# General Terms #

Thanks for your willingness to support development of this project! I'd want to see this project grow with an active community by its side. There are a few rules that we'd like contributors to follow.

## Issue tracking ##

If you want to address a specific problem or add functionality, please open an issue ticket and assign yourself to it. Add the issue number to any commits you make addressing it, and use words like "done", "completed", "resolved" to suggest that it has been properly addressed so we can know that the issue can be closed after your pull request is approved. 

## Testing ##

Please ensure that your edits undergo and pass logical testing with XCTests and that all other tests are still passing. For UI (non-logical) issues, such as layout changes, it is not necessary to use XCTests, but do include screenshots from the iOS Simulator or actual iOS devices as proof in your pull request.

We cannot guarantee backward compatibility for all iOS devices, but please test at least for iPhone 8, iPhone 14 Pro (range of devices with iOS 16 support) & any iPad from 2018 onward.

## Readability ##

This is a 50-50 aviation-software project. As a result, some devs might not be familiar with some aviation terminology. Please be generous with adding comments to code files, especially to explain aviation math or jargon. And of course, anything that helps understand what's going on with the code overall.

The same applies to writing code. Please abide by Swift style conventions, and lint your code with SwiftLint prior to making pull requests. As we set up a CI/CD pipeline for integrating pull requests, the system will reject pull requests that are flagged by SwiftLint.

## Community ##

This is a side project for me, and I understand that everyone who contributes is volunteering their time & effort. Let's keep this project fun and enjoyable for everyone. That means always treating fellow contributors with respect, keeping discussions technical (definitely steering clear of politics, religion & other sensitive topics), and being open to taking in others' perspectives. We will have zero tolerance for discrimination, spamming, and other abusive behavior. It's not a lot to ask, but it can make a great difference!
