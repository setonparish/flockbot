# Login
```
curl -c flocknote.cookie \
-X POST "https://setonparish.flocknote.com/login/password" \
-d '{"email":"me@example.com","password":"password"}'
```

# Groups
```
curl -b flocknote.cookie \
-X POST "https://setonparish.flocknote.com/unolytics/16439/getReport" \
--data-urlencode "startDate=2022-05-29" \
--data-urlencode "endDate=2022-06-29" \
--data-urlencode "reportType=notesSent"
```