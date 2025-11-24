# Curl Commands for Epidemy REST API

## Windows Setup & Troubleshooting
> **Important:** Windows 10 and 11 come with `curl` installed by default.
> 
> If you are using **PowerShell**, `curl` is often aliased to `Invoke-WebRequest`, which causes errors.
> To fix this, you have two options:
> 1. Use `curl.exe` instead of `curl` in your commands.
> 2. Or run this command to remove the alias for the current session: `Remove-Item alias:curl`
>
> If you use **Command Prompt (cmd)**, `curl` works normally.

## Setup
```bash
# Start the Flask app
set FLASK_APP=epidemy.py
python -m flask run
```

## Notes on curl
- Always specify `--request [TYPE]` for HTTP methods (GET, POST, PATCH, PUT, DELETE)
- JSON is **not** the default content type—always add `--header "Content-Type: application/json"` for JSON payloads
- Use `-d` or `--data` for request bodies
- Use `-v` for verbose output (equivalent to httpie's `-v`)
- Use `-H` as shorthand for `--header`
- Use `-X` as shorthand for `--request`

---

## 5. Create a new person (POST with JSON data)
```bash
curl -v -X POST http://localhost:5000/followed \
  -H "Content-Type: application/json" \
  -d '{"firstname":"Alice","lastname":"Durand","tel":"0123456789"}'
```
**Note:** Look for the `Location` header in the response to find the new person's id.

---

## 6. Location header
The `Location` header is returned in the 201 response and contains the URL to access the newly created resource.

---

## 7. Update sickness status via PATCH (JSON)
```bash
curl -v -X PATCH http://localhost:5000/followed/4 \
  -H "Content-Type: application/json" \
  -d '{"sick":true}'
```

---

## 8. Update person via PUT (form-encoded data)
```bash
curl -v -X PUT http://localhost:5000/followed/4 \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "firstname=Al&lastname=Fran&tel=00"
```
**Important:** For PUT, the content type is **form-encoded**, not JSON.

---

## 9. Inspect person #1's contacts (GET)
```bash
curl -v -X GET http://localhost:5000/followed/1/contacts
```

---

## 10. Add bidirectional contact links
```bash
# Add person #4 as a contact of person #1
curl -v -X POST http://localhost:5000/followed/1/contacts \
  -H "Content-Type: application/json" \
  -d '{"contid":4}'

# Add person #1 as a contact of person #4
curl -v -X POST http://localhost:5000/followed/4/contacts \
  -H "Content-Type: application/json" \
  -d '{"contid":1}'

# Re-check person #1's contacts
curl -v -X GET http://localhost:5000/followed/1/contacts
```

---

## 11. Delete contact links
```bash
# Delete person #4 from person #1's contacts
curl -v -X DELETE http://localhost:5000/followed/1/contacts/4

# Delete person #1 from person #4's contacts
curl -v -X DELETE http://localhost:5000/followed/4/contacts/1
```

---

## Curl Quick Reference
| Operation | Httpie | Curl |
|-----------|--------|------|
| Verbose output | `-v` | `-v` |
| POST (JSON) | `POST :5000/path data=value` | `-X POST -H "Content-Type: application/json" -d '{"data":"value"}'` |
| PATCH (JSON) | `PATCH :5000/path field:=value` | `-X PATCH -H "Content-Type: application/json" -d '{"field":value}'` |
| PUT (form) | `--form PUT :5000/path` | `-X PUT -H "Content-Type: application/x-www-form-urlencoded" -d "key=val"` |
| GET | `GET :5000/path` | `-X GET http://localhost:5000/path` |
| DELETE | `DELETE :5000/path` | `-X DELETE http://localhost:5000/path` |
