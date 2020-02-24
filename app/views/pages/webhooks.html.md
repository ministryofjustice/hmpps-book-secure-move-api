# Webhook Notifications

## 1. Introduction
Webhook notifications allow suppliers to subscribe to the PECS API system and receive notifications of when a move record is created or updated. The notification is transmitted via an HTTP POST to an endpoint specified by the supplier. The notification is signed with a shared key to ensure the authenticity of the message. If the endpoint is unavailable then the PECS system will re-attempt the delivery later, retrying up to 25 times.


## 2. Subscribing to notifications
The subscription process is currently manual - please contact the Book a Secure Move team via your Slack channel with the following details:

* **Callback URL**: this must be an `https://` endpoint which is publicly accessible and should not require authentication
* **Secret**: this is a shared secret which is used to generate a SHA-256 HMAC signature to guarantee the authenticity of the notification

Once the Book a Secure Move team have actioned the request, notifications of moves events will be immediately sent to the specified `callback_url`.


## 3. Receiving notifications
The supplier should ensure that the designated endpoint is available to receive notifications at all times. If for any reason the endpoint is offline when a notification is attempted, the PECS system will retry the notification later with an increasing random exponential delay. The system will continue to retry the notification up to 25 times. On the first day the notification will be attempted approximately 14 times (see [this table](https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry) for the approximate schedule). Once 25 failed delivery attempts are reached the notification record will be failed and will not be attempted again.

When a notification is received at the supplier's endpoint, it must:

1. Verify the PECS-SIGNATURE header of the notification
2. Upon verification return an HTTP success code (in the range 200-299)

The notification is not considered to have been delivered until an HTTP success is received.

**_The endpoint should return success (or failure) immediately after signature verification and success should not be contingent on subsequent processing._** 

I.e. if a notification was successfully received and the signature verified, it is not correct to return a failure code because of some other problem in the subsequent processing as this would compromise the decoupled nature of the systems.

An example notification message is given below:

    POST / HTTP/1.1
    Host: foobar.requestcatcher.com
    Accept: */*
    Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3
    Connection: keep-alive
    Content-Length: 415
    Content-Type: application/vnd.api+json
    Keep-Alive: 30
    Pecs-Notification-Id: 2cb108dd-8d47-4a5f-8d36-29324a770f05
    Pecs-Signature: 5cWQEe9emC7Myvj8jxVDIWI0jxoshOhitXfsCQBtTS4=
    User-Agent: pecs-webhooks/v1
    {
      "data": {
        "id": "2cb108dd-8d47-4a5f-8d36-29324a770f05",
        "type": "notifications",
        "attributes": {
          "event_type": "create_move",
          "timestamp": "2020-02-18T11:05:00+00:00"
        },
        "relationships": {
          "move": {
            "data": {
              "id": "149f1c27-1b7d-4c60-a4d4-ae8afbe92501",
              "type": "moves"
            },
            "links": {
              "self": "http://hmpps-book-secure-move-api-staging.apps.live-1.cloud-platform.service.justice.gov.uk/api/v1/moves/149f1c27-1b7d-4c60-a4d4-ae8afbe92501"
            }
          }
        }
      }
    }


## 4. Verification of the PECS-SIGNATURE header
It is necessary to verify the signature of the notification with the following algorithm in order to guarantee the authenticity of the message:

1. Calculate the SHA-256 HMAC of the message body using the pre-agreed <SECRET> when the subscription was created
2. Base64 encode the calculated HMAC
3. Check that the encoded value matches the PECS-SIGNATURE header. If it does match, return an HTTP success status (e.g. `202 - Accepted`). If it does not match, return an error code (e.g. 403 - Forbidden).

Ruby code for calculating the signature is given below:

    require 'base64'
    require 'openssl'
    expected_signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', secret, body))


## 5. Idempotent nature of notifications
The supplier should store the `id` (also in the `PECS-NOTIFICATION-ID` header) of every successful notification received. If a subsequent notification with the same `id` is received, it should be ignored.

In the event that the notification is ultimately ignored it is still necessary to return a `success` status (e.g. `202 - Accepted`).


## 6. Random order of notifications
The supplier should be mindful that because notifications may need to be retried several times before they are successfully delivered, the order in which they are received will not necessarily match the order in which the events occurred. For example, it is possible for the `update_move` notification to be received before the `create_move` notification, if the `create_move` notification was not successfully delivered on the first try.

To allow for this, the **supplier must always fetch the latest move record from the API and must not rely on the `event_type` field in the notification**.


## 7. Processing notifications
The notification typically contains minimal data: an `id`, a `timestamp`, an `event_type`, a `move:id` and a link to the move record:

    {
      "data": {
        "id": "0706f16b-d849-4f3e-a324-6a43bca5f0e5",
        "type": "notifications",
        "attributes": {
          "event_type": "update_move",
          "timestamp": "2020-02-18T17:43:08+00:00"
        },
        "relationships": {
          "move": {
            "data": {
              "id": "149f1c27-1b7d-4c60-a4d4-ae8afbe92501",
              "type": "moves"
            },
            "links": {
              "self": "http://hmpps-book-secure-move-api-staging.apps.live-1.cloud-platform.service.justice.gov.uk/api/v1/moves/149f1c27-1b7d-4c60-a4d4-ae8afbe92501"
            }
          }
        }
      }
    }


Upon receiving (any) notification the supplier should always retrieve the latest record using the `self` link in the JSON document.

Please note that the `update_move` event does not imply that a move record _requires_ updating on the PECS API: rather, the supplier should retrieve the latest record from the PECS API and then take any further action as neccesary (if any).

For example, updating a move status from `requested => accepted` on the PECS API will in turn trigger an `update_move` notification. In that case the supplier should retrieve the latest record but not further action is required.
