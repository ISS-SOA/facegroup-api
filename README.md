# FaceGroup Web API
[ ![Codeship Status for ISS-SOA/facegroup-api](https://app.codeship.com/projects/b6697790-8005-0134-d901-0295c16491cd/status?branch=master)](https://app.codeship.com/projects/182029)

API to check for feeds and information on public Facebook Groups

## Routes

- `/` - check if API alive
- `/v0.1/groups/:group_id` - confirm group id, get name of group
- `/v0.1/groups/:group_id/feed` - get first page feed of a group
