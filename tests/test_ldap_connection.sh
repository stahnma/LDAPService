#!/bin/bash

ldapsearch -x -Hldaps://thor.websages.com -b'dc=websages,dc=com' -D uid=stahnma,ou=people,dc=websages,dc=com -w${LDAP_PASSWORD} uid=stahnma
