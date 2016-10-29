# FaceGroup Web API
[ ![Codeship Status for ISS-SOA/FaceGroupie-API](https://app.codeship.com/projects/6d9e1b40-7f50-0134-e9e1-6e03b3627684/status?branch=master)](https://app.codeship.com/projects/181891)

API to check for feeds and information on public Facebook Groups

## Routes

`/` - check if API alive
`/v0.1/groups/:group_id` - confirm group id, get name of group
`/v0.1/groups/:group_id/feed` - get first page feed of a group
