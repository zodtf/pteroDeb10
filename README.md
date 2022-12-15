## Debian 11
### `Summary`
for internal use only of spooky.tf team. Do not reuse without permission. Or do. But I'll be mad.

## `VERSION = 1.0.7` 

---

### **GOALS**
- passwordless
- no root login
- create 1 privileged user via startup
- configure firewall (ufw) to allow: 80, 443

### `Includes` 

- `BASED VIM`
- AdminJS
- NGiNX
- PostgreSQL
- JavaScript
- NodeJS (16.x.)
- TypeSscript (maybe)
- dotenv & dotenv-cli
- gh & git
- ShadowSocks
- certbot + letsencrypt 
- OpenSSL
- OpenSSH / sshd
- ~~Fail2Ban~~ ? 
- net-tools
- cPanel maybe