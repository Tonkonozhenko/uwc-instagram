Insta UWC
===

Start
---
Create `.env` file with such content:
```
CALLBACK_URL: http://localhost:3000/auth/callback
INSTAGRAM_CLIENT_ID: your_client_id
INSTAGRAM_CLIENT_SECRET: your_client_secret
```

and run

`bundle install`
`bundle exec thin start`