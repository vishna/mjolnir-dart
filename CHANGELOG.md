# 0.1.5

- fix `delete` method not working

# 0.1.4

- codegen fix to better handle array of strings

# 0.1.3

- expose `getClientSingletonLazy()`, allows retrieving global dio client

# 0.1.2

- expose underlying dio client via `mjolnirClient` method

# 0.1.1

- fix: UTF-8 content type needs to be lower case in transformer

# 0.1.0

- update to Dio 3.x and thus support Flutter Web

# 0.0.21

- fix _smi is not a subtype of bool_ exception

# 0.0.20

- make json content work

# 0.0.19

- make content dynamic type

# 0.0.18

- fix type of ContentType

# 0.0.17

- include stacktrace in Mjolnir response
- add setContentJson
- plainJsonArray

# 0.0.16

- more paranoid parser

# 0.0.15

- fix declutter

# 0.0.14

- fix compute parsing

# 0.0.13

- Change Map<String, dynamic> to Map<dynamic, dynamic>

# 0.0.12

- Expose parsed json response in `MjolnirResponse`

# 0.0.11

- `_id` type for identifier fields

# 0.0.10

- ignore more lint options for reals now

# 0.0.9

- ignore some more lint options

# 0.0.8

- make RequestBuilder.listOf work properly

# 0.0.7

- allow setting custom client singleton

# 0.0.6

- safe date time parsing

# 0.0.5

- lint ignore rules

# 0.0.4

- generated classes now have const constructor and all final fields

# 0.0.3

- fix dartfmt bug

# 0.0.2

- added `flutter packages pub run mjolnir:codegen` for automated code generation of domain classes

# 0.0.1

- initial version
