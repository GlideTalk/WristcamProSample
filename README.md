partner/userRegistration:
===========================

A POST request, called by the partner's client app to our Wristcam App Server.

The partner is expected to call this API once for every "doctor" (call recipient) without the complicationCall/complicationMessage fields and complete the flow using the next API (partner/getFeatureSet). Only after a "doctor" is registered, a "patient" can call this API and request a complication that is configured to call that "doctor" (by filling in the relevant partnerContactId fields with the "doctor"'s partnerUserId).

-   Request (Body):
	-   partnerId {String}
	-   partnerKey {String}
	-   userDetails {Object}
    	- partnerUserId {String} - the id that the partner uses to refer to this user
		- [partnerUserName] {String}
		- [partnerUserAvatarUrl] {String}
	-	[complicationCall] {Object}
		- partnerContactId {String} - the partner's id for this user's contact
		-   [complicationMessage] {Object}
			- partnerContactId {String} - the partner's id for this user's contact
-   Response:
	- token {String} - an identifier our server can use to access the submitted data

Scheme for x-callback-url :
===========================

Make use of x-callback-url in a similar manner [as used by Apple's Shortcut App](https://support.apple.com/en-il/guide/shortcuts/apdcd7f20a6f/ios) to have the partner App launch the Wristcam App to provide it with relevant details and have a callback to the partner App for giving it the user's glideid

Scheme name: Wristcam
---------------------

Scheme format
-------------

wristcam://x-callback-url/setupPartnership?x-success=partnersourceappscheme://x-callback-url/success&x-source=[CFBundleDisplayName of partner App]&x-error=partnersourceappscheme://x-callback-url/error&partnerClientId=[partnerClientId]&partnerId=[partnerId]

Scheme implementation and general examples
------------------------------------------

-   Port [these Source files](https://github.com/phimage/CallbackURLKit/tree/master/Sources) to our App
-   [Example 1](https://support.apple.com/en-il/guide/shortcuts/apdcd7f20a6f/ios) 
-   [Example 2](https://x-callback-url.com/examples/)

Actions and parameters
----------------------

### setupPartnership

-   Input
	- partnerClientId
	- PartnerId
-   Output (success)
	- x-source=[Wristcam CFBundleDisplayName]&
	- glideID=GlideID&
	- [OptinalParams]=[OptionalParamsValue]&..
-   Output (errror)
	- x-source=[Wristcam CFBundleDisplayName]&
	- errorCode=[code]&
	- errorMessage=[message]

