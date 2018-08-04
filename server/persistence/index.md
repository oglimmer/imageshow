
OBJ
* user
	- id, rev
	- email: string
	- passwordHash: string
	- createdOn: date
	- lastLogin: date
  - lastFailedLogin: date
  - failedLoginCount: number
	- lastPasswordChange: date
  - emailConfirmationDate: date
* picture
	- id, rev
	- comment: string
	- filename: string
	- createdOn: date
  - contentType: string
	- user_ref: ref
	- group_ref: ref
  - pictureUUID: string (public)
* picturegroup
	- id, rev
	- name: string
	- [picture_ref]: array of ref UUIDs
	- user_ref: ref
	- lastUpdatedOn: date
	- createdOn: date

