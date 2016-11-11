# elm-json-example
Using Elm http with some involved JSON parsing in Elm 0.18

This is an attempt at re-implementing https://jsfiddle.net/ozk2qyhs/ in Elm, as posed by '@imdaveho' on the Elm Slack.

It makes an HTTP request, parses the JSON response to extract the interesting data,
and converts that data to group it by two nested dimensions.
